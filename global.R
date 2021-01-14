######################
####### GLOBAL #######
######################

# Load all the libraries
library(shiny)
library(shinydashboard)
library(dplyr)
library(ggvis)

# Sourcing config with xap functions
source("config.R")

# Sourcing all the files in the code folder
for (file in list.files("code", full.names = TRUE)){
  source(file, local = TRUE)
}

# Reading tables on data folder
demo <- xap.read_table("pediatrics_demographics")
geno <- xap.read_table("pediatrics_genotypes")
measures <- xap.read_table("pediatrics_measures")
clinics <- xap.read_table("pediatrics_clinic_identifiers")

cross_var_choices <- colnames(geno[2:11])

# Setting gender and treatment as factors
demo$gender <- factor(demo$gender, levels = c("Female", "Male"))
measures$treatment <- factor(measures$treatment, levels = c("Budesonide", "Nedocromil", "Placebo"))

geno <- geno[, 1:15]

perc_equal_to <- function(x, a, n = 2) {
  round(100 * sum(x == a) / length(x), n)
}

name_map <- colnames(geno[2:11])
names(name_map) <- colnames(geno[2:11])

# Crosstab for gene panels
cross_tab <- function(d, ...) {
  
  labels <- data.frame(x = c(-0.2, -0.2, 0.5, 1.5), y = c(0.5, 1.5, 2.2, 2.2), label = c("-", "+", "+", "-"))
  
  d %>% ggvis() %>% 
    layer_rects(x = ~x, y = ~y, x2 = ~x2, y2 = ~y2, fill = ~values, fillOpacity := 0.9, fillOpacity.hover := 1) %>%
    layer_text(x = ~x + 0.5, y = ~y + 0.5, text := ~values,
               align := "center", baseline := "middle",
               fill := "white", fontSize := 20) %>%
    layer_text(data = labels, x = ~x, y = ~y, text := ~label, fontSize := 20,
               align := "center", baseline := "middle") %>%
    hide_axis("x") %>%
    hide_axis("y")
  
}


participant_list <- demo %>% left_join(geno[, 1:10], by = "id") %>%
  left_join(measures, by = "id") %>% left_join(clinics, by = c("clinic_id" = "clinic_cd"))

participant_list <- participant_list[1:200, ]


participant_list$siteid <- participant_list$clinic_id
## mock up propensity
participant_list$propensity <- rnorm(nrow(participant_list))
## scale to 0-1
participant_list$propensity <- round((participant_list$propensity - min(participant_list$propensity)) / (max(participant_list$propensity) - min(participant_list$propensity)), 2)


participant_list$date_of_inclusion <- seq(as.Date("2016-01-01"), as.Date("2016-05-01"), length.out = nrow(participant_list))

labels <- c("< 2", "2 - 4", "4 - 6", "6 - 8", "8 - 10", "10 - 12", "12 - 14", ">= 14")

participant_list$age_bands <- cut(participant_list$age, c(-Inf, 2, 4, 6, 8, 10, 12, 14, Inf), labels = labels)

