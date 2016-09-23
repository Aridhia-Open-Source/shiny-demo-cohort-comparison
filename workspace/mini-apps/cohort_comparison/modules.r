participantListModule <- function(input, output, session, data, filter = list()) {
  init <- TRUE
  
  if (length(filter) > 0) {
    
    output$filter <- renderUI({
      ns <- session$ns
      
      id <- ns(filter[1])
      label <- filter
      x <- data[, filter[1]]
      
      create_filter(x, id, label)
    })
    
  } else {
    
    output$filter <- renderUI({
      ns <- session$ns
      
      fluidRow(
        
      )
    })
    
  }
  
  
  logical_vec <- reactive({
    
    if(length(filter) == 0) {
      return(rep(TRUE, nrow(data)))
    }
    
    print("Filtering")
    ns <- session$ns
    selected <- input[[filter[1]]]
    x <- data[, filter[1]]
    if(init) {
      print("Initializing")
      init <<- FALSE
      return(rep(TRUE, nrow(data)))
    }
    
    
    e <- eval_filter(x, selected)
    e
  })
  
  filtered_data <- reactive({
    data[logical_vec(), ]
  })
  
  output$dt <- renderDataTable({
    filtered_data()
  })
  
  selected_id <- reactive({
    input$dt_row_last_clicked
  })
  
  return(list(filtered_data = filtered_data, participant_id = selected_id))
}



participantListUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      uiOutput(ns("filter"))
    ),
    fluidRow(
      dataTableOutput(ns("dt"))
    )
  )
}



barplotFilter <- function(input, output, session, values, selection_type, ...) {
  # variables for this session
  sessionVars <- reactiveValues(clicked = c())
  
  d <- reactive({
    ## we want values to be reactive or not
    if(is.reactive(values)) {
      v <- as.character(values())
    } else {
      v <- as.character(values)
    }
    df <- data.frame(values = v)
    ## compute the extent of each rect (see ?compute_count)
    df %>% compute_count(~values) %>%
      #compute_align(~x_) %>%
      mutate(clicked = as.numeric(x_ %in% sessionVars$clicked))
  })
  
  click_handle <- function(data, location, session) {
    if (is.null(data)) return()
    cat(str(data))
    ## don't take a dependency on clicked
    isolate({
      sessionVars$clicked <- update_selection(sessionVars$clicked, data$x_, selection_type)
    })
  }
  
  g <- d %>% ggvis(x = ~x_, y = ~count_, y2 = 0) %>%
    layer_rects(key := ~x_, fillOpacity = ~clicked, width = band(), ...) %>%
    handle_click(click_handle) %>%
    scale_numeric("opacity", domain = c(0, 1), range = c(0.5, 0.9))
  
  ## take 'clicked' out of our session variables to be returned
  clicked <- reactive({
    sessionVars$clicked
  })
  
  return(list(barplot = g, clicked = clicked))
}



## a density plot with a two sided slider to select a range from the density


## a density plot with a two sided slider to select a range from the density

