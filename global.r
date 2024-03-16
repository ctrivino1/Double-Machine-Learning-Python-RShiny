
logger::log_info('running global.R')

#### Libraries ####
library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinydashboardPlus)
library(shinybusy)
library(shinyWidgets)
library(reticulate)
library(DT)
library(tidyverse)
library(openxlsx)
library(lubridate)
library(glue)


# logger output to make sure packes load
logger::log_info('packages loaded')


#### Global imported Data ####
global_dat <- read_csv("401k_practice data.csv")


#### Global reactive values ####
global <- reactiveValues(
  ATE_summary = NULL,
  plr_summary = NULL,
  non_sig_treats = NULL,
  trigger = NULL,
  hover_info = NULL,
  click_info = NULL,
  dblclick_info = NULL)



