fit_model <- function(data, outcome, ...) {
  troponin_lod <- get_troponin_lod()

  data_first_presentation <- data |>
    filter(presentation_no == 1)

  data_first_presentation_low_trop <- data |>
    filter(
      presentation_no == 1,
      troponin <= troponin_lod
    )

  m_form <- get_formula(outcome)
  fam <- get_family(data, outcome)
  outcome_is_binary <- is_binary(data[[outcome]])

  m_full_cohort <- glmmTMB(
    formula = m_form,
    family = fam,
    data = data_first_presentation
  )

  if (outcome == "ep_30d_event") {
    m_form <- get_formula(outcome, ep_30d_lod = TRUE)
  }

  m_lod_cohort <- glmmTMB(
    formula = m_form,
    family = fam,
    data = data_first_presentation_low_trop
  )

  list(
    outcome = outcome,
    m_full_cohort = m_full_cohort,
    m_lod_cohort = m_lod_cohort
  )
  # DHARMa::plotResiduals(DHARMa::simulateResiduals(m))
  # DHARMa::plotQQunif(DHARMa::simulateResiduals(m))

  # marginaleffects::plot_slopes(m, condition = "days_since_site_start", vcov = TRUE)
  # marginaleffects::avg_comparisons(m, variables = list(intervention = 0:1), re.form = NA)
}

bs <- splines::bs

get_troponin_lod <- function() 2

get_formula <- function(depvar_name, ep_30d_lod = FALSE) {
  if (ep_30d_lod) {
    f <- formula(
      glue(
        "{depvar_name} ~ intervention + days_since_site_start + bs(pt_age) + pt_sex + (1 | hospital_id)"
      )
    )
    return(f)
  }

  ranef_part <- case_when(
    depvar_name == "ep_hos_los" ~ "(0 + days_since_site_start | intervention:hospital_id)",
    .default = "(intervention*days_since_site_start | hospital_id)"
  )

  formula(
    glue(
      "{depvar_name} ~ intervention * days_since_site_start + bs(pt_age) + pt_sex + {ranef_part}"
    )
  )
}

get_family <- function(data, outcome) {
  if (is_binary(data[[outcome]])) {
    return(binomial("logit"))
  }

  family_list <- list(
    "ep_hos_los" = nbinom1(),
    "ep_6month_readmission_n" = poisson()
  )

  family_list[[outcome]]
}

is_binary <- function(x) {
  all(na.omit(x) %in% c(0, 1))
}
