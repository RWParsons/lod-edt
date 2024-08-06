
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lod-edt

<!-- badges: start -->
<!-- badges: end -->

This repository contains the analyses code used for the LEGEND clinical
trial.

It uses a [`{targets}`](https://books.ropensci.org/targets/) workflow
that includes all model fitting, evaluation and generation of figures
and tables presented in the (forthcoming) publication.

## `{targets}` workflow

-\|/-\|/-\|/-\|/-\|/-\|── Attaching core tidyverse packages
──────────────────────── tidyverse 2.0.0 ── ✔ dplyr 1.1.4 ✔ readr 2.1.5
✔ forcats 1.0.0 ✔ stringr 1.5.1 ✔ ggplot2 3.5.1 ✔ tibble 3.2.1 ✔
lubridate 1.9.3 ✔ tidyr 1.3.1 ✔ purrr 1.0.2  
/── Conflicts ──────────────────────────────────────────
tidyverse_conflicts() ── ✖ dplyr::filter() masks stats::filter() ✖
dplyr::lag() masks stats::lag() ℹ Use the conflicted package
(<http://conflicted.r-lib.org/>) to force all conflicts to become errors
-\|/-\|/-\|/-\|/-\|/-\|/-\|Styling / 9 files: .Rprofile -✔  
\_targets.R \|✔ / dependencies.R -✔  
README.Rmd \|ℹ / R/fit-model.R -✔  
R/impute-data.R \|✔ / R/util-group-models.R -✔  
R/vis-missingness.R \|✔ / R/wrangle-data.R -✔  
──────────────────────────────────────── Status Count Legend ✔ 8 File
unchanged. ℹ 1 File changed. ✖ 0 Styling threw an error.
\|──────────────────────────────────────── Please review the changes
carefully!
/- `mermaid graph LR   style Legend fill:#FFFFFF00,stroke:#000000;   style Graph fill:#FFFFFF00,stroke:#000000;   subgraph Legend     direction LR     xf1522833a4d242c5([""Up to date""]):::uptodate --- xd03d7c7dd2ddda2b([""Stem""]):::none     xd03d7c7dd2ddda2b([""Stem""]):::none --- x6f7e04ea3427f824[""Pattern""]:::none   end   subgraph Graph     direction LR     x56afa2603fe1d037(["d_raw"]):::uptodate --> x13b8365dcba4324c(["d_clean"]):::uptodate     x0d01c84c9424364d(["data_file"]):::uptodate --> x56afa2603fe1d037(["d_raw"]):::uptodate     x5ba341b1daa1fc45["models_iter"]:::uptodate --> xaca4bed467a54ff1(["models"]):::uptodate     x13b8365dcba4324c(["d_clean"]):::uptodate --> x979e976bb4cbf5ad(["endpoint_varnames"]):::uptodate     x13b8365dcba4324c(["d_clean"]):::uptodate --> x5ba341b1daa1fc45["models_iter"]:::uptodate     x979e976bb4cbf5ad(["endpoint_varnames"]):::uptodate --> x5ba341b1daa1fc45["models_iter"]:::uptodate   end   classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;   classDef none stroke:#000000,color:#000000,fill:#94a4ac;   linkStyle 0 stroke-width:0px;   linkStyle 1 stroke-width:0px;`
