wrangle_data <- function(d_raw) {
  dttm_cols <- c(
    "index_arrival_date",
    "arrival_date",
    "hospital_discharge",
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

  cols_recode_binary <- c(
    "familyhistory",
    "smoking",
    "hypertension",
    "dyslipidaemia",
    "diabetes",
    "prior_mi",
    "prior_cabg",
    "prior_angioplasty",
    "prior_cad"
  )

  cols_keep <- c(
    "ep_hos_los" = "hoslos",
    "ep_early_dsch_no_30d_event",
    "ep_6month_readmission_n",
    "ep_30d_event" = "thirtyevent",
    "ed_los" = "e_dlos",
    "admitted",
    "troponin" = "zero_trop",
    "trop_mins",
    "pt_id" = "studynumberunique",
    "presentation_no" = "presentation_number",
    "hospital_id" = "hospital",
    "pt_age",
    "pt_sex" = "sex",
    "intervention",
    "arrival_date",
    "days_since_site_start",
    "admit_days_since_2019",
    "indigenous",
    "under2_hoslos",
    cols_recode_binary
  )

  cols_rename <- cols_keep[names(cols_keep) != ""]

  cols_keep[names(cols_keep) != ""] <- names(cols_keep)[names(cols_keep) != ""]
  cols_keep <- unname(cols_keep)

  cols_factors <- c(
    "pt_id",
    "hospital_id",
    "pt_sex"
  )

  d <- d_raw |>
    janitor::clean_names() |>
    as_tibble() |>
    rename(all_of(cols_rename)) |>
    mutate(
      across(any_of(dttm_cols), ~ as.POSIXct(.x, format = "%m/%d/%Y %H:%M")),
      across(any_of(dt_cols), ~ as.Date.character(.x, format = "%m/%d/%Y"))
    ) |>
    mutate(
      # calculate dates
      pt_age = as.numeric(difftime(as.Date(arrival_date), as.Date(dob), units = "days")) / 365.25,
      admit_days_since_2019 = as.numeric(difftime(arrival_date, ymd("2019-01-01"), units = "days")),
      admit_days_since_first = as.numeric(difftime(arrival_date, index_arrival_date, units = "days")),
      trop_mins = as.numeric(difftime(zero_time, arrival_date, units = "mins")),
      # convert grouping vars to character/factor and relevel some variables to be binary [0, 1] rather than [1, 2]
      across(all_of(cols_factors), as.character),
      across(all_of(cols_recode_binary), ~ as.numeric(.x == 2)),
      intervention = intervention - 1,
      under2_hoslos = as.numeric(ep_hos_los <= 2),
      admitted = as.numeric(!is.na(hospital_discharge)),

      # calculate endpoints
      ep_early_dsch_no_30d_event = as.integer((ep_30d_event == 0 | is.na(ep_30d_event)) & ep_hos_los <= 4)
    ) |>
    add_days_since_site_start() |>
    group_by(pt_id) |>
    arrange(presentation_no) |>
    fill(pt_age, pt_sex, .direction = "down") |>
    ungroup() |>
    # add ep_6month_readmission_n
    mutate(ep_6month_readmission_n = NA_integer_) |>
    group_by(pt_id) |>
    group_split() |>
    map(\(.x) {
      n_readmissions <- .x |>
        filter(arrival_date <= index_arrival_date %m+% months(6)) |>
        nrow() |>
        (\(x) max(c(x - 1, 0)))()

      .x$ep_6month_readmission_n <- n_readmissions
      .x
    }) |>
    bind_rows()

  d |> select(
    all_of(cols_keep),
    est:mri,
    outpatient_est:outpatient_mri,
    matches("eq5d_[0-9]$"),
    matches("experience_[0-9]$")
  )
}

add_days_since_site_start <- function(d) {
  d_start_date_lkp <- d |>
    filter(intervention == 1) |>
    mutate(arrival_date = as.Date(arrival_date)) |>
    select(hospital_id, intervention_start_dt = arrival_date) |>
    slice_min(n = 1, order_by = intervention_start_dt, by = hospital_id, with_ties = FALSE)

  d |>
    left_join(d_start_date_lkp, by = "hospital_id") |>
    mutate(
      days_since_site_start = as.numeric(difftime(as.Date(arrival_date), intervention_start_dt, units = "days"))
    )
}
