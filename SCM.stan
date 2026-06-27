
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
  
  
  
  
  
}

//Intervention grid
//on grid per node (besides biofouling)

//imputation section

//model structures

//random effects

//transformed params

//priors

//structural equations?

//posteriors

//gcomp - will need to do one gcomp section per node
//will follow same format so not too difficult