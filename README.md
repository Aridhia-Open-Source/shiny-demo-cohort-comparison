# Cohort Comparison

This R Shiny mini-app reads and combines mock up data about clinic codes, demographic information, genotype and clinical measures. Then, it presents two
filterable cohort views for comparison and prints a filterable table with the participants list. It also allows you to download an automatically generated
PDF template report. 

## About the mini-app

This mini-app contains four tabs:

1. Viewing and comparing two cohorts side-by-side. You can apply filters in one side to create a cohort and easily compare it to the original population, shown in the other side of the screen.
2. Builds a table showing the participant list. You can apply some filters to the list based on gender, race, age, treatment and hospital.
3. Prints an automatically generated PDF report template.
4. Help tab.

## Checkout and run

You can clone this repository by using the command:

```
git clone https://github.com/aridhia/demo-cohort-comparison
```

Open the .Rproj file in RStudio and use `runApp()` to start the app.

## Deploying to the workspace

1. Create a new mini-app in the workspace called "cohort-comparison"" and delete the folder created for it
2. Download this GitHub repo as a .ZIP file, or clone the repository and zip all the files
3. Upload the .ZIP file to the workspace and upzip it inside a folder called "cohort-comparison"
4. Run the `dependencies.R` script to install all the packages that the app requires
5. Run the app in your workspace

For more information visit https://knowledgebase.aridhia.io/article/how-to-upload-your-mini-app/

