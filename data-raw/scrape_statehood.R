library(dplyr)
library(data.table)
library(stringr)

statehood <- readLines("https://www.50states.com/statehood.htm")

state <- str_extract(statehood,
                     "(?<=<td><b>)[A-Z a-z]+(?=</b></td>)") %>%
  .[!is.na(.)]
date <- str_extract(statehood,
                    "(?<=<td>)[[:alnum:] .,]+(?=<br>[[:alnum:]<> ]+</td>)")  %>%
  .[!is.na(.)] %>% str_trim() %>% gsub(".", "", x = ., fixed = TRUE) %>%
  gsub("Sept", "Sep", x = ., fixed = TRUE)

statehood <- data.table(state,
                        date = as.Date(date, "%b %d, %Y"))

devtools::use_data(statehood)
devtools::use_data(statehood, internal = TRUE)
