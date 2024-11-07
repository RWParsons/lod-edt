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
    tbl_intervention_effects,
    get_intervention_effects(models)
  ),
  tar_target(
    vis_early_disch_full,
    visualise_outcome(
      data = d_clean,
      model = models$ep_early_dsch_no_30d_event$m_full_cohort,
      outcome = "ep_early_dsch_no_30d_event",
      cohort = "full"
    )
  ),
  tar_target(
    vis_early_disch_lod,
    visualise_outcome(
      data = d_clean,
      model = models$ep_early_dsch_no_30d_event$m_lod_cohort,
      outcome = "ep_early_dsch_no_30d_event",
      cohort = "lod"
    )
  ),
  tar_target(
    vis_hoslos_full,
    visualise_outcome(
      data = d_clean,
      model = models$ep_hos_los$m_full_cohort,
      outcome = "ep_hos_los",
      cohort = "full"
    )
  ),
  tar_target(
    vis_hoslos_lod,
    visualise_outcome(
      data = d_clean,
      model = models$ep_hos_los$m_lod_cohort,
      outcome = "ep_hos_los",
      cohort = "lod"
    )
  ),
  tar_target(
    tbl_cardiac_assessments,
    get_cardiac_ax_tbls(d_clean)
  ),
  tar_target(
    vis_eq5d,
    visualise_eq5d(d_clean)
  ),
  tar_target(
    qnt_eq5d,
    get_qnt_eq5d(d_clean)
  ),
  tar_target(
    qnt_patient_experience,
    get_qnt_patient_experience(d_clean)
  ),
  tar_target(
    tbl_1,
    make_table_1(d_clean)
  ),
  # new visualisations for Jaimi
  tar_target(
    vis_hoslos_lod_new,
    visualise_outcome2(
      data = d_clean,
      model = models$ep_hos_los$m_lod_cohort,
      outcome = "ep_hos_los",
      cohort = "lod"
    )
  ),
  tar_target(
    vis_early_disch_full_new,
    visualise_outcome2(
      data = d_clean,
      model = models$ep_early_dsch_no_30d_event$m_full_cohort,
      outcome = "ep_early_dsch_no_30d_event",
      cohort = "full"
    )
  ),
  tar_target(
    outputs,
    store_outputs(
      tbl_intervention_effects = tbl_intervention_effects,
      tbl_cardiac_assessments = tbl_cardiac_assessments,
      tbl_1 = tbl_1,
      vis_hoslos_lod_model = vis_hoslos_lod_new$p_model_preds,
      vis_hoslos_lod_model_by_hosp = vis_hoslos_lod_new$p_model_preds_by_hosp,
      vis_early_disch_full_model = vis_early_disch_full_new$p_model_preds,
      vis_early_disch_full_model_by_hosp = vis_early_disch_full_new$p_model_preds_by_hosp,
      # vis_hoslos_full_data = combine_plots(vis_hoslos_full, which_pair = "smoothed"),
      # vis_hoslos_full_model = combine_plots(vis_hoslos_full, which_pair = "model"),
      # vis_early_disch_full_data = combine_plots(vis_early_disch_full, which_pair = "smoothed"),
      # vis_early_disch_full_model = combine_plots(vis_early_disch_full, which_pair = "model"),
      # vis_hoslos_lod_data = combine_plots(vis_hoslos_lod, which_pair = "smoothed"),
      # vis_hoslos_lod_model = combine_plots(vis_hoslos_lod, which_pair = "model"),
      # vis_early_disch_lod_data = combine_plots(vis_early_disch_lod, which_pair = "smoothed"),
      # vis_early_disch_lod_model = combine_plots(vis_early_disch_lod, which_pair = "model"),
      qnt_eq5d = qnt_eq5d,
      qnt_patient_experience = qnt_patient_experience
    ),
    format = "file"
  )
)
