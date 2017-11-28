rm(list = ls())
gc()

# Cole Tanigawa-Lau
# Wed Aug  9 10:30:33 2017
# Description: Download census population data.

# This script requires a U.S. Census API key.
# You can register for one here: http://api.census.gov/data/key_signup.html.
# Add your personal API key to the environment with:
# Sys.setenv(CENSUS_KEY = your_api_key)
# readRenviron(".Renviron")

library(data.table)
library(censusapi)

source("data-raw/functions.R")

pop <- fread("https://www.census.gov/population/www/censusdata/Population_PartII.txt",
             na.strings = "---")
# Remove unnecessary rows and columns
pop2 <- pop[-1:-8,
            -23:-24
            ][-52:-53]
setnames(pop2,
         c("state",
           seq(1990, 1790, -10),
           "fips")
)
# Remove commas from population figures
pop2[ ,
      (as.character(
        seq(1990, 1790, -10
        ))
      ) := lapply(.SD, function(x) as.numeric(gsub(",", "", x))),
      .SDcols = as.character(seq(1990, 1790, -10))
      ]
pop3 <- melt(pop2, id.vars = c("state", "fips"), variable.name = "year", value.name = "pop")
popl <- split(pop3, pop3$year)

pop2000 <- getCensus(name = "sf1", vintage = 2000, vars = "P001001", region = "state")
setDT(pop2000)
setnames(pop2000, c("fips", "pop"))

pop2000[ , year := 2000]
popl$`2000` <- pop2000[popl[[1]], state := state, on = "fips"]

pop2010 <- getCensus(name = "sf1", vintage = 2010, vars = "P0010001", region = "state")
setDT(pop2010)
setnames(pop2010, c("fips", "pop"))

pop2010[ , year := 2010]
# Remove Puerto Rico
popl$`2010` <- pop2010[popl[[1]], state := state, on = "fips"]
popl$`2010` <- popl$`2010`[fips != "72"]

setattr(popl, "names",
        paste0("pop", names(popl)))

save_list(popl, ext = ".csv", dir = "data/pop/")