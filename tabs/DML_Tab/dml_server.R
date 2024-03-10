source("./global.r")



## use the virtual environment to allow python script functions to be used (note: must use source_python)
source_python("./functions/dml.py")


### dml function
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
        py_dat <- r_to_py(global_dat)
        
        py_result <- dml_func(data=py_dat,outcome = input$outcome, n_treatments = input$n_treats)
        print("py_result worked")
        
        if (py_result[[3]]){
          remove_modal_spinner()
          showNotification("No significant Treatment Values found",type='warning',duration=NULL)
        } else {
          
          
          filter1 <- subset(py_result[[1]], Significant != 'FALSE')
          global$ATE_summary  <-subset(filter1, ATE != 'NULL')
          global$plr_summary <- py_result[[2]]
          update_modal_progress(1)
          remove_modal_spinner()
          
          
        }
      }else if (!is.null(input$treatments) && is.na(input$n_treats)) {
        #print("treatment list given")
        #print(input$treatments)
        py_dat <- r_to_py(global_dat)
        py_result <- dml_func(data=py_dat,outcome = input$outcome, treatments = input$treatments)
        
        if (py_result[[3]]){
          remove_modal_spinner()
          showNotification("No significant Treatment Values found",type='warning')
        } else {
          filter1 <- subset(py_result[[1]], Significant != 'FALSE')
          global$ATE_summary  <-subset(filter1, ATE != 'NULL')
          print("ATE data")
          print(global$ATE_summary)
          global$plr_summary <- py_result[[2]]
        }
        remove_modal_spinner()
      } else {
        remove_modal_spinner()
        showNotification("Please only select treatments, or n_treatments, there should not be values in both")
      }
      remove_modal_spinner()
      
    })
    ######### This code clears all global variables if the calculate button is pressed more than once
    ######### this is to ensure that there are no memory issues.
    ### creating variable for click_count
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
    
    ############################################################################################################
    
    
    
    
    ## call back for output DT's this allows for tooltips and other custom filters to be applied on click, double click and hover
    callback2 <- c("
                /* code for columns on hover */
                 table.on('mouseenter', 'td', function() {
                 var td = $(this);
                if(table.cell( this ).index().columnVisible == 0){
                 var data = table.row( this ).data();
                 Shiny.setInputValue('hoverIndexJS_2', data[0],{priority: 'event'});}
                
                if(table.cell( this ).index().columnVisible > 0){
                var data = 0;
                Shiny.setInputValue('hoverIndexJS_2', data,{priority: 'event'});}
                
                 });
                
                /* code for cell content on click */
                 table.on('click', 'td', function() {
                 var td = $(this);
                 var data = table.row( this ).data();
                 Shiny.setInputValue('clickIndexJS_2', data[0], {priority: 'event'});
                 
                 });
               /* code for columns on doubleclick */
                 table.on('dblclick', 'td', function() {
                 var td = $(this);
                 var data = table.row( this ).data();
                 Shiny.onInputChange('dblclickIndexJS_2', data[0]);
                                                });"
                   
    )
    
    ## render the ATE DT
    output$ATE <- renderDT(
      datatable({
        req(is.data.frame(global$ATE_summary))
        global$ATE_summary},
        #callback =JS(callback),
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
                           action = DT::JS("function ( e, dt, node, config ) {Shiny.setInputValue('test', true, {priority: 'event'});}"))
          )),selection = "single") %>% 
        formatStyle(0, cursor = 'pointer')) 
    
    ## redner the plr data
    output$plr <- renderDT(
      datatable({
        req(is.data.frame(global$plr_summary))
        global$plr_summary},
        #callback =JS(callback),
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
    #####################################
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
    
    
    
    
    
    
    
    
  }


