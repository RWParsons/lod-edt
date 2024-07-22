source("dependencies.R")

# Set target options:
tar_option_set(
  controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_file(
    data_file,
    "data/source-data.csv"
  ),
  tar_target(
    data,
    read.csv(data_file)
  )
)
