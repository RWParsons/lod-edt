source("dependencies.R")
# tar_load_everything()

troponin_lod <- get_troponin_lod()

data_first_presentation <- data |>
  filter(presentation_no == 1) |> 
  mutate(intervention = as.factor(intervention))


m_form <- get_formula(outcome)
fam <- get_family(data, outcome)
outcome_is_binary <- is_binary(data[[outcome]])

f <- ep_early_dsch_no_30d_event ~ intervention*days_since_site_start + bs(pt_age) + pt_sex + (1 | hospital_id)

m_full_cohort <- glmmTMB(
  # formula = m_form,
  formula = f,
  family = fam,
  data = data_first_presentation
)


pred_frame <- tibble(days_since_site_start = seq(
  min(data_first_presentation$days_since_site_start),
  max(data_first_presentation$days_since_site_start), 
  length.out = 100
)) |> 
  mutate(
    pt_sex = 1, 
    pt_age = mean(data_first_presentation$pt_age, na.rm = TRUE),
    post_intervention = days_since_site_start > 0,
    intervention = 0
  ) |> 
  (\(x) {
    bind_rows(
      x,
      mutate(x, intervention = ifelse(post_intervention, 1, 0))
    )
  })() |> 
  mutate(intervention = as.factor(intervention))

pred_frame$preds <- predict(m_full_cohort, newdata = pred_frame, re.form = ~ 0, type = "response")

# p_model_preds <- 
pred_frame |> 
  mutate(intervention = as.factor(intervention)) |> 
  ggplot(aes(days_since_site_start, preds, col = intervention)) + 
  geom_line() +
  theme_bw() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(
    caption = Reduce(paste, deparse(f)),
    y = "model predictions",
    x = "days since site start"
  )

marginaleffects::avg_comparisons(m_full_cohort, variables = list(intervention = 0:1), re.form = NA, type = "response")

ggsave("scripts/test-models1.png")

