library(shiny)
library(tidyverse)
library(plotly)
library(ggplot2)
library(DT)
library(shinyWidgets)

# Create sample data
set.seed(42)
n_points <- 50
data <- data.frame(
  date = seq(Sys.Date(), by = "day", length.out = n_points),
  value1 = rnorm(n_points),
  value2 = rnorm(n_points),
  value3 = rnorm(n_points),
  binary_column = sample(c(0, 1), n_points, replace = TRUE),
  group_column = sample(letters[1:5], n_points, replace = TRUE)
) 
data$row_id <- seq_len(nrow(data))

ui <- fluidPage(
  pickerInput("y_var", "Y Variable", choices = names(data), multiple = FALSE),
  pickerInput("x_var", "X Variable", choices = names(data), multiple = TRUE),
  pickerInput("color_by", "Color by", choices = c("None selected", "binary_column", "group_column"), multiple = FALSE, options = list(
    `actions-box` = TRUE,
    `live-search` = TRUE,
    `selected-text-format` = "count > 3",
    `count-selected-text` = "{0} items selected",
    `deselect-all-text` = "Clear All",
    `select-all-text` = "Select All",
    `none-selected-text` = "None selected"
  )),
  fluidRow(plotlyOutput("plot1")),
  DTOutput("data_table")
)

server <- function(input, output, session) {
  # Reactive data frame to store selected rows
  selected_data <- reactiveVal(NULL)
  
  # Reactive value to store the current interaction mode
  
  # Render ggplot objects
  gg1 <- reactive({
    req(input$y_var,input$x_var)
    print('input$color')
    print(input$color_by)
    if (input$color_by == "None selected") {
      ggplot(data, aes_string(x = input$x_var, y = input$y_var)) +
        geom_point() +
        labs(x = input$x_var, y = input$y_var)
    } else if (input$color_by == "binary_column") {
      data[[input$color_by]] <- factor(data[[input$color_by]], levels = c(0, 1)) # Convert to factor
      ggplot(data, aes_string(x = input$x_var, y = input$y_var, color = input$color_by,customdata = 'row_id')) +
        geom_point() +
        labs(x = input$x_var, y = input$y_var)
    } else if (input$color_by == "group_column") {
      ggplot(data, aes_string(x = input$x_var, y = input$y_var, color = input$color_by, customdata = 'row_id')) +
        geom_point() +
        labs(x = input$x_var, y = input$y_var)
    }
  })
  
  # Render ggplotly plots
  output$plot1 <- renderPlotly({
    ggplotly(gg1(),source='plot1') %>%
      layout(clickmode = "event+select", dragmode = 'select')
  })
  
  
  
  # Observe select event
  observeEvent(event_data("plotly_selected", source = "plot1"), {
    click_data <- event_data("plotly_selected", source = "plot1")
    print('click_data')
    print(click_data$customdata)
    if (!is.null(click_data)) {
      if (input$color_by == "None selected") {
  
        selected_data_indices <- click_data$pointNumber + 1
        selected_rows <- data[selected_data_indices, ]
        selected_data(selected_rows)
      } else  { 
        result <- inner_join(data, click_data, by = c("row_id" = "customdata"))
        selected_data(result)
      }
    }
  })
  
  
  
  # Output data table
  output$data_table <- renderDT({
    if (!is.null(selected_data())) {
      datatable(selected_data(), rownames = FALSE)
    } else {
      datatable(data, rownames = FALSE)
    }
  })
}

shinyApp(ui, server)
