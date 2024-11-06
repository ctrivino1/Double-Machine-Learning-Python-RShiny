source("./global.r")

source_python("./functions/dml.py")

source_python("./functions/elastic_net_dim_reduction.py")

logger::log_info('dml_server.r started')
####  Python dml function ####
render_dml_tab <- 
  function(input, output,session) {
    
    
    # observeEvent(input$open_modal, {
    #   showModal(modalDialog(
    #     title = "Upload CSV",
    #     fileInput("fileUpload", "Choose a CSV File", accept = ".csv"),
    #     easyClose = TRUE,
    #     footer = modalButton("Close")
    #   ))
    # })
    output$modalFooter <- renderUI({
      req(input$fileUpload)  # Only show footer if a file has been uploaded
      modalButton("Close")
    })
    
    # Observe to open the modal
    observeEvent(input$open_modal, {
      showModal(modalDialog(
        title = "Upload CSV",
        fileInput("fileUpload", "Choose a CSV File", accept = ".csv"),
        easyClose = FALSE,  # Prevent closing by clicking outside initially
        footer = uiOutput("modalFooter")  # Dynamically rendered footer
      ))
    })
    
    observe({
      runjs("document.getElementById('open_modal').click();")
    })
    
    
    observeEvent(input$fileUpload, {
      
      
      # Load and process the CSV file
      global_data <- as.data.table(read_csv(input$fileUpload$datapath))
      print("global_data")
      print(global_data)
      
      # Initialize tree choices, if any specific selection logic is applied
      column_data_frame <- data.frame(Columns = names(global_data))
      global$tree_choices <- make_tree(column_data_frame, c("Columns"))
      global$all_tree_choices <- unlist(global$tree_choices)
      
      
      
      print("computing binary cols")
      # Identify columns containing binary data (0/1 or "0"/"1")
      binary_cols <- names(global_data)[sapply(global_data, function(x) {
        (is.numeric(x) && all(unique(x) %in% c(0, 1))) || all(unique(x) %in% c("0", "1"))
      })]
      print('binary_cols finsihed')
      
      # Copy the data for other use
      global$data_copy <- data.table::copy(global_data)
      
      # Add a row_id column to keep track of rows uniquely
      global_data$row_id <- seq_len(nrow(global_data))
      
      # Identify columns containing strings or binary values
      print("computing string or binary")
      string_or_binary_cols <- sapply(global_data, function(x) {
        is.character(x) || (is.numeric(x) && all(unique(x) %in% c(0, 1)))
      })
      
      # Convert these columns to factors for better handling in UI elements
      #global_data[string_or_binary_cols] <- lapply(global_data[string_or_binary_cols], as.factor)
      global_data[, (names(global_data)[string_or_binary_cols]) := lapply(.SD, as.factor), .SDcols = string_or_binary_cols]
      
      # Store widget filters, using the generate_widget_filters function
      global$widget_filters <- generate_widget_filters(global$data_copy)
      
      # Initialize widget rules, if any additional filtering logic is desired
      ## Rules ##
      global$widget_rules <- NULL
      # can add a base filter like so:
      # widget_rules <- list(
      #   condition = "AND",
      #   rules = list(
      #     list(
      #       id = "date",
      #       operator = "between",
      #       value = c(earliest_date_str, today_str)
      #     )
      #   )
      # )
      global$data <- global_data
      # Update pickerInput choices based on uploaded data columns
      updatePickerInput(session, "y_sel", choices = names(global$data))
      updatePickerInput(session, "x_sel", choices = names(global$data))
      
      group_choices <- names(global$data)[sapply(global$data, function(x) is.character(x) || is.factor(x) ||(is.numeric(x) && all(unique(x) %in% c(0, 1))))]
      updatePickerInput(session, "group_var", choices = c('None selected', group_choices))
      
      updatePickerInput(
        session = session, 
        inputId = 'outcome', 
        choices = c('None Selected', names(global$data_copy)), 
        selected = NULL  # Keep initial selection NULL
      )
      
      
      
      
    })
    
    
    output$querbuilder_ui <- renderUI({
      req(global$widget_filters)  # Ensure that global$widget_filters is available
      
      # Create the UI with a fluidRow
      fluidRow(
        column(
          width = 12,
          # Add the query builder input
          queryBuilderInput(
            inputId = "widget_filter",
            filters = global$widget_filters,
            rules = global$widget_rules,
            display_errors = TRUE,
            return_value = "all"
          ),
          # Add the reset button
          div(
            style = "display: inline-block; margin-bottom: 20px;",
            actionButton("reset", "Reset", class = "btn-danger")
          )
        )
      )
    })
    
    
    output$treeview_ui <- renderUI({
      req(global$tree_choices,global$all_tree_choices)
      treecheckInput(
        inputId = "tree_choices",
        label = "Unselect unnecessary columns:",
        choices = global$tree_choices,
        selected = global$all_tree_choices,
        width = "100%"
      )
    })
    
    # Display selected tree output
    output$result <- renderPrint({
      input$tree
    })
    
    
    output$value <- renderText({input$n_treats})
    observeEvent(input$dml, {
      req(global$EN_ind_results)
      print("button clicked")
      show_modal_spinner(
        spin = "cube-grid",
        color = "#28b78d",
        text = "Please wait..."
      )
      print("global_lasso_dim_results")
      lasso_dim <<- input$treatments
      out <<- input$outcome
      j_q <- global$jquery_dat
      
      jq_dat <<- subset(global$jquery_dat, select = c(intersect(names(global$jquery_dat), input$treatments), input$outcome))
      print('computing py_dat')
      py_dat <- r_to_py(jq_dat)
      treats <<-  input$treatments
      pred <<- input$outcome
      print("computing dml")
      py_result <- dml_func(data=py_dat,outcome = input$outcome, treatments = input$treatments)

      # gets rid of duplicate treatments and keeps the treatment that is signficiant
      ate_sum <<- py_result[[1]] %>% group_by(treatment) %>% filter(!(Significant == F  & n() >1))

      global$ATE_summary  <- ate_sum
      test <<- py_result[[1]]
      # print("ATE data")
      # print(global$ATE_summary)
      global$plr_summary <- py_result[[2]]
      
      remove_modal_spinner()
      
    })
    
    
    
    
    
    #### Update DML covariates ####
    observeEvent(input$en, {
      req(input$outcome != 'None Selected')
      show_modal_spinner(
        spin = "cube-grid",
        color = "#28b78d",
        text = "Please wait..."
      )
      print("input$outcome is running elasticnet")
      lasso_df <<- global$jquery_dat
      
      pandas_df <- r_to_py(lasso_df)
      lasso_result <<- ENet_reg_dim_reduction(target = input$outcome,df = pandas_df )
      # evaluation metrics can be found in lasso_result[2]
      # found rates are found here:
      features <- lasso_result[[1]]$Features
      coefficients <- unlist(lasso_result[[1]]$Coefficients)
      display_labels <- paste(features, "(", format(coefficients, scientific = TRUE), ")")
      global$EN_ind_results <- setNames(as.list(features), display_labels)
      global$EN_eval_metrics <- as.data.frame(lasso_result[2])
      #global$lasso_dim_eval_metrics <- lasso_result[[1]]
      remove_modal_spinner()
    
    }, ignoreInit = TRUE)
    
    #### Exploratory Graph Functions/Functionality ####
    # update the picker input selection based on input$group_var column
    
    observeEvent(input$group_var, {
      if (input$group_var == "None selected") {
        updatePickerInput(session, "group_var_values", selected = "None selected")
      } else {
        # lapply with the as.character gets rid of the factors
        unique_values <- unique(lapply(global$data, as.character)[[input$group_var]])
        updatePickerInput(session, "group_var_values", choices = unique_values, selected = unique_values)
      }
    })
    
    #### update treatment list ####
    observe({
      print(" observe statement for updated treatments")
      # Update selectInput choices whenever global$EN_ind_results changes
      
      updatePickerInput(session, "treatments", choices = global$EN_ind_results, selected = global$EN_ind_results)
    })
  
    
    # Function to update selected x variables
    update_selected_x_vars <- function() {
      # Update selected x variables
      global$selected_x_vars <- lapply(input$x_sel, function(x_var) {
        list(name = x_var, type = get_variable_type(global$data[[x_var]]))
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
      binary_x_vars <- Filter(function(x) get_variable_type(global$data[[x]]) == "binary", input$x_sel)  # Filter binary variables
      plot_output_list <- lapply(binary_x_vars, function(x_var) {
        plotname <- paste("plot", x_var, sep = "_")
        plot_output <- plotlyOutput(plotname, height = '300px',width = '100%')  # Create plot output for each continuous variable
        div(style = "margin-bottom: 10px;", plot_output)
      })
      
      do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
    })
    
    output$continuous_plots <-  renderUI({
      print("made it to output$continuous plots")
      continuous_x_vars <- Filter(function(x) get_variable_type(global$data[[x]]) == "continuous", input$x_sel)  # Filter continuous variables
      plot_output_list <- lapply(continuous_x_vars, function(x_var) {
        plotname <- paste("plot", x_var, sep = "_")
        plot_output <- plotlyOutput(plotname, height = '300px',width = '100%')  # Create plot output for each continuous variable
        div(style = "margin-bottom: 20px;", plot_output)
      })

      do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
    })
    
    
    output$string_plots <- renderUI({
      string_x_vars <- Filter(function(x) get_variable_type(global$data[[x]]) == "string", input$x_sel)  # Filter string variables
      plot_output_list <- lapply(string_x_vars, function(x_var) {
        plotname <- paste("plot", x_var, sep = "_")
        plot_output <- plotlyOutput(plotname, height = '300px',width = '100%')  # Create plot output for each continuous variable
        div(style = "margin-bottom: 5px;", plot_output)
      })
      
      do.call(tagList, plot_output_list)  # Combine plot outputs into a tag list
    })
    
   
    
    #### Explore Graphs ####
    observe({
      # requirements to run
      req(
        input$y_sel,  # Requires input from the variable 'y_sel'.
        input$x_sel)#,  # Requires input from the variable 'x_sel'.
        #(!is.null(input$all_years) || length(input$month_range) >= 1 || length(input$year_range) >= 1 ))
      print(paste("y_sel:", input$y_sel))
      print(paste("x_sel:", input$x_sel))
      # print(paste("month_range:", toString(input$month_range)))
      # print(paste("year_range:", toString(input$year_range)))
      # print(paste("all_years:", toString(input$all_years)))
        # Requires that at least one of the following conditions is true:
        # 1. 'all_years' checkbox is selected (input$all_years).
        # 2. A month range of length 2 is selected (length(input$month_range) == 2).
        # 3. A year range of length 2 is selected (length(input$year_range) == 2).
      
      
      
      
      
      test <- global$data
      filtered_dat <- data.table::copy(global$data)
      # Apply filter based on selected group values
      if (!is.null(input$group_var_values) && length(input$group_var_values) > 0) {
        filtered_dat <- filtered_dat %>% filter(filtered_dat[[input$group_var]] %in% as.list(input$group_var_values))
      }
      
      
      # if (input$all_years) {
      #   print("all years")
      #   frame_value <- global$data$dt_time
      # } else if (length(input$month_range) == 1) {
      #   dt_range <- format(input$month_range, "%m/%d/%Y")
      #   filtered_dat <- filtered_dat %>%
      #     filter(as.Date(dt_time, format = "%m/%d/%Y") == as.Date(dt_range[1], format = "%m/%d/%Y"))
      #   filtered_dat$dt_time <- as.Date(filtered_dat$dt_time, format = "%m/%d/%Y")
      #   frame_value <- as.Date(filtered_dat$dt_time, format = "%m/%d/%Y")
      # } else if (length(input$month_range) == 2) {
      #   dt_range <- format(input$month_range, "%m/%d/%Y")
      #   filtered_dat <- filtered_dat %>%
      #     filter(as.Date(dt_time, format = "%m/%d/%Y") >= as.Date(dt_range[1], format = "%m/%d/%Y") & 
      #              as.Date(dt_time, format = "%m/%d/%Y") <= as.Date(dt_range[2], format = "%m/%d/%Y"))
      #   filtered_dat$dt_time <- as.Date(filtered_dat$dt_time, format = "%m/%d/%Y")
      #   frame_value <- as.Date(filtered_dat$dt_time, format = "%m/%d/%Y")
      # } else if (length(input$year_range) == 1) {
      #   dt_range <- format(input$year_range, "%Y")
      #   filtered_dat <- filtered_dat %>%
      #     filter(year(make_date(dt_time_year)) == year(make_date(dt_range[1])))
      #   frame_value <- filtered_dat$dt_time_year
      # } else if (length(input$year_range) == 2) {
      #   dt_range <- format(input$year_range, "%Y")
      #   filtered_dat <- filtered_dat %>%
      #     filter(year(make_date(dt_time_year)) >= year(make_date(dt_range[1])) & 
      #              year(make_date(dt_time_year)) <= year(make_date(dt_range[2])))
      #   frame_value <- filtered_dat$dt_time_year
      # } else{frame_value <- NULL}
      # 
      # print(unique(filtered_dat$dt_time_year))
      frame_value <- NULL
      
      
      print("identical")
      print(identical(test, filtered_dat))
      
      

      lapply(input$x_sel, function(x_var) {
        output[[paste("plot", x_var, sep = "_")]] <- renderPlotly({
          print("filtered dat insite lapply")
          

          # Define plot name for this iteration
          plot_name <- glue::glue('{input$y_sel}_vs_{x_var}')

          # Reset input values so the donwload csv names are unique to every input$y_sel and input$x_sel combination
          isolate({
            updateSelectInput(session, "y_sel", selected = NULL)
            updateSelectInput(session, "x_sel", selected = NULL)
          })

          # Generate plot
          p <- if (is.factor(filtered_dat[[x_var]]) || is.factor(filtered_dat[[input$y_sel]])) {
            g_point <- F
            if (input$group_var == 'None selected') {
              ggplot(filtered_dat, aes_string(x = x_var, y = input$y_sel, frame = frame_value, customdata='row_id')) +
                geom_boxplot() +
                ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel)) +
                theme_bw()
            } else {
              ggplot(filtered_dat, aes_string(x = x_var, y = input$y_sel, color = input$group_var,customdata = 'row_id'), frame = frame_value) +
                geom_boxplot() +
                ggtitle(paste("Boxplot of", x_var, "vs", input$y_sel, "with Group Coloring")) +
                theme_bw()
            }
          } else {
            if (input$group_var == 'None selected') {
              g_point <- F
              ggplot(filtered_dat, aes_string(x = x_var, y = input$y_sel, frame = frame_value, customdata='row_id')) +
                geom_point() +
                    stat_smooth(
                      method = "lm",se = F,
                      linetype = "dashed",
                      color = "red"
                    ) +
                ggtitle(paste("Scatter Plot of", x_var, "vs", input$y_sel)) +
                theme_bw()
            } else {
              g_point <- T
              filtered_dat %>% 
                highlight_key(~filtered_dat[[input$group_var]]) %>%
              ggplot( aes_string(x = x_var, y = input$y_sel, color = filtered_dat[[input$group_var]], frame = frame_value,customdata = 'row_id')) + #,customdata = 'row_id',
                geom_point(alpha = .5) +
                stat_smooth(method = "lm", se = F,linetype = 'dashed') +
                ggtitle(paste("Scatter Plot of", x_var, "vs", input$y_sel, "with Group Coloring")) +
                theme_bw()
            }
          }

          # Convert ggplot to plotly
          print('converted to ggploty')
          if (g_point == F) {
            print("gpoint FALSE")
            p <- ggplotly(p, source = "plot1") %>%  layout(clickmode = "event+select", dragmode = 'select')
          } else if (g_point) {
            print("gpoint TRUE")
            p <- highlight(
      ggplotly(p, source = "plot1"),on = "plotly_hover",
      off = "plotly_deselect",
      opacityDim = 0.1
            ) %>%  layout(clickmode = "event+select", dragmode = 'select')
          } else{}
          
          # Configure the plot with the download button
          print("adding custom buttons")
          # uncomment this and the button_download out to include a download csv button for each chart
          #plot_data <- p[["x"]][["visdat"]][[p[["x"]][["cur_data"]]]]()
          p <- config(
            p,
            scrollZoom = TRUE,
            modeBarButtonsToAdd = list(
              list(button_fullscreen()
                    #,button_download(data = plot_data, plot_name = plot_name))
            ))
            ,
            modeBarButtonsToRemove = c("toImage", "hoverClosest", "hoverCompare"),
            displaylogo = FALSE
          )
          print("done building custom button")

          
          p  
        })
      })
    })
    
    
    
    
    
    
    #### exploration Data Table ####
    
    # Observe click event
    selected_data <- reactiveVal(NULL)

    
    observeEvent(event_data("plotly_deselect", source = 'plot1'), {
      print('plotly_deselect')
      selected_data(NULL)
    })
    
    
    observeEvent(event_data("plotly_selected", source = "plot1"), {
      click_data <- event_data("plotly_selected", source = "plot1")
      if (!is.null(click_data)) {
        if (input$group_var == "None selected") {
          
          selected_data_indices <- click_data$pointNumber + 1
          selected_rows <- global$data[selected_data_indices, ]
          selected_data(selected_rows)
        } else  { 
          ## matching any datapoint on the graph with its original data row_id number,
          ## that way if there is the same x and y value then it will make sure to go to the correct row
          result <- inner_join(global$data, click_data, by = c("row_id" = "customdata"))
          selected_data(result)
        }
      }
    })
    
    
    output$data_table <- renderDT({
      if (!is.null(selected_data())) {
        datatable(selected_data(), rownames = FALSE, options = list(scrollX = TRUE, scrollY = TRUE))
      } else {
        datatable(global$data, rownames = FALSE, options = list(scrollX = TRUE, scrollY = TRUE))
      }
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
        
        # Exclude the variable 'global$data'
        objects_to_remove <- setdiff(all_objects, c('global$data','render_dml_tab','global','dml_func','global$jquery_dat','global$data_copy'))
        
        # Remove all objects, except 'global$data', from the global environment
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
    
    ### Render EN Evaluation metrics dv
    output$EN_eval <- renderDT(
      datatable({
        req(is.data.frame(global$EN_eval_metrics))
        global$EN_eval_metrics},
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
                           action = DT::JS("function ( e, dt, node, config ) {Shiny.setInputValue('test4', true, {priority: 'event'});}"))
          )),selection = "single") %>% 
        formatStyle(0, cursor = 'pointer'))
    
    
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
        global$plr_summary
      },
      # callback = JS(callback2), # create a callback2 variable
      rownames = FALSE, 
      extensions = c('Select', 'Buttons', 'FixedColumns'),
      fillContainer = TRUE, 
      editable = FALSE,
      options = list(
        paging = FALSE,
        searchHighlight = TRUE,
        dom = 'Bftir',
        scrollX = TRUE,
        scrollY = TRUE,
        fixedColumns = list(leftColumns = 1),
        buttons = list('copy', 'csv',
                       list(
                         extend = "collection",
                         text = 'Reset',
                         action = DT::JS("function ( e, dt, node, config ) {Shiny.setInputValue('test2', true, {priority: 'event'});}"))
        )
      ), 
      selection = "single") %>% 
        formatStyle(0, cursor = 'pointer')
    )
    
    
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
    
    
    
    #### Jquery ####
    
    ## restet button ##
    observeEvent(input$reset, {
      global$jquery_dat <- global$data_copy
      updateQueryBuilder(
        inputId = "widget_filter",
        reset = TRUE
      )
    })
    
    # make sure the tree selection does not include the outcome variable
    ##observeEvent(input$outcome, {
     ## req(input$outcome)
     ## print('outcome')
      ##print(input$outcome)
      ##tc <<- input$tree_choices
      ##new_tree_df <- global$tree_selection_df %>% filter(Metric != input$outcome)
      ##updateTreeview(inputId = 'tree_choices', selected = c(new_tree_df$Metric))
    #})
    
    # Observe the file input and process the uploaded CSV
   
    
    observe( {
    widget_filter_rules <<- input$widget_filter$r_rules
    print("widget rules")
    print(widget_filter_rules)
    dt <- datatable(filter_table(global$data_copy, widget_filter_rules))
    jquery_dat <<- as.data.frame(dt$x$data)
    valid_col_names <- intersect(input$tree_choices,colnames(jquery_dat))
    global$jquery_dat <- jquery_dat[, valid_col_names,drop = FALSE]
    print("jquary dat")
    print(length(colnames(global$jquery_dat )))
    print(jquery_dat %>% head())
    #print(unique(global$jquery_dat$dt_time))
    
    
    })
    
    
    observe({
      print("input$treatments")
      print(input$treatments)
    })
    
    ####  DML Instructions ####
    observeEvent(input$help, {
      introjs(session, options = list("nextLabel" = "Next Step", "prevLabel" = "Previous Step", "skipLabel" = "Skip Tour"),
              events = list("oncomplete" = I('alert("Tour completed!")')))
    })
  
    
    ### show the csv modal again if the button is clicked:
    observeEvent(input$upload_csv_btn, {
      show_modal(TRUE)  # Show the modal
    })
    
    observeEvent(input$cancel, {
      show_modal(FALSE)
    })
    
    
    logger::log_info('dml_server.r finished')
    #### PPT Full Screen Capability #### look at dml_ui notes at bottom of script
    observeEvent(input$fullscreenBtn, {runjs("var elem = document.getElementById('slidesIframe'); if (!document.fullscreenElement) {elem.requestFullscreen(); } else {if (document.exitFullscreen) {document.exitFullscreen();}}")})
    waiter_hide()
  }



