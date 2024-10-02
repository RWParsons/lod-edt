
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lod-edt

<!-- badges: start -->
<!-- badges: end -->

This repository contains the analyses code used for the LEGEND clinical
trial.

It uses a [`{targets}`](https://books.ropensci.org/targets/) workflow
that includes everything from data import to figures/tables used in the
publication.

## `{targets}` workflow

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- x6f7e04ea3427f824[""Pattern""]:::none
  end
  subgraph Graph
    direction LR
    x0d01c84c9424364d(["data_file"]):::uptodate --> x56afa2603fe1d037(["d_raw"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> x5ba341b1daa1fc45["models_iter"]:::uptodate
    x979e976bb4cbf5ad(["endpoint_varnames"]):::uptodate --> x5ba341b1daa1fc45["models_iter"]:::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> x979e976bb4cbf5ad(["endpoint_varnames"]):::uptodate
    x5ba341b1daa1fc45["models_iter"]:::uptodate --> xaca4bed467a54ff1(["models"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> x8c66d753e3a50a0e(["vis_hoslos_full"]):::uptodate
    xaca4bed467a54ff1(["models"]):::uptodate --> x8c66d753e3a50a0e(["vis_hoslos_full"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> xb59898fadcdec69f(["vis_eq5d"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> x7eeef084d656455c(["qnt_eq5d"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> xa2439dbf9eab4d88(["tbl_cardiac_assessments"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> x499e10682e6f581e(["vis_early_disch_lod"]):::uptodate
    xaca4bed467a54ff1(["models"]):::uptodate --> x499e10682e6f581e(["vis_early_disch_lod"]):::uptodate
    x7eeef084d656455c(["qnt_eq5d"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    xd979d4bdf1b06554(["qnt_patient_experience"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    xd34032695f0ff868(["tbl_1"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    xa2439dbf9eab4d88(["tbl_cardiac_assessments"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    x1b37a08095af01ef(["tbl_intervention_effects"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    x52f8121952cb8115(["vis_early_disch_full"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    x499e10682e6f581e(["vis_early_disch_lod"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    x8c66d753e3a50a0e(["vis_hoslos_full"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    x7d0e04e515a3eb8e(["vis_hoslos_lod"]):::uptodate --> xf2656b6bb75dfabe(["outputs"]):::uptodate
    xaca4bed467a54ff1(["models"]):::uptodate --> x1b37a08095af01ef(["tbl_intervention_effects"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> xd979d4bdf1b06554(["qnt_patient_experience"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> xd34032695f0ff868(["tbl_1"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> x52f8121952cb8115(["vis_early_disch_full"]):::uptodate
    xaca4bed467a54ff1(["models"]):::uptodate --> x52f8121952cb8115(["vis_early_disch_full"]):::uptodate
    x56afa2603fe1d037(["d_raw"]):::uptodate --> x13b8365dcba4324c(["d_clean"]):::uptodate
    x13b8365dcba4324c(["d_clean"]):::uptodate --> x7d0e04e515a3eb8e(["vis_hoslos_lod"]):::uptodate
    xaca4bed467a54ff1(["models"]):::uptodate --> x7d0e04e515a3eb8e(["vis_hoslos_lod"]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
```
