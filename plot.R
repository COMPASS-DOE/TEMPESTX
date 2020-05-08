# Boom!
# Read and plot 7810 data from Anya Hopple's TEMPEST exclusion plots
# BBL May 2020

library(readr)
library(dplyr)
library(ggplot2)
theme_set(theme_bw())
library(lubridate)

files <- list.files("7810_data/", pattern = "*.txt", full.names = TRUE)

dat <- bind_rows(lapply(files, read_tsv, 
                        col_names = c("Timestamp", "Obs", "Port",
                                      "CO2_Flux", "Collar", "CH4_Flux"), 
                        col_types = "_Tdcddd_",
                        skip = 1))

collars <- read_csv("design/collar_map.csv", col_types = "dcdc")

dat %>%
  filter(CO2_Flux != 0.0 & CH4_Flux != 0.0) %>%
  left_join(collars, by = "Collar") ->
  dat_plot

dat_plot %>%
  bind_rows(mutate(dat_plot, Plot = "Combined")) ->
  dat_plot_all

dat_plot_all %>% 
  group_by(Plot, Treatment, yday(Timestamp)) %>% 
  summarise(Timestamp = mean(Timestamp),
            CO2_Flux_sd = sd(CO2_Flux), 
            CO2_Flux = mean(CO2_Flux),
            CH4_Flux_sd = sd(CH4_Flux),
            CH4_Flux = mean(CH4_Flux)) ->
  dat_plot_all_means

dat_plot_all_means %>% 
  ggplot(aes(Timestamp, CO2_Flux, color = Treatment, size = Treatment == "Control")) +
  geom_errorbar(aes(ymin = CO2_Flux - CO2_Flux_sd, ymax = CO2_Flux + CO2_Flux_sd)) +
  geom_line() +
  scale_size_manual(guide = FALSE, values = c(0.5, 2)) +
  facet_wrap(~Plot) ->
  p

print(p)
ggsave("over_time_co2.png")

dat_plot_all_means %>% 
  ggplot(aes(Timestamp, CH4_Flux, color = Treatment, size = Treatment == "Control")) +
  geom_errorbar(aes(ymin = CH4_Flux - CH4_Flux_sd, ymax = CH4_Flux + CH4_Flux_sd)) +
  geom_line() +
  scale_size_manual(guide = FALSE, values = c(0.5, 2)) +
  facet_wrap(~Plot) ->
  p

print(p)
ggsave("over_time_ch4.png")
