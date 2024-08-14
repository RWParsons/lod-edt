analyse_primary_ep <- function(models, data) {
  primary_ep <- "ep_early_dsch_no_30d_event"

  data_first_presentation <- data |>
    filter(presentation_no == 1)

  fig_early_disch <- data_first_presentation |>
    ggplot(aes(days_since_site_start, ep_early_dsch_no_30d_event)) +
    geom_smooth(col = "black") +
    scale_y_continuous(labels = scales::percent, limits = c(0, NA)) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      x = "Days since site start",
      y = "Early discharge (<4 hours) without 30-day cardiac event (%)"
    ) +
    theme_bw() +
    theme(panel.grid.minor = element_blank())

  fig_hos_los <- data_first_presentation |>
    ggplot(aes(days_since_site_start, ep_hos_los)) +
    geom_smooth(col = "black", se = FALSE) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(
      x = "Days since site start",
      y = "Hospital length of stay (days)"
    ) +
    theme_bw() +
    theme(panel.grid.minor = element_blank())


  list(
    fig_early_disch = fig_early_disch,
    fig_hos_los = fig_hos_los
  )
}
