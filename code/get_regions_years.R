#!/usr/bin/env Rscript

library(tidyverse)
library(glue)
library(lubridate)
library(dataRetrieval)

# https://www.ncei.noaa.gov/pub/data/ghcn/daily/readme.txt
#------------------------------
#  Variable   Columns   Type
#------------------------------
#  ID            1-11   Character
#YEAR         12-15   Integer
#MONTH        16-17   Integer
#ELEMENT      18-21   Character
#VALUE1       22-26   Integer
#MFLAG1       27-27   Character
#QFLAG1       28-28   Character
#SFLAG1       29-29   Character
#VALUE2       30-34   Integer
#MFLAG2       35-35   Character
#QFLAG2       36-36   Character
#SFLAG2       37-37   Character
#.           .          .
#.           .          .
#.           .          .
#VALUE31    262-266   Integer
#MFLAG31    267-267   Character
#QFLAG31    268-268   Character
#SFLAG31    269-269   Character
#------------------------------

# BNA airport - "data/USW00013897.dly"
# Read in and format weather data

window <- 30
tday_julian <- yday(today())
quadruple <- function(x){
  c(glue("VALUE{x}"), glue("MFLAG{x}"), glue("QFLAG{x}"), glue("SFLAG{x}"))
}

widths <- c(11, 4, 2, 4, rep(c(5, 1, 1, 1), 31))
headers <- c("ID", "YEAR", "MONTH", "ELEMENT", unlist(map(1:31, quadruple)))

x <- "data/USW00013897.dly"



read_fwf(x, 
         fwf_widths(widths, headers),
         na = c("NA", "-9999"),
         col_types = cols(.default = col_character()),
         col_select = c(ID, YEAR, MONTH, ELEMENT, starts_with("VALUE"))) %>% 
  rename_all(tolower) %>% 
  filter(element == c("PRCP")) %>%
  pivot_longer(cols=starts_with("value"), 
               names_to="day") %>%
  drop_na() %>%
  mutate(day = str_replace(day,"value", ""),
         date=ymd(glue("{year}-{month}-{day}")),
         value = as.numeric(value)) %>%  #PRCP is in tenths of mm
  select(id, date, element, value) %>% 
  mutate(julian_day = yday(date),
         diff = tday_julian - julian_day,
         is_in_window = case_when(diff < window & diff > 0 ~TRUE,
                                  diff > window ~ FALSE,
                                  tday_julian < window &
                                    diff + 365 < window ~TRUE,
                                  diff < 0 ~ FALSE,
                                  diff == 0 ~ TRUE),
         year = year(date)) %>%
  filter(is_in_window) %>%
  write_tsv("data/composite_dly.tsv")

prcp_data <- read_tsv("data/composite_dly.tsv")

############################################################


############################################################

chart<-ggplot(prcp_data, aes(x=date, y=value)) + geom_line(col="blue")

ggsave("visuals/world_drought.png", width = 8, height = 4)
