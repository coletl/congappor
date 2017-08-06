library(pdftools)
library(readr)
library(data.table)

txt <- pdf_text("https://www.census.gov/content/dam/Census/library/publications/2011/dec/c2010br-08.pdf")
tbl <- read_lines(txt[grep("^Table 1", txt)])
header <- tbl[1:8]
tbl2 <- tbl[13:62]
tbl3 <- gsub("[ .]{2,}", ";", tbl2)
tbl4 <- gsub(",", "", tbl3)
tbl5 <-
  read_csv2(paste(tbl4, collapse = "\n"),
            col_names = c("state", "total_pop", "res_pop", "overseas_pop",
                          paste("census", seq(2010, 1910, -10), sep = "_")
                          ),
            na = "(X)"
            )
tbl6 <- tbl5[ , c("state", paste("census", seq(2010, 1910, -10), sep = "_"))]
setDT(tbl6)

tbl7 <- melt(tbl6, id.vars = "state",
             value = "congr_seats",
             variable.name = "census_year")
tbl7[ , census_year := gsub("[^0-9]", "", census_year)]

seats10 <- tbl7
use_data(seats10)
