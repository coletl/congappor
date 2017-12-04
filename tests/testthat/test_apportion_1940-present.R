rm(list = ls())
gc()

library(dplyr)
library(data.table)
library(stringr)
library(testthat)

data("seats10")

popl <- lapply(list.files("data/pop/", full = TRUE)[16:23],
               fread)
names(popl) <- gsub(".csv", repl = "", list.files("data/pop/")[16:23], fixed = TRUE)

apportion_test <- mapply(apportion,
                         pop_data = popl,
                         apportion_year = str_extract(names(popl), "[0-9]{4}"),
                         SIMPLIFY = FALSE)
apportion_test
apportionDT <- rbindlist(apportion_test,
                         idcol = "census_year")
apportionDT[ ,
             `:=`(census_year = gsub("pop", "", census_year, fixed = TRUE),
                  seats = as.integer(seats)
                  )
             ]
seats_official <- seats10[ , .(census_year, state, seats = congr_seats)]
seats_wrong <-
  fsetdiff(seats_official,
           apportionDT)[apportionDT,
                        sim_apportion := i.seats,
                        on = c("census_year", "state")
                        ][census_year %in% apportionDT$census_year]
expect_equal(nrow(seats_wrong), 0)
