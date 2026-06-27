
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