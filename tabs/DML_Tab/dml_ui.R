source("./global.r")



#### Intro Text ####
# tags$p lets me adjust the font size after the html text
intro_text <- tags$div(HTML("
  <strong>Double Machine Learning (DML)</strong> is a powerful approach in causal analysis, specifically designed to address the limitations of using traditional machine learning methods for estimating causal parameters. Unlike correlation-based methods that may overlook the complexities of causal relationships, DML provides a robust framework for obtaining accurate estimates of individual regression coefficients, average treatment effects, and other essential parameters.<br><br>

  <strong>Key Advantages:</strong><br>
  <ol>
    <li><strong>Regularization Bias Mitigation:</strong> Most machine learning methods excel in prediction tasks but may introduce regularization bias when applied to estimating causal parameters. DML overcomes this bias by solving auxiliary prediction problems, ensuring more reliable and unbiased parameter estimates.</li><br>

    <li><strong>Optimal Convergence Rate:</strong> DML typically achieves the fastest convergence rate of 1/root(n), making it highly efficient for obtaining accurate estimates even with limited data.</li><br>

    <li><strong>Versatility with ML Models:</strong> DML leverages a variety of machine learning models, such as random forests, lasso, ridge, deep neural networks, boosted trees, and their hybrids. This versatility allows data scientists to choose the most suitable models for their specific analysis.</li><br>

    <li><strong>Cross-Fitting for Overfitting Prevention:</strong> To combat overfitting, DML employs K-fold sample splitting, known as cross-fitting. This approach ensures robust model performance by utilizing a diverse set of ML predictive methods.</li>
  </ol><br>

  <strong>Implementation Methodology:</strong><br>

  This app follows the methodology outlined in the research paper 'Double/Debiased Machine Learning for Treatment and Causal Parameters' by Victor Chernozhukov, Denis Chetverikov, Mert Demirer, Esther Duflo, Christian Hansen, Whitney Newey, and James Robins. By adopting the principles and techniques proposed in this paper, this app aims to provide data scientists with a comprehensive and effective tool for mastering double machine learning in causal analysis."
), class = 'increase-fontsize-text')

#### Methedology Text ####
methodology_text <- tags$div(HTML("
  <strong>Methodology:</strong><br>
  Our approach adapts to the nature of the treatment variable:<br><br>

  <ol>
    <li><strong>Continuous Treatment:</strong> For continuous treatments, a three-model approach is employed. We utilize Random Forest Regressor, XGBoost Regressor, and Lasso Regression. The final Average Treatment Effect (ATE) score for a continuous treatment is computed as the mean slope of these three models. Models with insignificant p-values are excluded from the computation.</li><br>

    <li><strong>Binary Treatment:</strong> In the case of binary treatments, a singular XGBoost Classification model is utilized to estimate the ATE.</li><br>

    <li><strong>Categorical Treatment:</strong> For categorical treatments represented as string columns, the algorithm dynamically generates additional binary columns for each distinct value in the string field and subsequently applies the XGBoost Classification model. Individual ATE scores are then calculated for each generated binary field.</li>
  </ol><br>

  This versatile methodology ensures robust and accurate estimation of treatment effects across various types of treatments.<br><br>
  
  <strong>DataTable Structure:</strong><br>
  The first Data Table tab 'ATE DT' displays the three-model average ATE score for continuous treatments and the singular ATE score for binary treatments. The 'Significant' column in the first data table flags whether the model has a significant p-value.The second tab 'Model Summary DT' displays a comprehensive data table for each individual model used for computing the ATE for each treatment. This table provides model summary statistics which includes: slopes, p-values, and confidence intervals."
), class = 'increase-fontsize-text')

