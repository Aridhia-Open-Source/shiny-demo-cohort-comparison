source("xap_wrapper.r")

xap.require("ggvis",
            "dplyr",
            "shiny",
            "shinydashboard")



source("modules.r")


 
demo <- xap.read_table("pediatrics_demographics")
geno <- xap.read_table("pediatrics_genotypes")
measures <- xap.read_table("pediatrics_measures")
clinics <- xap.read_table("pediatrics_clinic_identifiers")

cross_var_choices <- colnames(geno[2:11])


demo$gender <- factor(demo$gender, levels = c("Female", "Male"))
measures$treatment <- factor(measures$treatment, levels = c("Budesonide", "Nedocromil", "Placebo"))

geno <- geno[, 1:15]

perc_equal_to <- function(x, a, n = 2) {
  round(100 * sum(x == a) / length(x), n)
}

name_map <- colnames(geno[2:11])
names(name_map) <- colnames(geno[2:11])


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


