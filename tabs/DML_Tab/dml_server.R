source("./global.r")
## turn on python virtual enviornment
#virtualenv_create('r-reticulate')
#use_virtualenv('r-reticulate')
## use the virtual environment to allow python script functions to be used (note: must use source_python)
source_python("./functions/dml.py")



render_dml_tab <- 
  function(input, output,session) {
    output$value <- renderText({input$n_treats})
    observeEvent(input$dml, {
      print("button clicked")
      show_modal_progress_line()
      if (is.null(input$treatments) && !is.na(input$n_treats)){
        print("n_treatments")
        print(input$n_treats)
        py_dat <- r_to_py(global_dat)
        update_modal_progress(.2)
        Sys.sleep(1)
        py_result <- dml_func(data=py_dat,outcome = input$outcome, n_treatments = input$n_treats)
        print("py_result worked")
        update_modal_progress(.6)
        Sys.sleep(1)
        if (py_result[[3]]){
          update_modal_progress(1)
          remove_modal_progress()
          Sys.sleep(1)
          showNotification("No significant Treatment Values found",type='warning',duration=NULL)
        } else {
          update_modal_progress(.8)
          Sys.sleep(1)
          filter1 <- subset(py_result[[1]], Significant != 'FALSE')
          global$ATE_summary  <-subset(filter1, ATE != 'NULL')
          global$plr_summary <- py_result[[2]]
          update_modal_progress(1)
          remove_modal_progress()
          Sys.sleep(1)
          
        }
      }else if (!is.null(input$treatments) && is.na(input$n_treats)) {
        #print("treatment list given")
        #print(input$treatments)
        py_dat <- r_to_py(global_dat)
        update_modal_progress(.2)
        Sys.sleep(1)
        py_result <- dml_func(data=py_dat,outcome = input$outcome, treatments = input$treatments)
        update_modal_progress(.6)
        Sys.sleep(1)
        if (py_result[[3]]){
          update_modal_progress(1)
          remove_modal_progress()
          Sys.sleep(1)
          showNotification("No significant Treatment Values found",type='warning')
        } else {
          filter1 <- subset(py_result[[1]], Significant != 'FALSE')
          global$ATE_summary  <-subset(filter1, ATE != 'NULL')
          print("ATE data")
          print(global$ATE_summary)
          global$plr_summary <- py_result[[2]]
        }
        update_modal_progress(1)
        Sys.sleep(1)
        remove_modal_progress()
      } else {
        remove_modal_progress()
        showNotification("Please only select treatments, or n_treatments, there should not be values in both")
        }
      remove_modal_progress()
    
    })
    
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
    
    ### for testing purposes###################################################################################
    # I have to have a reactive value that changes in the observe function in order for the observe function to be live.
    observe({
      print(global$trigger)
      # Get the names of all objects in the global environment
      global_objects <- ls(envir = .GlobalEnv)
      # Display the names of the global objects
      output$globalenv <- renderText(paste("Global Environment Objects:", paste(global_objects,collapse = ', ')))
    })
    
    ############################################################################################################
   
    
    
    
    
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
    
    ### for pension data###################################################
    # passed_male <- reactive({
    #   print("passed male working")
    #   # Extract the 'male' parameter from the URL
    #   url_params <- strsplit(session$clientData$url_search, "&")[[1]]
    #   male_param <- grep("male=", url_params, value = TRUE)
    #   if (length(male_param) > 0) {
    #     male_value <- gsub("male=", "", male_param)
    #     male_value <- gsub("^\\?","",male_value)
    #     male_value <- URLdecode(male_value)
    #     male_vector <- unlist(strsplit(male_value,","))
    #     male_vector <<- unique(male_vector)
    #     distinct_male_value  <- as.list(male_vector)
    #     global$tableau_filter <- distinct_male_value
    #     print("tableau filter: ")
    #     print(global$tableau_filter)
    #     #distinct_male_value  <- paste(male_vector, collapse = ",")
    #     return(distinct_male_value)
    # 
    #   } else {
    #     return('No value')
    #   }
    # 
    # })
    
    # test_dat <- reactive({
    #   print("test_dat working")
    #   if (is.null(global$tableau_filter)){
    #     print("OG data")} else {
    #       dat <<- filter(global_dat,male==global$tableau_filter)
    #       print("filtered gender for: ")
    #       print(unique(dat$male))
    #   }})

    
    
    
    #observe(global$test_dat <- test_dat())
    
    #observe(global$tableau_filter  <- passed_male())
    
    # output$filter <- renderPrint({
    #   paste("gender filter selected from Tableau: ",global$tableau_filter )
    # })
     
    
    
    }


