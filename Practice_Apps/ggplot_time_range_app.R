library(shiny)
library(gapminder)
library(tidyverse)
library(plotly)
library(shinyWidgets)

# Convert continent column to factor
gapminder$continent <- as.factor(gapminder$continent)
gapminder$year <-  as.Date(paste0(gapminder$year, "-01-01"))
# Get the names of factor columns in the dataset
factor_columns <- names(Filter(is.factor, gapminder))
max_year <- max(gapminder$year)

ui <- fluidPage(
  titlePanel("Gapminder Data Visualization"),
  sidebarLayout(
    sidebarPanel(
      selectInput("continent", "Select Factor Column:", choices = factor_columns,selected = 'continent'),
      airYearpickerInput(
        inputId = "range",
        label = "Select range of years:", range = T,
        #value = c(min(gapminder$year),max(gapminder$year))
        minDate = c(min(gapminder$year)), maxDate = c(max(gapminder$year))
      )
    ),
    mainPanel(
      plotlyOutput("gapminder_plot")
    )
  )
)

server <- function(input, output) {
  output$gapminder_plot <- renderPlotly({
    yr_input <<- input$range
    filtered_data <- gapminder %>%
      filter(year >= input$range[1] & year <= input$range[2])
    
    g <- highlight_key(filtered_data, ~filtered_data[[input$continent]])
    gg <- ggplot(g, aes(gdpPercap, lifeExp, 
                        color = filtered_data[[input$continent]], frame = year)) +
      geom_point() +
      stat_smooth(se = FALSE, method = "lm") +
      scale_x_log10()
    
    p <- highlight(ggplotly(gg), "plotly_hover")
    p
  })
  
  
}

shinyApp(ui, server)
