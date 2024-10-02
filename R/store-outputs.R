store_outputs <- function(...) {
  l_all <- c(as.list(environment()), list(...))

  # remove existing files
  old_files <- list.files(here("output"), full.names = TRUE)
  map(old_files, ~ file.remove(.x))

  for (i in 1:length(l_all)) {
    withr::with_dir(
      here("output"),
      save_dispatch(l_all[i])
    )
  }
  list.files(here("output"), full.names = TRUE)
}

save_dispatch <- function(x) {
  # assert that length(x) == 1?
  if (inherits(x[[1]], "ggplot")) save_plot(x[[1]], name = names(x))
  if (inherits(x[[1]], "data.frame")) save_tbl(x[[1]], name = names(x))
}

save_tbl <- function(x, name) {
  write.csv(x, file = glue("{name}.csv"), row.names = FALSE)
}

save_plot <- function(x, name) {
  ggsave(plot = x, filename = glue("{name}.png"), height = 6, width = 10)
}
