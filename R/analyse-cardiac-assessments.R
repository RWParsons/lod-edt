get_cardiac_ax_tbls <- function(data) {
  # data <- tar_read(d_clean)
  d_within_6months <- data |> 
    # +1 because `presentation_no` and "readmission" doesn't the initial presentation
    mutate(presentation_within_6_months = presentation_no <= (ep_6month_readmission_n + 1)) |> 
    filter(presentation_within_6_months)

  d_inpatient_cardiac <- d_within_6months |> 
    select(pt_id, intervention, est:mri)

  d_outpatient_cardiac <- d_within_6months |> 
    select(pt_id, intervention, outpatient_est:outpatient_mri) |> 
    rename_with(~str_remove(.x, "outpatient_")) |> 
    mutate(across(est:mri, ~replace_na(.x, 0)))

  list(
    inpatient_cardiac_events = get_cardiac_table(d_inpatient_cardiac),
    outpatient_cardiac_events = get_cardiac_table(d_outpatient_cardiac)
  )
}

get_cardiac_table <- function(d_cardiac_tests) {
  d_intervention_lkp <- d_cardiac_tests |> 
    distinct(pt_id, intervention)

  d_cardiac_tests |> 
    select(-intervention) |> 
    na.omit() |> 
    summarize(across(everything(), max), .by = pt_id) |> 
    mutate(cardiac_any = as.numeric(rowSums(pick(!pt_id)) > 0)) |> 
    pivot_longer(!pt_id, names_to = "cardiac_test", values_to = "value") |> 
    left_join(d_intervention_lkp, by = "pt_id") |> 
    group_by(intervention, cardiac_test) |> 
    summarize(n_perc = format_n_perc(n = sum(value), total = n())) |> 
    ungroup() |> 
    mutate(intervention = ifelse(intervention == 1, "intervention_period", "non_intervention_period")) |> 
    pivot_wider(names_from = intervention, values_from = n_perc)
}

format_n_perc <- function(n, total) {
  f_perc <- scales::percent_format()
  glue::glue("{n} / {total} ({f_perc(n / total)})")
}

