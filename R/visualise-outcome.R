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

  p_binned_data_by_hosp <- d_first_presentation |>
    select(intervention, ep_var, days_since_site_start, hospital_id) |>
    mutate(
      days_cut = cut(
        days_since_site_start,
        breaks = seq(from = -155, to = 123, by = 7)
      ),
      days_cut = as.numeric(str_extract(days_cut, "(?<=\\().*(?=,)"))
    ) |>
    summarize(ep_var = mean(ep_var), .by = c(intervention, days_cut, hospital_id)) |>
    ggplot(aes(days_cut, ep_var, fill = intervention)) +
    geom_col() +
    facet_wrap(~hospital_id)

  p_smoothed_data_by_hosp <- d_first_presentation |>
    ggplot(aes(days_since_site_start, ep_var, fill = intervention)) +
    geom_smooth(col = "black") +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      x = "Days since site start",
      y = ep_lab
    ) +
    theme_bw() +
    theme(panel.grid.minor = element_blank()) +
    facet_wrap(~hospital_id)

  p_smoothed_data <- d_first_presentation |>
    ggplot(aes(days_since_site_start, ep_var, fill = intervention)) +
    geom_smooth(col = "black") +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      x = "Days since site start",
      y = ep_lab
    ) +
    theme_bw() +
    theme(panel.grid.minor = element_blank())

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

  d_date_ranges_by_hosp <- d_first_presentation |>
    summarize(
      dt_min = min(days_since_site_start),
      dt_max = max(days_since_site_start),
      .by = c(hospital_id, intervention)
    )

  pred_frame_by_hosp <- map(unique(d_first_presentation$hospital_id), ~ mutate(pred_frame, hospital_id = .x)) |>
    bind_rows() |>
    left_join(d_date_ranges_by_hosp, by = c("hospital_id", "intervention")) |>
    filter(days_since_site_start <= dt_max, days_since_site_start >= dt_min)

  pred_frame$preds <- predict(model, newdata = pred_frame, re.form = ~0, type = "response")
  pred_frame$preds_se <- predict(model, newdata = pred_frame, re.form = ~0, type = "response", se.fit = TRUE)$se.fit

  z <- 1.96

  pred_frame <- pred_frame |>
    mutate(
      preds_lwr = preds - preds_se * z,
      preds_upr = preds + preds_se * z
    )

  pred_frame_by_hosp$preds <- predict(model, newdata = pred_frame_by_hosp, type = "response")
  pred_frame_by_hosp$preds_se <- predict(model, newdata = pred_frame_by_hosp, type = "response", se.fit = TRUE)$se.fit
  pred_frame_by_hosp <- pred_frame_by_hosp |>
    mutate(
      preds_lwr = preds - preds_se * z,
      preds_upr = preds + preds_se * z
    )

  p_model_preds <- pred_frame |>
    filter(intervention == 1 | days_since_site_start < 0) |>
    mutate(intervention = as.factor(intervention)) |>
    ggplot(aes(days_since_site_start, preds, col = intervention, fill = intervention, ymin = preds_lwr, ymax = preds_upr)) +
    geom_ribbon(alpha = 0.6) +
    geom_line() +
    geom_line(
      data = filter(pred_frame, intervention == 0, days_since_site_start > 0),
      aes(days_since_site_start, preds),
      linetype = "dashed"
    ) +
    theme_bw() +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      y = glue("{ep_lab} (model predictions)"),
      x = "days since site start"
    )

  p_model_preds_by_hosp <- pred_frame_by_hosp |>
    mutate(intervention = as.factor(intervention)) |>
    ggplot(aes(days_since_site_start, preds, col = intervention)) +
    geom_line() +
    geom_ribbon(alpha = 0.6, aes(fill = intervention, ymin = preds_lwr, ymax = preds_upr)) +
    geom_smooth(data = d_first_presentation, aes(days_since_site_start, ep_var, fill = intervention), col = "black") +
    theme_bw() +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      y = glue("{ep_lab} (model predictions)"),
      x = "days since site start"
    ) +
    facet_wrap(~hospital_id)

  plotlist <- list(
    p_smoothed_data = p_smoothed_data,
    p_smoothed_data_by_hosp = p_smoothed_data_by_hosp,
    p_model_preds = p_model_preds,
    p_model_preds_by_hosp = p_model_preds_by_hosp
  )

  if (outcome_is_binary) {
    plotlist <- plotlist |>
      map(~ .x + scale_y_continuous(labels = scales::label_percent(), limits = c(0, NA)))
  }
  plotlist
}

combine_plots <- function(p_set, which_pair = c("smoothed", "model")) {
  which_pair <- match.arg(which_pair)

  if (which_pair == "smoothed") {
    p1 <- p_set$p_smoothed_data
    p2 <- p_set$p_smoothed_data_by_hosp
  } else {
    p1 <- p_set$p_model_preds
    p2 <- p_set$p_model_preds_by_hosp
  }

  p2 <- p2 + theme(legend.position = "none")

  plot_grid(p1, p2)
}

get_ep_lab <- function(outcome) {
  case_when(
    outcome == "ep_early_dsch_no_30d_event" ~ "Early discharge (<4 hours) without 30-day cardiac event (%)",
    .default = "outcome var label"
  )
}
