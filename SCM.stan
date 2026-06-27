

data {
  //Random effects
  int<lower=1> N;
  int<lower=1> J_replicate;
  array[N] int<lower=1, upper=J_farm> farm_id;
  array[N] int<lower=1, upper=J_replicate> replicate_id;
  
  //Response = biofouling
  vector<lower=0, upper = 1>[N] biofouling;
  
  
}