densityFilter <- function(input, output, session, values, ..., N = 50, label = "Select Density Range") {
  ns <- session$ns
  sessionVars <- reactiveValues(click_count = 0, x1 = NULL, x2 = NULL, x = NULL)
  
  output$slider_ui <- renderUI({
    v <- if(is.reactive(values)) {
      values()
    } else {
      values
    }
    min_v <- min(v)
    max_v <- max(v)
    r <- max_v - min_v
    sliderInput(ns("slider"), label, min = min_v, max = max_v,
                step = 0.01, value = c(min_v, max_v))
  })
  
  ## sort out the data to be plotted
  d <- reactive({
    if(is.reactive(values)) {
      v <- values()
    } else {
      v <- values
    }
    
    data.frame(values = v)
  })
  
  ## create a box to show the selected range
  vlines <- reactive({
    s <- input$slider
    density_df <- d() %>% compute_density(~values, trim = T)
    max_y <- max(density_df$resp_) * 1.05
    
    ## check the slider for min and max x values
    if (is.null(s)) {
      min_x <- min(density_df$pred_)
      max_x <- max(density_df$pred_)
    } else {
      min_x <- s[1]
      max_x <- s[2]
    }
    
    data.frame(x = rep(c(min_x, max_x), each = 2), y = c(0, max_y, max_y, 0))
  })
  
  domain_reactive <- reactive({
    df <- vlines()
    c(df[1, 2], df[2, 2])
  })
  
  
  coord_box <- reactive({
    v <- if(is.reactive(values)) {
      values()
    } else {
      values
    }
    
    min_x <- min(v)
    max_x <- max(v)
    
    t <- seq(min_x, max_x, length.out = N)
    data.frame(x = rep(t, 2), y = rep(c(0, 10/(max_x - min_x)), each = N)) %>% group_by(x)
  })
  
  click_handle <- function(data, location, session) {
    ## wait for 2 clicks
    isolate({
      sessionVars$click_count <- (sessionVars$click_count + 1) %% 2
      if(sessionVars$click_count == 1) {
        ## if it's the first click just update x1 and return
        print("One click")
        sessionVars$x1 <- data$x
        cat(str(data))
        return()
      } else {
        ## on the second click update the x min, max pair
        cat(str(data))
        sessionVars$x2 <- data$x
        print("Two clicks")
        sessionVars$x <- sort(c(sessionVars$x1, sessionVars$x2))
      }
    })
  }
  
  # watch for clicks on the plot and update the slider if necessary
  observe({
    x <- sessionVars$x
    updateSliderInput(session, "slider", value = x)
  })
  
  g <- d %>%
    ggvis(~values) %>%
    layer_densities(...) %>%
    layer_paths(data = vlines, x=~x, y=~y, strokeOpacity := 0, fill := "red", fillOpacity := 0.2) %>%
    layer_paths(data = coord_box, x=~x, y=~y, strokeOpacity := 0.01, stroke := "white",
                strokeWidth := 20) %>%
    scale_numeric("y", domain = domain_reactive, clamp = T) %>%
    handle_click(click_handle)
  
  ## extract the selected range
  x_range <- reactive({
    input$slider
  })
  
  return(list(density = g, x_range = x_range))
}



densityFilterUI <- function(id) {
  ns <- NS(id)
  
  uiOutput(ns("slider_ui"))
}





create_filter <- function(x, ...) {
  
  UseMethod("create_filter", x)
  
}

create_filter.factor <- function(x, ...) {
  create_filter(as.character(x), ...)
}

create_filter.character <- function(x, inputId, label) {
  selectInput(inputId, label, choices = c("Choose One..." = "", unique(x)))
}

create_filter.numeric <- function(x, inputId, label) {
  sliderInput(inputId, label, min = min(x), max = max(x), value = c(min(x), max(x)))
}

create_filter.Date <- function(x, inputId, label) {
  dateRangeInput(inputId, label, start = min(x), end = max(x), min = min(x), max = max(x))
}




eval_filter <- function(x, ...) {
  
  UseMethod("eval_filter", x)
  
}

eval_filter.factor <- function(x, ...) {
  eval_filter(as.character(x), ...)
}

eval_filter.character <- function(x, selected) {
  if(is.null(selected)) {
    return(x == x)
  }
  if (selected == "") {
    return(x == x)
  }
  x == selected
}

eval_filter.numeric <- function(x, selected) {
  x >= selected[1] & x <= selected[2]
}

eval_filter.Date <- function(x, selected) {
  x >= selected[1] & x <= selected[2]
}





update_selection <- function(selection, new, selection_type = c("single", "many")) {
  if(!(selection_type %in% c("single", "many"))) {
    stop(paste("Invalid selection type", selection_type, ": Choose one of \"single\", \"many\""))
  }
  if (selection_type == "single") {
    selection <- new
  }
  
  if (selection_type == "many") {
    if(new %in% selection) {
      selection <- selection[selection != new]
    } else {
      selection <- c(selection, new)
    }
  }
  selection
}


