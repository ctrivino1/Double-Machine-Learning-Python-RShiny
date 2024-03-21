source('./tabs/DML_Tab/dml_ui.R')
JS_navbar <- tags$script(HTML(
  "var header = $('.navbar > .container-fluid');
   var githubURL = 'https://github.com/ctrivino1/Double-Machine-Learning-Python-RShiny.git'; 
   header.append('<div style=\"float:right;margin-right: 10px;\"><a href=\"' + githubURL + '\"><img src=\"github_logo.png\" alt=\"GitHub\" style=\"width:75px;height:50px;padding-top:2px;\"></a></div>');
   header.append('<div style=\"float:right;margin-right: 10px;padding-top:20px;\"><a href=\"' + githubURL + '\">Follow me on GitHub</a></div>');"
))

css_navbar <- tags$style(HTML('
    .navbar-default {
        background-color: #28b78d !important;
    }

'))

#### Nav Bar UI ####
navbarPage(id = 'tabs', span( "Causal Analysis App", style = "background-color: ##28b78d; color: white"), dml_outcome,JS_navbar,css_navbar)
# colors: bs_theme(bg ='#2222', fg ='#F3F6F8',,success = '#00BC8C'  ) 




