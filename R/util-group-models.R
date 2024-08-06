group_models <- function(models) {
  names(models) <- unlist(unname(map(models, ~ .x$outcome)))
  models
}
