
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
library(plotly)




# logger output to make sure packes load
logger::log_info('packages loaded')


#### Global imported Data ####
global_dat <- DoubleML::fetch_401k(return_type = "data.frame", instrument = TRUE)
global_dat_python <- DoubleML::fetch_401k(return_type = "data.frame", instrument = TRUE)





#### Global reactive values ####
global <- reactiveValues(
  # plots 
  ATE_summary = NULL,
  plr_summary = NULL,
  # other 
  non_sig_treats = NULL,
  trigger = NULL,
  # ATE DT actions
  hover_info = NULL,
  click_info = NULL,
  dblclick_info = NULL,
  # Exploration Graph counts
  binary_count = 0,
  continuous_count = 0,
  string_count = 0,
  selected_x_vars = NULL)

#### Global Functions ####
# Identify columns that contain strings or numeric values of 0 and 1
string_or_binary_cols <- sapply(global_dat, function(x) is.character(x) || (is.numeric(x) && all(unique(x) %in% c(0, 1))))


# Convert identified columns to factor columns
global_dat[string_or_binary_cols] <- lapply(global_dat[string_or_binary_cols], as.factor)



# Function to classify variable types
get_variable_type <- function(variable) {
  variable <- as.character(variable)
  if (is.character(variable) && all(unique(variable) %in% c("0", "1")) && length(unique(variable)) == 2) { 
    "binary"                                                              
  } else if (is.numeric(variable) && all(unique(variable) %in% c(0, 1)) && length(unique(variable)) == 2) {              
    "binary"                                                              
  } else if (any(grepl("[a-zA-Z]", variable))) {                                       
    "string"                                                                                   
  } else {
    "continuous"                                                           
  }
}