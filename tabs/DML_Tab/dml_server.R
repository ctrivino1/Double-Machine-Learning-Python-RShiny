source("./global.r")
source_python("./functions/dml.py")


####  Python dml function ####
render_dml_tab <- 
  function(input, output,session) {
    output$value <- renderText({input$n_treats})
    observeEvent(input$dml, {
      print("button clicked")
      show_modal_spinner(
        spin = "cube-grid",
        color = "firebrick",
        text = "Please wait..."
      )
      if (is.null(input$treatments) && !is.na(input$n_treats)){
        print("n_treatments")
        print(input$n_treats)
        test_global_dat <<- global_dat
        py_dat <<- r_to_py(global_dat)
        
        py_result <- dml_func(data=py_dat,outcome = input$outcome, n_treatments = input$n_treats)
        print("py_result worked")
          
          
          filter1 <- subset(py_result[[1]], Significant != 'FALSE')
          global$ATE_summary  <-subset(filter1, ATE != 'NULL')
          global$plr_summary <- py_result[[2]]
          update_modal_progress(1)
          remove_modal_spinner()
          
          
        #}
      }else if (!is.null(input$treatments) && is.na(input$n_treats)) {
        #print("treatment list given")
        #print(input$treatments)
        py_dat <- r_to_py(global_dat)
        py_result <- dml_func(data=py_dat,outcome = input$outcome, treatments = input$treatments)
        
       # gets rid of duplicate treatments and keeps the treatment that is signficiant
        ate_sum <<- py_result[[1]] %>% group_by(treatment) %>% filter(!(Significant == F  & n() >1))
        
          global$ATE_summary  <- ate_sum
          test <<- py_result[[1]]
          print("ATE data")
          print(global$ATE_summary)
          global$plr_summary <- py_result[[2]]
        
        remove_modal_spinner()
      } else {
        remove_modal_spinner()
        showNotification("Please only select treatments, or n_treatments, there should not be values in both")
      }
      remove_modal_spinner()
      
    })
    
    #### Exploratory Graph Functions/Functionality ####
    # update the picker input selection based on input$group_var column
    observeEvent(input$group_var, {
      print("input$group_var")
      print(input$groupPvar)
      unique_values <- unique(global_dat[[input$group_var]])
      print("unique values")
      print(unique_values)
      updatePickerInput(session, "group_var_values", choices = unique_values)
    })
    # Function to update selected x variables
    update_selected_x_vars <- function() {
      # Update selected x variables
      global$selected_x_vars <- lapply(input$x_sel, function(x_var) {
        list(name = x_var, type = get_variable_type(global_dat[[x_var]]))
      })
    }
    
    # Observer to update counts and selected x variables
    observeEvent(input$x_sel, {
      req(input$x_sel)  # Require selection of x variables
      
      # Update selected x variables
      update_selected_x_vars()
      
      # Calculate counts based on selected x variables
      binary_count <- sum(sapply(global$selected_x_vars, function(var) var$type == "binary"))
      continuous_count <- sum(sapply(global$selected_x_vars, function(var) var$type == "continuous"))
      string_count <- sum(sapply(global$selected_x_vars, function(var) var$type == "string"))
      
      # Update global counts
      global$binary_count <- binary_count
      global$continuous_count <- continuous_count
      global$string_count <- string_count
      
      # Print counts to console
      cat("Binary count:", global$binary_count, "\n")
      cat("Continuous count:", global$continuous_count, "\n")
      cat("String count:", global$string_count, "\n")
    })
    
    output$binary_count <- renderText({
      paste("Binary (", global$binary_count, ")")
    })
    
    output$continuous_count <- renderText({
      paste('Continuous (', global$continuous_count, ')')
    })
    
    output$string_count <- renderText({
      paste("String (", global$string_count, ")")
    })
    
    output$binary_plots <- renderUI({
      binary_x_vars <- Filter(function(x) get_variable_type(global_dat[[x]]) == "binary", input$x_sel)  # Filter binary variables
      plot_output_list <- lapply(binary_x_vars, function(x_var) {
        plotname <- paste("plot", x_var, sep = "_")
        plotlyOutput(plotname, height = '300px',width = '70%')  # Create plot output for each binary variable
      })
      
      do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
    })
    
    output$continuous_plots <-  renderUI({
      continuous_x_vars <- Filter(function(x) get_variable_type(global_dat[[x]]) == "continuous", input$x_sel)  # Filter continuous variables
      plot_output_list <- lapply(continuous_x_vars, function(x_var) {
        plotname <- paste("plot", x_var, sep = "_")
        plotlyOutput(plotname, height = '300px',width = '70%')  # Create plot output for each continuous variable
      })
      
      do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
    })
    
    output$string_plots <- renderUI({
      string_x_vars <- Filter(function(x) get_variable_type(global_dat[[x]]) == "string", input$x_sel)  # Filter string variables
      plot_output_list <- lapply(string_x_vars, function(x_var) {
        plotname <- paste("plot", x_var, sep = "_")
        plotlyOutput(plotname, height = '300px',width = '70%')  # Create plot output for each string variable
      })
      
      do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
    })
    
    observe({
      req(input$y_sel, input$x_sel)  # Require selection of y and x variables
      
      lapply(input$x_sel, function(x_var) {
        output[[paste("plot", x_var, sep = "_")]] <- renderPlotly({  
          filtered_dat <- global_dat
          
          # Apply filter based on selected group values
          if (!is.null(input$group_var_values) && length(input$group_var_values) > 0) {
            print("input$group_var")
            print(input$group_var)
            print("input$group_var_values")
            print(input$group_var_values)
            filtered_dat <- subset(filtered_dat, subset = (filtered_dat[, input$group_var] %in% as.list(input$group_var_values)))
            
          }
          print("filtered dat ran")
          print(filtered_dat %>% head())
          
          if (is.factor(filtered_dat[[x_var]]) || is.factor(filtered_dat[[input$y_sel]])) {  
            if (input$group_var == 'None selected') {  
              p <- ggplot(filtered_dat, aes_string(x = x_var, y = input$y_sel)) +  
                geom_boxplot() +
                ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel))
            } else {
              p <- ggplot(filtered_dat, aes_string(x = x_var, y = input$y_sel, color = input$group_var)) +  
                geom_boxplot() +
                ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel, "with Group Coloring"))
            }
          } else {  
            if (input$group_var == 'None selected') {  
              p <- ggplot(filtered_dat, aes_string(x = x_var, y = input$y_sel)) +  
                geom_point() +
                {
                  if (input$regression)
                    stat_smooth(
                      method = "lm",se = F,
                      linetype = "dashed",
                      color = "red"
                    ) 
                } +
                ggtitle(paste("Scatter Plot of", x_var, "vs", input$y_sel))
            } else {
              p <- ggplot(filtered_dat, aes_string(x = x_var, y = input$y_sel, color = as.character(input$group_var))) +  
                geom_point(alpha = .5) +
                {
                  if (input$regression)
                    stat_smooth(method = "lm", se = F,linetype = 'dashed')
                } +
                ggtitle(paste("Scatter Plot of", x_var, "vs", input$y_sel, "with Group Coloring"))
            }
          }
          ggplotly(p)
          # ggplotly(p) %>% 
          #   plotly::config(displayModeBar = TRUE, displaylogo = FALSE, scrollZoom = FALSE, modeBarButtonsToRemove = list('toImage')) %>%
          #   htmlwidgets::onRender('function(el, x) {$(el).parent().css({"height": "100%", "width": "100%"});}')
        })
      })
    })
    
    
    
    #### Session info ####
    session_info <- reactive({
      session_info_data <- 
      data.frame(
        Treatments = str_c(glue("{input$treatments}"), collapse = ","),
        Target = str_c(glue("{input$outcome}"), collapse = ","), check.names = F)
      
      
      info_dt <-
        data.frame(sapply(session_info_data, function(x)
          gsub('"', "", x)))
      
      info_dt <- cbind(Filters = rownames(info_dt), info_dt)
      colnames(info_dt)[2] = "Filter_Values"
      rownames(info_dt) <- 1:nrow(info_dt)
      
      return(info_dt)
    })
    
  
    #### Clear Gobal Variabes ####
    #This code clears all global variables if the calculate button is pressed more than once
    # this is to ensure that there are no memory issues.
    # creating variable for click_count
    click_count <- reactiveVal(0)
    observeEvent(input$dml, {
      # Increment the click counter
      click_count(click_count() + 1)
      
      # Check if it's the second click
      if (click_count() >= 2) {
        print('more than two clicks')
        # Get the names of all objects in the global environment
        all_objects <- ls(envir = .GlobalEnv)
        
        # Exclude the variable 'global_dat'
        objects_to_remove <- setdiff(all_objects, c('global_dat','render_dml_tab','global','dml_func'))
        
        # Remove all objects, except 'global_dat', from the global environment
        rm(list = objects_to_remove, envir = .GlobalEnv)
        ## using garbage collection function instead of a session refresh. Garbage collection will update the memory useage(in my case the global enviornment variables) automatically
        gc()
        ## assigning a random number so the observe function will be live
        global$trigger <- runif(1)
        
        
      }
    })
    
    ### part 2 of clearing the global variables ( I have to inlcude the global$trigger value in order for the global variables to update)
    observe({
      print(global$trigger)
      # Get the names of all objects in the global environment
      global_objects <- ls(envir = .GlobalEnv)
      # Display the names of the global objects
      output$globalenv <- renderText(paste("Global Environment Objects:", paste(global_objects,collapse = ', ')))
    })
    
    
    
    #### JS callbacks ####
    # Note: if you have more than one datatable you are doing this for you will have to create more callback variables (ex: callback2, etc)
    # and you will have to rename the setInputValues for example hoverIndexJS2,hoverIndexJS3, etc.
    # this code is creating Rshiny inputs through javascript while a user hovers,clicks, or double clicks values in columns/rows on data tables
    
    # if you only want one or two of these features enabled in your data table then just take the code out for which features you don't want
    # also if you are only wanting a user to be able to click anywhere on a specific row and only get one specific value out of that row change data to data[0] (data[0] = the first value in the first column of the row), change this as needed
    
    callback <- "
    /* code for columns on hover */
    table.on('mouseenter', 'td', function() {
        var data = $(this).text(); // Get the text value of the cell
        Shiny.setInputValue('hoverIndexJS', data, {priority: 'event'});
    });

    /* code for cell content on click */
    table.on('click', 'td', function() {
        var data = $(this).text(); // Get the text value of the cell
        Shiny.setInputValue('clickIndexJS', data, {priority: 'event'});
    });

    /* code for columns on doubleclick */
    table.on('dblclick', 'td', function() {
        var data = $(this).text(); // Get the text value of the cell
        Shiny.onInputChange('dblclickIndexJS', data);
    });
