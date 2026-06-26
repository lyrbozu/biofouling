#All adjustment sets for total/direct effects
adj_registry <- list(
  
  # SEAWEED GROWTH
  list(exposure = "seaweed_growth", estimand = "total",
       adj_vars = c("current", "daylight", "nutrients", "precipitation")),
  list(exposure = "seaweed_growth", estimand = "direct",
       adj_vars = c("current", "daylight", "nutrients", "precipitation")),
  
  # AIR TEMPERATURE
  list(exposure = "air_temp", estimand = "total",
       adj_vars = NULL),
  list(exposure = "air_temp", estimand = "direct",
       adj_vars = c("current", "daylight", "nutrients",
                    "precipitation", "seaweed_growth")),
  
  # SST
  list(exposure = "sst", estimand = "total",
       adj_vars = NULL,
       priors = list(
         b_exposure = "normal(0.5,0.5)", 
         b_exposure_zi = "normal(0.3,0.5)"
       )), 
  list(exposure = "sst", estimand = "direct",
       adj_vars = c("current", "daylight", "nutrients",
                    "precipitation", "seaweed_growth"),
       priors = list(
         b_exposure = "normal(0.5,0.5)", 
         b_exposure_zi = "normal(0.3,0.5)"
       )),
  
  # CURRENT
  list(exposure = "current", estimand = "total",
       adj_vars = NULL),
  list(exposure = "current", estimand = "direct",
       adj_vars = c("seaweed_growth", "cyphonautes", "phyto")),
  
  # NUTRIENTS
  list(exposure = "nutrients", estimand = "total",
       adj_vars = c("current", "precipitation", "sst")),
  list(exposure = "nutrients", estimand = "direct",
       adj_vars = c("current", "seaweed_growth", "phyto")),
  
  # DAYLIGHT HOURS
  list(exposure = "daylight", estimand = "total",
       adj_vars = NULL,
       priors = list(
         b_exposure    = "normal(0.5, 0.3)",
         b_exposure_zi = "normal(0.3, 0.3)"
       )),
  list(exposure = "daylight", estimand = "direct",
       adj_vars = c("current", "seaweed_growth", "phyto"),
       priors = list(
         b_exposure    = "normal(0.5, 0.3)",
         b_exposure_zi = "normal(0.3, 0.3)"
       )),
  
  # SALINITY
  list(exposure = "salinity", estimand = "total",
       adj_vars = "precipitation"),
  list(exposure = "salinity", estimand = "direct",
       adj_vars = c("current", "phyto", "seaweed_growth")),
  
  # PHYTOPLANKTON ABUNDANCE
  list(exposure = "phyto", estimand = "total",
       adj_vars = c("seaweed_growth", "current")),
  list(exposure = "phyto", estimand = "direct",
       adj_vars = c("seaweed_growth", "cyphonautes")),
  
  # PREDATORY ZOOPLANKTON
  list(exposure = "pred_zoo", estimand = "total",
       adj_vars = NULL),
  list(exposure = "pred_zoo", estimand = "direct",
       adj_vars = c("phyto", "seaweed_growth", "cyphonautes")),
  
  # PRECIPITATION
  list(exposure = "precipitation", estimand = "total",
       adj_vars = NULL),
  list(exposure = "precipitation", estimand = "direct",
       adj_vars = c("seaweed_growth", "current", "phyto")),
  
  # CYPHONAUTES
  list(exposure = "cyphonautes", estimand = "total",
       adj_vars = c("current", "phyto")),
  list(exposure = "cyphonautes", estimand = "direct",
       adj_vars = c("current", "phyto"))
)