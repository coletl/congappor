% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/apportion.R
\name{apportion}
\alias{apportion}
\title{Calculate U.S. congressional apportionment.}
\usage{
apportion(pop_data, total_seats = 435, apportion_year = NULL,
  DC_seats = FALSE, PR_seats = FALSE, GU_seats = FALSE, min_seats = 1,
  store_priority = FALSE, store_seat_order = FALSE)
}
\arguments{
\item{pop_data}{A data frame of population values for each state. State names will be internally coerced to uppercase.}

\item{total_seats}{The total number of voting seats in the hypothetical congress. This number was fixed at the default (435) in 1911.}

\item{apportion_year}{A character string (or coercible) indicating the year of apportionment to simulate.
For now, this parameter affects only the number of states in the union, not the apportionment method,
so you're better off just supplying \code{pop_data} with population values for only the states in which you're interested.}

\item{DC_seats}{A logical indicating whether to allocate voting seats to Washington, D.C.}

\item{PR_seats}{A logical indicating whether to allocate voting seats to Puerto Rico.}

\item{GU_seats}{A logical indicating whether to allocate voting seats to Guam.}

\item{min_seats}{The minimum (starting) number of seats per state. The default is 1.}

\item{store_priority}{A logical indicating whether to store the priority scores calculated for each state-seat combination.
Scores are stored as a wide \code{data.table} object named \code{priority_scores} in the enclosing environment,}

\item{store_seat_order}{A logical indicating whether to store state names in the order that seats were allocated.
The seat order is stored as a character vector named \code{seat_order} in the enclosing environment.}
}
\value{
A two-column \code{data.table} containing the name of each state and the number of seats allocated to it.
}
\description{
\code{apportion()} simulates U.S. congressional apportionment with a state-level
population data set you provide.
}
\details{
Currently, \code{apportion()} can implement only the
\link{https://www.census.gov/population/apportionment/about/computing.html}{method of equal proportions}.
This method has been used since 1941. Support for obsolete methods may be added later.
}
