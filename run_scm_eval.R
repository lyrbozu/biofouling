#!/usr/bin/env Rscript
#' Fit the updated SCM and compare against the previous fit (if available).
suppressPackageStartupMessages({
  library(cmdstanr)
  library(tidyverse)
  library(posterior)
  library(bayesplot)
})

prep_var <- function(x) {
  obs_idx <- which(!is.na(x))
  miss_idx <- which(is.na(x))
  list(
    n_obs = length(obs_idx),
    n_miss = length(miss_idx),
    obs_idx = obs_idx,
    miss_idx = miss_idx,
    obs_vals = x[obs_idx],
    imp_mean = mean(x, na.rm = TRUE),
    imp_sd = max(sd(x, na.rm = TRUE), 1e-3)
  )
}

build_df <- function() {
  data <- read.csv("data.csv")
  df <- data |>
    mutate(biofouling = if_else(
      biofouling == 0, 0, (biofouling * (n() - 1) + 0.5) / n()
    ))
  df$biofouling <- df$biofouling / 100
  df <- df |>
    mutate(
      pred_zoo = copepoda + arrow_worm,
      nutrients = NO2_um + NO3_um + PO4_um
    ) |>
    rename(
      current = current_velocity_w17,
      seaweed_growth = blade_length,
      salinity = Salinity,
      precipitation = precipitation_mm_w17,
      daylight = daylight_duration_h_w17,
      sst = sea_surface_temperature_c_w17,
      phyto = total_phytoplankton,
      cyphonautes = cyphonaute,
      air_temp = avg_temp_w17
    ) |>
    mutate(across(
      c(nutrients, phyto, seaweed_growth, current, air_temp, sst, daylight,
        salinity, pred_zoo, precipitation, cyphonautes),
      ~ scale(.)[, 1]
    )) |>
    mutate(
      farm_id = as.integer(factor(farm)),
      replicate_id = as.integer(factor(replicate))
    )
  df
}

