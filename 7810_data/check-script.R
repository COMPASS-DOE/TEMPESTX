# Quick check of the ESS-DIVE submission data: do all chamber IDs look OK?
# BBL November 2024
# Run this AFTER ess-dive.R

files <- list.files("ess-dive/", pattern = "_fluxes.csv$", full.names = TRUE)

library(dplyr)
library(readr)

results <- list()
for(f in files) {
  results[[f]] <- read_csv(f, col_types = "cdddddcdddddddddcdd")
  results[[f]]$File <- basename(f)
}

results <- bind_rows(results)

print(sort(unique(results$Chamber_ID)))

message("All done!")
