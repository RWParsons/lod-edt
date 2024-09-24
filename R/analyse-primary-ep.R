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

  p_smoothed_data <- d_first_presentation |>
    ggplot(aes(days_since_site_start, ep_early_dsch_no_30d_event)) +
    geom_smooth(col = "black") +
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

  pred_frame$preds <- predict(model, newdata = pred_frame, re.form = ~0, type = "response")

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

  list(
    p_smoothed_data = p_smoothed_data,
    p_model_preds = p_model_preds
  )
}
