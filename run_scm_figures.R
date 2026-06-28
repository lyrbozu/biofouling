#!/usr/bin/env Rscript
#' Generate SCM analysis figures (uses saved SCM fit if available).
suppressPackageStartupMessages({
  library(cmdstanr)
  library(tidyverse)
  library(posterior)
  library(bayesplot)
  library(patchwork)
})

prep_var <- function(x) {
  obs_idx <- which(!is.na(x))
  miss_idx <- which(is.na(x))
  list(
    n_obs = length(obs_idx), n_miss = length(miss_idx),
    obs_idx = obs_idx, miss_idx = miss_idx,
    obs_vals = x[obs_idx],
    imp_mean = mean(x, na.rm = TRUE),
    imp_sd = max(sd(x, na.rm = TRUE), 1e-3)
  )
}

ey_to_df <- function(fit, prefix, grid_values) {
  vars <- paste0(prefix, "[", seq_along(grid_values), "]")
  fit$summary(vars) |>
    transmute(do_value = grid_values, mean = mean, lo = q5, hi = q95)
}

prop_zero <- function(x) mean(x == 0)

# --- data prep (matches SCMmatch.Rmd) ---
data <- read.csv("data.csv")
df <- data |>
  mutate(biofouling = if_else(biofouling == 0, 0, (biofouling * (n() - 1) + 0.5) / n()))
df$biofouling <- df$biofouling / 100
df <- df |>
  mutate(pred_zoo = copepoda + arrow_worm, nutrients = NO2_um + NO3_um + PO4_um) |>
  rename(
    current = current_velocity_w17, seaweed_growth = blade_length,
    salinity = Salinity, precipitation = precipitation_mm_w17,
    daylight = daylight_duration_h_w17, sst = sea_surface_temperature_c_w17,
    phyto = total_phytoplankton, cyphonautes = cyphonaute, air_temp = avg_temp_w17
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

pv_daylight <- prep_var(df$daylight)
N_interv <- 11
interv_grid <- seq(-1, 1, length.out = N_interv)
y_obs <- df$biofouling
nz_idx <- y_obs > 0
n_ppc_draws <- 50

# --- SCM fit (reuse saved if available) ---
if (file.exists("scm_fit_updated.rds")) {
  cat("Loading saved SCM fit...\n")
  fit <- readRDS("scm_fit_updated.rds")$fit
} else {
  cat("No saved SCM fit found; run SCMmatch.Rmd fitting chunk first.\n")
  quit(status = 1)
}

# --- daylight-only benchmark ---
daylight_total <- list(
  N = nrow(df), biofouling = df$biofouling,
  N_day_obs = pv_daylight$n_obs, N_day_miss = pv_daylight$n_miss,
  day_obs_idx = pv_daylight$obs_idx, day_miss_idx = pv_daylight$miss_idx,
  day_obs = pv_daylight$obs_vals,
  imp_day_mean = pv_daylight$imp_mean, imp_day_sd = pv_daylight$imp_sd,
  farm_id = df$farm_id, replicate_id = df$replicate_id,
  J_farm = max(df$farm_id), J_replicate = max(df$replicate_id),
  N_interv = N_interv, do_daylight = interv_grid
)

cat("Fitting daylight-only benchmark...\n")
mod_daylight <- cmdstan_model("daylight.stan", quiet = TRUE)
fit_daylight <- mod_daylight$sample(
  data = daylight_total,
  chains = 4, parallel_chains = 4,
  iter_warmup = 1000, iter_sampling = 1000,
  adapt_delta = 0.95, max_treedepth = 12,
  refresh = 200, show_messages = FALSE
)

# --- PPC: SCM ---
y_rep_mat <- fit$draws("y_rep", format = "matrix")
y_rep_draws <- posterior::as_draws_matrix(fit$draws("y_rep"))

p_ppc_hist <- ppc_hist(y = y_obs, yrep = y_rep_mat[seq_len(n_ppc_draws), ]) +
  labs(title = "SCM — posterior predictive histogram")
p_ppc_dens <- ppc_dens_overlay(
  y = y_obs[nz_idx], yrep = y_rep_mat[seq_len(n_ppc_draws), nz_idx]
) + labs(title = "SCM — non-zero values only")
p_ppc_zero <- ppc_stat(y_obs, y_rep_draws, stat = prop_zero) +
  labs(title = "SCM — proportion of zeros")
p_ppc_mean_sd <- ppc_stat_2d(y_obs, y_rep_draws, stat = c("mean", "sd")) +
  labs(title = "SCM — mean vs SD")

# --- PPC: daylight-only ---
y_rep_day_mat <- fit_daylight$draws("y_rep", format = "matrix")
y_rep_day_draws <- posterior::as_draws_matrix(fit_daylight$draws("y_rep"))

p_day_hist <- ppc_hist(y = y_obs, yrep = y_rep_day_mat[seq_len(n_ppc_draws), ]) +
  labs(title = "Daylight-only — posterior predictive histogram")
p_day_dens <- ppc_dens_overlay(
  y = y_obs[nz_idx], yrep = y_rep_day_mat[seq_len(n_ppc_draws), nz_idx]
) + labs(title = "Daylight-only — non-zero values only")

# --- intervention curves ---
exposure_map <- c(
  Ey_do_daylight = "Daylight", Ey_do_airtemp = "Air temperature",
  Ey_do_sst = "SST", Ey_do_current = "Current",
  Ey_do_precip = "Precipitation", Ey_do_nutrients = "Nutrients",
  Ey_do_seaweed = "Seaweed growth", Ey_do_phyto = "Phytoplankton",
  Ey_do_salinity = "Salinity", Ey_do_predzoo = "Predatory zooplankton",
  Ey_do_cypho = "Cyphonautes"
)

Ey_scm_all <- imap_dfr(exposure_map, \(label, prefix) {
  ey_to_df(fit, prefix, interv_grid) |> mutate(exposure = label)
})

p_interv_all <- ggplot(Ey_scm_all, aes(x = do_value, y = mean)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.2) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~exposure, scales = "free_y", ncol = 3) +
  labs(
    title = expression(SCM ~ E[Y * "|" * do(X)]),
    x = "Intervention level (standardised)",
    y = "Expected biofouling"
  ) +
  theme_bw()

