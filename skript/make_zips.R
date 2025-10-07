# Erzeuge ZIP-Dateien nach dem Rendern des Buches
zip_dir <- "_book/zips"
dir.create(zip_dir, recursive = TRUE, showWarnings = FALSE)

html_files <- list.files("_book/skript", pattern = "\\.html$", full.names = TRUE)

for (file in html_files) {
  base <- tools::file_path_sans_ext(basename(file))
  zipfile <- file.path(zip_dir, paste0(base, ".zip"))
  utils::zip(zipfile, file)
}

message("ZIP-Dateien erstellt in ", zip_dir)