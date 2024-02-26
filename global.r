library(plyr)
library(reticulate)

library(glue)
library(reactable)
library(shinyglide)
library(shiny)
library(shinydashboardPlus)
library(shinydashboard) # , exclude = c('infoBox', 'infoBoxOutput', 'renderInfoBox'))
library(shinyBS, warn.conflicts = F)
library(DT)
library(shinyWidgets)
library(tidyverse)
library(bslib)
library(zoo)
library(shinycssloaders)
library(plotly, exclude = c("group_by", "summarise"))
library(rpivotTable)
library(data.table)
library(lubridate)
library(RPostgreSQL)
library(pool)
library(glue)
library(shinypivottabler)
library(janitor)
library(stringi)
library(shinyjs)
library(shinyalert)
library(dplyr)
library(padr)
library(shinybusy)
library(openxlsx)
library(timetk)
library(shinyFeedback)
library(tidyverse)
library(reticulate)

library(glue)
library(shinythemes)
library(shinyjs)
library(shinybusy)
library(plotly)





global_dat <- read_csv("401k_practice data.csv") # can import from hdm library



global <- reactiveValues(
  ATE_summary = NULL,
  plr_summary = NULL,
  non_sig_treats = NULL,
  test_dat = NULL,
  tableau_filter = NULL)


