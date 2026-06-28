
//data section. Will go as:
//random effects
//response
//exposures - 
//start w/ parent nodes (climate)
//go into middle nodes (physical)
data {
  //Random effects
  int<lower=1> N;
  int<lower=1> J_farm;
  int<lower=1> J_replicate;
  array[N] int<lower=1, upper=J_farm> farm_id;
  array[N] int<lower=1, upper=J_replicate> replicate_id;
  
  //Response = biofouling
  vector<lower=0, upper = 1>[N] biofouling;
  
  //Exposure nodes
  //Root nodes: daylight, current, precipitation, predatory zooplankton
  //Intermediate nodes include air_temp (daylight -> air_temp -> sst ...)
  int<lower=0> N_daylight_obs;
  int<lower=0> N_daylight_miss;
  array[N_daylight_obs] int daylight_obs_idx;
  array[N_daylight_miss] int daylight_miss_idx;
  vector[N_daylight_obs] daylight_obs;
  real imp_daylight_mean;
  real <lower=0> imp_daylight_sd;
  
  //Current
  int<lower=0> N_current_obs;
  int<lower=0> N_current_miss;
  array[N_current_obs] int current_obs_idx;
  array[N_current_miss] int current_miss_idx;
  vector[N_current_obs] current_obs;
  real imp_current_mean;
  real <lower=0> imp_current_sd;
  
  //Precipitation
  int<lower=0> N_precip_obs;
  int<lower=0> N_precip_miss;
  array[N_precip_obs] int precip_obs_idx;
  array[N_precip_miss] int precip_miss_idx;
  vector[N_precip_obs] precip_obs;
  real imp_precip_mean;
  real <lower=0> imp_precip_sd;
  
  //Predatory Zooplankton
  int<lower=0> N_predzoo_obs;
  int<lower=0> N_predzoo_miss;
  array[N_predzoo_obs] int predzoo_obs_idx;
  array[N_predzoo_miss] int predzoo_miss_idx;
  vector[N_predzoo_obs] predzoo_obs;
  real imp_predzoo_mean;
  real<lower=0> imp_predzoo_sd;
  
  //non-root nodes
  
  //Air temperature (parent = daylight)
  int<lower=0> N_airtemp_obs;
  int<lower=0> N_airtemp_miss;
  array[N_airtemp_obs] int airtemp_obs_idx;
  array[N_airtemp_miss] int airtemp_miss_idx;
  vector[N_airtemp_obs] airtemp_obs;
  
  //SST
  int<lower=0> N_sst_obs;
  int<lower=0> N_sst_miss;
  array[N_sst_obs] int sst_obs_idx;
  array[N_sst_miss] int sst_miss_idx;
  vector[N_sst_obs] sst_obs;
  
  //Salinity
  int<lower=0> N_sal_obs;
  int<lower=0> N_sal_miss;
  array[N_sal_obs] int sal_obs_idx;
  array[N_sal_miss] int sal_miss_idx;
  vector[N_sal_obs] sal_obs;
  
  //Nutrients
  int<lower=0> N_nut_obs;
  int<lower=0> N_nut_miss;
  array[N_nut_obs] int nut_obs_idx;
  array[N_nut_miss] int nut_miss_idx;
  vector[N_nut_obs] nut_obs;
  
  //Seaweed Growth
  int<lower=0> N_seaweed_obs;
  int<lower=0> N_seaweed_miss;
  array[N_seaweed_obs] int seaweed_obs_idx;
  array[N_seaweed_miss] int seaweed_miss_idx;
  vector[N_seaweed_obs] seaweed_obs;
  
  //Phytoplankton
  int<lower=0> N_phyto_obs;
  int<lower=0> N_phyto_miss;
  array[N_phyto_obs] int phyto_obs_idx;
  array[N_phyto_miss] int phyto_miss_idx;
  vector[N_phyto_obs] phyto_obs;
  
  //Cyphonautes
  int<lower=0> N_cyph_obs;
  int<lower=0> N_cyph_miss;
  array[N_cyph_obs] int cyph_obs_idx;
  array[N_cyph_miss] int cyph_miss_idx;
  vector[N_cyph_obs] cyph_obs;
  
  //all nodes finished
  
  //Intervention grid
  // One grid per node
  // same do(X=x) logic as causal model
  
  int<lower=1> N_interv;
  vector[N_interv] do_airtemp;
  vector[N_interv] do_daylight;
  vector[N_interv] do_current;
  vector[N_interv] do_predzoo;
  vector[N_interv] do_precip;
  vector[N_interv] do_sst;
  vector[N_interv] do_nutrients;
  vector[N_interv] do_seaweed;
  vector[N_interv] do_phyto;
  vector[N_interv] do_salinity;
  vector[N_interv] do_cypho;
}

