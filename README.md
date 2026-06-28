# biofouling

Bayesian structural causal modelling of seaweed-farm biofouling.

## Main files

| File | Description |
|------|-------------|
| `SCM.stan` | Full DAG structural causal model |
| `SCMmatch.Rmd` | Data prep, fitting, PPC, and intervention plots |
| `daylight.stan` | Daylight-only benchmark (total effect on biofouling) |
| `daylight_test.Rmd` | Earlier daylight model development |
| `wip.R` | Adjustment-set registry (Dagitty) for direct effects |
| `SCM_IMPROVEMENTS.md` | Documentation of recent SCM revisions and results |

## Reproducing analysis

Install [cmdstanr](https://mc-stan.org/cmdstanr/) and CmdStan, then knit `SCMmatch.Rmd`
or run:

```bash
Rscript run_scm_eval.R
Rscript run_scm_figures.R
```

Figures are written to `figures/`.
