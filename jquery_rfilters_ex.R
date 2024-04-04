library(shiny)
library(jqbr)

# Define the filters
r_filters <- list(
  list(
    id = "mpg",
    title = "MPG",
    type = "double",
    plugin = "slider",
    operators = c("greater", "less", "between"),
    plugin_config = list(
      min = min(mtcars$mpg) - 1,
      max = max(mtcars$mpg) + 1,
      value = 20
    )
  ),
  list(
    id = "cyl",
    type = "integer",
    input = "checkbox",
    values = list(
      4,
      6,
      8
    ),
    operators = c("equal", "not_equal", "in")
  ),
  list(
    id = "disp",
    operators = c("is_na", "is_not_na")
  )
)

rules_r <- list(
  condition = "AND",
  rules = list(
    list(
      id = "mpg",
      operator = "greater",
      value = 20)
    # ),
    # list(
    #   id = "cyl",
    #   operator = "in",
    #   value = 4
    # ),
    # list(
    #   id = "disp",
    #   operator = "is_not_na"
    # )
  )
)

# UI definition
ui <- fluidPage(
  theme = bslib::bs_theme(version = "5"),
  useQueryBuilder(bs_version = "5"),
  fluidRow(
    column(
      width = 6,
      h4("Builder"),
      queryBuilderInput(
        inputId = "r_filter",
        filters = r_filters,
        return_value = "r_rules",
        display_errors = TRUE,
        rules = rules_r,
        add_na_filter = TRUE
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
      tableOutput("cars")
    )
  )
)

# Server logic
server <- function(input, output, session) {
  output$cars <- renderTable({
    r_filter <<- input$r_filter
    filter_table(mtcars, input$r_filter)
  })
  
  observeEvent(input$reset, {
    updateQueryBuilder(
      inputId = "r_filter",
      reset = TRUE
    )
  })
}

# Run the application
shinyApp(ui, server)
