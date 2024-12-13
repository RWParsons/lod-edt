visualise_outcome <- function(data, model, outcome, cohort = c("full", "lod")) {
  cohort <- match.arg(cohort)
  ep_lab <- get_ep_lab(outcome)
  outcome_is_binary <- is_binary(data[[outcome]])

  d_first_presentation <- data |>
    filter(presentation_no == 1) |>
    rename(ep_var := !!rlang::sym(outcome))

  if (cohort == "lod") {
    d_first_presentation <- d_first_presentation |> filter(troponin <= get_troponin_lod())
  }

  pred_frame <- tibble(days_since_site_start = seq(
    min(d_first_presentation$days_since_site_start),
    max(d_first_presentation$days_since_site_start),
    length.out = 100
  )) |>
    mutate(
      pt_sex = 1,
      pt_age = mean(d_first_presentation$pt_age, na.rm = TRUE),
      post_intervention = days_since_site_start > 0,
      intervention = 0
    ) |>
    (\(x) {
      bind_rows(
        x,
        mutate(x, intervention = ifelse(post_intervention, 1, 0))
      )
    })() |>
    mutate(intervention = as.factor(intervention))

  pred_frame$preds <- predict(model, newdata = pred_frame, re.form = ~0, type = "response")
  pred_frame$preds_se <- predict(model, newdata = pred_frame, re.form = ~0, type = "response", se.fit = TRUE)$se.fit

  z <- 1.96

  pred_frame_by_hosp <- map(unique(d_first_presentation$hospital_id), ~ pred_frame |> mutate(hospital_id = .x)) |>
    bind_rows()

  pred_frame <- pred_frame |>
    mutate(
      preds_lwr = preds - preds_se * z,
      preds_upr = preds + preds_se * z,
      intervention = as.character(intervention)
    )

  pred_frame_by_hosp$preds <- predict(model, newdata = pred_frame_by_hosp, type = "response")
  pred_frame_by_hosp$preds_se <- predict(model, newdata = pred_frame_by_hosp, type = "response", se.fit = TRUE)$se.fit
  pred_frame_by_hosp <- pred_frame_by_hosp |>
    mutate(
      preds_lwr = preds - preds_se * z,
      preds_upr = preds + preds_se * z,
      intervention = as.character(intervention),
      hospital_id = as.numeric(as.factor(hospital_id))
    )

  p_utils <- list(
    values = c("0", "1"),
    colours = c("navyblue", "#b50f04"),
    labels = c("Standard care", "Intervention")
  )

  p_common <- list(
    scale_y_continuous(limits = c(0, NA)),
    theme_bw(),
    theme(legend.title = element_blank(), panel.grid.minor = element_blank()),
    scale_colour_manual(labels = p_utils$labels, values = p_utils$colours),
    scale_fill_manual(labels = p_utils$labels, values = p_utils$colours),
    scale_x_continuous(breaks = seq(from = -150, to = 120, by = 30)),
    labs(
      y = ep_lab,
      x = "Days since site start"
    ),
    geom_vline(xintercept = 0, linetype = "dashed")
  )

  p_model_preds <- pred_frame |>
    filter(intervention == "1" | days_since_site_start < 0) |>
    ggplot(aes(days_since_site_start, preds, col = intervention, fill = intervention, ymin = preds_lwr, ymax = preds_upr)) +
    geom_ribbon(alpha = 0.6) +
    geom_line() +
    p_common

  p_model_preds
  p_model_preds_by_hosp <- pred_frame_by_hosp |>
    filter(!(intervention == "0" & days_since_site_start > 0)) |>
    ggplot(aes(days_since_site_start, preds, col = intervention)) +
    geom_line() +
    geom_ribbon(alpha = 0.6, aes(fill = intervention, ymin = preds_lwr, ymax = preds_upr)) +
    p_common +
    facet_wrap(~hospital_id)

  plotlist <- list(
    p_model_preds = p_model_preds,
    p_model_preds_by_hosp = p_model_preds_by_hosp
  )

  if (outcome_is_binary) {
    plotlist <- plotlist |>
      map(~ .x + scale_y_continuous(labels = scales::label_percent(), limits = c(0, NA)))
  }
  plotlist
}


get_ep_lab <- function(outcome) {
  case_when(
    outcome == "ep_early_dsch_no_30d_event" ~ "Early discharge (<4 hours)\nwithout 30-day cardiac event (%)",
    outcome == "ep_hos_los" ~ "Hospital length of stay (hours)",
    .default = "outcome var label"
  )
}
