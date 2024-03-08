
logger::log_info('running global.R')


library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinybusy)
library(reticulate)
library(DT)
library(tidyverse)



logger::log_info('packages loaded')



global_dat <- read_csv("401k_practice data.csv")


global <- reactiveValues(
  ATE_summary = NULL,
  plr_summary = NULL,
  non_sig_treats = NULL,
  trigger = NULL,
  tableau_filter = NULL)



