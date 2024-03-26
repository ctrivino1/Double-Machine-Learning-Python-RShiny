source('./tabs/DML_Tab/dml_ui.R')

JS_navbar <- tags$script(HTML(
  '
  // Add GitHub logo and text link to the navbar
  $(document).ready(function() {
    var header = $(".navbar > .container-fluid");
    var githubURL = "https://github.com/ctrivino1/Double-Machine-Learning-Python-RShiny.git"; 
    header.append(\'<div style="float:right;margin-right: 10px;padding-top:20px;"><a href="\' + githubURL + \'" target="_blank" style="color: white; text-decoration: underline;">Follow me on GitHub</a></div>\');
    header.append(\'<div style="float:right;margin-right: 10px;"><a href="\' + githubURL + \'" target="_blank"><img src="github_logo.png" alt="GitHub" style="width:75px;height:50px;padding-top:2px;"></a></div>\');
  });
  '
))


css_navbar <- tags$style(HTML(
  '
  /* Set background color of navbar */
  .navbar-default {
    background-color: #28b78d !important;
  }
  
  /* Set styling for active tabs */
  .navbar-default .navbar-nav > .active > a,
  .navbar-default .navbar-nav > .active > a:focus,
  .navbar-default .navbar-nav > .active > a:hover {
    color: #555 !important; /* Text color for active tabs */
    background-color: white !important; /* Background color for active tabs is white */
  }
  '
))


#### Nav Bar UI ####
navbarPage(id = 'tabs', span( 'Causal Analysis App', style = 'background-color: ##28b78d; color: white'), dml_outcome,JS_navbar,css_navbar)





