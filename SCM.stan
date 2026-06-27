
//data section. Will go as:
//random effects
//response
//exposures - 
//start w/ parent nodes (climate)
//go into middle nodes (physical)
data {
  //Random effects
  int<lower=1> N;
  int<lower=1> J_replicate;
  array[N] int<lower=1, upper=J_farm> farm_id;
  array[N] int<lower=1, upper=J_replicate> replicate_id;
  
  //Response = biofouling
  vector<lower=0, upper = 1>[N] biofouling;
  
  //Exposure nodes
  //starting with nodes w/o parents
  //root nodes
  
  //structure 
  //number of observed vals 
  //number of missing vals
  //obs index
  //miss index
  //observed values
  //imputation of mean
  //imputation of sd
  //same for all root nodes
  
  //Air temperature
  int<lower=0> N_airtemp_obs;
  int<lower=0> N_airtemp_miss;
  array[N_airtemp_obs] int airtemp_obs_idx;
  array[N_airtemp_miss] int airtemp_miss_idx;
  vector[N_airtemp_obs] airtemp_obs;
  real imp_airtemp_mean;
  real <lower=0> imp_airtemp_sd;
  
  //Daylight
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
  real <lower=0> imp_current_sd;
  
  //Predatory Zooplankton
  int<lower=0> N_predzoo_obs;
  int<lower> N_predzoo_miss;
  array[N_predzoo_obs] int precip_obs_idx;
  array[N_predzoo_miss] int precip_miss_idx;
  vector[N_predzoo_obs] predzoo_obs;
  real imp_predzoo_mean;
  real<lower=0> imp_predzoo_sd;
  
  //non-root nodes
  
  //structure same as root nodes w/o impute lines
  
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
  
  
  
  
  
  
}

//imputation section

//model structures

//random effects

//transformed params

//priors

//structural equations?

//posteriors

//gcomp - will need to do one gcomp section per node
//will follow same format so not too difficult