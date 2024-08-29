get_cardiac_ax_tbls <- function(data) {
  # data <- tar_read(d_clean)
  troponin_lod <- get_troponin_lod()
  low_trop_pts <- data |>
    filter(
      presentation_no == 1,
      troponin <= troponin_lod
    ) |>
    pull(pt_id)

  d_full_cohort <- filter_for_6month_presentations(data)

  d_full_inpatient_cardiac <- d_full_cohort |>
    select(pt_id, intervention, est:mri)

  d_full_outpatient_cardiac <- d_full_cohort |>
    select(pt_id, intervention, outpatient_est:outpatient_mri) |>
    rename_with(~ str_remove(.x, "outpatient_")) |>
    mutate(across(est:mri, ~ replace_na(.x, 0)))

  d_lod_cohort <- data |>
    filter(pt_id %in% low_trop_pts) |>
    filter_for_6month_presentations()

  d_lod_inpatient_cardiac <- d_lod_cohort |>
    select(pt_id, intervention, est:mri)

  d_lod_outpatient_cardiac <- d_lod_cohort |>
    select(pt_id, intervention, outpatient_est:outpatient_mri) |>
    rename_with(~ str_remove(.x, "outpatient_")) |>
    mutate(across(est:mri, ~ replace_na(.x, 0)))

  tbl_full_inpatients <- d_full_inpatient_cardiac |>
    get_cardiac_table() |>
    mutate(.before = everything(), cohort = "full", pt_group = "inpatient")

  tbl_full_outpatients <- d_full_outpatient_cardiac |>
    get_cardiac_table() |>
    mutate(.before = everything(), cohort = "full", pt_group = "outpatient")

  tbl_lod_inpatients <- d_lod_inpatient_cardiac |>
    get_cardiac_table() |>
    mutate(.before = everything(), cohort = "lod", pt_group = "inpatient")

  tbl_lod_outpatients <- d_lod_outpatient_cardiac |>
    get_cardiac_table() |>
    mutate(.before = everything(), cohort = "lod", pt_group = "outpatient")

  bind_rows(
    tbl_full_inpatients,
    tbl_full_outpatients,
    tbl_lod_inpatients,
    tbl_lod_outpatients
  )
}

filter_for_6month_presentations <- function(data) {
  data |>
    # +1 because `presentation_no` and "readmission" doesn't the initial presentation
    mutate(presentation_within_6_months = presentation_no <= (ep_6month_readmission_n + 1)) |>
    filter(presentation_within_6_months)
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
  glue("{n} / {total} ({f_perc(n / total)})")
}
