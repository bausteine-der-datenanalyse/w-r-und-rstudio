library(padr)
library(readxl)
library(tidyverse)
library(lubridate)

d_sum <- function(ti) {
  d_all |>
    group_by(Datum = floor_date(Datum, paste(ti, "minutes")), Fahrzeug) |>
    summarise(
      Anzahl = n(),
      VMit = mean(Geschwindigkeit),
      VMin = min(Geschwindigkeit),
      VMax = max(Geschwindigkeit)
    ) |>
    ungroup() |>
    group_by(Fahrzeug) |>
    pad()
}

d <- read_excel("data/unistrasse-2017.xlsx", sheet = "raw(T)", range = "B2:H20712")

d_all <- d |>
  filter(!is.na(Fahrzeug)) |>
  select(Datum, Geschwindigkeit, Abstand, Fahrzeug) |>
  mutate(
    Datum = dmy_hms(Datum)
  )
d_all

d_15m <- d_sum(15)
d_15m

d_60m <- d_sum(60)
d_60m

save(d_all, d_15m, d_60m, file="data/data-exercise.Rdata")