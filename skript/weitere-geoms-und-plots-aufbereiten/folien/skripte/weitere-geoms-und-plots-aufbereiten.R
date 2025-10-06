library(readxl)
library(wbstats)
library(tidyverse)

# Alles löschen
rm(list = ls())

# Datenssätze heraussuchen
wbsearch(pattern = "total population")
wbsearch(pattern = "greenhouse")
wbsearch(pattern = "GDP")
# https://datahelpdesk.worldbank.org/knowledgebase/articles/906519

#
# Datensätze herunterladen
#

# Bevölkerung
pop <- as.tibble(wb(indicator = "SP.POP.TOTL"))
pop

# Treibhausgasemissionen
gge <- as.tibble(wb(indicator = "EN.ATM.GHGT.KT.CE"))
gge

# Bruttosozialprodukt
gdp <- as.tibble(wb(indicator = "NY.GDP.MKTP.CD"))
gdp

# Klassifizierung
download.file("http://databank.worldbank.org/data/download/site-content/CLASS.xls", "data/class.xls")
cls <- read_xls("data/class.xls", sheet = "List of economies", range = "A5:G224") |>
  filter(Economy != "x")
cls

#
# Datensätze filtern und umbenennen
#
# 1. Aggregierte Daten herausfiltern
#
# 2. Bezeichnungen und Spaltentitel
#      pop - Bevölkerung
#      gge - Treibhausgasemissionen (kt CO2 äquivalent)
#      gdp - BIP ($)
#   region - Region
#       ig - Einkommensgruppe (aktuelle Klassifizierung)
#
countries <- cls$Economy
countries

# Bevölkerung
popf <- pop |> 
  filter(country %in% countries) |>
  select(year = date, country, pop = value)
summary(popf)

# Treibhausgasemissionen
ggef <- gge |>
  filter(country %in% countries) |>
  select(year = date, country, gge = value)
summary(ggef)

# Bruttoinlandsprodukt
gdpf <- gdp |>
  filter(country %in% countries) |>
  select(year = date, country, gdp = value)
summary(gdpf)

# Klassifizierung
unique(cls$`Income group`)
clsf <- cls |>
  select(country = Economy, region = Region, ig = `Income group`)
summary(clsf)

#
# Daten kombinieren
#
d_wb_all <- popf |>
  left_join(ggef, by = c("year", "country")) |>
  left_join(gdpf, by = c("year", "country")) |>
  left_join(clsf, by = "country") |>
  mutate(
    year = as.integer(year),
    ig = factor(ig, levels = c("Low income", "Lower middle income", "Upper middle income", "High income"))
  ) |>
  arrange(country, year)
d_wb_all

#
# Weitere Datensätze
#

# Jahr 2012
d_wb_2012 <- d_wb_all |>
  filter(year == 2012)
d_wb_2012

# Ausgewählte Länder
d_wb_countries <- d_wb_all |>
  filter(country %in% c("Germany", "Vietnam", "India", "China", "Portugal", "Switzerland", "United States", "Maledives", "Russian Federation"))
d_wb_countries

# Ausgewählte Länder im Jahr 2012
d_wb_countries_2012 <- d_wb_countries |>
  filter(year == 2012)
d_wb_countries_2012

# Regionen
d_wb_regions <- d_wb_all |>
  drop_na() |>
  group_by(region, year) |>
  summarize(
    gdp = sum(gdp),
    pop = sum(pop), 
    gge = sum(gge)
  )

#
# Niederschlagsdaten für Bochum
#

# Herunterladen
download.file(
  "ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/daily/more_precip/historical/tageswerte_RR_00055_19510101_20171231_hist.zip",
  destfile = "data/niederschlag.zip"
)

# Auspacken
unzip(
  "data/niederschlag.zip", 
  files = "produkt_nieder_tag_19510101_20171231_00055.txt",
  exdir = "data"
)

# Tageswerte einlesen
d_ns_bochum_tag <- read.csv(
    "data/produkt_nieder_tag_19510101_20171231_00055.txt", 
    sep = ";", dec = "."
  ) |>
  select(MESS_DATUM, RS) |>
  mutate(
    Datum = ymd(MESS_DATUM),
    Jahr = as.integer(year(Datum)),
    Monat = month(Datum, label = TRUE, locale = "DE_de"),
    NS = replace(RS, RS == -999, NA)
  ) |>
  as.tibble()
d_ns_bochum_tag

# Monatswerte summieren
d_ns_bochum_monat <- d_ns_bochum_tag |>
  group_by(Jahr, Monat) |>
  summarise(NS = sum(NS))

#
# Speichern und Aufräumen
#
save(
  d_wb_all, d_wb_2012, d_wb_countries, d_wb_countries_2012, d_wb_regions, 
  d_ns_bochum_tag, d_ns_bochum_monat, 
  file="data/data-lecture.Rdata"
)
file.remove("data/class.xls")
file.remove("data/niederschlag.zip")
file.remove("data/produkt_nieder_tag_19510101_20171231_00055.txt")