"
    
    
    
    
    ## prinint off the Rshiny input values the callbacks give me
    observeEvent(input$hoverIndexJS, { 		
      if (input$hoverIndexJS != 0 ){
        info <- input$hoverIndexJS
        
        global$hover_info <- info
        print("Hover info:")
        print(global$hover_info)
      } else {
        global$hover_info <- NULL 
      }
    })
    
    observeEvent(input$clickIndexJS, { 		
      if (!is.null(input$clickIndexJS)){
        info <- input$clickIndexJS
        
        global$click_info <- info
        print("Single click info:")
        print(global$click_info)
      } else {
        global$click_info <- NULL 
      }
    })
    
    observeEvent(input$dblclickIndexJS, { 		
      if (!is.null(input$dblclickIndexJS)){
        info <- input$dblclickIndexJS
        
        global$dblclick_info <- info
        print("Double click info:")
        print(global$dblclick_info)
      } else {
        global$dblclick_info <- NULL 
      }
    })
    ####
    
    #### Render Data Tables ####
    # render the ATE DT
    output$ATE <- renderDT(
      datatable({
        req(is.data.frame(global$ATE_summary))
        global$ATE_summary},
        callback =JS(callback), ## using callback variable which is defined above
        rownames = F, 
        extensions = c('Select','Buttons','FixedColumns'),
        fillContainer = TRUE, 
        editable=F,
        options = list(
          paging=FALSE,
          searchHighlight = TRUE,
          dom = 'Bftir',
          scrollX="200px",
          scrollY="200px",
          fixedColumns = list(leftColumns = 1),
          buttons = list('copy', 'csv',
                         list(
                           extend = "collection",
                           text = 'Reset',
                           action = DT::JS("function ( e, dt, node, config ) {Shiny.setInputValue('test', true, {priority: 'event'});}")),
                         # creating a custom download button that will download both data tables in each tab into one excel file
                         # where each data table is in its own sheet. 
                         list(
                           extend = "collection",
                           text = "ATE and Model Summary Data Download",
                           action = DT::JS(
                             "function ( e, dt, node, config ) {
                                        Shiny.setInputValue('ATE_PLR_Dat', true,{priority: 'event'});}"
                           )
                         )
          )),selection = "single") %>% 
        formatStyle(0, cursor = 'pointer')) 
    
    ## redner the plr data
    output$plr <- renderDT(
      datatable({
        req(is.data.frame(global$plr_summary))
        global$plr_summary},
        #callback =JS(callback2), # create a callback2 variable
        rownames = F, 
        extensions = c('Select','Buttons','FixedColumns'),
        fillContainer = TRUE, 
        editable=F,
        options = list(
          paging=FALSE,
          searchHighlight = TRUE,
          dom = 'Bftir',
          scrollX="200px",
          scrollY="200px",
          fixedColumns = list(leftColumns = 1),
          buttons = list('copy', 'csv',
                         list(
                           extend = "collection",
                           text = 'Reset',
                           action = DT::JS("function ( e, dt, node, config ) {Shiny.setInputValue('test2', true, {priority: 'event'});}"))
          )),selection = "single") %>% 
        formatStyle(0, cursor = 'pointer'))
    
    
    #### DT Custom Bttns ####
    # custom download button for output$ATE
    # this will combine the filters, and both the ATE & plr DT's together and store them in a reactiveVal object,
    # then we will call a download button called 'download_all_data' that I manually create and download the excel files
    chart_download <- reactiveVal()
    observeEvent(input$ATE_PLR_Dat, {
      # we put thise ins a list so that we can name the indiviudals tabs of the excel file and store the data we want in that tab
      ate_dat <- list('ATE DT'= global$ATE_summary)
      plr_dat <- list('PLR DT' = global$plr_summary)
      session_info_ <- list("Query&Filters" = session_info())
      all_data <- append(session_info_,ate_dat)
      all_data <- append(all_data,plr_dat)
      chart_download(all_data)
      runjs("$('#combined_data')[0].click();")
    })
    
    output$combined_data <- downloadHandler(
      filename = function() {
        ## name of the xlsx file
        paste0("Causal_Analyis_Data_", today(), ".xlsx")
      },
      content = function(filename) {
        write.xlsx(x = chart_download() ,
                   file = filename,
                   rowNames = FALSE)
      }
    )
    
    
    
    
    #### Ploty ggplot EX ####
    # plotly graph example
    # output$plotlygraph <- renderPlotly({
    #   if (!is.null(global$ATE_summary)) {
    #     graph <- ggplotly(ggplot(global$ATE_summary[order(global$ATE_summary$ATE),], aes(x = treatment, y = ATE, fill = ATE,label = ATE)) +
    #                              
    #                              geom_bar(stat = "identity") +
    #                              
    #                              scale_fill_viridis_c() +  # Use viridis color scale
    #                              
    #                              scale_y_log10() +  # Add log-scale transformation to the y-axis
    #                              
    #                              
    #                              labs(title = "ATE Scores Bar Chart with Heatmap Color (Log-Scale Y-axis)",
    #                                   
    #                                   x = "treatment", y = "ATE Score (log scale)") +
    #                              
    #                              theme_minimal() +
    #                              
    #                              theme(axis.text.x = element_text(angle = 45, hjust = 1)))
    #     
    #   # return the graph
    #   graph
    #   }})
    
  

    #### PPT Full Screen Capability ####
    observeEvent(input$fullscreenBtn, {runjs("var elem = document.getElementById('slidesIframe'); if (!document.fullscreenElement) {elem.requestFullscreen(); } else {            if (document.exitFullscreen) {              document.exitFullscreen();            }          }")})
    
    }


