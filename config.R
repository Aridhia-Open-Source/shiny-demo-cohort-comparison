
xap.list_tables <- function() {
  list.files("data")
}

xap.read_table <- function(table_name) {
  read.csv(file.path("data", paste0(table_name, ".csv")))
}

