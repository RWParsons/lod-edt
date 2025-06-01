visualise_hoslos_km <- function(d_clean) {
  d_plot <- d_clean |>
    filter(presentation_no == 1)

  list(
    p_full_cohort = make_hoslos_km(d_plot),
    p_lod_cohort = make_hoslos_km(filter(d_plot, troponin <= get_troponin_lod()))
  )
}


make_hoslos_km <- function(d_plot) {
  fit <- survfit(Surv(ep_hos_los, presentation_no) ~ intervention, data = d_plot)

  p_utils <- list(
    values = c("0", "1"),
    colours = c("navyblue", "#b50f04"),
    labels = c("Standard care", "Intervention")
  )

  autoplot(fit, conf.int.alpha = 0.6) +
    scale_x_continuous(limits = c(0, 120), breaks = seq(0, 120, 24)) +
    scale_colour_manual(labels = p_utils$labels, values = p_utils$colours) +
    scale_fill_manual(labels = p_utils$labels, values = p_utils$colours) +
    labs(x = "Hospital length of stay (hours)", fill = "", col = "", y = "") +
    theme_bw() +
    theme(panel.grid.major = element_line(colour = "grey92"))
}
