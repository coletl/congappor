# This script requires a U.S. Census API key.
# You can register for one here: http://api.census.gov/data/key_signup.html.
# Add your personal API key to the environment with:
# Sys.setenv(CENSUS_KEY = your_api_key)
# readRenviron(".Renviron")


library(data.table)
library(censusapi)
library(readxl)
library(readr)

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
# Remove 1990, which we download separately
pop4 <- pop3[year != "1990"]
popl <- split(pop4, pop4$year)

# Download and clean 1990 apportionment population data ----
tmp <- tempfile(fileext = ".xls")
download.file("http://www2.census.gov/programs-surveys/decennial/1990/data/apportionment/taba.xls",
              tmp)
pop1990 <- read_excel(tmp, skip = 3)

# Clean
setDT(pop1990)
setnames(pop1990,
         c("state", "seats", "pop", "resident", "overseas"))
        # Remove US and NA rows
pop1990b <- pop1990[c(-1:-3, -55:-56),
                    ][ ,
                       `:=`(state = str_extract(state, "[[:alpha:] ]+"),
                            pop   = as.numeric(gsub("[^0-9]", "", pop)),
                            year  = "1990")
                       ][state != "District of Columbia" & !is.na(state)
                         ]
# Download and clean 2000 apportionment population data ----
pop2000 <- read_fwf("https://www.census.gov/population/www/cen2000/maps/files/tab01.txt",
                    col_positions = fwf_cols(state = 31, pop = 25, seats = 16, seats_change = 2),
                    skip = 6)
# Clean, remove unnecessary rows and column
setDT(pop2000)
pop2000[ ,
         names(pop2000) := lapply(.SD, str_trim)
         ]

pop2000b <- pop2000[c(-1:-2, -53:-68),
                    c("state", "pop", "seats")
                    ][ ,
                       c("pop", "year") := .(as.numeric(gsub(",", "", pop, fixed = TRUE)),
                                             "2000")
                       ]

# Download and clean 2010 apportionment population data ----
download.file("https://www.census.gov/population/apportionment/files/Apportionment%20Population%202010.xls",
              tmp)
pop2010 <- read_excel(tmp, skip = 8)[c(-1:-2, -53:-58),
                                     c(-3, -5)
                                     ]
setDT(pop2010)
setnames(pop2010,
         c("state", "pop", "seats", "seats_change"))
pop2010[ , year := "2010"]

popl[c("1990", "2000", "2010")] <-
  list(pop1990b, pop2000b, pop2010)

setattr(popl, "names",
        paste0("pop", names(popl)))

save_list(popl, ext = ".csv", dir = "data/pop")
