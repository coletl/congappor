#' @import data.table

apportion <-
  function(pop_data,
           total_seats = 435, # Total number of voting seats in the hypothetical congress. This number was fixed at the default (435) in 1911.
           apportion_year = NULL, # Year of apportionment to simulate, affects only number of states in the union. Overrides `states` parameter.
           # Currently, `apportion()` supports only the method of equal proportions, used only since 1940.
           states = 50, # Number of states.
           DC_seats = FALSE, # Whether DC should be eligible for voting seats in congress.
           PR_seats = FALSE, # Whether Puerto Rico should be eligible for voting seats in congress.
           min_seats = 1, # Minimum (starting) number of seats per state.,
           store_priority = FALSE, # Store, as a data.table named "priority_scores" in the enclosing environment, priority scores calculated for each seat.
           store_seat_order = FALSE # Store, as a character vector named "seat_order" in the enclosing environment, state names in the order that seats were allocated.
           ){
    # Equation from: https://www.census.gov/population/apportionment/about/computing.html

    if(!is.data.table(pop_data)) setDT(pop_data)

    if(! DC_seats) pop_data <- pop_data[state != "District of Columbia"]
    if(! PR_seats) pop_data <- pop_data[state != "Puerto Rico"]

    if(!is.null(apportion_year) || states != 50) {
      data("statehood")
      apportion_jan <- as.Date(paste(apportion_year, "01", "01", sep = "-"))

      valid_states <- statehood[date < apportion_jan]
    } else {
      valid_states <- pop_data
      }

    rem_seats <- total_seats - min_seats * (nrow(valid_states) + DC_seats + PR_seats)

    # Compute multipliers
    # n = number of seats, if the state were to gain a seat (seats + 1)
    n <- (1:total_seats)[1:rem_seats]
    mult <- 1/sqrt(n * (n - 1))

    # Fill seats
    pop_data[ ,
              seats := ifelse(state %in% valid_states$state, 1, NA)
              ]
    priority <- as.list(rep(NA_real_, rem_seats))
    max_priority <- numeric()
    state <- character()

    for(seat in 1:rem_seats) {
      priority[[seat]] <- pop_data$pop * mult[ pop_data$seats + 1 ]
      max_priority[seat] <- max(priority[[seat]])

      which_state <- which.max(priority[[seat]])
      state[[seat]] <- pop_data$state[which_state]

      pop_data[
        which_state,
        seats := seats + 1
        ]
    }

    out <- pop_data[ , .(state, seats)]

    if(store_priority) {
      priority_scores <<- data.table(state = pop_data$state,
                                     do.call(cbind, priority))
      setnames(priority_scores,
               c("state", paste0("priority", 1:length(priority)))
               )
    }

    if(store_seat_order) {
      seat_order <<- state
    }

    return(out)
  }
