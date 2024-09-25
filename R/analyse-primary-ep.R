visualise_hos_los <- function(data) {
  data |>
    filter(presentation_no == 1) |>
    ggplot(aes(days_since_site_start, ep_hos_los)) +
    geom_smooth(col = "black", se = FALSE) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      x = "Days since site start",
      y = "Hospital length of stay (days)"
    ) +
    theme_bw() +
    theme(panel.grid.minor = element_blank())
}

visualise_early_disch <- function(data, model) {
  d_first_presentation <- data |>
    filter(presentation_no == 1)

  p_binned_data_by_hosp <- d_first_presentation |>
    select(intervention, ep_early_dsch_no_30d_event, days_since_site_start, hospital_id) |>
    mutate(
      days_cut = cut(
        days_since_site_start,
        breaks = seq(from = -155, to = 123, by = 7)
      ),
      days_cut = as.numeric(str_extract(days_cut, "(?<=\\().*(?=,)"))
    ) |>
    dplyr::summarize(early_disch = mean(ep_early_dsch_no_30d_event), .by = c(intervention, days_cut, hospital_id)) |>
    ggplot(aes(days_cut, early_disch, fill = intervention)) +
    geom_col() +
    facet_wrap(~hospital_id)

  p_smoothed_data_by_hosp <- d_first_presentation |>
    ggplot(aes(days_since_site_start, ep_early_dsch_no_30d_event, fill = intervention)) +
    geom_smooth(col = "black", span = 0.0001) +
    scale_y_continuous(labels = scales::percent, limits = c(0, NA)) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      title = "early discharge with no 30d event (full cohort)",
      x = "Days since site start",
      y = "Early discharge (<4 hours) without 30-day cardiac event (%)"
    ) +
    theme_bw() +
    theme(panel.grid.minor = element_blank()) +
    facet_wrap(~hospital_id)

  p_smoothed_data <- d_first_presentation |>
    ggplot(aes(days_since_site_start, ep_early_dsch_no_30d_event, fill = intervention)) +
    geom_smooth(col = "black", span = 0.0001) +
    scale_y_continuous(labels = scales::percent, limits = c(0, NA)) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      title = "early discharge with no 30d event (full cohort)",
      x = "Days since site start",
      y = "Early discharge (<4 hours) without 30-day cardiac event (%)"
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
    })()

  pred_frame_by_hosp <- map(unique(d_first_presentation$hospital_id), ~ mutate(pred_frame, hospital_id = .x)) |>
    bind_rows()

  # f <- ep_early_dsch_no_30d_event ~ intervention * days_since_site_start +
  #   bs(pt_age) + pt_sex + (intervention*days_since_site_start | hospital_id)
  #
  # model <- glmmTMB(
  #   formula = f,
  #   family = binomial(),
  #   data = d_first_presentation,
  #   check_hessian  = FALSE
  # )
  #
  # summary(model)$AIC


  # predict(model, newdata = tibble(
  #   pt_sex = 1, intervention = 1, days_since_site_start =0, pt_age = seq(from = 20, to = 90, by = 1)
  # ), re.form = ~0, type = "response")

  pred_frame$preds <- predict(model, newdata = pred_frame, re.form = ~0, type = "response")
  pred_frame_by_hosp$preds <- predict(model, newdata = pred_frame_by_hosp, type = "response")


  p_model_preds <- pred_frame |>
    mutate(intervention = as.factor(intervention)) |>
    ggplot(aes(days_since_site_start, preds, col = intervention)) +
    geom_line() +
    theme_bw() +
    geom_vline(xintercept = 0, linetype = "dashed") +
    scale_y_continuous(labels = scales::label_percent(), limits = c(0, NA)) +
    labs(
      y = "model predictions",
      x = "days since site start"
    )


  p_model_preds_by_hosp <- pred_frame_by_hosp |>
    mutate(intervention = as.factor(intervention)) |>
    ggplot(aes(days_since_site_start, preds, col = intervention)) +
    geom_line() +
    geom_smooth(data = d_first_presentation, aes(days_since_site_start, ep_early_dsch_no_30d_event, fill = intervention), col = "black", span = 0.0001) +
    theme_bw() +
    geom_vline(xintercept = 0, linetype = "dashed") +
    scale_y_continuous(labels = scales::label_percent(), limits = c(0, NA)) +
    labs(
      y = "model predictions",
      x = "days since site start"
    ) +
    facet_wrap(~hospital_id)

  list(
    p_smoothed_data = p_smoothed_data,
    p_smoothed_data_by_hosp = p_smoothed_data_by_hosp,
    p_model_preds = p_model_preds,
    p_model_preds_by_hosp = p_model_preds_by_hosp
  )
}
