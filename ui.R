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

JS_navbar <- tags$script(HTML( 
  
  '
 
  // Add GitHub logo and text link to the navbar
 
  $(document).ready(function() {
 
    var header = $(".navbar > .container-fluid");
 
    var githubURL = "https://github.com/ctrivino1/Double-Machine-Learning-Python-RShiny.git"; 
 
    header.append(\'<div style="float:right;margin-right: 10px;padding-top:20px;"><a href="\' + githubURL + \'" target="_blank" style="color: white; text-decoration: underline;">Follow me on GitHub</a></div>\');
 
    header.append(\'<div style="float:right;margin-right: 10px;"><a href="\' + githubURL + \'" target="_blank"><img src="github_logo.png" alt="GitHub" style="width:75px;height:50px;padding-top:2px;"></a></div>\');
 
  });
 
  '))


#### Nav Bar UI ####
fluidPage( useWaiter() ,waiter_show_on_load(
  color = "#024d70",  # Overlay background color
  html = tagList(
    spin_3k(),        # Loading spinner
    h3("Loading Causal Analysis Tool...")  # Loading text
  ),
), useShinyjs(),
actionButton("open_modal", "Upload CSV", class = "btn-primary"),
  
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
  tags$div(
    class = "banner",
    style = "display: flex; flex-direction: column; align-items: center; font-size: 15px;",
  
    # Main title text
  tags$div(
    span("CAUSAL ANALYSIS TOOL")
  ),
  
  # Version text positioned underneath
  tags$div(
    style = "font-size: 10px; margin-top: 0px;",
    glue::glue("v1.0")
  )
  ), 
  #hide the navbar title text
  tags$head(tags$style(type = 'text/css','.navbar-brand{display:none;}')),
  
  # Navbar page content
  navbarPage(
    id = 'tabs',
    title = 'CAUSAL ANALYSIS TOOL',
    Overview_tab,
    Explore_tab,
    DML_tab,
    JS_navbar,
    css_navbar
  )
  )