Ey_day_compare <- bind_rows(
  ey_to_df(fit, "Ey_do_daylight", interv_grid) |>
    mutate(model = "SCM (DAG total effect)"),
  ey_to_df(fit_daylight, "Ey_do", interv_grid) |>
    mutate(model = "Daylight-only (direct on Y)")
)

p_day_compare <- ggplot(Ey_day_compare, aes(x = do_value, y = mean, colour = model, fill = model)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.15, colour = NA) +
  geom_line(linewidth = 1) +
  scale_colour_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title = expression("Daylight intervention:" ~ E[Y * "|" * do(daylight)]),
    subtitle = "SCM propagates through air temp, SST, nutrients, seaweed, and phytoplankton",
    x = "Daylight intervention (standardised)",
    y = "Expected biofouling",
    colour = NULL, fill = NULL
  ) +
  theme_bw()

ppc_compare <- bind_rows(
  tibble(
    model = "SCM", stat = c("zero", "mean", "sd"),
    observed = c(prop_zero(y_obs), mean(y_obs), sd(y_obs)),
    replicated = c(
      mean(apply(y_rep_mat, 1, prop_zero)),
      mean(rowMeans(y_rep_mat)),
      mean(apply(y_rep_mat, 1, sd))
    )
  ),
  tibble(
    model = "Daylight-only", stat = c("zero", "mean", "sd"),
    observed = c(prop_zero(y_obs), mean(y_obs), sd(y_obs)),
    replicated = c(
      mean(apply(y_rep_day_mat, 1, prop_zero)),
      mean(rowMeans(y_rep_day_mat)),
      mean(apply(y_rep_day_mat, 1, sd))
    )
  )
)

p_ppc_bar <- ppc_compare |>
  pivot_longer(c(observed, replicated), names_to = "type", values_to = "value") |>
  ggplot(aes(x = stat, y = value, fill = type)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  facet_wrap(~model) +
  labs(
    title = "Posterior predictive summary: observed vs replicated",
    x = NULL, y = "Value", fill = NULL
  ) +
  theme_bw()

dir.create("figures", showWarnings = FALSE)
ggsave("figures/scm_ppc_hist_dens.png", p_ppc_hist / p_ppc_dens, width = 10, height = 4, dpi = 150)
ggsave("figures/scm_ppc_zero_mean_sd.png", p_ppc_zero / p_ppc_mean_sd, width = 10, height = 4, dpi = 150)
ggsave("figures/daylight_ppc_hist_dens.png", p_day_hist / p_day_dens, width = 10, height = 4, dpi = 150)
ggsave("figures/scm_intervention_all.png", p_interv_all, width = 11, height = 9, dpi = 150)
ggsave("figures/daylight_intervention_compare.png", p_day_compare, width = 8, height = 5, dpi = 150)
ggsave("figures/ppc_scm_vs_daylight.png", p_ppc_bar, width = 8, height = 4, dpi = 150)

saveRDS(
  list(
    fit_scm = fit, fit_daylight = fit_daylight,
    Ey_scm_all = Ey_scm_all, Ey_day_compare = Ey_day_compare,
    ppc_compare = ppc_compare
  ),
  "scm_analysis_results.rds"
)

cat("\n=== PPC comparison ===\n")
print(ppc_compare |> mutate(abs_error = abs(observed - replicated)))

cat("\n=== Daylight intervention (endpoints) ===\n")
print(Ey_day_compare |> filter(do_value %in% range(interv_grid)))

cat("\nFigures saved to figures/\n")
