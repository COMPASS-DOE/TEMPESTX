# deadband analysis

files <- list.files("deadband/", pattern = "export", full.names = TRUE)

library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
theme_set(theme_bw())

lapply(files, read_csv, skip = 3, 
       col_names = c("DOY", "Tair", "Pa", "Vol", "FCO2_Exp", "FCO2_Lin", "Collar")) %>%
  bind_rows(.id = "File") %>% 
  mutate(File = basename(files[as.integer(File)]),
         Deadband = gsub("export", "", File),
         Deadband = gsub("\\.csv", "", Deadband),
         Deadband = as.numeric(Deadband)) %>% 
  filter(FCO2_Exp > 0) ->
  dat

dat %>% 
  pivot_longer(cols = starts_with("FCO2"), names_to = "Flux") %>% 
  group_by(Deadband, Flux, Collar) %>% 
  summarise(value = mean(value)) %>% 
  ggplot(aes(Deadband, value, color = Collar, group = Collar)) + 
  geom_line() + 
  facet_grid(Flux~.) +
  geom_vline(xintercept = 6.1, linetype = 2) +
  xlab("Dead band setting (s)") + ylab("Flux (µmol/m2/s)") +
  ggtitle("TEMPESTX_20200415.json")
ggsave("deadband1.pdf")

ggplot(dat, aes(FCO2_Exp, FCO2_Lin, color = Collar)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  geom_abline() +
  facet_wrap(~Deadband) +
  ggtitle("TEMPESTX_20200415.json")
ggsave("deadband2.pdf")

deadbands <- read_csv("deadband/deadbands.csv")

ggplot(deadbands, aes(x = deadband)) + 
  geom_histogram(bins = 20) + 
  geom_vline(xintercept = 6.1, linetype = 2) +
  ggtitle("TEMPESTX_20200415.json") +
  xlab("Deadband guidance")
ggsave("deadband3.pdf")

deadbands %>% 
  group_by(Collar) %>% 
  summarise(deadband_diff = deadband[2] - deadband[1]) %>% 
  ggplot(aes(x = deadband_diff)) + 
  geom_histogram(bins = 20) + 
  ggtitle("TEMPESTX_20200415.json") +
  xlab("Deadband difference (msmt 2 minus msmt 1)")
ggsave("deadband4.pdf")
