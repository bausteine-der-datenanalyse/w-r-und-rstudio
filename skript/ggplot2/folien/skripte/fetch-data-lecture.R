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
  filter(year == 2012) |>
  drop_na()


#
# Speichern und Aufräumen
#
save(
  d_wb_all, d_wb_2012,
  file="data/data-lecture.Rdata"
)
file.remove("data/class.xls")

