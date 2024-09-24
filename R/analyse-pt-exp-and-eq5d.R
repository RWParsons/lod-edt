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
  list(
    prep_eq5d_data(data, cohort = "full"),
    prep_eq5d_data(data, cohort = "lod")
  ) |>
    map(~ pivot_wider(.x, names_from = domain, values_from = value)) |>
    bind_rows()
}

prep_eq5d_data <- function(data, cohort = c("full", "lod")) {
  cohort <- match.arg(cohort)
  troponin_lod <- get_troponin_lod()
  data |>
    filter(presentation_no == 1) |>
    (\(d) {
      if (cohort == "lod") {
        d <- d |> filter(troponin <= troponin_lod)
      }
      d
    })() |>
    select(pt_id, intervention, starts_with("eq5d")) |>
    na.omit() |>
    pivot_longer(starts_with("eq5d"), names_to = "domain") |>
    group_by(intervention, domain) |>
    summarize(value = glue("{round(mean(value), 2)} ({round(sd(value), 2)})"), n = n()) |>
    ungroup() |>
    mutate(
      cohort = .env$cohort
    )
}

get_qnt_patient_experience <- function(data) {
  troponin_lod <- get_troponin_lod()
  data |>
    filter(presentation_no == 1) |>
    (\(d) {
      d_lod <- d |>
        filter(troponin <= troponin_lod) |>
        mutate(cohort = "lod")
      d_full <- d |> mutate(cohort = "full")
      list(d_lod, d_full)
    })() |>
    map(
      ~ .x |>
        select(pt_id, cohort, intervention, starts_with("experience")) |>
        na.omit() |>
        pivot_longer(starts_with("experience"), names_to = "pt_exp_q") |>
        group_by(intervention, cohort, pt_exp_q) |>
        summarize(value = glue("{round(mean(value), 2)} ({round(sd(value), 2)})"), n = n()) |>
        ungroup() |>
        pivot_wider(values_from = value, names_from = pt_exp_q)
    ) |>
    bind_rows()
}
