######################
####### SERVER #######
######################

server <- function(input, output, session) {
  
  # Second tab - builds participant list
  participant_list_outputs <- callModule(participantListModule, "pl", data = participant_list, filter = c("gender", "Gender"))
  
  # Possible filters for participants list table
  observeEvent(input$filter_choice, {
    if (input$filter_choice == "Gender") {
      participant_list_outputs <- callModule(participantListModule, "pl", data = participant_list, filter = c("gender", "Gender"))
    } else if (input$filter_choice == "Race") {
      participant_list_outputs <- callModule(participantListModule, "pl", data = participant_list, filter = c("race", "Race"))
    } else if (input$filter_choice == "Age") {
      participant_list_outputs <- callModule(participantListModule, "pl", data = participant_list, filter = c("age", "Age"))
    } else if (input$filter_choice == "Treatment") {
      participant_list_outputs <- callModule(participantListModule, "pl", data = participant_list, filter = c("treatment", "Treatment"))
    } else if (input$filter_choice == "Hospital") {
      participant_list_outputs <- callModule(participantListModule, "pl", data = participant_list, filter = c("clinic_name", "Age"))
    }
  })
  
  # Defining side ID
  siteid <- reactive({
    participant_list_outputs$filtered_data()$siteid
  })
  
  # Defining propensity
  propensity <- reactive({
    participant_list_outputs$filtered_data()$propensity
  })
  
  # First tab -------
  
  # Bar plot for cohort 1
  site_plot1 <- callModule(barplotFilter, "barplot_cohort1", values = siteid, selection_type = "many", fillOpacity.hover := 0.8)
  # Density plot for cohort 1
  density_plot1 <- callModule(densityFilter, "density_cohort1", values = propensity, label = "Select Risk Range")
  
  # Tooltip that appears when browsing over the barplot
  site_tooltip <- function(x) {
    if(is.null(x)) return(NULL)
    if(x$clicked == 0) {
      return("Click to Add Clinic to Cohort")
    }
    if(x$clicked == 1) {
      return("Click to Remove Clinic from Cohort")
    }
  }
  
  # Barplot for cohort 1
  site_plot1$barplot %>%
    add_axis("x", title = "Clinic ID") %>%                 # X axis
    add_axis("y", title = "Number of Participants") %>%    # Y axis
    add_tooltip(site_tooltip, on = "hover") %>%            # Tooltip
    set_options(width = "auto") %>%                        # Options
    bind_shiny("barplot1")                                 # Embedding ggvis in a shiny app
  
  # Density plot for cohort 1
  density_plot1$density %>%
    add_axis("x", title = "Risk of Asthma Exacerbation") %>%     # X axis
    set_options(width = "auto") %>%                              # Options
    bind_shiny("density1")                                       # Embedding ggvis in a shiny app
  
  
  # Bar plot for cohort 2
  site_plot2 <- callModule(barplotFilter, "barplot_cohort2", values = siteid, selection_type = "many", fillOpacity.hover := 0.8)
  # Density plot for cohort 2
  density_plot2 <- callModule(densityFilter, "density_cohort2", values = propensity, label = "Select Risk Range")
  
  site_plot2$barplot %>% set_options(width = "auto") %>%
    add_axis("x", title = "Clinic ID") %>%
    add_axis("y", title = "Number of Participants") %>%
    add_tooltip(site_tooltip, on = "hover") %>% 
    set_options(width = "auto") %>%
    bind_shiny("barplot2")
  
  density_plot2$density %>%
    set_options(width = "auto") %>%
    add_axis("x", title = "Risk of Asthma Exacerbation") %>%
    bind_shiny("density2")
  
  cohort1_filters <- reactive({
    cohort_sites <- site_plot1$clicked()
    cohort_range <- density_plot1$x_range()
    cohort_date_range <- input$date1
    
    if(is.null(cohort_sites)) {
      cohort_sites <- sort(unique(participant_list$siteid))
    }
    if(length(cohort_sites) == 0) {
      cohort_sites <- sort(unique(participant_list$siteid))
    }
    if(is.null(cohort_range)) {
      cohort_range <- c(0, 1)
    }
    
    list(sites = cohort_sites, range = cohort_range, date = cohort_date_range)
  })
  
  cohort1 <- reactive({
    d <- participant_list_outputs$filtered_data()
    filters <- cohort1_filters()
    cohort_sites <- filters$sites
    cohort_range <- filters$range
    cohort_date_range <- filters$date
    
    out <- d %>% filter(siteid %in% cohort_sites, propensity >= cohort_range[1], propensity <= cohort_range[2], date_of_inclusion >= cohort_date_range[1], date_of_inclusion <= cohort_date_range[2])
    if(nrow(out) == 0) {
      return(d)
    } else {
      return(out)
    }
  })
  
  output$cohort1_summary <- renderUI({
    d <- cohort1()
    filters <- cohort1_filters()
    n <- nrow(d)
    
    HTML(
      paste0("<h3><strong style=\"font-size: 125%;\">", n, "</strong> Participants in Current Selection:</h3><p>Clinic ID in ",
             paste(filters$sites, collapse = ","),
             "</br> Risk of asthma exacerbation between ", filters$range[1], " and ", filters$range[2],
             "</br> Date of Inclusion between ", as.Date(filters$date[1]), " and ", as.Date(filters$date[2]),
             "</p>"
      )
    )
  })
  
  cohort2_filters <- reactive({
    cohort_sites <- site_plot2$clicked()
    cohort_range <- density_plot2$x_range()
    cohort_date_range <- input$date2
    
    if(is.null(cohort_sites)) {
      cohort_sites <- sort(unique(participant_list$siteid))
    }
    if(length(cohort_sites) == 0) {
      cohort_sites <- sort(unique(participant_list$siteid))
    }
    if(is.null(cohort_range)) {
      cohort_range <- c(0, 1)
    }
    
    list(sites = cohort_sites, range = cohort_range, date = cohort_date_range)
  })
  
  cohort2 <- reactive({
    d <- participant_list_outputs$filtered_data()
    filters <- cohort2_filters()
    cohort_sites <- filters$sites
    cohort_range <- filters$range
    cohort_date_range <- filters$date
    
    out <- d %>% filter(siteid %in% cohort_sites, propensity >= cohort_range[1], propensity <= cohort_range[2], date_of_inclusion >= cohort_date_range[1], date_of_inclusion <= cohort_date_range[2])
    if(nrow(out) == 0) {
      return(d)
    } else {
      return(out)
    }
  })
  
  output$cohort2_summary <- renderText({
    d <- cohort2()
    filters <- cohort2_filters()
    n <- nrow(d)
    
    HTML(
      paste0("<h3><strong style=\"font-size: 125%;\">", n, "</strong> Participants in Current Selection:</h3><p>Clinic ID in ",
             paste(filters$sites, collapse = ","),
             "</br> Risk of asthma exacerbation ", filters$range[1], " and ", filters$range[2],
             "</br> Date of Inclusion between ", as.Date(filters$date[1]), " and ", as.Date(filters$date[2]),
             "</p>"
      )
    )
  })
  
  cohort1 %>% ggvis(~gender) %>%
    layer_bars(fill := "B22222", fillOpacity := 0.8, fillOpacity.hover := 0.9, strokeWidth := 2) %>%
    add_axis("x", title = "Gender") %>%
    add_axis("y", title = "Number of Participants") %>%
    set_options(width = "auto") %>%
    bind_shiny("sex_cohort1")
  
  cohort2 %>% ggvis(~gender) %>%
    layer_bars(fill := "B22222", fillOpacity := 0.8, fillOpacity.hover := 0.9, strokeWidth := 2) %>%
    add_axis("x", title = "Gender") %>%
    add_axis("y", title = "Number of Participants") %>%
    set_options(width = "auto") %>%
    bind_shiny("sex_cohort2")
  
  
  cohort1 %>% ggvis(~age_bands) %>% layer_bars() %>%
    add_axis("x", title = "", properties = axis_props(labels = list(angle = 45, align = "left", baseline = "middle"))) %>%
    add_axis("y", title = "Number of Participants") %>% 
    set_options(width = "auto") %>%
    bind_shiny("age_cohort1")
  
  cohort2 %>% ggvis(~age_bands) %>% layer_bars() %>%
    add_axis("x", title = "", properties = axis_props(labels = list(angle = 45, align = "left", baseline = "middle"))) %>%
    add_axis("y", title = "Number of Participants") %>% 
    set_options(width = "auto") %>%
    bind_shiny("age_cohort2")
  
  
  cross_tab_data1 <- reactive({
    d <- cohort1()
    var1 <- input$cross_var11
    var2 <- input$cross_var12
    
    if(is.null(var1) || is.null(var2) || nrow(d) == 0) {
      return(data.frame(x = c(0, 0, 1, 1), x2 = c(1, 1, 2, 2), y = c(0, 1, 0, 1), y2 = c(1, 2, 1, 2), values = c(0, 0, 0, 0)))
    }
    vars <- name_map[c(var1, var2)]
    
    d <- d[, vars]
    
    t <- table(factor(d[,1], levels = c(0, 1)), factor(d[,2], levels = c(0, 1)))
    d <- data.frame(x = c(0, 0, 1, 1), x2 = c(1, 1, 2, 2), y = c(0, 1, 0, 1), y2 = c(1, 2, 1, 2))
    d$values <- c(t[2], t[4], t[1], t[3])
    d
  })
  
  
  cross_tab_tt <- function(x) {
    if(is.null(x)) return(NULL)
    
    link1 <- if (x$x == 0) {
      "with "
    } else {
      "without "
    }
    
    link2 <- if (x$y == 1) {
      "with "
    } else {
      "without "
    }
    
    paste0(x$values, " Participants ", link1, input$cross_var11, " and ", link2, input$cross_var12)
  }
  
  observe({
    cross_tab_data1 %>% cross_tab() %>%
      add_tooltip(cross_tab_tt) %>%
      set_options(width = "auto") %>%
      hide_legend("fill") %>%
      bind_shiny("cross_tab1")
  })
  
  output$cohort1_measures <- renderUI({
    d <- cohort1()
    
    values <- lapply(d[, cross_var_choices[1:4]], perc_equal_to, a = 1)
    
    fluidRow(
      column(3,
             valueBox(values[[1]], cross_var_choices[1], width = NULL)
      ),
      column(3,
             valueBox(values[[2]], cross_var_choices[2], width = NULL)
      ),
      column(3,
             valueBox(values[[3]], cross_var_choices[3], width = NULL)
      ),
      column(3,
             valueBox(values[[4]], cross_var_choices[4], width = NULL)
      )
    )
  })
  
  cross_tab_data2 <- reactive({
    d <- cohort2()
    var1 <- input$cross_var21
    var2 <- input$cross_var22
    
    if(is.null(var1) || is.null(var2) || nrow(d) == 0) {
      return(data.frame(x = c(0, 0, 1, 1), x2 = c(1, 1, 2, 2), y = c(0, 1, 0, 1), y2 = c(1, 2, 1, 2), values = c(0, 0, 0, 0)))
    }
    vars <- name_map[c(var1, var2)]
    
    d <- d[, vars]
    
    t <- table(d[,1], d[,2])
    d <- data.frame(x = c(0, 0, 1, 1), x2 = c(1, 1, 2, 2), y = c(0, 1, 0, 1), y2 = c(1, 2, 1, 2))
    d$values <- c(t[2], t[4], t[1], t[3])
    d
  })
  
  observe({
    cross_tab_data2 %>% cross_tab() %>%
      add_tooltip(cross_tab_tt) %>%
      set_options(width = "auto") %>%
      hide_legend("fill") %>%
      bind_shiny("cross_tab2")
  })
  
  output$cohort2_measures <- renderUI({
    d <- cohort2()
    
    values <- lapply(d[, cross_var_choices[1:4]], perc_equal_to, a = 1)
    
    fluidRow(
      column(3,
             valueBox(values[[1]], cross_var_choices[1], width = NULL)
      ),
      column(3,
             valueBox(values[[2]], cross_var_choices[2], width = NULL)
      ),
      column(3,
             valueBox(values[[3]], cross_var_choices[3], width = NULL)
      ),
      column(3,
             valueBox(values[[4]], cross_var_choices[4], width = NULL)
      )
    )
  })
  
  bp_density1 <- reactive({
    cohort1() %>% group_by(gender)
  })
  
  bp_density2 <- reactive({
    cohort2() %>% group_by(gender)
  })
  
  bp_density1 %>% ggvis(~bp_diastolic) %>% layer_densities(fill = ~gender, stroke = ~gender) %>%
    set_options(width = "auto") %>%
    bind_shiny("bp_density1")
  
  bp_density1 %>% ggvis(~gender, ~resp) %>% layer_boxplots(fill = ~gender, stroke = ~gender, fillOpacity := 0.8) %>%
    set_options(width = "auto") %>%
    bind_shiny("resp_box1")
  
  
  bp_density2 %>% ggvis(~bp_diastolic) %>% layer_densities(fill = ~gender, stroke = ~gender) %>%
    set_options(width = "auto") %>%
    bind_shiny("bp_density2")
  
  bp_density2 %>% ggvis(~gender, ~resp) %>% layer_boxplots(fill = ~gender, stroke = ~gender, fillOpacity := 0.8) %>%
    set_options(width = "auto") %>%
    bind_shiny("resp_box2")
  
  
  cohort1 %>% ggvis(~treatment) %>% layer_bars(fill = ~treatment) %>%
    set_options(width = "auto") %>%
    bind_shiny("treatment_bars1")
  
  cohort2 %>% ggvis(~treatment) %>% layer_bars(fill = ~treatment) %>%
    set_options(width = "auto") %>%
    bind_shiny("treatment_bars2")
  
  cohort1 %>% ggvis(~height, ~weight) %>% layer_points(fill = ~treatment) %>%
    set_options(width = "auto") %>%
    bind_shiny("treatment_points1")

  cohort2 %>% ggvis(~height, ~weight) %>% layer_points(fill = ~treatment) %>%
    set_options(width = "auto") %>%
    bind_shiny("treatment_points2")
    
  observe({
    input$report
    if(input$report > 0) {
      updateNavbarPage(session, inputId = "navbar", selected = "Report")
    }
  })
    
    
  output$pdf <- renderText({
    return(paste('<iframe style="height:900px; width:100%" src="report.pdf"></iframe>', sep = ""))
  })
    
}

