# Cohort Comparison

This R Shiny mini-app reads and combines mock up data about clinic codes, demographic information, genotype and clinical measures. Then, it presents two
filterable cohort views for comparison and prints a filterable table with the participants list. It also allows you to download an automatically generated
PDF template report. 

## About the mini-app

This mini-app contains four tabs:

1. The first tab allows viewing and comparing two cohorts side-by-side. You can apply filters in one side to create a cohort and easily compare it to the original population, shown in the other side of the screen.
2. The second tab builds a table showing the participant list. You can apply some filters to the list based on gender, race, age, treamtment and hospital.
3. The third tab prints an automatically generated PDF reporte template.
4. The fourth tab is the help tab, gives you an overview of the mini-app itself.

## Checkout and run

You can clone this repository by using the command:

```
git clone https://github.com/aridhia/demo-cohort-comparison
```

Open the .Rproj file in RStudio and use `runApp()` to start the app.

## Deploying to the workspace

1. Create a new mini-app in the workspace called "cohort-comparison" and delete the folder created for it
2. Download this GitHub repo as a .ZIP file, or zip all the files
3. Upload the .ZIP file to the workspace and upzip it inside a folder called "cohort-comparison"
4. Run the app in your workspace

