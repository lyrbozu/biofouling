# SCM model improvements (June 2026)

This document records changes to the Bayesian structural causal model (`SCM.stan`) and
analysis workflow (`SCMmatch.Rmd`) for seaweed-farm biofouling.

## Summary

The SCM was revised to fix a statistical bug, extend the DAG with a daylight → air
temperature pathway, and add a full post-fit analysis pipeline including posterior
predictive checks, intervention curves, and comparison with a daylight-only benchmark.

---

## Changes made

### 1. DAG: `daylight → air_temp`

**Before:** Air temperature was a root (exogenous) node, imputed from its marginal
distribution when missing.

**After:** Daylight is the sole exogenous driver of air temperature:

```
daylight → air_temp → sst → nutrients → …
```

- New parameters: `a_airtemp`, `b_airtemp_daylight`, `sigma_airtemp`
- Missing air temperatures are imputed from daylight via the structural equation
- `do(daylight)` g-computation now propagates through air temp and SST before
  seaweed and phytoplankton paths

### 2. Double-likelihood fix (missing intermediate values)

**Before:** Intermediate nodes (SST, salinity, nutrients, seaweed, phytoplankton,
cyphonautes) entered the likelihood twice — once on the full vector and again on
missing indices.

**After:** Each intermediate node uses a single likelihood per row:

| Rows | Treatment |
|------|-----------|
| Observed | `node[obs_idx] ~ normal(parents, sigma)` |
| Missing | `node_miss ~ normal(parents, sigma)` |

Root nodes (daylight, current, precipitation, predatory zooplankton) still use
marginal imputation when missing, which is correct for exogenous variables.

### 3. Numerical stability

- Structural error terms use `real<lower=1e-3> sigma_*` to prevent HMC rejections
  when σ → 0
- `prep_var()` floors imputation SD at `1e-3` for root nodes

### 4. Bug fix: `do(seaweed)` intensity

In `generated quantities`, the seaweed intervention used `b_zi_cyph` (occupancy
coefficient) instead of `b_bf_cyph` (intensity coefficient) for the non-zero
biofouling mean. Corrected to `b_bf_cyph`.

### 5. Analysis workflow (`SCMmatch.Rmd`)

Added after model fitting:

- Convergence diagnostics (divergences, R-hat, ESS)
- Posterior predictive checks for the SCM
- Structural coefficient summary
- Faceted intervention curves for all 11 exposures
- Daylight-only benchmark fit (`daylight.stan`)
- Side-by-side daylight intervention plot (SCM vs benchmark)
- PPC comparison bar chart
- Figure export to `figures/`

### 6. Reproducibility scripts

| Script | Purpose |
|--------|---------|
| `run_scm_eval.R` | Full SCM fit + diagnostics + comparison with previous fit |
| `run_scm_figures.R` | Regenerate figures (reuses `scm_fit_updated.rds` if present) |

---

## Improvements (empirical)

Full production fit: 4 chains × 1000 warmup + 1000 sample, N = 581.

### Sampling

| Metric | Previous SCM | Updated SCM |
|--------|--------------|-------------|
| Divergences | 0 | 0 |
| Max R-hat | 1.02 | 1.04 |
| Min bulk ESS | 144 | 183 |
| Parameters with ESS < 400 | 131 | 80 |
| σ = 0 HMC errors (full run) | Frequent | None |

### Posterior predictive checks

| Quantity | Observed | Previous rep. | Updated rep. |
|----------|----------|---------------|--------------|
| Zero proportion | 0.670 | 0.669 | 0.669 |
| Mean biofouling | 0.0263 | 0.0275 | **0.0268** |
| SD biofouling | 0.0806 | 0.0692 | **0.0781** |

The updated SCM matches observed mean and variance more closely. The daylight-only
benchmark still under-estimates SD (replicated 0.065 vs observed 0.081).

### Daylight total effect `E[Y | do(daylight)]`

| | Low (−1 SD) | High (+1 SD) |
|---|-------------|--------------|
| Previous SCM | 0.024 | 0.027 |
| **Updated SCM** | **0.004** | **0.016** |
| Daylight-only (direct) | 0.0004 | 0.050 |

The updated SCM produces a larger, structurally coherent daylight effect by routing
through air temperature and SST. The daylight-only model implies a much steeper
association because it ignores mediation and confounding paths encoded in the DAG.

### Key new coefficient

- `b_airtemp_daylight ≈ 0.59` — more daylight associated with higher air temperature
  on the standardised scale (consistent with seasonal co-variation)

---

## Figures

Generated outputs in `figures/`:

- `scm_ppc_hist_dens.png` — SCM posterior predictive histogram and non-zero density
- `scm_ppc_zero_mean_sd.png` — SCM zero proportion and mean/SD checks
- `daylight_ppc_hist_dens.png` — Daylight-only benchmark PPC
- `scm_intervention_all.png` — All exposure intervention curves
- `daylight_intervention_compare.png` — SCM vs daylight-only intervention
- `ppc_scm_vs_daylight.png` — PPC summary comparison

---

## How to reproduce

```bash
# Full workflow (knit or source chunks in order)
# SCMmatch.Rmd

# Or: evaluation fit + figures separately
Rscript run_scm_eval.R      # fits SCM, saves scm_fit_updated.rds
Rscript run_scm_figures.R   # benchmark + figures (uses saved SCM fit)
```

Requires [cmdstanr](https://mc-stan.org/cmdstanr/) and CmdStan.

---

## Remaining considerations

- Random effects are still included per observation in g-computation; for a strict
  population-level estimand, marginalise over farm/replicate effects or set to zero
- Max R-hat remains slightly above 1.01 for some parameters; consider longer chains
  or reparameterisation for publication
- Direct effects using adjustment sets in `wip.R` are not yet implemented in the
  full SCM (only in `daylightdirect.stan`)
