get_intervention_effects <- function(models) {
  outcome_names <- models |>
    map(~ .x$outcome) |>
    unlist() |>
    unname()

  models[[1]]$m_lod_cohort

  # m <- models[[2]]$m_full_cohort
  # get_ranef_summary(m)

  full_cohort_effects <- map(
    models,
    ~ marginaleffects::avg_comparisons(.x$m_full_cohort, variables = list(intervention = 0:1), re.form = NA, type = "response") |>
      mutate(
        formula = Reduce(paste, deparse(.x$m_full_cohort$call$formula)),
        dispersion_parameter = sigma(.x$m_full_cohort)
      ) # |> bind_cols(get_ranef_summary(.x$m_full_cohort))
  )
  lod_cohort_effects <- map(
    models,
    ~ marginaleffects::avg_comparisons(.x$m_lod_cohort, variables = list(intervention = 0:1), re.form = NA, type = "response") |>
      mutate(
        formula = Reduce(paste, deparse(.x$m_lod_cohort$call$formula)),
        dispersion_parameter = sigma(.x$m_lod_cohort)
      ) # |> bind_cols(get_ranef_summary(.x$m_lod_cohort))
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

get_disp <- function(model) {
  ff <- x$modelInfo$family$family
  s <- sigma(model)

  if (all(glmmTMB:::usesDispersion(ff))) {
    if (ff %in% glmmTMB:::.classicDispersionFamilies) {
      dname <- "Dispersion estimate"
      sname <- "sigma^2"
      sval <- s^2
    } else {
      dname <- "Dispersion parameter"
      sname <- ""
      sval <- s
    }
    sval
  }
}

get_ranef_summary <- function(object) {
  browser()
  varcor <- VarCorr(object)
  whichRE <- !sapply(varcor, is.null)
  ranef.comp <- c("Variance", "Std.Dev.")

  res <- map_dfr(
    names(varcor[whichRE]),
    \(nn){
      d <- as_tibble(glmmTMB:::formatVC(varcor[[nn]], digits = 4, comp = ranef.comp))
      names(d) <- paste0("ranef_", names(d))
      d
    }
  )

  res
}
