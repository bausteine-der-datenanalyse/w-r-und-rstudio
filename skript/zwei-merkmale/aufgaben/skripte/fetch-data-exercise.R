library(readxl)
library(lubridate)
library(tidyverse)
Sys.setlocale("LC_ALL", "de_DE")

rm(list = ls())

load("data-raw/wea-red.Rdata")

d_wea_min <- d_wea_min |> select(datum, zeit, v_wind, drehzahl, leistung, B6_y, w5)

save(
  d_wea_min,
  file="data/data-exercise.Rdata"
)
