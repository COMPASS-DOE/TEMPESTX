# Boom!

library(readr)
library(dplyr)
library(ggplot2)
theme_set(theme_bw())

dat <- read_tsv("7810_data/TEMPESTX_20200415.txt")

collars <- read_csv("design/collar_map.csv")

dat %>%
  select(-X8,
         Collar = `File Name`,
         CO2_Flux = Exp_Flux,
         CH4_Flux = `Exp_Flux[2]`) %>%
  filter(CO2_Flux > 0) %>%
  left_join(collars, by = "Collar") ->
  dat_plot

dat_plot %>%
  ggplot(aes(Treatment, CO2_Flux)) +
  geom_boxplot() + geom_point() +
  facet_wrap(~Plot) ->
  p

print(p)
ggsave("20200415_CO2.png")

dat_plot %>%
  ggplot(aes(Treatment, CH4_Flux)) +
  geom_boxplot() + geom_point() +
  facet_wrap(~Plot) ->
  p

print(p)
ggsave("20200415_CH4.png")



