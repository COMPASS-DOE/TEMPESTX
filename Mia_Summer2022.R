## Summer 2022 Data Analysis
## Author: Mia DiCianna

library(readr)
library(dplyr)
library(ggplot2)
theme_set(theme_bw())
library(lubridate)
library(tidyr)
library(scales)

## Step1: Read in data

files <- list.files("7810_data/Mia_Summer2022/",
                    pattern = "*.txt",
                    full.names = TRUE)

readfn <- function(x) {
  dat <- read_tsv(x, 
                  # note we're dropping "Item" and a junk column at the end
                  # this is done by skipping their names, and specifying "_" type below
                  col_names = c("Item", "Timestamp", "Collar", "Obs", 
                                "Flux_CO2", "Flux_CH4", "Soil_c", "Soil_m", "Soil_t", 
                                "Length", "R2_CO2", "R2_CH4", "err", "junk"), 
                  col_types = "cTcinnnnninnic",
                  na = c("", "NA", "9999"), # soil probe NA is 9999
                  skip = 1)
  
  # Some of the files output from SoilFluxPro are structurally different :(
  # with one or more missing columns. Record this
  dat %>% 
    mutate(file_structure_prob = nrow(problems(dat))) %>% 
    select(-Item, -junk)
}

lapply(files, readfn) %>% 
  bind_rows(.id = "File") %>% 
  mutate(File = as.integer(File)) %>% 
  filter(Flux_CO2 > 0)->
  dat