parameters {
  
  //Imputatiiiiiiiiooooooon
  //root nodes are imputed by mean/sd
  //intermediate nodes are imputed using their parent functions 
  
  //root nodes
  vector[N_daylight_miss] daylight_miss;
  vector[N_current_miss] current_miss;
  vector[N_precip_miss] precip_miss;
  vector[N_predzoo_miss] predzoo_miss;
  
  //Intermediate nodes (not orphans)
  vector[N_airtemp_miss] airtemp_miss;
  vector[N_sst_miss] sst_miss;
  vector[N_sal_miss] sal_miss;
  vector[N_nut_miss] nut_miss;
  vector[N_seaweed_miss] seaweed_miss;
  vector[N_phyto_miss] phyto_miss;
  vector[N_cyph_miss] cyph_miss;
  
  //defining model structures
  //only for intermediate nodes
  
  //Air temperature parent = daylight
  real a_airtemp;
  real b_airtemp_daylight;
  real<lower=1e-3> sigma_airtemp;
  
  //SST parent = airtemp
  real a_sst;
  real b_sst_airtemp;
  real<lower=1e-3> sigma_sst;
  
  //Salinity parent = precipitation
  real a_sal;
  real b_sal_precip;
  real<lower=1e-3> sigma_sal;
  
  //Nutrients 
  //parents = sst, current, precipitation
  //stratification parents
  real a_nut;
  real b_nut_sst;
  real b_nut_current;
  real b_nut_precip;
  real<lower=1e-3> sigma_nut;
  
  //Seaweed growth 
  //parents = sst, nutrients, daylight
  real a_seaweed;
  real b_seaweed_sst;
  real b_seaweed_nut;
  real b_seaweed_daylight;
  real<lower=1e-3> sigma_seaweed;
  
  //Phytoplankton
  //parents = salinity, nutrients, daylight
  real a_phyto;
  real b_phyto_sal;
  real b_phyto_nut;
  real b_phyto_daylight;
  real<lower=1e-3> sigma_phyto;
  
  //Cyphonautes
  //parents = phytoplankton, predzoo, current
  real a_cyph;
  real b_cyph_phyto;
  real b_cyph_predzoo;
  real b_cyph_current;
  real<lower=1e-3> sigma_cyph;
  
  //Biofouling
  //parents = seaweed, phytoplankton, cyphonautes
  //Intensity model 
  real alpha_bf;
  real b_bf_seaweed;
  real b_bf_phyto;
  real b_bf_cyph;
  real<lower=1> phi; //zero inflated beta
  //occupancy 
  real alpha_zi;
  real b_zi_seaweed;
  real b_zi_phyto;
  real b_zi_cyph;
  
  //Random effects 
  //nested w/ farm/replicate
  vector[J_farm] z_farm;
  vector[J_replicate] z_replicate;
  real<lower=0> sigma_farm;
  real<lower=0> sigma_replicate;
}
  
//transformed params

