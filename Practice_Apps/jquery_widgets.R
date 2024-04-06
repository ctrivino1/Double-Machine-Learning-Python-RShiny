library(shiny)
library(jqbr)
library(dplyr)
library(lubridate)
library(DT)

# Define dummy data
# Define dummy data
library(DT)

# Define dummy data
set.seed(123)
n_rows <- 825

# Get today's date
today <- Sys.Date()

# Adjust the length of dates vector
dates <- seq(as.Date("2022-01-01"), today, by = "day")
n_rows <- length(dates)

binary_cols <- matrix(sample(0:1, n_rows * 3, replace = TRUE), nrow = n_rows, ncol = 3, 
                      dimnames = list(NULL, paste0("binary_", 1:3)))

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

# Define the filters based on dummy data columns
#### Widget filters ####
widget_filters <- list(
  list(
    id = "date",
    label = "Datepicker",
    type = "date",
    validation = list(
      format = "YYYY/MM/DD"
    ),
    plugin = "datepicker",
    plugin_config = list(
      format = "yyyy/mm/dd",
      todayBtn = "linked",
      todayHighlight = TRUE,
      autoclose = TRUE
    )
  ),
  list(
    id = "binary_1",
    label = "Binary 1",
    type = "integer",
    validation = list(
      min = 0,
      max = 1
    ),
    plugin = "slider",
    plugin_config = list(
      min = 0,
      max = 1,
      value = 0
    )
  ),
  list(
    id = "binary_2",
    label = "Binary 2",
    type = "integer",
    validation = list(
      min = 0,
      max = 1
    ),
    plugin = "slider",
    plugin_config = list(
      min = 0,
      max = 1,
      value = 0
    )
  ),
  list(
    id = "binary_3",
    label = "Binary 3",
    type = "integer",
    validation = list(
      min = 0,
      max = 1
    ),
    plugin = "slider",
    plugin_config = list(
      min = 0,
      max = 1,
      value = 0
    )
  ),
  list(
    id = "continuous_1",
    label = "Continuous 1",
    type = "integer",
    validation = list(
      min = round(min(continuous_vars$continuous_1), 0),
      max = round(max(continuous_vars$continuous_1), 0)
    ),
    plugin = "slider",
    plugin_config = list(
      min = round(min(continuous_vars$continuous_1), 0),
      max = round(max(continuous_vars$continuous_1), 0),
      value = round(min(continuous_vars$continuous_1), 0)
    )
  ),
  list(
    id = "continuous_2",
    label = "Continuous 2",
    type = "integer",
    validation = list(
      min = round(min(continuous_vars$continuous_2), 0),
      max = round(max(continuous_vars$continuous_2), 0)
    ),
    plugin = "slider",
    plugin_config = list(
      min = round(min(continuous_vars$continuous_2), 0),
      max = round(max(continuous_vars$continuous_2), 0),
      value = round(min(continuous_vars$continuous_2), 0)
    )
  ),
  list(
    id = "continuous_3",
    label = "Continuous 3",
    type = "integer",
    validation = list(
      min = round(min(continuous_vars$continuous_3), 0),
      max = round(max(continuous_vars$continuous_3), 0)
    ),
    plugin = "slider",
    plugin_config = list(
      min = round(min(continuous_vars$continuous_3), 0),
      max = round(max(continuous_vars$continuous_3), 0),
      value = round(min(continuous_vars$continuous_3), 0)
    )
  ),
  list(
    id = "categorical_1",
    label = "Categorical 1",
    type = "string",
    input = "select",
    multiple = TRUE,
    plugin = "selectize",
    plugin_config = list(
      valueField = "id",
      labelField = "name",
      searchField = "name",
      sortField = "name",
      options = list(
        list(id = "A", name = "A"),
        list(id = "B", name = "B"),
        list(id = "C", name = "C")
      )
    )
  ),
  list(
    id = "categorical_2",
    label = "Categorical 2",
    type = "string",
    input = "select",
    multiple = TRUE,
    plugin = "selectize",
    plugin_config = list(
      valueField = "id",
      labelField = "name",
      searchField = "name",
      sortField = "name",
      options = list(
        list(id = "X", name = "X"),
        list(id = "Y", name = "Y"),
        list(id = "Z", name = "Z")
      )
    )
  )
)

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
rules_widgets <- list(
  condition = "AND",
  rules = list(
    list(
      id = "date",
      operator = "between",
      value = c(earliest_date_str, today_str)
    )
  )
)

#### ui ####
ui <- fluidPage(
  theme = bslib::bs_theme(version = "5"),
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
