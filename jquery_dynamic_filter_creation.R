library(shiny)
library(jqbr)
library(dplyr)
library(lubridate)
library(DT)

set.seed(123)
n_rows <- 825

# Get today's date
today <- Sys.Date()

# Adjust the length of dates vector
dates <- seq(as.Date("2022-01-01"), today, by = "day")
n_rows <- length(dates)

binary_cols <- matrix(sample(0:1, n_rows * 2, replace = TRUE), nrow = n_rows, ncol = 2, 
                      dimnames = list(NULL, paste0("binary_",  1:2)))

continuous_vars <- data.frame(
  continuous_1 = rnorm(n_rows, mean = 50, sd = 10),
  continuous_2 = rnorm(n_rows, mean = 100, sd = 20),
  continuous_3 = rnorm(n_rows, mean = 25, sd = 5)
)

categorical_cols <- data.frame(
  categorical_1 = sample(c("A", "B", "C"), n_rows, replace = TRUE),
  categorical_2 = sample(c("X", "Y", "Z"), n_rows, replace = TRUE)
)

dummy_data <- data.frame(
  date = dates,
  binary_cols,
  continuous_vars,
  categorical_cols
)


generate_widget_filters <- function(data) {
  widget_filters <- list()
  
  
  # For binary columns
  binary_cols <- names(dummy_data)[sapply(dummy_data, function(x) (is.numeric(x) && all(unique(x) %in% c(0, 1))) || all(unique(x) %in% c("0", "1")))]
  ## change string binary to numeric binary if found
  dummy_data <- dummy_data %>%
    mutate(across(all_of(binary_cols), as.numeric))
  
  for (col in binary_cols) {
    filter <- list(
      id = col,
      label = col,
      type = "integer",
      validation = list(min = 0, max = 1),
      plugin = "slider",
      plugin_config = list(min = 0, max = 1, value = 0)
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  
  # For continuous columns
  continuous_cols <- names(dummy_data)[sapply(dummy_data, function(x) {
    is_numeric <- is.numeric(x)
    not_binary <- is.numeric(x) && !all(unique(x) %in% c(0, 1))
    return(is_numeric && not_binary)
  })]
  for (col in continuous_cols) {
    min_val <- round(min(data[[col]]), 0)
    max_val <- round(max(data[[col]]), 0)
    filter <- list(
      id = col,
      label = col,
      type = "integer",
      validation = list(min = min_val, max = max_val),
      plugin = "slider",
      plugin_config = list(min = min_val, max = max_val, value = min_val)
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  
  # For date columns
  date_cols <- names(dummy_data)[sapply(dummy_data, is.Date)]
  for (col in date_cols) {
    filter <- list(
      id = col,
      label = col,
      type = "date",
      validation = list(format = "YYYY/MM/DD"),
      plugin = "datepicker",
      plugin_config = list(
        format = "yyyy/mm/dd",
        todayBtn = "linked",
        todayHighlight = TRUE,
        autoclose = TRUE
      )
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  
  # For categorical columns
  categorical_cols <- names(dummy_data)[sapply(dummy_data, is.character)]
  for (col in categorical_cols) {
    unique_values <- unique(data[[col]])
    options <- lapply(unique_values, function(value) list(id = value, name = value))
    filter <- list(
      id = col,
      label = col,
      type = "string",
      input = "select",
      multiple = TRUE,
      plugin = "selectize",
      plugin_config = list(
        valueField = "id",
        labelField = "name",
        searchField = "name",
        sortField = "name",
        options = options
      )
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  
  return(widget_filters)
}

# Usage
widget_filters<<- generate_widget_filters(dummy_data)



# Define the initial rules based on dummy data

# Get the earliest date in the data
earliest_date <- min(dummy_data$date)

# Convert earliest date to the desired format
earliest_date_str <- format(earliest_date, "%Y/%m/%d")

# Get today's date
today <- Sys.Date()

# Convert today's date to the desired format
today_str <- format(today, "%Y/%m/%d")

# Define the rules for the date filter

rules_widgets <- NULL
## can add a base filter like so:
# rules_widgets <- list(
#   condition = "AND",
#   rules = list(
#     list(
#       id = "date",
#       operator = "between",
#       value = c(earliest_date_str, today_str)
#     )
#   )
# )

#### ui ####
ui <- fluidPage(
  theme = bslib::bs_theme(version = "3"),
  useQueryBuilder(bs_version = "5"),
  fluidRow(
    column(
      width = 8,
      h2("Widgets"),
      p("jqbr supports all three available widgets for queryBuilder: 'datepicker', 'slider' and 'selectize'. See them in action below.")
    )
  ),
  fluidRow(
    column(
      width = 6,
      h4("Builder"),
      queryBuilderInput(
        inputId = "widget_filter",
        filters = widget_filters,
        rules = rules_widgets,
        display_errors = TRUE,
        return_value = "all"
      ),
      fluidRow(
        column(
          width = 12,
          div(
            style = "display: inline-block;",
            actionButton(
              "reset",
              "Reset",
              class = "btn-danger"
            ),
            actionButton(
              "set_rules",
              "Set rules",
              class = "btn-warning"
            )
          )
        )
      )
    ),
    column(
      width = 6,
      h4("Outputs"),
      dataTableOutput("test")
    )
  )
)



#### server ####


server <- function(input, output, session) {
  
  output$test <- renderDT({
    widget_filter_rules <- input$widget_filter$r_rules
    datatable(filter_table(dummy_data, widget_filter_rules))
  })
  
  observeEvent(input$reset, {
    updateQueryBuilder(
      inputId = "widget_filter",
      reset = TRUE
    )
  })
  
}


shinyApp(ui, server)