transformed parameters {
  //this block will
  //reconstruct vectors from the observed and imputed values
  
  //assigning
  vector[N] air_temp;
  vector[N] daylight;
  vector[N] current;
  vector[N] precip;
  vector[N] pred_zoo;
  vector[N] sst;
  vector[N] salinity;
  vector[N] nutrients;
  vector[N] seaweed;
  vector[N] phyto;
  vector[N] cyphonautes;
  
  //Root nodes
  daylight[daylight_obs_idx] = daylight_obs;
  if (N_daylight_miss > 0)
    daylight[daylight_miss_idx] = daylight_miss;
  
  //current
  current[current_obs_idx] = current_obs;
  if (N_current_miss > 0) 
  current[current_miss_idx] = current_miss;
  
  //precipitation
  precip[precip_obs_idx] = precip_obs;
  if (N_precip_miss > 0)
  precip[precip_miss_idx] = precip_miss;
  
  //predatory zooplankton
  pred_zoo[predzoo_obs_idx] = predzoo_obs;
  if (N_predzoo_miss > 0)
  pred_zoo[predzoo_miss_idx] = predzoo_miss;
  
  //Intermediate nodes
  air_temp[airtemp_obs_idx] = airtemp_obs;
  if (N_airtemp_miss > 0)
    air_temp[airtemp_miss_idx] = airtemp_miss;
  
  //sst
  sst[sst_obs_idx] = sst_obs;
  if (N_sst_miss > 0)
  sst[sst_miss_idx] = sst_miss;
  
  //salinity 
  salinity[sal_obs_idx] = sal_obs;
  if (N_sal_miss > 0)
  salinity[sal_miss_idx] = sal_miss;
  
  //nutrients
  nutrients[nut_obs_idx] = nut_obs;
  if (N_nut_miss > 0)
  nutrients[nut_miss_idx] = nut_miss;
  
  //seaweed growth
  seaweed[seaweed_obs_idx] = seaweed_obs;
  if (N_seaweed_miss > 0)
  seaweed[seaweed_miss_idx] = seaweed_miss;
  
  //phytoplankton abundance
  phyto[phyto_obs_idx] = phyto_obs;
  if (N_phyto_miss > 0 )
  phyto[phyto_miss_idx] = phyto_miss;
  
  //cyphonautes
  cyphonautes[cyph_obs_idx] = cyph_obs;
  if (N_cyph_miss > 0)
  cyphonautes[cyph_miss_idx] = cyph_miss;
  
  //Random effects 
  //non centering
  // noise * variation = farm units
  vector[J_farm] u_farm = sigma_farm * z_farm;
  vector[J_replicate] u_replicate = sigma_replicate * z_replicate;
  
}

  
  
