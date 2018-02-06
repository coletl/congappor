# congappor: Calculate U.S. Congressional Apportionment in R

The Constitution of the United States requires that seats in the House of Representatives be reapportioned decennially 
to align with population figures from the U.S. Census Bureau.

The current process of allocating seats to states uses the
[method of equal proportions](https://www.census.gov/population/apportionment/about/computing.html): after every state
is allotted one member of congress, priority values are calculated for the remaining 345 seats 
according to each state's population. Journalist Felicity Barringer analogizes the process:

> To understand how the priority numbers are awarded, it is easiest to imagine a cafeteria with 50 people in line. 
> Each gets at least one helping, then comes back for more. 
>
> As the diners come back again and again, the entry door begins to slide closed. 
> The formula favors heavier diners in the early rounds and leaner ones in the later rounds. 
> In the early rounds, it is easy for the more populous states to push to the front of the line for seconds and thirds; 
> in the later rounds, they have trouble squeezing through the narrowing entry, and the less populous states can slip in ahead.

This small package is meant to assist in calculating the apportionment of seats given states' population values. To install it:

    # install.packages("devtools")
    devtools::install_github("coletl/congappor")
