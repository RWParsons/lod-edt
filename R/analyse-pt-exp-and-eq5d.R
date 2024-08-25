visualise_eq5d <- function(data) {
  prep_eq5d_data(data) |>
    mutate(domain = str_remove(domain, "eq5d_")) |>
    ggplot(aes(fill = intervention, y = value, x = domain)) +
    geom_bar(position = "dodge", stat = "identity") +
    labs(
      y = "",
      x = "EQ-5D Domain",
      fill = ""
    ) +
    theme_bw() +
    theme(panel.grid.minor = element_blank())
}

get_qnt_eq5d <- function(data) {
  prep_eq5d_data(data) |>
    pivot_wider(names_from = domain, values_from = value)
}

prep_eq5d_data <- function(data) {
  data |>
    filter(presentation_no == 1) |>
    select(pt_id, intervention, starts_with("eq5d")) |>
    na.omit() |>
    pivot_longer(starts_with("eq5d"), names_to = "domain") |>
    group_by(intervention, domain) |>
    summarize(value = mean(value), n = n()) |>
    ungroup() |>
    mutate(intervention = ifelse(intervention == 1, "Post-intervention", "Pre-intervention"))
}

get_qnt_patient_experience <- function(data) {
  data |>
    filter(presentation_no == 1) |>
    select(pt_id, intervention, starts_with("experience")) |>
    na.omit() |>
    pivot_longer(starts_with("experience"), names_to = "pt_exp_q") |>
    group_by(intervention, pt_exp_q) |>
    summarize(value = mean(value), n = n()) |>
    ungroup() |>
    pivot_wider(values_from = value, names_from = pt_exp_q)
}
