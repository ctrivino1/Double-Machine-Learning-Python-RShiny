source('./tabs/DML_Tab/dml_ui.R')
JS_navbar <- tags$script(HTML(
  "
   / This puts the logo and text link to my github repo
   var header = $('.navbar > .container-fluid');
   var githubURL = 'https://github.com/ctrivino1/Double-Machine-Learning-Python-RShiny.git'; 
   header.append('<div style=\"float:right;margin-right: 10px;\"><a href=\"' + githubURL + '\"><img src=\"github_logo.png\" alt=\"GitHub\" style=\"width:75px;height:50px;padding-top:2px;\"></a></div>'); 	
   header.append('<div style=\"float:right;margin-right: 10px;padding-top:20px;\"><a href=\"' + githubURL + '\">Follow me on GitHub</a></div>');"
))

css_navbar <- tags$style(HTML("
    /* this makes the navBar a specific color */
    .navbar-default {
        background-color: #28b78d !important;
    }
    
    /* This makes the tab background whie */
    .navbar-default .navbar-nav > .active > a,
    .navbar-default .navbar-nav > .active > a:focus,
    .navbar-default .navbar-nav > .active > a:hover {
        color: #555 !important; /* Set text color for active tabs */
        background-color: white !important; /* Set background color for active tabs */
    }

"))

#### Nav Bar UI ####
navbarPage(id = 'tabs', span( 'Causal Analysis App', style = 'background-color: ##28b78d; color: white'), dml_outcome,JS_navbar,css_navbar)





