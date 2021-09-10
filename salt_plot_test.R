# Boom!
# Read and plot 7810 data from Anya Hopple's TEMPEST exclusion plots
# BBL May 2020

library(readr)
library(dplyr)
library(ggplot2)
theme_set(theme_bw())
library(lubridate)
library(tidyr)
library(scales)

collars <- read_csv("design/collar_map.csv", col_types = "dcdci")

files <- list.files("7810_data/salt_test/", pattern = "*.txt", full.names = TRUE)

read_7810_data <- function(fn) {
  read_tsv(fn, col_names = c("Timestamp", "Obs", "Port",
                             "CO2", "Collar", "CH4"), 
           col_types = "_Tdcddd_",
           skip = 1) %>% 
    mutate(File = basename(fn))
}

lapply(files, read_7810_data) %>% 
  bind_rows() %>% 
  mutate(Round = as.integer(as.factor(File))) %>% 
  filter(CO2 != 0.0) %>% 
  left_join(collars, by = "Collar") %>% 
  pivot_longer(c(CO2, CH4), names_to = "Flux") ->
  dat

if(any(is.na(dat$Collar))) {
  warning("We have empty collars!")
}

# There's a -60 uptake for CH4 that's messing my graphs. Remove
dat <- filter(dat, Flux == "CO2" | value > -50)

dat %>% 
  filter(Plot != "Fresh") %>% 
  group_by(File, Round, Plot, Treatment, Flux) %>% 
  summarise(Timestamp = mean(Timestamp),
            value_sd = sd(value),
            value = mean(value)) ->
  dat_smry

for(gas in unique(dat_smry$Flux)) {
  ggplot(filter(dat_smry, Flux == gas), 
         aes(Timestamp, value, color = Plot, size = Plot)) + 
    geom_point() +
    geom_line() +
    scale_size_manual(values = c(0.5, 1.75)) +
    scale_color_manual(values = c("black", "blue")) +
    geom_errorbar(aes(ymin = value - value_sd, ymax = value + value_sd)) +
    facet_grid(Treatment~., scales = "free") +
    annotate("rect", xmin = ymd_hm("2021-09-09 07:00"),
             xmax = ymd_hm("2021-09-09 16:30"), 
             ymin = -Inf, ymax = Inf,
             fill = "lightblue", alpha = 0.3) +
#    coord_cartesian(xlim = c(ymd_hm("2021-08-24 12:00"), ymd_hm("2021-09-03 17:00"))) +
    ggtitle(gas)
  
  ggsave(paste0("salt_", gas, ".pdf"), width = 8, height = 5)
}



stop("All done")

# Code to process new 8250/7810/7820 data

trts <- tibble(Port = 1:4, Treatment = c("Control", "Disturbance", "1 µm", "45 µm"))
exp8250_files <- list.files("8250_data/", "dense_summary", full.names = TRUE)
read_8250_files <- function(fn) {
  x <- readLines(fn)
  newnames <- paste(strsplit(x[1], ",")[[1]], strsplit(x[2], ",")[[1]], sep = ".")
  x[2] <- paste(newnames, collapse = ",")
  x <- x[c(-1, -3)]
  dat <- read.csv(textConnection(x), na.strings = "-9999", check.names = FALSE)
  dat$file <- fn
  dat
}
lapply(exp8250_files, read_8250_files) %>% 
  bind_rows() %>% 
  as_tibble() %>% 
  mutate(`LI-8250.TIME` = sprintf("%06d", `LI-8250.TIME`),
         Timestamp = ymd_hms(paste(`LI-8250.DATE`, `LI-8250.TIME`))) %>% 
  select(Timestamp, Port = `LI-8250.PORT`, 
         "FLUX_LI-7810.FCH4", `FLUX_LI-7810.FCO2`,
         `FLUX_LI-7810.FH2O`, `FLUX_LI-7820.FN2O`) %>% 
  left_join(trts, by = "Port") %>% 
  mutate(Treatment = factor(Treatment, levels = c("Control", "Disturbance", "45 µm", "1 µm"))) %>% 
  pivot_longer(c(-Timestamp, -Port, -Treatment), names_to = "flux") %>% 
  separate(flux, into = c("Instrument", "Gas"), sep = "\\.") ->
  exp8250

message("Rows = ", nrow(exp8250))
message("Good rows = ", nrow(filter(exp8250, !is.na(value))))

ggplot(exp8250, aes(Timestamp, value, color = Treatment)) + 
  facet_grid(Gas~Treatment, scales = "free") + 
  geom_point()
ggsave("8250_test.pdf")

exp8250 %>% 
  filter(Timestamp > ymd_hm("2021-08-24 12:00")) %>% 
  ggplot(aes(Timestamp, value, color = Treatment)) +
  facet_grid(Gas~Treatment, scales = "free") + 
  geom_point() +
  theme(axis.text.x = element_text(angle = 90))
ggsave("8250_test_recent.pdf")