model {
  
  real eps = 1e-6; //no 0
  
  //Priors
  //need priors for - 
  //root node imputations
  //random effects
  // actual coefficient priors
  
  //root node imputation priors (marginal for exogenous nodes only)
  
  //daylight
  if (N_daylight_miss > 0)
  daylight_miss ~ normal(imp_daylight_mean, imp_daylight_sd);
  
  //current 
  if (N_current_miss > 0)
  current_miss ~normal(imp_current_mean, imp_current_sd);
  
  //precipitation
  if (N_precip_miss > 0)
  precip_miss ~ normal(imp_precip_mean, imp_precip_sd);
  
  //predatory zooplankton
  if (N_predzoo_miss > 0)
  predzoo_miss ~ normal(imp_predzoo_mean, imp_predzoo_sd);
  
  //Random effect priors
  z_farm ~ std_normal();
  z_replicate ~ std_normal();
  sigma_farm ~ exponential(1);
  sigma_replicate ~ exponential(1);
  
  //Priors for coefficients and their structural relationships
  
  //Air temperature
  a_airtemp ~ normal(0, 2);
  b_airtemp_daylight ~ normal(0.3, 0.5);
  sigma_airtemp ~ exponential(1);
  
  //SST
  a_sst ~ normal(0.5, 0.4);
  b_sst_airtemp ~ normal(0, 2);
  sigma_sst ~ exponential(1);
  
  //Salinity 
  a_sal ~ normal(0,2);
  b_sal_precip ~ normal(0,2);
  sigma_sal ~ exponential(1);
  
  //Nutrients
  a_nut ~ normal(0,2);
  b_nut_sst ~ normal(0,2);
  b_nut_current ~ normal(0,2);
  b_nut_precip ~ normal(0,2);
  sigma_nut ~ exponential(1);
  
  //Seaweed Growth 
  a_seaweed ~ normal(0,2);
  b_seaweed_sst ~ normal(0,2);
  b_seaweed_nut ~ normal(0,2);
  b_seaweed_daylight ~ normal(0.3, 0.5); //daylight v impactful when it appears i think
  sigma_seaweed ~ exponential(1);
  
  // Phyto
  a_phyto ~ normal(0,2);
  b_phyto_sal ~ normal(0,2);
  b_phyto_nut ~ normal(0,2);
  b_phyto_daylight ~ normal(0.3, 0.5);
  sigma_phyto ~ exponential(1);
  
  //Cyphonautes
  a_cyph ~ normal(0,2); 
  b_cyph_phyto ~ normal(0,2);
  b_cyph_predzoo ~ normal(0,2);
  b_cyph_current ~ normal(0,2);
  sigma_cyph ~ exponential(1);
  
  //Biofouling
  alpha_bf ~ normal(0,2);
  b_bf_seaweed ~ normal(0,2);
  b_bf_phyto ~ normal(0,2);
  b_bf_cyph ~ normal(0,2);
  phi ~ gamma(4, 0.1);
  alpha_zi ~ normal(0,2);
  b_zi_seaweed ~ normal(0,2);
  b_zi_phyto ~ normal(0,2);
  b_zi_cyph ~ normal(0,2);
  
  
  //Structural equations
  //Observed rows: likelihood on data; missing rows: imputation from parents
  
  //Air temperature (parent = daylight)
  if (N_airtemp_obs > 0)
    air_temp[airtemp_obs_idx] ~ normal(
      a_airtemp + b_airtemp_daylight * daylight[airtemp_obs_idx],
      sigma_airtemp);
  if (N_airtemp_miss > 0)
    airtemp_miss ~ normal(
      a_airtemp + b_airtemp_daylight * daylight[airtemp_miss_idx],
      sigma_airtemp);
  
  //SST (parent = air temperature)
  if (N_sst_obs > 0)
    sst[sst_obs_idx] ~ normal(
      a_sst + b_sst_airtemp * air_temp[sst_obs_idx],
      sigma_sst);
  if (N_sst_miss > 0)
    sst_miss ~ normal(
      a_sst + b_sst_airtemp * air_temp[sst_miss_idx],
      sigma_sst);
  
  //Salinity (parent = precipitation)
  if (N_sal_obs > 0)
    salinity[sal_obs_idx] ~ normal(
      a_sal + b_sal_precip * precip[sal_obs_idx],
      sigma_sal);
  if (N_sal_miss > 0)
    sal_miss ~ normal(
      a_sal + b_sal_precip * precip[sal_miss_idx],
      sigma_sal);
  
  //Nutrients (parents = sst, current, precipitation)
  if (N_nut_obs > 0)
    nutrients[nut_obs_idx] ~ normal(
      a_nut
      + b_nut_sst * sst[nut_obs_idx]
      + b_nut_current * current[nut_obs_idx]
      + b_nut_precip * precip[nut_obs_idx],
      sigma_nut);
  if (N_nut_miss > 0)
    nut_miss ~ normal(
      a_nut
      + b_nut_sst * sst[nut_miss_idx]
      + b_nut_current * current[nut_miss_idx]
      + b_nut_precip * precip[nut_miss_idx],
      sigma_nut);
  
  //Seaweed growth (parents = sst, nutrients, daylight)
  if (N_seaweed_obs > 0)
    seaweed[seaweed_obs_idx] ~ normal(
      a_seaweed
      + b_seaweed_sst * sst[seaweed_obs_idx]
      + b_seaweed_nut * nutrients[seaweed_obs_idx]
      + b_seaweed_daylight * daylight[seaweed_obs_idx],
      sigma_seaweed);
  if (N_seaweed_miss > 0)
    seaweed_miss ~ normal(
      a_seaweed
      + b_seaweed_sst * sst[seaweed_miss_idx]
      + b_seaweed_nut * nutrients[seaweed_miss_idx]
      + b_seaweed_daylight * daylight[seaweed_miss_idx],
      sigma_seaweed);
  
  //Phytoplankton (parents = salinity, nutrients, daylight)
  if (N_phyto_obs > 0)
    phyto[phyto_obs_idx] ~ normal(
      a_phyto
      + b_phyto_sal * salinity[phyto_obs_idx]
      + b_phyto_nut * nutrients[phyto_obs_idx]
      + b_phyto_daylight * daylight[phyto_obs_idx],
      sigma_phyto);
  if (N_phyto_miss > 0)
    phyto_miss ~ normal(
      a_phyto
      + b_phyto_sal * salinity[phyto_miss_idx]
      + b_phyto_nut * nutrients[phyto_miss_idx]
      + b_phyto_daylight * daylight[phyto_miss_idx],
      sigma_phyto);
  
  //Cyphonautes (parents = phytoplankton, predatory zooplankton, current)
  if (N_cyph_obs > 0)
    cyphonautes[cyph_obs_idx] ~ normal(
      a_cyph
      + b_cyph_phyto * phyto[cyph_obs_idx]
      + b_cyph_predzoo * pred_zoo[cyph_obs_idx]
      + b_cyph_current * current[cyph_obs_idx],
      sigma_cyph);
  if (N_cyph_miss > 0)
    cyph_miss ~ normal(
      a_cyph
      + b_cyph_phyto * phyto[cyph_miss_idx]
      + b_cyph_predzoo * pred_zoo[cyph_miss_idx]
      + b_cyph_current * current[cyph_miss_idx],
      sigma_cyph);
          
  //Biofouling zero inflated beta regression
  //mixture model 
  // occupancy vs intensity
  //check for biofouling at all
  //check effect of things if biofouling is present
  //zero inflation such joy such joy such joy such joy
  for (n in 1:N) { 
    real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]]; //random effects nested hierarchy
    
    //occupancy
    // does biofouling exist at all
    real p_occ = inv_logit(alpha_zi 
    + b_zi_seaweed * seaweed[n]
    + b_zi_phyto * phyto[n]
    + b_zi_cyph * cyphonautes[n]
    + re);
    
    if (biofouling[n] == 0) { 
      target += log1m(p_occ); // if zero, log probability of it being zero. I THINK. 
      } else { 
        real mu_raw = inv_logit(alpha_bf
        + b_bf_seaweed * seaweed[n]
        + b_bf_phyto * phyto[n]
        + b_bf_cyph * cyphonautes[n]
        + re); 
        real mu = fmax(eps, fmin(1-eps, mu_raw)); //mu cannot be 0 or 1 or it'll all explode
        target += log(p_occ) 
        + beta_lpdf(biofouling[n] | mu * phi, (1 - mu) * phi); //if not zero, return probability of being present from probability of it being zero
        }
    
  }
  
} //block }
     
        
 generated quantities {
   real eps = 1e-6;
   
   //Posterior Predictive
   vector[N] y_rep;
   for(n in 1:N) {
     real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
     real p_occ = inv_logit(alpha_zi + 
     b_zi_seaweed * seaweed[n]
     + b_zi_phyto * phyto[n]
     + b_zi_cyph * cyphonautes[n] 
     + re);
    
    real mu_raw = inv_logit(alpha_bf + 
    b_bf_seaweed * seaweed[n] + 
    b_bf_phyto * phyto[n] 
    + b_bf_cyph * cyphonautes[n]
    + re);
    real mu = fmax(eps, fmin(1 - eps, mu_raw));
    if (bernoulli_rng(p_occ)) y_rep[n] = beta_rng(mu * phi, (1- mu) * phi);
    else
    y_rep[n] = 0;
    
   }
   
   //Interventions
   //interventions could change distributions of variables
   //not sure that's something i need to care about
 vector[N_interv] Ey_do_airtemp;
 vector[N_interv] Ey_do_current;
 vector[N_interv] Ey_do_daylight;
 vector[N_interv] Ey_do_precip;
 vector[N_interv] Ey_do_predzoo;
 vector[N_interv] Ey_do_sst;
 vector[N_interv] Ey_do_nutrients;
 vector[N_interv] Ey_do_seaweed;
 vector[N_interv] Ey_do_phyto;
 vector[N_interv] Ey_do_salinity;
 vector[N_interv] Ey_do_cypho;
 
 for (k in 1:N_interv) { 
   
   //air temp
   
   { real acc = 0;
   for (n in 1:N) {
     real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
     //propagating intervention through air temp paths
     //include parents (full structure of intermediate nodes)
     
    //air temp -> sst
    real sst_k = a_sst + b_sst_airtemp * do_airtemp[k];
    
    //sst -> nutrients 
    real nut_k = a_nut + b_nut_sst * sst_k
    + b_nut_current * current[n] 
    + b_nut_precip * precip[n];
    
    //sst and nutrients -> seaweed
    real seaweed_k = a_seaweed + b_seaweed_sst * sst_k
    + b_seaweed_nut * nut_k
    + b_seaweed_daylight * daylight[n];
    
    // nutrients -> phytoplankton
    real phyto_k = a_phyto + b_phyto_sal * salinity[n]
    + b_phyto_nut * nut_k
    + b_phyto_daylight * daylight[n];
    
    //phyto -> cyphonautes
    real cyph_k = a_cyph + b_cyph_phyto   * phyto_k
                  + b_cyph_predzoo * pred_zoo[n]
                  + b_cyph_current * current[n];
                  
    real p_occ = inv_logit(alpha_zi
      + b_zi_seaweed * seaweed_k
      + b_zi_phyto   * phyto_k
      + b_zi_cyph    * cyph_k
      + re);
      
      real mu = fmax(eps, fmin(1 - eps, inv_logit(
      alpha_bf
      + b_bf_seaweed * seaweed_k
      + b_bf_phyto   * phyto_k
      + b_bf_cyph    * cyph_k
      + re)));
    acc += p_occ * mu;
   }
   Ey_do_airtemp[k] = acc / N;
   }
   
   //current
   
   {real acc = 0;
   for (n in 1:N) {
     real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
     //current -> nut
     real nut_k = a_nut 
     + b_nut_sst * sst[n]
     + b_nut_current * do_current[k]
     + b_nut_precip * precip[n];
     //nutrients -> seaweed
     real seaweed_k = a_seaweed 
     + b_seaweed_sst * sst[n]
     + b_seaweed_nut * nut_k
     + b_seaweed_daylight * daylight[n];
     //nutrients -> phyto 
     real phyto_k = a_phyto 
     + b_phyto_sal * salinity[n]
     + b_phyto_nut * nut_k
     + b_phyto_daylight * daylight[n];
     //current/phyto -> cyphonautes
     real cyph_k = a_cyph 
     + b_cyph_phyto * phyto_k
     + b_cyph_predzoo * pred_zoo[n]
     + b_cyph_current * do_current[k];
     
     real p_occ = inv_logit(
       alpha_zi
       + b_zi_seaweed * seaweed_k
       + b_zi_phyto * phyto_k
       + b_zi_cyph * cyph_k
       + re);
       
       real mu = fmax(eps, fmin(1- eps, inv_logit(
         alpha_bf 
         + b_bf_seaweed * seaweed_k
         + b_bf_phyto * phyto_k
         + b_bf_cyph * cyph_k
         + re)));
         
         acc += p_occ * mu;
   }
     Ey_do_current[k] = acc/N;
     }
     
     //daylight
     
     {
       real acc = 0;
       for (n in 1:N) {
         real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
         
         // daylight -> air temp -> sst -> nutrients
         real airtemp_k = a_airtemp + b_airtemp_daylight * do_daylight[k];
         real sst_k = a_sst + b_sst_airtemp * airtemp_k;
         real nut_k = a_nut
         + b_nut_sst * sst_k
         + b_nut_current * current[n]
         + b_nut_precip * precip[n];
         
         // daylight -> seaweed (direct and via sst/nutrients)
         real seaweed_k = a_seaweed
         + b_seaweed_sst * sst_k
         + b_seaweed_nut * nut_k
         + b_seaweed_daylight * do_daylight[k];
         
         // daylight -> phytoplankton (direct and via nutrients)
         real phyto_k = a_phyto
         + b_phyto_sal * salinity[n]
         + b_phyto_nut * nut_k
         + b_phyto_daylight * do_daylight[k];
         
         // phyto -> cyphonautes
         real cyph_k = a_cyph
         + b_cyph_phyto * phyto_k
         + b_cyph_predzoo * pred_zoo[n]
         + b_cyph_current * current[n];
         
         real p_occ = inv_logit(alpha_zi 
         + b_zi_seaweed * seaweed_k
         + b_zi_phyto * phyto_k
         + b_zi_cyph * cyph_k
         + re);
         
         real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf
         + b_bf_seaweed * seaweed_k
         + b_bf_phyto * phyto_k
         + b_bf_cyph * cyph_k
         + re)));
         
         acc += p_occ * mu;
       }
       Ey_do_daylight[k] = acc/N;
       }
       
       //Precipitation
       {
         real acc = 0;
         for (n in 1:N) {
           real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
           
           //precipitation -> salinity
           real sal_k = a_sal 
           + b_sal_precip * do_precip[k];
           
           //precipitation -> nutrients 
           real nut_k = a_nut
           + b_nut_sst * sst[n]
           + b_nut_current * current[n]
           + b_nut_precip * do_precip[k];
          
          //nutrients -> seaweed 
          real seaweed_k = a_seaweed 
          + b_seaweed_sst * sst[n]
          + b_seaweed_nut * nut_k
          + b_seaweed_daylight * daylight[n];
          
          //salinity + nutrients -> phytoplankton
          real phyto_k = a_phyto 
          + b_phyto_sal * sal_k
          + b_phyto_nut * nut_k
          + b_phyto_daylight * daylight[n];
          
          //phytoplankton -> cyphonautes 
          real cyph_k = a_cyph 
          + b_cyph_phyto * phyto_k
          + b_cyph_predzoo * pred_zoo[n]
          + b_cyph_current * current[n];
          
          real p_occ = inv_logit(alpha_zi
          + b_zi_seaweed * seaweed_k
          + b_zi_phyto * phyto_k
          + b_zi_cyph * cyph_k + 
          re);
          
          real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf 
          + b_bf_seaweed * seaweed_k
          + b_bf_phyto * phyto_k
          + b_bf_cyph * cyph_k
          + re)));
          
          acc += p_occ * mu;
         }
         Ey_do_precip[k] = acc/N;
         }
         
         //Predatory zooplankton
         
         { real acc = 0;
         for (n in 1:N) {
           real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
           
           //predatory zooplankton -> cyphonautes
           real cyph_k = a_cyph
          + b_cyph_phyto * phyto[n] +
          b_cyph_predzoo * do_predzoo[k]
          + b_cyph_current * current[n];
          
          real p_occ = inv_logit(alpha_zi 
          + b_zi_seaweed * seaweed[n]
          + b_zi_phyto * phyto[n]
          + b_zi_cyph * cyph_k
          + re);
          
          real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf
          + b_bf_seaweed * seaweed[n]
          + b_bf_phyto * phyto[n]
          + b_bf_cyph * cyph_k
          + re)));
          
          acc += p_occ * mu;
          
         }
         Ey_do_predzoo[k] = acc/N;
         }
         
         //sst
         //lots of paths
         {
           real acc = 0;
           for (n in 1:N) {
             real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
             
             //sst -> nutrients
             real nut_k = a_nut
             + b_nut_sst * do_sst[k]
             + b_nut_current * current[n]
             + b_nut_precip * precip[n];
             
             //sst + nutrients -> seaweed
             real seaweed_k = a_seaweed
             + b_seaweed_sst * do_sst[k]
             + b_seaweed_nut * nut_k
             + b_seaweed_daylight * daylight[n];
             
             //nutreitns -> phyto
             real phyto_k = a_phyto 
             + b_phyto_sal * salinity[n] //no effect from sst
             + b_phyto_nut *  nut_k
             + b_phyto_daylight * daylight[n];
             
             //phyto -> cyphonautes
             real cyph_k = a_cyph
             + b_cyph_phyto * phyto_k
             + b_cyph_predzoo * pred_zoo[n]
             + b_cyph_current * current[n];
             
             real p_occ = inv_logit(alpha_zi
             + b_zi_seaweed * seaweed_k
             + b_zi_phyto * phyto_k
             + b_zi_cyph * cyph_k
             + re);
             
             real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf
             + b_bf_seaweed * seaweed_k 
             + b_bf_phyto * phyto_k
             + b_bf_cyph * cyph_k
             + re)));
             
             acc += p_occ * mu;
             }
             Ey_do_sst[k] = acc/N;
         }
         
         //Nutrients
         
         {
           real acc = 0;
           for (n in 1:N) {
             real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
             
             //nutrients -> seaweed
             real seaweed_k = a_seaweed
             + b_seaweed_sst * sst[n]
             + b_seaweed_nut * do_nutrients[k]
             + b_seaweed_daylight * daylight[n];
             
             //nutrients -> phytoplankton
             real phyto_k =  a_phyto
             + b_phyto_sal * salinity[n]
             + b_phyto_nut * do_nutrients[k]
             + b_phyto_daylight * daylight[n];
             
             //phytoplankton -> cyphonautes
             real cyph_k = a_cyph 
             + b_cyph_phyto * phyto_k
             + b_cyph_predzoo * pred_zoo[n]
             + b_cyph_current * current[n];
             
             real p_occ = inv_logit(alpha_zi 
             + b_zi_seaweed * seaweed_k
             + b_zi_phyto * phyto_k
             + b_zi_cyph * cyph_k
             + re);
             
             real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf
             + b_bf_seaweed * seaweed_k
             + b_bf_phyto * phyto_k
             + b_bf_cyph * cyph_k
             + re)));
             
             acc += p_occ * mu;
           }
           Ey_do_nutrients[k] = acc/N;
         }
         
         //Seaweed growth
         {
           real acc = 0;
           for (n in 1:N) {
             real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
            //no downstream nodes connecting it to biofouling
            //# awesome
            
            real p_occ = inv_logit(alpha_zi
            + b_zi_seaweed * do_seaweed[k]
            + b_zi_phyto * phyto[n]
            + b_zi_cyph * cyphonautes[n]
            + re);
            
            real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf + 
            b_bf_seaweed * do_seaweed[k]
            + b_bf_phyto * phyto[n] 
            + b_bf_cyph * cyphonautes[n]
            + re)));
            
            acc += p_occ * mu;
            }
            Ey_do_seaweed[k] = acc/N;
         }

         //Phytoplankton
         //only one downstream variable
         { 
           real acc = 0;
           for(n in 1:N) {
             real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
             
             //phytoplankton -> cyphonautes
             real cyph_k = a_cyph 
             + b_cyph_phyto * do_phyto[k]
             + b_cyph_predzoo * pred_zoo[n]
             + b_cyph_current * current[n];
             
             real p_occ = inv_logit(alpha_zi
             + b_zi_seaweed * seaweed[n]
             + b_zi_phyto * do_phyto[k]
             + b_zi_cyph * cyph_k
             + re);
             
             real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf
             + b_bf_seaweed * seaweed[n]
             + b_bf_phyto * do_phyto[k]
             + b_bf_cyph * cyph_k
             + re)));
             
             acc += p_occ * mu;
           }
           Ey_do_phyto[k] = acc/N;
         }
         
         // salinity
         { 
           real acc = 0;
           for (n in 1:N) {
             real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
             
             //salinity -> phytoplankton
             real phyto_k = a_phyto
             + b_phyto_sal * do_salinity[k]
             + b_phyto_nut * nutrients[n]
             + b_phyto_daylight * daylight[n];
             
             //phyto -> cyphonautes
             real cyph_k = a_cyph
             + b_cyph_phyto * phyto_k
             + b_cyph_predzoo * pred_zoo[n]
             + b_cyph_current * current[n];
             
             //biofoulin
             real p_occ = inv_logit(alpha_zi
             + b_zi_seaweed * seaweed[n]
             + b_zi_phyto * phyto_k
             + b_zi_cyph * cyph_k
             + re);
             
             real mu = fmax(eps, fmin(1- eps, inv_logit(alpha_bf
             + b_bf_seaweed * seaweed[n] 
             + b_bf_phyto * phyto_k
             + b_bf_cyph * cyph_k
             + re)));
             
             acc += p_occ * mu;
             }
             Ey_do_salinity[k] = acc/N;
             
           }
           
           //Cyphonautes
           //no downstream
           {
             real acc = 0;
             for (n in 1:N) {
               real re = u_farm[farm_id[n]] + u_replicate[replicate_id[n]];
               real p_occ = inv_logit(alpha_zi
               + b_zi_seaweed * seaweed[n]
               + b_zi_phyto * phyto[n] 
               + b_zi_cyph * do_cypho[k]
               + re);
               
               real mu = fmax(eps, fmin(1 - eps, inv_logit(alpha_bf 
               +  b_bf_seaweed * seaweed[n]
               + b_bf_phyto * phyto[n]
               + b_bf_cyph * do_cypho[k] 
               + re)));
               
               acc += p_occ * mu;
             }
             Ey_do_cypho[k] = acc/N;
           }
         
         
       }// closes intervention section
       
   

  
} //block end
  





