library(tidyverse)

# Alles löschen
rm(list = ls())

# Load old files (from first year of lecture)
load(file = "daten-rohdaten/data-lebenserwartung.Rdata")
load(file = "daten-rohdaten/data-svrw.Rdata")
load(file = "daten-rohdaten/pisa.Rdata")

d_le_latest <- ungroup(d_le_latest)
d_pisa <- d_pisa |> select(country, math, read)

# Speichern
save(d_le_all, d_le_latest, d_svrw, d_pisa, file = "daten/zwei-merkmale-1.Rdata")
