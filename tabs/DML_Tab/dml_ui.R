source("./global.r")
logger::log_info('dml_ui.r started')



# tags$p lets me adjust the font size after the html text
#### App Intro Text ####
app_overview <- tags$div(HTML("
  <div>
    <h2><strong>Welcome to Our Application:</strong></h2>
    <p>Our application is designed for causal analysis and exploration of data. It is equipped with two main functionalities: 'Explore' and 'Causal Analysis'.</p>
    
    
    <h3><strong>Purpose:</strong></h3>
    <p>The primary objective of our app is to uncover causal relationships between various metrics of interest. By leveraging advanced statistical techniques, users can analyze their data to identify factors that influence the outcome of interest, allowing for informed decision-making and deeper understanding of the underlying relationships.</p>
    
    <h3><strong>Explore Tab:</strong></h3>
    <p>The 'Explore' tab provides users with a flexible platform to visualize and analyze their data according to their preferences. Users can create custom graphs and plots, explore trends, patterns, and relationships within their data, and gain valuable insights to inform further analysis.</p>
    
    <h3><strong>Causal Analysis Tab:</strong></h3>
    <p>In the 'Causal Analysis' tab, our app utilizes advanced methodologies such as double machine learning to estimate average treatment effects. By employing sophisticated statistical techniques, users can assess the causal impact of various interventions or treatments on the outcome of interest, providing valuable insights for decision-making and policy evaluation.</p>
  </div>
"), class = 'increase-fontsize-text')

dml_intro_text <- tags$div(HTML("
  <strong>Double Machine Learning (DML)</strong> is a powerful approach in causal analysis, specifically designed to address the limitations of using traditional machine learning methods for estimating causal parameters. Unlike correlation-based methods that may overlook the complexities of causal relationships, DML provides a robust framework for obtaining accurate estimates of individual regression coefficients, average treatment effects, and other essential parameters.<br><br>

  <strong>Key Advantages:</strong><br>
  <ol>
    <li><strong>Regularization Bias Mitigation:</strong> Most machine learning methods excel in prediction tasks but may introduce regularization bias when applied to estimating causal parameters. DML overcomes this bias by solving auxiliary prediction problems, ensuring more reliable and unbiased parameter estimates.</li><br>

    <li><strong>Optimal Convergence Rate:</strong> DML typically achieves the fastest convergence rate of 1/root(n), making it highly efficient for obtaining accurate estimates even with limited data.</li><br>

    <li><strong>Versatility with ML Models:</strong> DML leverages a variety of machine learning models, such as random forests, lasso, ridge, deep neural networks, boosted trees, and their hybrids. This versatility allows data scientists to choose the most suitable models for their specific analysis.</li><br>

    <li><strong>Cross-Fitting for Overfitting Prevention:</strong> To combat overfitting, DML employs K-fold sample splitting, known as cross-fitting. This approach ensures robust model performance by utilizing a diverse set of ML predictive methods.</li>
  </ol><br>"
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

  <strong>Elasticnet for Independent Treatment Variables:</strong><br>
  To identify Independent treatment variables, we employ the Elasticnet algorithm. Elasticnet is a hybrid regularization method that combines the penalties of Lasso and Ridge regression, providing a balance between variable selection and coefficient shrinkage. By utilizing Elasticnet, we aim to identify the most influential and relevant Independent treatment variables in our analysis.<br><br>

  This versatile methodology ensures robust and accurate estimation of treatment effects across various types of treatments.<br><br>
  
  

  <strong>Double Machine Learning:</strong><br>
  
  Our application harnesses the Double Machine Learning (DML) methodology to uncover causal relationships among diverse metrics of interest. This approach offers invaluable insights that are crucial for informed decision-making and policy evaluation. This methodology is outlined in the research paper 'Double/Debiased Machine Learning for Treatment and Causal Parameters', authored by Victor Chernozhukov, Denis Chetverikov, Mert Demirer, Esther Duflo, Christian Hansen, Whitney Newey, and James Robins. By incorporating insights from the Elasticnet algorithm into the Double Machine Learning process, we enhance the accuracy and robustness of our causal analysis.
  
  "
), class = 'increase-fontsize-text')

#### Explore DML intro tab ####
explore_tab_graph_intro <- tags$div(
  HTML("
    This application contains the following tabs:<br><br>
    <strong>Binary:</strong> Visualizes binary columns by a continuous variable.<br><br>
    <strong>Continuous:</strong> Visualizes continuous variables (e.g., Depot Rate, MC. Rate) by continuous variables.<br><br>
    <strong>String:</strong> Visualizes string values (e.g., 'bases') by a continuous variable.<br><br>
    <strong>Usage Instructions:</strong><br><br>
    Please select filters above to narrow down the data displayed in the graphs.<br><br>
    The data table to the right will reflect the data corresponding to the populated graphs and will dynamically change based on the rows of data that you click on.
  ")
)
                                         
                                         
                                         

#### css_body code ####
css_body <- tags$head(
  tags$style(
    HTML(" 
    $(document).ready(function() {
      $('button[data-add=\"rule\"]').contents().last()[0].textContent = 'Add Filter';
    });
    
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
    
    /* creating a class '.custom-tab-scrollbar' to add a scroll bar to the contents displayed in tabs */
    .custom-tab-scrollbar {
      height: 50vh;
      overflow-y: auto;
      padding: 10px;
    }
    
    /* creating a class name '.full_screen' */
    .full-screen {
      position: fixed;
      height: 98vh !important;
      width: 98vw !important;
      left: 0;
      top: 0;
      z-index: 9999;
      overflow: hidden;
    }
    
    /* Creating custom vertical dotted line */
    .vertical-dotted-line {
      border-left: 2px dotted #28b78d; /* Adjust color and thickness as needed */
      height: 100vh; /* Adjust height as needed */
    }
    
    
    
    
    /* Need both of the following two sections: .selectize-input & .rule-value-container widths set so that the selection options are seable */
    .selectize-input input[type='text'] {
      width: 300px !important; /* Adjust the width as needed */
    }
    .rule-value-container {
    border-left: 1px solid #ddd;
    padding-left: 5px;
    width: 300px;
    }
    
    
    
    
    
    
    }
  ")
  ),
  tags$style(
    HTML("
         /* enabling tooltip for the Jquery slider selcections */
    .tooltip {
    position: absolute;
    z-index: 1070;
    display: none; /* Initially hide tooltip */
    font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
    font-style: normal;
    font-weight: 400;
    line-height: 1.42857143;
    line-break: auto;
    text-align: left;
    text-align: start;
    text-decoration: none;
    text-shadow: none;
    text-transform: none;
    letter-spacing: normal;
    word-break: normal;
    word-spacing: normal;
    word-wrap: normal;
    white-space: normal;
    font-size: 12px;
    filter: alpha(opacity = 100); /* For older versions of IE */
    opacity: 1; /* Make the tooltip fully visible */
    color: #ffffff; /* Text color */
    background-color: #000000; /* Background color */
    
    /* Lower the position of the tooltip */
    bottom: 15px; /* Adjust the value as needed */
    }
  ")
  )
)




#### Hiden Btns ####
hidden_buttons <- conditionalPanel('false',verbatimTextOutput("globalenv"),downloadButton('combined_data'))


#### JS UI Body ####
jss_body <- tags$head(
  tags$style(HTML("
    // put style tags here
  ")),
  tags$script(HTML("

    

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

    // Code to automatically click the minimize options on all sections in the app that can be minimized
    $(document).ready(function(){
        // Simulate a click on the collapse button
        $('.box-header .fa-minus').click();
    });

    // Additional JavaScript code for custom options
    // Add your custom JavaScript code here
    
    
    // expand the button by defualt in the Causal analysis tab
    $(document).ready(function() {
      var box = $('#Test');
      if (box.hasClass('collapsed-box')) {
        // Expand the box
        box.removeClass('collapsed-box');
        box.find('.fa-plus').removeClass('fa-plus').addClass('fa-minus');
        box.find('.box-body, .box-footer').show();
      }
    });
    
    
    
  "))
)



#### Google Slides PPT ####

ppt <-  tags$iframe(
  id = 'slidesIframe',
  src = './slidy_presentation.html', ### figure this out , 
  width = '100%', height = '766px',
  class = 'iframe-border',
  allowfullscreen = TRUE, mozallowfullscreen = TRUE, webkitallowfullscreen = TRUE
)





#### Overview Tab ####
Overview_tab <- tabPanel(
  title = 'OVERVIEW',
  fluidPage(
    shinyjs::useShinyjs(),introjsUI(),
    useQueryBuilder(bs_version='5'),
    jss_body,
    css_body,
    hidden_buttons,
    tabBox(
    tabPanel('Summary',p(app_overview)),
    tabPanel('Causal Analsyis Methodology',
    fluidRow(
      shinydashboardPlus::box(
        title = NULL,
        collapsible = FALSE,
        width = NULL,
        tabBox( width = NULL,
                id = 'overview_tabBox', 
                tabPanel('App Methodology', p(methodology_text)),
                tabPanel(width= NULL,'Double Machine Learning', p(dml_intro_text)),
                tabPanel(
                  'DML PPT',
                  column(
                    width = 12,
                    align = 'center',
                    actionButton('fullscreenBtn', 'Toggle Fullscreen', onclick = 'toggleFullScreen();'),
                    tags$div(
                      style = 'margin-top: 10px;',  # Optional: Adds some space between the button and the text
                      span("Click on the powerpoint in order to scroll through slides with arrow keys, click the 'esc' key to exit full screen.")
                    ),
                    ppt
                  )
                )
        )
      )
    )))  # Move tags$hr() inside the fluidRow() function
  )
)


#### Explore Tab ####
Explore_tab <- tabPanel(
  title = 'EXPLORE',
  fluidRow(
    width = 12,
    box(
      title = 'Filters',
      collapsible = FALSE,
      width = 12,
      fluidRow(
        column(
          width = 2,
          pickerInput(
            inputId = "y_sel",
            label = "Select y variable",
            choices = NULL,
            options = list(
              `actions-box` = TRUE,
              `live-search` = TRUE,
              `selected-text-format` = "count > 3",
              `count-selected-text` = "{0} items selected",
              `deselect-all-text` = "Clear All",
              `select-all-text` = "Select All",
              `none-selected-text` = "None selected"
            ),
            multiple = FALSE
          )
        ),
        column(
          width = 2,
          pickerInput(
            inputId = "x_sel",
            label = "Select x variables",
            choices = NULL,
            options = list(
              `actions-box` = TRUE,
              `live-search` = TRUE,
              `selected-text-format` = "count > 2",
              `count-selected-text` = "{0} items selected",
              `deselect-all-text` = "Clear All",
              `select-all-text` = "Select All",
              `none-selected-text` = "None selected"
            ),
            multiple = TRUE
          )
        ),
        column(
          width = 2,
          pickerInput(
            inputId = "group_var",
            label = "Choose color grouping variable",
            choices = NULL, #c('None selected', names(global$data)[sapply(global$data, function(x) get_variable_type(x) == "binary") | sapply(global$data, function(x) get_variable_type(x) == "string")]),
            options = list(
              `actions-box` = TRUE,
              `live-search` = TRUE,
              `count-selected-text` = "{0} items selected",
              `deselect-all-text` = "Clear All",
              `select-all-text` = "Select All",
              `none-selected-text` = "None selected"
            ),
            multiple = FALSE
          ), 
          conditionalPanel(
            condition = "input.group_var != 'None selected'",
            pickerInput(
              inputId = "group_var_values",
              label = "Select values",
              choices =  NULL,
              options = list(
                `actions-box` = TRUE,
                `live-search` = TRUE,
                `selected-text-format` = "count > 3",
                `count-selected-text` = "{0} items selected",
                `deselect-all-text` = "Clear All",
                `select-all-text` = "Select All",
                `none-selected-text` = "None selected"
              ),
              multiple = TRUE
            )
          )
        )#,
        # column(width = 2,
        #        airMonthpickerInput(
        #          inputId = "month_range",
        #          label = "Select range of Month/Year:", range = T,
        #          #value = c(min(gapminder$year),max(gapminder$year))
        #          minDate = c(min(global$dat_copy$dt_time)), maxDate = c(max(global$dat_copy$dt_time))
        #        )),
        # column(width = 2,airYearpickerInput(
        #          inputId = "year_range",
        #          label = "Select range of years:", range = T,
        #          #value = c(min(gapminder$year),max(gapminder$year))
        #          minDate = c(min(global$dat_copy$dt_time)), maxDate = c(max(global$dat_copy$dt_time))),
        #        checkboxInput("all_years", "Include All Years", value = FALSE))
        ),
      # fluidRow(
      #   column(width =6,actionBttn("explore_charts", "Calculate", style = "fill", color = "success"))
      # ),
      fluidRow(tags$hr()),
      fluidRow(
        column(
          width = 7,
          tags$div(
            class = "custom-tab-scrollbar",
            tabBox(width = '100%',
                   tabPanel('Introduction', p(explore_tab_graph_intro)),
                   tabPanel(textOutput('binary_count'), withSpinner(uiOutput("binary_plots"),color = '#28b78d')),
                   tabPanel(textOutput('continuous_count'), withSpinner(uiOutput("continuous_plots"),color = '#28b78d')),
                   tabPanel(textOutput('string_count'), withSpinner(uiOutput("string_plots"),color = '#28b78d')),
                   id = "tabset1"
            )
          )
        ),column(
          width = 1,
          tags$div(class = "vertical-dotted-line"),style = "padding: 0; margin: 0;"
        ),
        column(width=4, DTOutput("data_table",width = '100%'),style = "padding: 0; margin: 0;")
      )
    )
  ),
  fluidRow(tags$hr(), width = 12),
  br())






#### DML Tab ####
DML_tab <- tabPanel(
  title = 'CAUSAL ANALYSIS',
  fluidRow(
    box(
      title = 'Selection Criteria',
      collapsible = TRUE,
      collapsed = TRUE,
      id = "Test",
      width = 12,
      fluidRow(
        column(
          width = 12,
          actionButton("help", "Press for instructions", style = "margin-bottom: 20px; border: 2px solid yellow;")
        )
      ),
      fluidRow(
        style = "display: flex; justify-content: space-between;",  # Flexbox for horizontal alignment
        div(
          style = "flex: 1; padding: 5px;",
          introBox(
            box(
              title = "Step 1: Pick Predictive Variable",
              width = NULL,
              fluidRow(
                column(
                  width = 12,
                  introBox(
                    box(
                      title = NULL,
                      width = NULL,
                      pickerInput('outcome', 'Predictive Variable', selected = NULL, choices = NULL, multiple = FALSE,
                                  options = list(
                                    `actions-box` = TRUE,
                                    `live-search` = TRUE,
                                    `none-selected-text` = "N/A"
                                  ))
                    ),
                    data.step = 1,
                    data.intro = "Pick the predictive variable for your analysis."
                  )
                )
              )
            )
          )
        ),
        div(
          style = "flex: 1; padding: 5px;",
          introBox(
            box(
              title = "Step 2: Filter the data",
              width = NULL,
              fluidRow(
                column(
                  width = 12,
                  h4("Builder"),
                  uiOutput("querbuilder_ui"),
                  column(
                    width = 12,
                    bsCollapsePanel(
                      'Unselect Unnecessary Metrics',
                      tags$p(
                        style = "font-weight: bold; color: #333; margin-bottom: 10px;",
                        "Please uncheck any unnecessary metrics to exclude them from the analysis. Ensure that the target feature remains checked."
                      ),
                      uiOutput("treeview_ui")
                    )
                  )
                )
              )
            ),
            data.step = 2,
            data.intro = "Use the query builder to refine your data, which can be an iterative process to explore DML-driven insights."
          )
        ),
        div(
          style = "flex: 1; padding: 5px;",
          introBox(
            box(
              title = 'Step 3: Find Treatments',
              width = NULL,
              fluidRow(
                column(
                  width = 12,
                  div(
                    style = "margin-top: 0px;",
                    actionBttn("en", "Find Treatments", style = "fill", color = "success")
                  )
                ),
                conditionalPanel(
                  condition = 'input.en > 0',
                  column(
                    width = 12,
                    div(
                      style = "margin-top: 0px;",
                      tabBox(
                        width = NULL,
                        id = 'overview_tabBox', 
                        tabPanel('Ind', 
                                 pickerInput(
                                   inputId = 'treatments',
                                   label = 'Treatment Variables',
                                   choices = NULL,
                                   multiple = TRUE,
                                   options = list(
                                     `actions-box` = TRUE,
                                     `live-search` = TRUE,
                                     `selected-text-format` = "count > 3",
                                     `count-selected-text` = "{0} items selected",
                                     `deselect-all-text` = "Clear All",
                                     `select-all-text` = "Select All",
                                     `none-selected-text` = "N/A"
                                   )
                                 )
                        ),
                        tabPanel('Eval', dataTableOutput('EN_eval'))
                      )
                    )
                  )
                )
              )
            ),
            data.step = 3,
            data.intro = "Compute/Select found independent variables"
          )
        ),
        div(
          style = "flex: 1; padding: 5px;",
          introBox(
            box( 
              width = NULL,
              title = 'Step 4: Execute DML Analysis',
              fluidRow(
                column(
                  width = 12,
                  div(
                    style = "margin-top: 0px;",
                    actionBttn("dml", "DML", style = "fill", color = "success")
                  ),
                  conditionalPanel(
                    condition = 'input.dml > 0',
                    column ( width = 12,
                             tabBox(
                               id = 'dml_data_tabbox',
                               width = 12,
                               tabPanel('ATE DT', dataTableOutput('ATE')),
                               tabPanel('Model Summary DT', dataTableOutput('plr'))
                             ))
                  )
                )
              )
            ),
            data.step = 4,
            data.intro = "Run DML after selecting treatment variables. Click the DML button to run the analysis.",
            data.position = "bottom"
          )
        )
      )
    )
  )
)

logger::log_info('dml.ui finished')

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


## conditionalPanel(
condition = 'input.dml > 0',
box(
  title = 'Conditional Data Tables',
  width = 12,
  tabBox(
    id = 'dml_data_tabbox',
    title = 'Data Tables',
    width = 6,
    tabPanel('ATE DT', dataTableOutput('ATE')),
    tabPanel('Model Summary DT', dataTableOutput('plr'))
  )
)
)
"
