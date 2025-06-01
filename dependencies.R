suppressPackageStartupMessages({
  library(cowplot)
  library(tidyverse)
  library(targets)
  library(tarchetypes)
  library(ggfortify)
  library(glmmTMB)
  library(glue)
  library(scales)
  library(survival)
  library(here)
})

style_dir <- styler::style_dir
