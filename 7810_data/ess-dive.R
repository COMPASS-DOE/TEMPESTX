# Prep processed data for ESS-DIVE submission, following reporting formats
# BBL September 2024
# Run this AFTER process_7810.R

if(basename(getwd()) != "7810_data") stop("Set working directory to 7810_data")

library(readr)
library(tidyr)
library(dplyr)

FLMD_OUTPUT_FILE <- "ess-dive/flmd.csv"
if(file.exists(FLMD_OUTPUT_FILE)) file.remove(FLMD_OUTPUT_FILE)

# Read in flux data and reformat following soil respiration reporting format
# https://github.com/ess-dive-community/essdive-soil-respiration/blob/main/instructions.md
message("Processing flux data...")
all_data <- list()
files <- list.files("fluxes/", pattern = "csv$", full.names = TRUE)
for(f in files) {
  message("\t", f)
  x <- read_csv(f)
  
  x %>% 
    # make ESS-DIVE formatted timestamps; replace missing data with -9999
    mutate(Timestamp_Begin = format(TIMESTAMP, "%Y%m%d%H%M"), # YYYYMMDDHHMM
           Timestamp_End = format(TIMESTAMP + 60, "%Y%m%d%H%M",), 
           CrvFit_CO2 = "Exp",
           CrvFit_CH4 = "Exp",
           co2_F_o = if_else(co2_F_o != 0, co2_F_o, -9999),
           co2_C_o = if_else(co2_C_o != 0, co2_C_o, -9999),
           ch4_F_o = if_else(ch4_F_o != 0, ch4_F_o, -9999),
           ch4_C_o = if_else(ch4_C_o != 0, ch4_C_o, -9999),
           soilp_t = if_else(soilp_t != 0, soilp_t, -9999),
           soilp_m = if_else(soilp_m != 0, soilp_m, -9999),
           soilp_c = if_else(soilp_c != 0, soilp_c, -9999)) %>% 
    # field names follow the soil respiration reporting format
    select(Chamber_ID = label, 
           Timestamp_Begin, 
           Timestamp_End, 
           Flux_CO2 = co2_F_o, 
           Dry_CO2 = co2_C_o,
           Flux_SE_CO2 = co2_ses,
           CrvFit_CO2,
           R2_CO2 = co2_r2,
           CV_CO2 = co2_F_cv,
           
           Tair_Amb = chamber_t,
           T5 = soilp_t,
           SM5 = soilp_m,
           EC5 = soilp_c,
           
           FLux_CH4 = ch4_F_o,
           Dry_CH4 = ch4_C_o,
           Flux_SE_CH4 = ch4_ses,
           CrvFit_CH4,
           R2_CH4 = ch4_r2,
           CV_CH4 = ch4_F_cv) ->
    all_data[[f]]
}

message("Writing all data...")
all_data <- dplyr::bind_rows(all_data)

write_csv(all_data, file.path("ess-dive", "fluxes.csv"))
first_ts <- sort(all_data$Timestamp_Begin)[1]
last_ts <- sort(all_data$Timestamp_End, decreasing = TRUE)[1]

# Include raw concentration data
message("Zipping concentration data...")
files <- list.files("concentrations//", full.names = TRUE)
utils::zip(file.path("ess-dive", "concentrations.zip"), files = files)

# Construct file-level metadata
# https://github.com/ess-dive-community/essdive-file-level-metadata/blob/main/flmd_instructions.md
message("Building FLMD...")
files <- list.files("./ess-dive/", full.names = TRUE, recursive = TRUE)

flmd <- tibble(File_Name = basename(files),  
               File_Path = gsub("^\\./ess-dive[/]*", "", dirname(files)),
               File_Description = "",
               Standard = "",
               UTC_Offset = "",
               Date_Start = "",
               Date_End = "")

fluxes <- grep("fluxes", files)
stopifnot(length(fluxes) > 0)
flmd$File_Description[fluxes] <- "Computed greenhouse gas fluxes"
flmd$Standard[fluxes] <- "Soil respiration"
flmd$Date_Start[fluxes] <- substr(first_ts, 1, 8)
flmd$Date_End[fluxes] <- substr(last_ts, 1, 8)
flmd$UTC_Offset[fluxes] <- "-5"

concs <- grep("concentrations.zip", files, fixed = TRUE)
stopifnot(length(concs) > 0)
flmd$File_Description[concs] <- "Measured gas concentration data"
flmd$UTC_Offset[concs] <- "-5"
flmd$Date_Start[concs] <- substr(first_ts, 1, 8)
flmd$Date_End[concs] <- substr(last_ts, 1, 8)

md <- grep("collar_metadata", files)
stopifnot(length(md) == 1)
flmd$File_Description[md] <- "Soil respiration collar metadata"

cmd <- grep("concentrations_metadata", files)
stopifnot(length(cmd) == 1)
flmd$File_Description[cmd] <- "Gas concentration metadata"

rdme <- grep("README", files)
stopifnot(length(rdme) == 1)
flmd$File_Description[rdme] <- "README file"
flmd$Standard[rdme] <- "Markdown"

write_csv(flmd, file = FLMD_OUTPUT_FILE, na = "")

message("All done!")
