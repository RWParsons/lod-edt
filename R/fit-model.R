fit_model <- function(data, outcome, ...) {
  if (outcome == "ep_early_dsch_no_30d_event") {
    data <- data |> 
      filter(presentation_no == 1)
    m <- glmmTMB::glmmTMB(
      ep_early_dsch_no_30d_event ~ intervention + bs(pt_age) + pt_sex + bs(days_since_site_start) + bs(admit_days_since_2019) + (1 | hospital_id),
      family = binomial("logit"),
      data = data
    )
  }

  m



  # DHARMa::plotResiduals(DHARMa::simulateResiduals(m))
  # DHARMa::plotQQunif(DHARMa::simulateResiduals(m))
}


bs <- splines::bs
