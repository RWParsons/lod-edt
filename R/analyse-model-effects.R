get_intervention_effects <- function(models) {
  outcome_names <- models |>
    map(~ .x$outcome) |>
    unlist() |>
    unname()

  full_cohort_effects <- map(
    models,
    ~ marginaleffects::avg_comparisons(.x$m_full_cohort, variables = list(intervention = 0:1), re.form = NA, type = "response") |>
      mutate(formula = Reduce(paste, deparse(.x$m_full_cohort$call$formula)))
  )
  lod_cohort_effects <- map(
    models,
    ~ marginaleffects::avg_comparisons(.x$m_lod_cohort, variables = list(intervention = 0:1), re.form = NA, type = "response") |>
      mutate(formula = Reduce(paste, deparse(.x$m_lod_cohort$call$formula)))
  )

  full_cohort_effects_tbl <- map(
    full_cohort_effects,
    as_tibble
  ) |>
    bind_rows() |>
    mutate(outcome = outcome_names, cohort = "full", .before = everything())


  lod_cohort_effects_tbl <- map(
    lod_cohort_effects,
    as_tibble
  ) |>
    bind_rows() |>
    mutate(outcome = outcome_names, cohort = "lod", .before = everything())

  bind_rows(full_cohort_effects_tbl, lod_cohort_effects_tbl)
}
