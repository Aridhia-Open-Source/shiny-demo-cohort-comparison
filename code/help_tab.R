########################
####### HELP TAB #######
########################


documentation_tab <- function() {
  tabPanel("Help",
           fluidPage(width = 12,
                     fluidRow(column(
                       6,
                       h3("Cohort Comparison"), 
                       p("This R Shiny mini-app reads and combines mock up data about clinic codes, demographic information and genotype and clinical measures.
                       It then presents two filterable cohort views for comparison, prints a filterable table with the participants list, and allows you to 
                       download an automatically generated PDF template report"),
                       h4("How to use the mini-app"),
                       p("The mini-app contains three tabs. This 'Help' tab gives you an overview of the mini-app itself."),

                       tags$ol(
                         tags$li("The first tab allows ", strong("viewing and comparing two cohorts side-by-side. "), "You can apply filter in one 
                                 side to create a cohort and easily compare it to the original population shown in the other side of the screen."), 
                         
                         tags$li("The second tab builds a ", strong("the participant list"), 
                                 " as a table. You can apply some filters to the list based on gender, race, age, treatment and hospital."),
                         tags$li("In the third tab prints an automatically generated ", strong("PDF report template "))
                       ),
                     ),
                     column(
                       6,
                       h3("Walkthrough video"),
                       tags$video(src="cohort-comparison.mp4", type = "video/mp4", width="100%", height = "350", frameborder = "0", controls = NA),
                       p(class = "nb", "NB: This mini-app is for provided for demonstration purposes, is unsupported and is utilised at user's 
                       risk. If you plan to use this mini-app to inform your study, please review the code and ensure you are 
                       comfortable with the calculations made before proceeding. ")
                       
                     ))
                     
                     
                     
                     
           ))
}