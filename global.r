
logger::log_info('running global.R')
library(plyr)
#library(hdm)
library(glue)
library(reactable)
library(shinyglide)
library(shiny)
library(shinydashboard)
library(shinyBS)
library(DT)
library(shinyWidgets)
library(tidyverse)
library(zoo)
library(shinycssloaders)
library(plotly)
library(rpivotTable)
library(data.table)
library(RPostgreSQL)
library(shinythemes)
library(shinyjs)
library(shinyalert)
library(dplyr)
library(padr)
library(shinybusy)
library(shinyFeedback)
library(reticulate)


logger::log_info('packages loaded')



global_dat <- read_csv("401k_practice data.csv")


global <- reactiveValues(
  ATE_summary = NULL,
  plr_summary = NULL,
  non_sig_treats = NULL,
  trigger = NULL,
  tableau_filter = NULL)



