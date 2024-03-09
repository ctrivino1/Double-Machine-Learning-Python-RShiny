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

### for powerpoint 
ppt <-  tags$iframe(
  id = "slidesIframe",
  src = "https://docs.google.com/presentation/d/e/2PACX-1vQLNvTbl2icrWS8nYTRswhfn8-sqJBUlLbsxlovPVkh6xp6KFDLmx3Z6BmcfofCcQ/embed?start=true&loop=true&delayms=60000",
  #src = './www/dml_ppt_rshiny.pptx', ### figure this out
  frameborder = 1, width = "100%", height = 600,
  allowfullscreen = TRUE, mozallowfullscreen = TRUE, webkitallowfullscreen = TRUE
)



dml_outcome <- tabPanel(
  "Causation", 
  fluidPage(useShinyjs(), css_body,box(solidHeader = T, title = 'Overview',collapsible = T,width = 12,
                                       p("
       The purpose of this dashboard is blah. This app consists of blah. explanation of how app works, how users can navigate"), 
                                       p(),
                                       p(strong("Note:"),"blah blah"),
                                       p(strong("Table Guide:")),
                                       p("When a table is generated, you may download, print, copy, or merge the table with your inputted csv. r all time recorded."),
                                       p(),
                                       p("Double click on any NIIN row to generate a time-series graph that visualizes the overall requisitions and usages of a particular NIIN."),
                                       p(strong("Note:"),"This data is pulled from blah. (This app will be updated fro blah in the future)"),
                                       p("**(In order to use this tool successfully, please read )**"),
                                       ppt),fluidRow(column(4,selectInput('outcome','Target Variable',selected = 'net_tfa', names(global_dat), multiple = F)), column(4,selectInput('treatments','Treatment Variables',names(global_dat), multiple = T))),fluidRow(column(4,numericInput('n_treats','top_n_treatments',value=NULL,min=1,max=100))),fluidRow(column(4,actionButton("dml", "Calculate", style = "fill", color = "success"))),tags$hr(), fluidRow(column(4,dataTableOutput("ATE")), column(4,dataTableOutput("plr")), hidden_buttons
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
  )))







