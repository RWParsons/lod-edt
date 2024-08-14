source("dependencies.R")

tar_option_set(
  controller = crew::crew_controller_local(workers = 4, seconds_idle = 60)
)

tar_source()

list(
  # read and wrangle data
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

  # fit models
  tar_target(
    endpoint_varnames,
    str_subset(names(d_clean), "^ep_")
  ),
  tar_target(
    models_iter,
    fit_model(
      data = d_clean,
      outcome = endpoint_varnames[1]
    ),
    pattern = map(endpoint_varnames),
    iteration = "list"
  ),
  tar_target(
    models,
    group_models(models_iter)
  ),
  tar_target(
    intervention_effects,
    get_intervention_effects(models)
  ),
  tar_target(
    primary_ep_figure,
    analyse_primary_ep(
      models = models,
      data = d_clean
    )
  )
)