build_scm_data <- function(df) {
  pvs <- list(
    airtemp = prep_var(df$air_temp),
    daylight = prep_var(df$daylight),
    current = prep_var(df$current),
    precip = prep_var(df$precipitation),
    predzoo = prep_var(df$pred_zoo),
    sst = prep_var(df$sst),
    sal = prep_var(df$salinity),
    nut = prep_var(df$nutrients),
    seaweed = prep_var(df$seaweed_growth),
    phyto = prep_var(df$phyto),
    cyph = prep_var(df$cyphonautes)
  )
  interv_grid <- seq(-1, 1, length.out = 11)
  list(
    N = nrow(df),
    J_farm = max(df$farm_id),
    J_replicate = max(df$replicate_id),
    farm_id = df$farm_id,
    replicate_id = df$replicate_id,
    biofouling = df$biofouling,
    N_airtemp_obs = pvs$airtemp$n_obs,
    N_airtemp_miss = pvs$airtemp$n_miss,
    airtemp_obs_idx = pvs$airtemp$obs_idx,
    airtemp_miss_idx = pvs$airtemp$miss_idx,
    airtemp_obs = pvs$airtemp$obs_vals,
    N_daylight_obs = pvs$daylight$n_obs,
    N_daylight_miss = pvs$daylight$n_miss,
    daylight_obs_idx = pvs$daylight$obs_idx,
    daylight_miss_idx = pvs$daylight$miss_idx,
    daylight_obs = pvs$daylight$obs_vals,
    imp_daylight_mean = pvs$daylight$imp_mean,
    imp_daylight_sd = pvs$daylight$imp_sd,
    N_current_obs = pvs$current$n_obs,
    N_current_miss = pvs$current$n_miss,
    current_obs_idx = pvs$current$obs_idx,
    current_miss_idx = pvs$current$miss_idx,
    current_obs = pvs$current$obs_vals,
    imp_current_mean = pvs$current$imp_mean,
    imp_current_sd = pvs$current$imp_sd,
    N_precip_obs = pvs$precip$n_obs,
    N_precip_miss = pvs$precip$n_miss,
    precip_obs_idx = pvs$precip$obs_idx,
    precip_miss_idx = pvs$precip$miss_idx,
    precip_obs = pvs$precip$obs_vals,
    imp_precip_mean = pvs$precip$imp_mean,
    imp_precip_sd = pvs$precip$imp_sd,
    N_predzoo_obs = pvs$predzoo$n_obs,
    N_predzoo_miss = pvs$predzoo$n_miss,
    predzoo_obs_idx = pvs$predzoo$obs_idx,
    predzoo_miss_idx = pvs$predzoo$miss_idx,
    predzoo_obs = pvs$predzoo$obs_vals,
    imp_predzoo_mean = pvs$predzoo$imp_mean,
    imp_predzoo_sd = pvs$predzoo$imp_sd,
    N_sst_obs = pvs$sst$n_obs,
    N_sst_miss = pvs$sst$n_miss,
    sst_obs_idx = pvs$sst$obs_idx,
    sst_miss_idx = pvs$sst$miss_idx,
    sst_obs = pvs$sst$obs_vals,
    N_sal_obs = pvs$sal$n_obs,
    N_sal_miss = pvs$sal$n_miss,
    sal_obs_idx = pvs$sal$obs_idx,
    sal_miss_idx = pvs$sal$miss_idx,
    sal_obs = pvs$sal$obs_vals,
    N_nut_obs = pvs$nut$n_obs,
    N_nut_miss = pvs$nut$n_miss,
    nut_obs_idx = pvs$nut$obs_idx,
    nut_miss_idx = pvs$nut$miss_idx,
    nut_obs = pvs$nut$obs_vals,
    N_seaweed_obs = pvs$seaweed$n_obs,
    N_seaweed_miss = pvs$seaweed$n_miss,
    seaweed_obs_idx = pvs$seaweed$obs_idx,
    seaweed_miss_idx = pvs$seaweed$miss_idx,
    seaweed_obs = pvs$seaweed$obs_vals,
    N_phyto_obs = pvs$phyto$n_obs,
    N_phyto_miss = pvs$phyto$n_miss,
    phyto_obs_idx = pvs$phyto$obs_idx,
    phyto_miss_idx = pvs$phyto$miss_idx,
    phyto_obs = pvs$phyto$obs_vals,
    N_cyph_obs = pvs$cyph$n_obs,
    N_cyph_miss = pvs$cyph$n_miss,
    cyph_obs_idx = pvs$cyph$obs_idx,
    cyph_miss_idx = pvs$cyph$miss_idx,
    cyph_obs = pvs$cyph$obs_vals,
    N_interv = 11,
    do_airtemp = interv_grid,
    do_current = interv_grid,
    do_daylight = interv_grid,
    do_precip = interv_grid,
    do_predzoo = interv_grid,
    do_sst = interv_grid,
    do_nutrients = interv_grid,
    do_seaweed = interv_grid,
    do_phyto = interv_grid,
    do_salinity = interv_grid,
    do_cypho = interv_grid
  )
}

fit_diagnostics <- function(fit, label) {
  summ <- fit$summary()
  diag <- fit$sampler_diagnostics(format = "draws_df")
  tibble(
    model = label,
    divergences = sum(diag$divergent__ == 1, na.rm = TRUE),
    max_rhat = max(summ$rhat, na.rm = TRUE),
    min_ess_bulk = min(summ$ess_bulk, na.rm = TRUE),
    n_bad_rhat = sum(summ$rhat > 1.01, na.rm = TRUE),
    n_low_ess = sum(summ$ess_bulk < 400, na.rm = TRUE)
  )
}

