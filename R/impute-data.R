impute_missing_data <- function(d_clean) {
  # TODO: just using m = 1 (single imputation) for the time being while working through the rest of the pipeline
  # intention will be to do 5 or 10 imputation datasets
  d_mice <- mice::mice(d_clean, m = 1, maxit = 50, meth = "pmm", seed = 42)
  mice::complete(d_mice) |>
    as_tibble()
}
