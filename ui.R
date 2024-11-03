source("./tabs/DML_Tab/dml_ui.R")
source("./tabs/DML_Tab/dml_server.R")

# CSS for the banner
css_navbar <- tags$style(HTML(
  '
  /* Set background color of navbar */
  .navbar-default {
    background-color: #024d70 !important;
  }
  
  /* Set styling for all tabs */
  .navbar-default .navbar-nav > li > a {
    color: white !important; /* Text color for all tabs is white */
    font-weight: bold !important; /* Always bold the tab titles */
  }

  /* Set styling for active tabs */
  .navbar-default .navbar-nav > .active > a,
  .navbar-default .navbar-nav > .active > a:focus,
  .navbar-default .navbar-nav > .active > a:hover {
    color: black !important; /* Text color for active tabs is black */
    background-color: white !important; /* Background color for active tabs is white */
  }
  '
))


#### Nav Bar UI ####
fluidPage( useWaiter() ,waiter_show_on_load(
  color = "#024d70",  # Overlay background color
  html = tagList(
    spin_3k(),        # Loading spinner
    h3("Loading Causal Analysis Tool...")  # Loading text
  )
),
# I don't think I nee dthe uioutput with the waiter_show_on_load, fix this to just be a server file modal
uiOutput("modalUI"),
  
  # Add CSS for the banner in the head
  tags$head(
    tags$style(HTML(" 
      .banner {
        width: 100%;
        background-color: #800080; /* Purple background */
        color: #FFFFFF; /* White text */
        text-align: center;
        padding: 0px;
        font-size: 18px;
        font-weight: bold;
      }
    "))
  ),
  
  # Banner div, placed above the navbarPage
  tags$div(class = "banner", "Example"),
  
  # Navbar page content
  navbarPage(
    id = 'tabs',
    title = tags$div(
      style = '
        text-align:left;
        font-size:16px;
        padding-left:0px;
        padding-bottom:0px;
        margin-bottom:0px;
        margin-top:0px;
      ',
      tags$a(
        href = "",
        tags$img(
          style = 'margin: -20px 0px 0px 0px; padding:0px;',
          src = "./dart-logo.png",
          height = '50'
        )
      ),
      tags$a(
        href = "",
        tags$img(
          style = 'margin: -10px 0px 0px 0px; padding:0px;',
          src = "./AMATLogo.png",
          height = '50',
          width = '50'
        )
      ),
      span('CAUSAL ANALYSIS TOOL', style = 'background-color: #024d70; color: white; font-weight: bold;font-size: 15px;'),
      tags$a(
        style = "font-size:10px;color:white;position:absolute;left:325px;top:34px; margin:0px; padding:0px;",
        glue::glue('v1.0')
      )
    ),
    Overview_tab,
    Explore_tab,
    DML_tab,
    csv_button_tab,
    css_navbar
  )
  )