library(tidyverse)
library(shiny)
library(shinyWidgets)
library(glue)

# Load data
data("iris")

# Add a binary column randomly
set.seed(123) # Setting seed for reproducibility
iris$binary_column <- sample(0:1, nrow(iris), replace = TRUE)  # Convert to factor

# Identify columns that contain strings or numeric values of 0 and 1
string_or_binary_cols <- sapply(iris, function(x) is.character(x) || (is.numeric(x) && all(unique(x) %in% c(0, 1))))

# Convert identified columns to factor columns
iris[string_or_binary_cols] <- lapply(iris[string_or_binary_cols], as.factor)

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



# Define the user interface (UI)
ui <- fluidPage(
  sidebarPanel(
    selectInput(inputId = "y_sel", label = "Select y variable",
                choices = names(iris)),
    selectInput(inputId = "x_sel", label = "Select x variable(s)",
                choices = names(iris), multiple = TRUE),
    selectInput(inputId = "group_var", label = "Select group variable for color",
                choices = c("None",  # Option for no grouping
                            names(iris)[sapply(iris, is.factor) | sapply(iris, function(x) get_variable_type(x) == "binary")]),  # Factor or binary columns for grouping
                selected = "None")  # Default selection
  ),
  mainPanel(
    tabsetPanel(
      #tabPanel('test', uiOutput("binary_plots")),         # Tab for binary variables
      tabPanel(textOutput('binary_count'), uiOutput("binary_plots")),
      tabPanel(textOutput('continuous_count'), uiOutput("continuous_plots")), # Tab for continuous variables
      tabPanel(textOutput('string_count'), uiOutput("string_plots"))          # Tab for string variables
    )
  )
)


# Define the server logic
server <- function(input, output, session) {
  # Initialize global reactive values
  global <- reactiveValues(
    binary_count = 0,
    continuous_count = 0,
    string_count = 0,
    selected_x_vars = NULL  # Store selected x variables
  )
  
  # Function to update selected x variables
  update_selected_x_vars <- function() {
    # Update selected x variables
    global$selected_x_vars <- lapply(input$x_sel, function(x_var) {
      list(name = x_var, type = get_variable_type(iris[[x_var]]))
    })
  }
  
  # Observer to update counts and selected x variables
  observeEvent(input$x_sel, {
    req(input$x_sel)  # Require selection of x variables
    
    # Update selected x variables
    update_selected_x_vars()
    
    # Calculate counts based on selected x variables
    binary_count <- sum(sapply(global$selected_x_vars, function(var) var$type == "binary"))
    continuous_count <- sum(sapply(global$selected_x_vars, function(var) var$type == "continuous"))
    string_count <- sum(sapply(global$selected_x_vars, function(var) var$type == "string"))
    
    # Update global counts
    global$binary_count <- binary_count
    global$continuous_count <- continuous_count
    global$string_count <- string_count
    
    # Print counts to console
    cat("Binary count:", global$binary_count, "\n")
    cat("Continuous count:", global$continuous_count, "\n")
    cat("String count:", global$string_count, "\n")
  })
  
  output$binary_count <- renderText({
    paste("Binary (",global$binary_count,")")
  })
  output$continuous_count <- renderText({
    paste('Continuous (',global$continuous_count,')')
  })
  output$string_count <- renderText({
    paste("String (", global$string_count,")")
  })
  
  output$binary_plots <- renderUI({
    binary_x_vars <- Filter(function(x) get_variable_type(iris[[x]]) == "binary", input$x_sel)  # Filter binary variables
    plot_output_list <- lapply(binary_x_vars, function(x_var) {
      plotname <- paste("plot", x_var, sep = "_")
      plotOutput(plotname, height = '250px')  # Create plot output for each binary variable
    })
    
    do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
  })
  
  output$continuous_plots <- renderUI({
    continuous_x_vars <- Filter(function(x) get_variable_type(iris[[x]]) == "continuous", input$x_sel)  # Filter continuous variables
    plot_output_list <- lapply(continuous_x_vars, function(x_var) {
      plotname <- paste("plot", x_var, sep = "_")
      plotOutput(plotname, height = '250px')  # Create plot output for each continuous variable
    })
    
    do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
  })
  
  output$string_plots <- renderUI({
    string_x_vars <- Filter(function(x) get_variable_type(iris[[x]]) == "string", input$x_sel)  # Filter string variables
    plot_output_list <- lapply(string_x_vars, function(x_var) {
      plotname <- paste("plot", x_var, sep = "_")
      plotOutput(plotname, height = '250px')  # Create plot output for each string variable
    })
    
    do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
  })
  
  observe({
    req(input$y_sel, input$x_sel)  # Require selection of y and x variables
    
    lapply(input$x_sel, function(x_var) {
      output[[paste("plot", x_var, sep = "_")]] <<- renderPlot({  # Render plot for each selected x variable
        if (is.factor(iris[[x_var]]) || is.factor(iris[[input$y_sel]])) {  # Check if either x or y variable is a factor
          if (input$group_var == "None") {  # If no grouping variable selected
            ggplot(iris, aes_string(x = x_var, y = input$y_sel)) +  # Create boxplot without grouping
              geom_boxplot() +
              ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel))
          } else {
            ggplot(iris, aes_string(x = x_var, y = input$y_sel, color = input$group_var)) +  # Create boxplot with grouping
              geom_boxplot() +
              ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel, "with Group Coloring"))
          }
        } else {  # If neither x nor y variable is a factor (assumed to be continuous)
          if (input$group_var == "None") {  # If no grouping variable selected
            ggplot(iris, aes_string(x = x_var, y = input$y_sel )) +  # Create scatter plot without grouping
              geom_point() +
              ggtitle(paste("Scatter Plot of", x_var, "vs", input$y_sel))
          } else {
            ggplot(iris, aes_string(x = x_var, y = input$y_sel, color = as.character(input$group_var))) +  # Create scatter plot with grouping
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
