# Read in raw LI-7810 data and produce concentration and flux CSV files
# BBL July 2024

if(basename(getwd()) != "7810_data") stop("Set working directory to 7810_data")


library(fluxfinder)
options(fluxfinder.quiet = TRUE)
library(readr)

files <- list.files("./raw/", pattern = "\\.json$", recursive = TRUE, full.names = TRUE)

problem_files <- 0
for(f in files) {
  message(f)
  outfn <- gsub("\\.json$", "", basename(f))
  
  tryCatch({
    x <- ffi_read_LIsmartchamber(f, concentrations = FALSE)
    write_csv(x, file.path("fluxes", paste0(outfn, "_fluxes.csv")))
    x <- ffi_read_LIsmartchamber(f, concentrations = TRUE)
    write_csv(x, file.path("concentrations", paste0(outfn, "_concentrations.csv")))
  },
    error = function(e) {
      message("\tHad a problem!")
      warning("Had a problem with ", f, ": ", e)
      problem_files <<- problem_files + 1
    })
}

if(problem_files > 0) {
  message("\n\n*** HAD A PROBLEM processing ", problem_files, " files!")
}

# Plot entire dataset
flux_files <- list.files("./fluxes/", pattern = "\\.csv$", full.names = TRUE)
fluxes <- lapply(flux_files, read_csv, show_col_types = FALSE)
fluxes_df <- do.call("rbind", fluxes)
fluxes_df <- fluxes_df[fluxes_df$co2_F_o > 0 & fluxes_df$co2_F_o < 100,]

library(ggplot2)
p <- ggplot(fluxes_df, aes(TIMESTAMP, co2_F_o, group = label)) + geom_line()
print(p)