ppc_metrics <- function(fit, y_obs) {
  y_rep <- fit$draws("y_rep", format = "matrix")
  prop_zero <- function(x) mean(x == 0)
  tibble(
    zero_obs = prop_zero(y_obs),
    zero_rep_mean = mean(apply(y_rep, 1, prop_zero)),
    zero_rep_sd = sd(apply(y_rep, 1, prop_zero)),
    mean_obs = mean(y_obs),
    mean_rep_mean = mean(rowMeans(y_rep)),
    mean_rep_sd = sd(rowMeans(y_rep)),
    sd_obs = sd(y_obs),
    sd_rep_mean = mean(apply(y_rep, 1, sd)),
    sd_rep_sd = sd(apply(y_rep, 1, sd))
  )
}

intervention_summary <- function(fit, prefix) {
  vars <- paste0(prefix, "[", 1:11, "]")
  fit$summary(vars) |>
    transmute(
      exposure = sub("Ey_do_", "", prefix),
      grid = 1:11,
      mean = mean,
      lo = q5,
      hi = q95
    )
}

cat("=== Building data ===\n")
df <- build_df()
stan_data <- build_scm_data(df)
y_obs <- df$biofouling

cat("=== Compiling SCM.stan ===\n")
model <- cmdstan_model("SCM.stan", quiet = TRUE, force = TRUE)

cat("=== Fitting updated SCM (4 chains x 1000 iter) ===\n")
fit_new <- model$sample(
  data = stan_data,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 1000,
  adapt_delta = 0.95,
  max_treedepth = 12,
  refresh = 200,
  show_messages = TRUE
)

cat("\n=== Updated SCM diagnostics ===\n")
diag_new <- fit_diagnostics(fit_new, "SCM_updated")
print(diag_new)

cat("\n=== Updated SCM key coefficients ===\n")
print(
  fit_new$summary(c(
    "b_airtemp_daylight", "b_sst_airtemp", "b_seaweed_daylight",
    "b_bf_phyto", "b_bf_seaweed", "sigma_farm", "phi"
  )) |>
    select(variable, mean, sd, rhat, ess_bulk)
)

cat("\n=== Updated SCM posterior predictive checks ===\n")
ppc_new <- ppc_metrics(fit_new, y_obs)
print(ppc_new)

cat("\n=== Updated SCM intervention curves (selected exposures) ===\n")
for (prefix in c("Ey_do_daylight", "Ey_do_airtemp", "Ey_do_sst", "Ey_do_phyto")) {
  s <- intervention_summary(fit_new, prefix)
  cat("\n", unique(s$exposure), ":\n")
  print(s |> filter(grid %in% c(1, 6, 11)) |> select(grid, mean, lo, hi))
}

# Compare to previous fit if available
if (file.exists("scm_fit_results.rds")) {
  cat("\n=== Comparison with previous SCM fit ===\n")
  old <- readRDS("scm_fit_results.rds")
  fit_old <- old$scm
  diag_old <- fit_diagnostics(fit_old, "SCM_previous")
  ppc_old <- ppc_metrics(fit_old, y_obs)
  print(bind_rows(diag_old, diag_new))

  cat("\nPPC comparison:\n")
  print(bind_rows(
    ppc_old |> mutate(model = "SCM_previous"),
    ppc_new |> mutate(model = "SCM_updated")
  ))

  cat("\nDaylight intervention comparison (grid 1 vs 11):\n")
  old_day <- intervention_summary(fit_old, "Ey_do_daylight") |>
    filter(grid %in% c(1, 11)) |>
    mutate(model = "SCM_previous")
  new_day <- intervention_summary(fit_new, "Ey_do_daylight") |>
    filter(grid %in% c(1, 11)) |>
    mutate(model = "SCM_updated")
  print(bind_rows(old_day, new_day) |>
    select(model, grid, mean, lo, hi))
}

saveRDS(
  list(
    fit = fit_new,
    diagnostics = diag_new,
    ppc = ppc_new,
    df = df,
    stan_data = stan_data
  ),
  "scm_fit_updated.rds"
)
cat("\nSaved scm_fit_updated.rds\n")
