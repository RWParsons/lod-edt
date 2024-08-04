source("dependencies.R")

tar_option_set(
  controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
)

tar_source()

list(
  tar_file(
    data_file,
    "data/source-data-2.csv"
  ),
  tar_target(
    d_raw,
    read.csv(data_file)
  ),
  tar_target(
    d_clean,
    wrangle_data(d_raw)
  ),
  tar_target(
    d_model,
    impute_missing_data(d_clean)
  )
)
