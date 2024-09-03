make_table_1 <- function(d_clean, d_raw) {
  cols_add_to_d_clean <- c(
    "indigenous",
    "zero_time",
    "familyhistory",
    "smoking",
    "hypertension",
    "dyslipidaemia",
    "diabetes",
    "prior_mi",
    "prior_cabg",
    "prior_angioplasty",
    "prior_cad"
  )

  # TODO: also fix coding to be what is in the labelled data for the family history - TBD to see what Jaimi says about how these are coded
  # TODO: move these fixes into changes in d_clean
  # TEMP FIXES to add cols:
  d_more_cols <- d_raw |>
    rename(
      pt_id = studynumberunique,
      presentation_no = presentation_number
    ) |>
    mutate(
      pt_id = as.character(pt_id),
      trop_time = difftime(as.POSIXct(zero_time, format = "%m/%d/%Y %H:%M"), as.POSIXct(arrival_date, format = "%m/%d/%Y %H:%M"), units = "mins"),
      across(
        all_of(c(
          "smoking", "familyhistory", "hypertension", "dyslipidaemia", "diabetes",
          "prior_mi", "prior_cabg", "prior_angioplasty", "prior_cad"
        )),
        ~ as.numeric(.x == 1)
      )
    ) |>
    select(pt_id, presentation_no, all_of(cols_add_to_d_clean), trop_time) |>
    as_tibble()

  d_cohorts <- d_clean |>
    filter(presentation_no == 1) |>
    inner_join(d_more_cols, by = c("pt_id", "presentation_no")) |>
    mutate(
      male = as.numeric(pt_sex == 1),
      under2_hoslos = as.numeric(ep_hos_los <= 2)
    ) |>
    (\(d) {
      bind_rows(
        d |> mutate(cohort = "full"),
        d |>
          filter(troponin <= get_troponin_lod()) |>
          mutate(cohort = "lod")
      )
    })()

  total_n_row <- d_cohorts |>
    summarize(col = "total_n", cell_content = as.character(n()), .by = c(cohort, intervention))

  n_perc_cols <- c(
    "male",
    "indigenous",
    "under2_hoslos",
    "smoking",
    "familyhistory",
    "hypertension",
    "dyslipidaemia",
    "diabetes",
    "prior_mi", "prior_cabg", "prior_angioplasty", "prior_cad"
  )

  n_perc_cells <- n_perc_cols |>
    map(~ summarize_by_n_percent(d_cohorts, .x)) |>
    bind_rows()


  iqr_cols <- c("troponin", "trop_time")

  iqr_cells <- iqr_cols |>
    map(~ summarize_by_iqr(d_cohorts, .x)) |>
    bind_rows()

  # make full table
  bind_rows(
    total_n_row,
    n_perc_cells,
    iqr_cells
  ) |>
    mutate(cohort = glue("{cohort}_cohort"), intervention = ifelse(intervention, "intervention", "standard_care")) |>
    pivot_wider(names_from = c("cohort", "intervention"), values_from = cell_content, names_sep = ":")
}


summarize_by_iqr <- function(d, continuous_var) {
  new_name <- glue("{continuous_var}_iqr")
  d |>
    rename(var := !!rlang::sym(continuous_var)) |>
    summarize(iqr_var = get_iqr_cell(var), .by = c(cohort, intervention)) |>
    rename(!!new_name := iqr_var) |>
    pivot_longer(cols = all_of(new_name), names_to = "col", values_to = "cell_content")
}

get_iqr_cell <- function(x) {
  paste0(
    quantile(x, probs = c(0.25, 0.75), na.rm = TRUE),
    collapse = " - "
  )
}

summarize_by_n_percent <- function(d, binary_var) {
  cohort_n <- d |>
    filter(!is.na(!!rlang::sym(binary_var))) |>
    summarize(n = n(), .by = c(cohort, intervention))

  new_name <- glue("{binary_var}_n_perc")

  d |>
    rename(var := !!rlang::sym(binary_var)) |>
    filter(var == 1) |>
    summarize(n_var = n(), .by = c(cohort, intervention)) |>
    left_join(cohort_n, by = c("cohort", "intervention")) |>
    mutate(n_perc_var = tbl_format_n_perc(n = n_var, n_total = n)) |>
    select(cohort, intervention, !!new_name := n_perc_var) |>
    pivot_longer(cols = all_of(new_name), names_to = "col", values_to = "cell_content")
}

tbl_format_n_perc <- function(n, n_total) {
  pc <- scales::label_percent(accuracy = 1)
  glue("{n} ({pc(n / n_total)})")
}
