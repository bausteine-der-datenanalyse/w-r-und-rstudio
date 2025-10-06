library(readxl)
library(tidyverse)

load_file <- function(year, range = NULL) {
  read_xlsx(
    paste0("data-raw/BefragungMVP", year, "_0.xlsx"),
    range = range
  ) |>
    select(
      geschlecht_id = V1_Ge,
      fachbereich_id = V2_FB,
      vm_heute_id = V3_VMheute,
      ort_id = V5_Ort,
      ort_ir = V51_OrtRuhr,
      ort_nir = V52_Ortaußer,
      zeit = V6_Zeit
    ) |>
    mutate(
      im_ruhrgebiet = ort_id != 9,
      jahr = year
    ) |>
    left_join(read_xlsx("data-raw/BefragungMVP_kodierung.xlsx", sheet = "geschlecht")) |>
    left_join(read_xlsx("data-raw/BefragungMVP_kodierung.xlsx", sheet = "fachbereich")) |>
    left_join(read_xlsx("data-raw/BefragungMVP_kodierung.xlsx", sheet = "vm_heute")) |>
    left_join(read_xlsx("data-raw/BefragungMVP_kodierung.xlsx", sheet = "ort")) |>
    mutate(
      ort = if_else(ort == "IR", ort_ir, ort),
      ort = if_else(ort == "NIR", ort_nir, ort),
      ort = recode(
        ort,
        "Wupperta" = "Wuppertal",
        "Remschei" = "Remscheid",
      )
    ) |>
    select(-ends_with("_id"), -ort_ir, -ort_nir, -im_ruhrgebiet) |>
    select(Jahr = jahr, Fachbereich = fachbereich, Geschlecht = geschlecht, Verkehrsmittel = vm_heute, Zeit = zeit)
}

d_bo_vm <- rbind(
  load_file(2017),
  load_file(2019, range = "A2:Q316")
) |>
  mutate(Jahr = factor(Jahr)) |>
  drop_na()

save(
  d_bo_vm,
  file="data/data-exercise.Rdata"
)
