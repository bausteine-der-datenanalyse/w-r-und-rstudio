library(tidyverse)

rm(list = ls())

load(file="data/old/data-lecture.Rdata")

d_ns_bochum_tag <- ungroup(d_ns_bochum_tag)
d_ns_bochum_monat <- ungroup(d_ns_bochum_monat)

save(
  d_wb_all, d_wb_2012, d_wb_countries, d_wb_countries_2012, d_wb_regions, 
  d_ns_bochum_tag, d_ns_bochum_monat, 
  file="data/data-lecture.Rdata"
)
