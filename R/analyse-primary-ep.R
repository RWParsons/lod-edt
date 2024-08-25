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

visualise_early_disch <- function(data) {
  data |>
    filter(presentation_no == 1) |>
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
}
