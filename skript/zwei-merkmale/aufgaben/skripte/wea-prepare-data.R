library(plyr)
library(R.matlab)
library(lubridate)
library(tidyverse)
library(tidyquant)

# Tabelle mit Konvertierung
o <- -1
g <- 9.80665
conversion_table <- tribble(
       ~name, ~column,    ~a,   ~b,    ~c,
      "zeit",       1,     1,    1,     0, 
      "B1_x",       2, g/699, 1000,  o*29,
      "B1_y",       3, g/699, 1000,  o*24,
      "B1_z",       4, g/702, 1000,   o*1,
      "B2_x",       5, g/700, 1000,  o*32,
      "B2_y",       6, g/701, 1000,  o*23,
      "B2_z",       7, g/705, 1000,  o*18,
      "B3_x",       8, g/698, 1000,  o*18,
      "B3_y",      29, g/698, 1000,  -o*1,
      "B3_z",      10, g/700, 1000,  -o*9,
      "B4_x",      11, g/699, 1000, -o*10,
      "B4_y",      12, g/696, 1000,  o*12,
      "B4_z",      13, g/705, 1000,  o*13,
      "B5_x",      14, g/705, 1000,  o*23,
      "B5_y",      15, g/697, 1000,   o*9,
      "B5_z",      16, g/703, 1000,   o*3,
      "B6_x",      17, g/699, 1000,  o*17,
      "B6_y",      18, g/694, 1000,  o*31,
      "B6_z",      19, g/710, 1000,  o*29,
        "w1",      20,     1,    1,     0,
        "w2",      21,     1,    1,     0,
        "w3",      22,     1,    1,     0,
        "w4",      23,     1,    1,     0,
        "w5",      24,     1,    1,     0,
        "w6",      25,     1,    1,     0,
  "leistung",       9,     1,   80,     0,
    "v_wind",      30,     1,    4,     0,
  "drehzahl",      31,     1,    6,     0,
   "azimuth",      32,     1,  3.6,     0,
     "pitch",      33,     1,    8,    15
)

# Eine Spalte konvertieren
convert_column <- function(i, A) {
  c <- conversion_table[i,]
  c$a * (c$b * A[,c$column] + c$c)
}

# Ein mat-File einlesen und konvertieren
read_mat <- function (filename) {
  t0 <- filename |>
    str_sub(start = 9, end = 18) |>
    ymd_h() |>
    as.numeric()
  
  A <- readMat(paste0("data-raw/lwea/", filename))$B
  
  tmp <- map(1:nrow(conversion_table), convert_column, A)
  names(tmp) <- conversion_table[[1]]
  
  as_tibble(tmp) |>
    mutate(
      zeit = zeit + t0,
      datum = as_datetime(zeit)
    ) |>
    select(datum, zeit, everything())
}

# Alles einlesen
d_wea <- map(list.files("data-raw/lwea", "*.mat"), read_mat) |>
  ldply()



# Zusammenfassen
d_wea_sec <- d_wea |>
  tq_transmute(select = zeit:pitch, mutate_fun = to.period, period = "seconds")
d_wea_min <- d_wea |>
  tq_transmute(select = zeit:pitch, mutate_fun = to.period, period = "minutes")
d_wea_full_10min <- d_wea |>
  filter(datum >= ydm_hm("2010-07-06 12:40"), datum < ydm_hm("2010-07-06 12:50"))

# Sichern
save(d_wea, file = "data-raw/wea-full.Rdata")
save(d_wea_sec, d_wea_min, d_wea_full_10min, file = "data-raw/wea-red.Rdata")

