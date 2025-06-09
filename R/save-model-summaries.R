save_model_summaries <- function(models) {
  outcome_names <- models |>
    map(~ .x$outcome) |>
    unlist() |>
    unname()

  map(
    seq_along(outcome_names),
    \(.x) {
      ep_name <- outcome_names[.x]
      outdir <- "output/model-summaries"
      full_model <- models[[.x]]$m_full_cohort

      capture.output(
        summary(models[[.x]]$m_full_cohort),
        file = glue("{outdir}/{ep_name}-full-model-summary.txt")
      )

      capture.output(
        summary(models[[.x]]$m_lod_cohort),
        file = glue("{outdir}/{ep_name}-lod-model-summary.txt")
      )
    }
  )
}
