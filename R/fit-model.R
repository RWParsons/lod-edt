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

get_formula <- function(depvar_name) {
  formula(paste(
    depvar_name,
    "~ intervention + bs(pt_age) + pt_sex + bs(days_since_site_start) + bs(admit_days_since_2019) + (1 | hospital_id)"
  ))
}

get_family <- function(data, outcome) {
  if (is_binary(data[[outcome]])) {
    return(binomial("logit"))
  }

  family_list <- list(
    "ep_hos_los" = nbinom1(),
    "ep_6month_readmission_n" = nbinom1()
  )

  family_list[[outcome]]
}

is_binary <- function(x) {
  all(na.omit(x) %in% c(0, 1))
}
