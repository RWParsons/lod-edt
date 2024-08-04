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

  cols_keep <- c(
    "pt_id" = "study_no",
    "presentation_no" = "presentation_number",
    "hospital_id" = "hospital",
    "pt_age"
  )

  d_raw |>
    janitor::clean_names() |>
    as_tibble() |>
    mutate(across(any_of(dttm_cols), ~ as.POSIXct(.x, format = "%d/%m/%Y %H:%M"))) |>
    mutate(across(any_of(dt_cols), ~ as.Date.character(.x, format = "%m/%d/%Y"))) |>
    mutate(
      pt_age = as.numeric(difftime(as.Date(arrival_date), as.Date(dob), units = "days")) / 365.25,
      admit_days_since_2019 = as.numeric(difftime(arrival_date, ymd("2019-01-01"), units = "days"))
    ) |>
    select(cols_keep)
}
