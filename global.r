
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
  if ((is.factor(variable) && all(levels(variable) %in% c("0", "1"))) ||  # Check if factor with levels 0 and 1
      (is.numeric(variable) && all(variable %in% c(0, 1)))) {              # Check if numeric with values 0 and 1
    "binary"                                                               # Return "binary" if the conditions are met
  } else if (is.factor(variable)) {                                       
    "string"                                                                # Return "string" if the variable is a factor but not binary
  } else {
    "continuous"                                                            # Return "continuous" if the variable is numeric but not binary
  }
}