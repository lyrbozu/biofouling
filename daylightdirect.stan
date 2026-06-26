data {
  int<lower=1> N;
  vector<lower=0, upper=1>[N] biofouling;

  //daylight - current exposure goes here 4 future runs
  int<lower=0> N_day_obs;
  int<lower=0> N_day_miss;
  array[N_day_obs] int day_obs_idx;
  array[N_day_miss] int day_miss_idx;
  vector[N_day_obs] day_obs;
  real imp_day_mean;
  real<lower=0> imp_day_sd;
   // Adjustment sets- current/seaweed_growth/phytoplankton
   //daggity
   //current and sst cannot be in the same adjustment set, too collinear (nutrients has no choice)
  //current
  int<lower=0> N_cur_obs;
  int<lower=0> N_cur_miss;
  array[N_cur_obs] int cur_obs_idx;
  array[N_cur_miss] int cur_miss_idx;
  vector[N_cur_obs] cur_obs;
  real imp_cur_mean;
  real<lower=0> imp_cur_sd;

  //Seaweed
  int<lower=0> N_sw_obs;
  int<lower=0> N_sw_miss;
  array[N_sw_obs] int sw_obs_idx;
  array[N_sw_miss] int sw_miss_idx;
  vector[N_sw_obs] sw_obs;
  real imp_sw_mean;
  real<lower=0> imp_sw_sd;

  //phyto
  int<lower=0> N_phy_obs;
  int<lower=0> N_phy_miss;
  array[N_phy_obs] int phy_obs_idx;
  array[N_phy_miss] int phy_miss_idx;
  vector[N_phy_obs] phy_obs;
  real imp_phy_mean;
  real<lower=0> imp_phy_sd;

  //nested random effects farm + replicate
  int<lower=1> J_farm;
  int<lower=1> J_replicate;
  array[N] int<lower=1, upper=J_farm> farm_id;
  array[N] int<lower=1, upper=J_replicate> replicate_id;

  int<lower=1> N_interv;
  vector[N_interv] do_daylight;
}

parameters {
  //imputation 4 exposure + adjustment
  vector[N_day_miss] day_miss;
  vector[N_cur_miss] cur_miss;
  vector[N_sw_miss] sw_miss;
  vector[N_phy_miss] phy_miss;
  //fixed effects
  real alpha;
  real b_daylight;

  real g_cur;
  real g_sw;
  real g_phy;

  real alpha_zi;
  real b_daylight_zi;

  real<lower=1e-3> phi;
 //random effects farm + replicate
  vector[J_farm] z_farm;
  vector[J_replicate] z_replicate;

  real<lower=0> sigma_farm;
  real<lower=0> sigma_replicate;
}

transformed parameters {
  vector[N] daylight;
  vector[N] current;
  vector[N] seaweed_growth;
  vector[N] phyto;

  vector[J_farm] u_farm;
  vector[J_replicate] u_replicate;

  daylight[day_obs_idx] = day_obs;
  if (N_day_miss > 0)
    daylight[day_miss_idx] = day_miss;

  current[cur_obs_idx] = cur_obs;
  if (N_cur_miss > 0)
    current[cur_miss_idx] = cur_miss;

  seaweed_growth[sw_obs_idx] = sw_obs;
  if (N_sw_miss > 0)
    seaweed_growth[sw_miss_idx] = sw_miss;

  phyto[phy_obs_idx] = phy_obs;
  if (N_phy_miss > 0)
    phyto[phy_miss_idx] = phy_miss;

  u_farm = sigma_farm * z_farm;
  u_replicate = sigma_replicate * z_replicate;
}

model {
  //priors
  alpha ~ normal(0, 2);
  b_daylight ~ normal(0.5, 0.3); //informative
  // normal priors 4 now
  g_cur ~ normal(0, 2);
  g_sw ~ normal(0, 2);
  g_phy ~ normal(0, 2);

  alpha_zi ~ normal(0, 2);
  b_daylight_zi ~ normal(0.3, 0.3);

  phi ~ exponential(0.1);

  z_farm ~ normal(0, 1);
  z_replicate ~ normal(0, 1);

  sigma_farm ~ exponential(1);
  sigma_replicate ~ exponential(1);

  if (N_day_miss > 0)
    day_miss ~ normal(imp_day_mean, imp_day_sd);
  if (N_cur_miss > 0)
    cur_miss ~ normal(imp_cur_mean, imp_cur_sd);
  if (N_sw_miss > 0)
    sw_miss ~ normal(imp_sw_mean, imp_sw_sd);
  if (N_phy_miss > 0)
    phy_miss ~ normal(imp_phy_mean, imp_phy_sd);

  real eps = 1e-6;

  for (n in 1:N) {

    real lp_occ =
      alpha_zi
      + b_daylight_zi * daylight[n]
      + u_farm[farm_id[n]]
      + u_replicate[replicate_id[n]];

    real p_occ = inv_logit(lp_occ);

    if (biofouling[n] == 0) {
      target += log1m(p_occ);
    } else {

      real lp_mu =
        alpha
        + b_daylight * daylight[n]
        + g_cur * current[n]
        + g_sw * seaweed_growth[n]
        + g_phy * phyto[n]
        + u_farm[farm_id[n]]
        + u_replicate[replicate_id[n]];

      real mu = inv_logit(lp_mu);
      mu = fmax(eps, fmin(1 - eps, mu));

      target += log(p_occ)
              + beta_lpdf(biofouling[n] | mu * phi, (1 - mu) * phi);
    }
  }
}

generated quantities {

  vector[N] y_rep; // sim data
  vector[N_interv] Ey_do; // intervention estimates
  real eps = 1e-6; //bleh beta

  for (n in 1:N) {
    //occupancy model
    real p_occ =
      inv_logit(alpha_zi
      + b_daylight_zi * daylight[n]
      + u_farm[farm_id[n]]
      + u_replicate[replicate_id[n]]);
    //intensity model 
    real mu =
      inv_logit(alpha
      + b_daylight * daylight[n]
      + g_cur * current[n]
      + g_sw * seaweed_growth[n]
      + g_phy * phyto[n]
      + u_farm[farm_id[n]]
      + u_replicate[replicate_id[n]]);

    mu = fmax(eps, fmin(1 - eps, mu));

    if (bernoulli_rng(p_occ))
      y_rep[n] = beta_rng(mu * phi, (1 - mu) * phi);
    else
      y_rep[n] = 0;
  }
  //gcomp
  for (k in 1:N_interv) {

    real acc = 0;

    for (n in 1:N) {

      real p_occ =
        inv_logit(alpha_zi + b_daylight_zi * do_daylight[k]
        + u_farm[farm_id[n]]
        + u_replicate[replicate_id[n]]);

      real mu =
        inv_logit(alpha
        + b_daylight * do_daylight[k]
        + g_cur * current[n]
        + g_sw * seaweed_growth[n]
        + g_phy * phyto[n]
        + u_farm[farm_id[n]]
        + u_replicate[replicate_id[n]]);

      mu = fmax(eps, fmin(1 - eps, mu));

      acc += p_occ * mu;
    }

    Ey_do[k] = acc / N;
  }
}