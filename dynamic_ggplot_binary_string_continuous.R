# Load the required libraries
library(shiny)
library(ggplot2)
library(tidyverse)

# Load data
data("iris")

# Add a binary column randomly
set.seed(123) # Setting seed for reproducibility
iris$binary_column <- as.factor(sample(0:1, nrow(iris), replace = TRUE))  # Convert to factor

# Function to classify variable types
get_variable_type <- function(variable) {
  if (is.factor(variable)) {
    "string"
  } else if ((is.numeric(variable) && length(unique(variable)) == 2 && all(unique(variable) %in% c(0, 1))) ||
             (is.character(variable) && length(unique(variable)) == 2 && all(unique(variable) %in% c("0", "1")))) {
    "binary"
  } else {
    "continuous"
  }
}

# ui
ui <- fluidPage(
  sidebarPanel(
    selectInput(inputId = "y_sel", label = "Select y variable",
                choices = names(iris)),
    selectInput(inputId = "x_sel", label = "Select x variable(s)",
                choices = names(iris), multiple = TRUE),
    selectInput(inputId = "group_var", label = "Select group variable for color",
                choices = c("None", names(iris)), selected = "None")
  ),
  mainPanel(
    tabsetPanel(
      tabPanel("Binary", uiOutput("binary_plots")),
      tabPanel("Continuous", uiOutput("continuous_plots")),
      tabPanel("String", uiOutput("string_plots"))
    )
  )
)

# server
server <- function(input, output, session) {
  output$binary_plots <- renderUI({
    binary_x_vars <- Filter(function(x) get_variable_type(iris[[x]]) == "binary", input$x_sel)
    plot_output_list <- lapply(binary_x_vars, function(x_var) {
      plotname <- paste("plot", x_var, sep = "_")
      plotOutput(plotname, height = '250px')
    })
    
    do.call(tagList, plot_output_list)
  })
  
  output$continuous_plots <- renderUI({
    continuous_x_vars <- Filter(function(x) get_variable_type(iris[[x]]) == "continuous", input$x_sel)
    plot_output_list <- lapply(continuous_x_vars, function(x_var) {
      plotname <- paste("plot", x_var, sep = "_")
      plotOutput(plotname, height = '250px')
    })
    
    do.call(tagList, plot_output_list)
  })
  
  output$string_plots <- renderUI({
    string_x_vars <- Filter(function(x) get_variable_type(iris[[x]]) == "string", input$x_sel)
    plot_output_list <- lapply(string_x_vars, function(x_var) {
      plotname <- paste("plot", x_var, sep = "_")
      plotOutput(plotname, height = '250px')
    })
    
    do.call(tagList, plot_output_list)
  })
  
  observe({
    req(input$y_sel, input$x_sel)
    
    lapply(input$x_sel, function(x_var) {
      output[[paste("plot", x_var, sep = "_")]] <<- renderPlot({
        if (is.factor(iris[[x_var]]) || is.factor(iris[[input$y_sel]])) {
          if (input$group_var == "None") {
            ggplot(iris, aes_string(x = x_var, y = input$y_sel)) +
              geom_boxplot() +
              ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel))
          } else {
            ggplot(iris, aes_string(x = x_var, y = input$y_sel, color = input$group_var)) +
              geom_boxplot() +
              ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel, "with Group Coloring"))
          }
        } else {
          if (input$group_var == "None") {
            ggplot(iris, aes_string(x = x_var, y = input$y_sel)) +
              geom_point() +
              ggtitle(paste("Scatter Plot of", x_var, "vs", input$y_sel))
          } else {
            ggplot(iris, aes_string(x = x_var, y = input$y_sel, color = input$group_var)) +
              geom_point() +
              ggtitle(paste("Scatter Plot of", x_var, "vs", input$y_sel, "with Group Coloring"))
          }
        }
      })
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
