wrangle_data <- function(d_raw) {
  dttm_cols <- c(
    "index_arrival_date",
    "arrival_date",
    "ed_dischargedate",
    "maxtrop_time",
    "symptom_onset",
    "zero_time",
    "two_time"
  )

  dt_cols <- c(
    "dob",
    "last_contact"
  )

  cols_factors <- c(
    "study_no",
    "hospital",
    "sex"
  )

  cols_keep <- c(
    "hos_los" = "hoslos",
    "troponin" = "zero_trop",
    "pt_id" = "study_no",
    "presentation_no" = "presentation_number",
    "hospital_id" = "hospital",
    "pt_age",
    "pt_sex" = "sex",
    "intervention",
    "arrival_date",
    "days_since_site_start",
    "admit_days_since_2019",
    "ep_early_dsch_no_30d_event"
  )

  d <- d_raw |>
    janitor::clean_names() |>
    as_tibble() |>
    mutate(across(any_of(dttm_cols), ~ as.POSIXct(.x, format = "%m/%d/%Y %H:%M"))) |>
    mutate(across(any_of(dt_cols), ~ as.Date.character(.x, format = "%m/%d/%Y"))) |>
    mutate(
      # calculate dates
      pt_age = as.numeric(difftime(as.Date(arrival_date), as.Date(dob), units = "days")) / 365.25,
      admit_days_since_2019 = as.numeric(difftime(arrival_date, ymd("2019-01-01"), units = "days")),
      admit_days_since_first = as.numeric(difftime(arrival_date, index_arrival_date, units = "days")),

      # convert grouping vars to character/factor and relevel some variables to be binary [0, 1] rather than [1, 2]
      across(all_of(cols_factors), as.character),
      intervention = intervention - 1,

      # calculate endpoints
      ep_early_dsch_no_30d_event = as.integer((thirty_day_endpoint == 0 | is.na(thirty_day_endpoint)) & hoslos <= 4)
    ) |>
    add_days_since_site_start() |>
    group_by(study_no) |>
    arrange(presentation_number) |>
    fill(pt_age, sex, .direction = "down") |>
    ungroup() |>
    select(all_of(cols_keep))
}


add_days_since_site_start <- function(d) {
  d_start_date_lkp <- d |>
    filter(intervention == 1) |>
    mutate(arrival_date = as.Date(arrival_date)) |>
    select(hospital, intervention_start_dt = arrival_date) |>
    slice_min(n = 1, order_by = intervention_start_dt, by = hospital, with_ties = FALSE)

  d |>
    left_join(d_start_date_lkp, by = "hospital") |>
    mutate(
      days_since_site_start = as.numeric(difftime(as.Date(arrival_date), intervention_start_dt, units = "days"))
    )
}