#### css_body code ####
css_body <- tags$head(
  tags$style(
    HTML(" 
    /* Custom styles for notifications */
    .shiny-notification {  
      position: fixed;
      top: calc(50%);  
      left: calc(50%);  
      transform: translate(-50%, 0%);
      height: 100%;
      max-height: 40px;
      width: 100%;
      max-width: 480px;
      font-size: 24px;
      font-weight: bold;
      color: black;
    }
    
    /* darker font for break line */
    hr {
    border-top: 1px solid #000000;
       }
    
    /* border for iframe */
    iframe-border {
    border: 2px solid #000000;
    }
    
    /* hide slide header numbersin presentation */
    .slides > slide > htroup > h1 {
    display: none;
    }
    
    /* hide slide headers */
    .increase-fontsize-text {
    font-size: 20px;
    }
    
    /* Additional JavaScript code for custom options */
    /* Add your custom JavaScript code here */

    
    
         ")
  )
)

#### Hiden Btns ####
hidden_buttons <- conditionalPanel('false',verbatimTextOutput("globalenv"))

#### JS UI Body ####
JS_UI_body <- tags$script(HTML(
  "
        // JavaScript function to handle box minimization
        $(document).on('click', '.box-header .fa-minus', function() {
          var box = $(this).parents('.box').first();
          box.find('.box-body, .box-footer').slideUp();
          box.find('.box-header .fa-minus').removeClass('fa-minus').addClass('fa-plus');
        });
        
        // JavaScript function to handle box restoration
        $(document).on('click', '.box-header .fa-plus', function() {
          var box = $(this).parents('.box').first();
          box.find('.box-body, .box-footer').slideDown();
          box.find('.box-header .fa-plus').removeClass('fa-plus').addClass('fa-minus');
        });
        
        // Additional JavaScript code for custom options
        // Add your custom JavaScript code here
        
        
        
        "))
#### Google Slides PPT ####
# Hosting a google slides ppt
ppt <-  tags$iframe(
  id = "slidesIframe",
  src = "https://docs.google.com/presentation/d/e/2PACX-1vQLNvTbl2icrWS8nYTRswhfn8-sqJBUlLbsxlovPVkh6xp6KFDLmx3Z6BmcfofCcQ/embed?start=true&loop=true&delayms=60000",
  frameborder = 0 , width = "100%", height = 600,
  allowfullscreen = TRUE, mozallowfullscreen = TRUE, webkitallowfullscreen = TRUE
)




#### UI Body ####

dml_outcome <- tabPanel(
  "Causation",
  fluidPage(shinyjs::useShinyjs(),JS_UI_body, css_body,hidden_buttons,
            fluidRow(width=12,shinydashboardPlus::box(title = "Overview",collapsible = TRUE,width=12,  # Change "info" to the color you prefer
                                                      tabBox(id = 'overview_tabBox',
                                                             tabPanel('Overview', p(intro_text)),
                                                             tabPanel('Methodology', p(methodology_text))
                                                      ))),
            fluidRow(tags$hr(),width=12),
            br(),
            fluidRow(shinydashboardPlus::box( title = 'DML Powerpoint Explanation',collapsible = T,width = 12,
                                              ppt
                                              
            )),
            fluidRow(tags$hr()),
            br(),
            fluidRow(column(4,selectInput('outcome','Target Variable',selected = 'net_tfa', names(global_dat), multiple = F)), column(4,selectInput('treatments','Treatment Variables',names(global_dat), multiple = T))),fluidRow(column(4,numericInput('n_treats','top_n_treatments',value=NULL,min=1,max=100))),fluidRow(column(4,actionButton("dml", "Calculate", style = "fill", color = "success"))),tags$hr(),
            fluidRow(conditionalPanel(
              condition = "input.dml > 0",
              tabBox(id = "ppt_tabBox", title = 'Data Tables', width = 6,
                     tabPanel('ATE DT', dataTableOutput("ATE")),
                     tabPanel('Model Summary DT', dataTableOutput("plr"))
              )
            ))
            
  ))

#### Notes ####

"
If I ever have a need to display a powerpoint that is rendered from an RMD filed this is the code I need to use:
## rmd file:
- render slidy_presentation.Rmd
- move the html to the www folder

Server:
## this code allows for full screen capability
observeEvent(input$fullscreenBtn, {runjs('var elem = document.getElementById('slidesIframe'); if (!document.fullscreenElement) {elem.requestFullscreen(); } else {
if (document.exitFullscreen) {document.exitFullscreen();}}')})

UI: 
## create a variable that renders that allows me to access my html rendered from my 'slidy_presentation.Rmd' file
## even though the src pathfile doesn't reference a www having the .html in the www is necessary, for some reason we don't need to reference the www
ppt <-  tags$iframe(
  id = 'slidesIframe',
  src = './slidy_presentation.html', ### figure this out , 
  width = '100%', height = '766px',
  class = 'iframe-border',
  allowfullscreen = TRUE, mozallowfullscreen = TRUE, webkitallowfullscreen = TRUE
)

## output the object like so:
column(width=6,align='center',actionButton('fullscreenBtn', 'Toggle Fullscreen', onclick = 'toggleFullScreen();'),ppt)
"







