library(dplyr)
library(readr)
library(lubridate)


# Datei mit Stationsdaten einlesen
# - Datei mit festen Spaltenbreiten (ein ziemlicher Mist)

d_stat <-
  read_fwf(
    "daten/RR_Tageswerte_Beschreibung_Stationen.txt",
    col_positions = fwf_positions(
      start = c(1, 6, 15, 24, 39, 49, 61, 102, 143),
      end = c(5, 14, 23, 38, 48, 60, 101, 142, 147),
      col_names = c(
        "Stations_id", "von_datum", "bis_datum", "Stationshoehe",
        "geoBreite", "geoLaenge", "Station", "Bundesland", "Abgabe"
      )
    ),
    skip = 2,
    locale = locale(encoding = "ISO8859-1"),
    show_col_types = FALSE
  ) |>
  mutate(
    Stations_id = as.numeric(Stations_id),
    Station = case_match(
      Station,
      "Essen-Bredeney" ~ "Essen",
      "Berlin-Tempelhof" ~ "Berlin",
      "Hamburg (Stadtpark)" ~ "Hamburg",
      "Tübingen (Botanischer Garten)" ~ "Tübingen",
      .default = Station
    )
  ) |>
  st_as_sf(coords = c("geoLaenge", "geoBreite"), crs = "+proj=longlat") |>
  select(Station, Stations_id, geometry)


# Dateien mit den Niederschlagsdaten einlesen
# - CSV-Datei mit . als Dezimaltrenner und ; für die Einträge

read_one_file <- function(file) {
  read_delim(file, delim = ";", trim_ws = TRUE, show_col_types = FALSE) |>
    mutate(
      Datum = ymd(MESS_DATUM),
      Monat = month(Datum, label = TRUE),
      Jahr = year(Datum),
      Niederschlag = na_if(as.numeric(RS), -999)
    ) |>
    left_join(d_stat, by = join_by(STATIONS_ID == Stations_id)) |>
    select(Station, Datum, Monat, Jahr, Niederschlag)
}

d_ns <- list.files(
  path = "daten", pattern = "produkt_nieder_tag_.*txt", full.names = TRUE
) |>
  map(read_one_file) |>
  bind_rows()
