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

box_collapse_functionality <- tags$script(HTML(
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
        "))

### for powerpoint 
ppt <-  tags$iframe(
  id = "slidesIframe",
  src = "https://docs.google.com/presentation/d/e/2PACX-1vQLNvTbl2icrWS8nYTRswhfn8-sqJBUlLbsxlovPVkh6xp6KFDLmx3Z6BmcfofCcQ/embed?start=true&loop=true&delayms=60000",
 #src = './www/dml_ppt_rshiny.pptx', ### figure this out
  frameborder = 0 , width = "100%", height = 600,
  allowfullscreen = TRUE, mozallowfullscreen = TRUE, webkitallowfullscreen = TRUE
)



dml_outcome <- tabPanel(
  "Causation",  
  fluidPage(shinyjs::useShinyjs(),box_collapse_functionality, css_body,hidden_buttons,
        shinydashboardPlus::box(solidHeader = T,title = "Overview",collapsible = T,
        p("blah blah"),
        p(),
        p(strong("Note:"),"blah"),
        p(strong("Table Guide:")),
        p("blah blah"),
        p(),
        p("Dblah"),
        p(strong("Note:"),"blah"),
        p("**(In order to use this tool successfully, please read blah and see the powerpoints)"),width=12),
        box(solidHeader = T, title = 'Overview',collapsible = T,width = 12,ppt),fluidRow(column(4,selectInput('outcome','Target Variable',selected = 'net_tfa', names(global_dat), multiple = F)), column(4,selectInput('treatments','Treatment Variables',names(global_dat), multiple = T))),fluidRow(column(4,numericInput('n_treats','top_n_treatments',value=NULL,min=1,max=100))),fluidRow(column(4,actionButton("dml", "Calculate", style = "fill", color = "success"))),tags$hr(), 
        #fluidRow(tabBox( id = "myTabBox", title = 'Data Tables', width = 6,
          #tabPanel('Tab 1',dataTableOutput("ATE")), tabPanel('Tab 2',dataTableOutput("plr")))
        fluidRow(conditionalPanel(
          condition = "input.dml > 0",
          tabBox(id = "myTabBox", title = 'Data Tables', width = 6,
                 tabPanel('Tab 1', dataTableOutput("ATE")), 
                 tabPanel('Tab 2', dataTableOutput("plr"))
          )
        ))

  ))










