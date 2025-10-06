# Daten aus Marktstammdatenregister von SQLite-Datenbank einlesen und
# als Dataframe speichern.
#
# Siehe 
# - https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html
# - https://rdrr.io/cran/DBI/

library(DBI)

db <- dbConnect(RSQLite::SQLite(), "~/.open-MaStR/data/sqlite/open-mastr.db")
dbListTables(db)
d_wind <- dbGetQuery(db, 'SELECT * FROM wind_extended')
d_nuklear <- dbGetQuery(db, 'SELECT * FROM nuclear_extended')
save(d_wind, d_nuklear, file="daten/mastr-data.RData")
dbDisconnect(db)
