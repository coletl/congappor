#' Calculate U.S. congressional apportionment.
#'
#' \code{apportion()} simulates U.S. congressional apportionment with a state-level
#' population data set you provide.
#'
#' Currently, \code{apportion()} can implement only the
#' \link{https://www.census.gov/population/apportionment/about/computing.html}{method of equal proportions}.
#' This method has been used since 1941. Support for obsolete methods may be added later.

#' @param   pop_data           A data frame of population values for each state. State names will be internally coerced to uppercase.
#' @param   total_seats        The total number of voting seats in the hypothetical congress. This number was fixed at the default (435) in 1911.
#' @param   apportion_year     A character string (or coercible) indicating the year of apportionment to simulate.
#'                               For now, this parameter affects only the number of states in the union, not the apportionment method,
#'                               so you're better off just supplying \code{pop_data} with population values for only the states in which you're interested.
#' @param   DC_seats           A logical indicating whether to allocate voting seats to Washington, D.C.
#' @param   PR_seats           A logical indicating whether to allocate voting seats to Puerto Rico.
#' @param   GU_seats           A logical indicating whether to allocate voting seats to Guam.
#' @param   min_seats          The minimum (starting) number of seats per state. The default is 1.
#' @param   store_priority     A logical indicating whether to store the priority scores calculated for each state-seat combination.
#'                               Scores are stored as a wide \code{data.table} object named \code{priority_scores} in the enclosing environment,
#' @param   store_seat_order   A logical indicating whether to store state names in the order that seats were allocated.
#'                               The seat order is stored as a character vector named \code{seat_order} in the enclosing environment.
#' @return A two-column \code{data.table} containing the name of each state and the number of seats allocated to it.
#'
#' @import data.table methods
#'
apportion <-
  function(pop_data,
           total_seats = 435,
           apportion_year = NULL,
           DC_seats = FALSE,
           PR_seats = FALSE,
           GU_seats = FALSE,
           min_seats = 1,
           store_priority = FALSE,
           store_seat_order = FALSE
           ){

    if(!require(data.table)) stop("apportion requires the data.table package.")
    if(!is.data.table(pop_data)) setDT(pop_data)

    pop_data[ ,
              state := toupper(state)
              ][ ,
                 state := gsub("[[:punct:]]", " ", state, perl = TRUE)
                 ]

    if(! DC_seats) pop_data <- pop_data[state != "DISTRICT OF COLUMBIA"]
    if(! PR_seats) pop_data <- pop_data[state != "PUERTO RICO"]
    if(! GU_seats) pop_data <- pop_data[state != "GUAM"]

    if(!is.null(apportion_year)) {
      data("statehood")
      apportion_jan <- as.Date(paste(apportion_year, "01", "01", sep = "-"))

      valid_states <- statehood[date < apportion_jan]
    } else {
      valid_states <- pop_data
    }

    valid_states[ ,
                  state := toupper(state)
                  ]

    rem_seats <- total_seats - min_seats * (nrow(valid_states) + DC_seats + PR_seats + GU_seats)

    # Compute multipliers
    # n = number of seats, if the state were to gain a seat (seats + 1)
    n <- 1:rem_seats
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
