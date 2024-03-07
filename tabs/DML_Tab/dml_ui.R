<<<<<<< HEAD
source("./global.r")
css_body <- tags$head(
  tags$style(
    HTML(" 
    .shiny-notification{  
    position: fixed;
    top: calc(50%);  
    left: calc(50%);  
    transform: translate(-50%,0%);
    height: 100%;
    max-height: 40px;
    width: 100%;
    max-width: 480px;
    font-size: 24px;
    font-weight: bold;
    color: black;}")))

hidden_buttons <- conditionalPanel('false',verbatimTextOutput("globalenv"))
         
         

dml_outcome <- tabPanel(
  "Causation", 
  fluidPage(useShinyjs(), css_body,fluidRow(column(4,selectInput('outcome','Target Variable',selected = 'net_tfa', names(global_dat), multiple = F)), column(4,selectInput('treatments','Treatment Variables',names(global_dat), multiple = T))),fluidRow(column(4,numericInput('n_treats','top_n_treatments',value=NULL,min=1,max=100))),fluidRow(column(4,actionBttn("dml", "Calculate", style = "fill", color = "success"))),tags$hr(), fluidRow(column(4,dataTableOutput("ATE")), column(4,dataTableOutput("plr")), hidden_buttons
            
            )))
            
            
           




=======
source("~/DML_2/global.r")
css_body <- tags$head(
  tags$style(
    HTML(" 
    .shiny-notification{  
    position: fixed;
    top: calc(50%);  
    left: calc(50%);  
    transform: translate(-50%,0%);
    height: 100%;
    max-height: 40px;
    width: 100%;
    max-width: 480px;
    font-size: 24px;
    font-weight: bold;
    color: black;}")))
         
         

dml_outcome <- tabPanel(
  "Causation", 
  fluidPage(css_body,fluidRow(column(4,selectInput('outcome','Target Variable',selected = 'net_tfa', names(global_dat), multiple = F)), column(4,selectInput('treatments','Treatment Variables',names(global_dat), multiple = T))),fluidRow(column(4,numericInput('n_treats','top_n_treatments',value=NULL,min=1,max=100)),column(4,verbatimTextOutput("filter"))),fluidRow(column(4,actionBttn("dml", "Calculate", style = "fill", color = "success"))),tags$hr(), fluidRow(column(4,dataTableOutput("ATE")), column(4,dataTableOutput("plr")),column(4,plotlyOutput("plotlygraph"))
            
            )))
            
            
           




>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
