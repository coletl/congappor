rm(list = ls())
gc()

library(dplyr)
library(data.table)
library(readxl)
library(testthat)

data("seats10")
data(state)

states <- data.table(state_abb = state.abb,
                     state     = state.name)

pop2010 <- fread("data/pop/pop2010.csv")
true_pv <- read_excel("data-raw/PriorityValues2010.xls", skip = 7,
                      col_names = c("house_seat", "priority", "state", "state_seat"))
setDT(true_pv)

invisible(apportion(pop2010, store_priority = TRUE, total_seats = 440))

prio2 <- melt(priority_scores, id = "state", value = "priority")
prio2[states,
      state := i.state_abb,
      on = "state"
      ]
# Retain only the highest priority score in each round
prio3 <- prio2[order(priority)
               ][ ,
                  data.table::last(.SD),
                  by = variable
                  ]

# Census-provided data are rounded
expect_equivalent(prio3[ , .(state, round(priority))],
                  true_pv[ , .(state, priority)])
