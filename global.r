
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
library(shinycssloaders)




# logger output to make sure packes load
logger::log_info('packages loaded')


#### Global imported Data ####
global_dat <- DoubleML::fetch_401k(return_type = "data.frame", instrument = TRUE)
global_dat$row_id <- seq_len(nrow(global_dat))
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
### need to fix this
get_variable_type <- function(variable) {
  variable <- as.character(variable)
  # Check if variable contains only "0" and "1" characters
  if (is.character(variable) && all(unique(variable) %in% c("0", "1")) && length(unique(variable)) == 2) { 
    return("binary")                                                              
  }  else if (all(grepl("[0-9]", variable, fixed = TRUE)) && !all(grepl("[a-zA-Z]", variable))) { 
    # Check if variable contains only numeric characters
    return("continuous")                                                           
  } else if (!all(is.na(as.numeric(variable)))) {
    # Check if variable can be converted to numeric
    return("continuous")
  } else {
    # Check if variable contains alphanumeric characters
    if (any(grepl("[a-zA-Z]", variable))) {
      return("alphanumeric")
    } else {
      return("string")                                                                                   
    }
  }
}

#### Global Plotly graph functions ####
# This code creates a full screen button and a download csv button in the poltly/ggplotly plot menu
# SVG icons
icons <- list()
# Fullscreen (source : https://fontawesome.com/icons/expand?f=classic&s=solid)
icons$expand <- "M32 32C14.3 32 0 46.3 0 64v96c0 17.7 14.3 32 32 32s32-14.3 32-32V96h64c17.7 0 32-14.3 32-32s-14.3-32-32-32H32zM64 352c0-17.7-14.3-32-32-32s-32 14.3-32 32v96c0 17.7 14.3 32 32 32h96c17.7 0 32-14.3 32-32s-14.3-32-32-32H64V352zM320 32c-17.7 0-32 14.3-32 32s14.3 32 32 32h64v64c0 17.7 14.3 32 32 32s32-14.3 32-32V64c0-17.7-14.3-32-32-32H320zM448 352c0-17.7-14.3-32-32-32s-32 14.3-32 32v64H320c-17.7 0-32 14.3-32 32s14.3 32 32 32h96c17.7 0 32-14.3 32-32V352z"
# Download Data CSV (source : https://fontawesome.com/icons/file-csv?f=classic&s=solid)
icons$csv <- "M0 64C0 28.7 28.7 0 64 0H224V128c0 17.7 14.3 32 32 32H384V304H176c-35.3 0-64 28.7-64 64V512H64c-35.3 0-64-28.7-64-64V64zm384 64H256V0L384 128zM200 352h16c22.1 0 40 17.9 40 40v8c0 8.8-7.2 16-16 16s-16-7.2-16-16v-8c0-4.4-3.6-8-8-8H200c-4.4 0-8 3.6-8 8v80c0 4.4 3.6 8 8 8h16c4.4 0 8-3.6 8-8v-8c0-8.8 7.2-16 16-16s16 7.2 16 16v8c0 22.1-17.9 40-40 40H200c-22.1 0-40-17.9-40-40V392c0-22.1 17.9-40 40-40zm133.1 0H368c8.8 0 16 7.2 16 16s-7.2 16-16 16H333.1c-7.2 0-13.1 5.9-13.1 13.1c0 5.2 3 9.9 7.8 12l37.4 16.6c16.3 7.2 26.8 23.4 26.8 41.2c0 24.9-20.2 45.1-45.1 45.1H304c-8.8 0-16-7.2-16-16s7.2-16 16-16h42.9c7.2 0 13.1-5.9 13.1-13.1c0-5.2-3-9.9-7.8-12l-37.4-16.6c-16.3-7.2-26.8-23.4-26.8-41.2c0-24.9 20.2-45.1 45.1-45.1zm98.9 0c8.8 0 16 7.2 16 16v31.6c0 23 5.5 45.6 16 66c10.5-20.3 16-42.9 16-66V368c0-8.8 7.2-16 16-16s16 7.2 16 16v31.6c0 34.7-10.3 68.7-29.6 97.6l-5.1 7.7c-3 4.5-8 7.1-13.3 7.1s-10.3-2.7-13.3-7.1l-5.1-7.7c-19.3-28.9-29.6-62.9-29.6-97.6V368c0-8.8 7.2-16 16-16z"

dirty_js <- function(x) {
  structure(x, class = unique(c("JS_EVAL", oldClass(x))))
}

button_fullscreen <- function() {
  list(
    name = "fullscreen",
    title = "Toggle fullscreen",
    icon = list(
      path = icons$expand,
      transform = 'matrix(1 0 0 1 0 -1) scale(0.03571429)'
    ),
    attr = "full_screen",
    val = "false",
    click = dirty_js(
      "function(gd, ev) {
         var button = ev.currentTarget;
         var astr = button.getAttribute('data-attr');
         var val = button.getAttribute('data-val') || false;
      
         if(astr === 'full_screen') {
           if(val === 'false') {
             button.setAttribute('data-val', 'true');
             gd.classList.add('full-screen');
             Plotly.Plots.resize(gd);
           } else {
             button.setAttribute('data-val', 'false');
             gd.classList.remove('full-screen');
             Plotly.Plots.resize(gd);
           }
         }
      }"
    )
  )
}

dirty_csv <- function(data) {
  c(
    paste0(colnames(data), collapse = ","),
    apply(data, 1, paste0, collapse = ",")
  ) |> paste0(collapse = "\n") |> utils::URLencode(reserved = TRUE)
}


button_download <- function(data, plot_name) {
  # Concatenate multiple plot names into a single string separated by underscores
  
  list(
    name = "datacsv",
    title = "Download plot data as csv",
    icon = list(
      path = icons$csv,
      transform = 'matrix(1 0 0 1 0 0) scale(0.03125)'
    ),
    click = dirty_js(
      sprintf(
        "function(gd, ev) {
           var el = document.createElement('a');
           el.setAttribute('href', 'data:text/plain;charset=utf-8,%s');
           el.setAttribute('download', '%s.csv');
           el.click();
        }",
        dirty_csv(data),
        plot_name  # Use the concatenated plot name
      )
    )
  )
}
