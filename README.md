# Postcode Quality in England

## Motivations and goals of this project

The goal of this project is to create an analysis of the best postcodes to move into depending on freely available UK data.

The raw data is cleaned in a jupyter notebook file.

This project contains 2 code versions: 

- A version coded in R, using reticulate to read the pickle files and outputting a Shiny App.
- A version coded in Python, using a jupyter notebook to show the results.


## Data used

For this analysis, I used freely available UK data (Links in section below). In particular, I used:

1. The Index of Multiple Deprivation Data from ONS
2. The Flood data from getthedata.com
3. Elevation and some pets data from data.world

All data are cleaned in the jupyter notebook "filter_raw_data.ipynb" to contain only english rows and necessary columns.



## Libraries used

### In Python

I used the following packages:

- pandas version 1.5.0
- numpy version 1.23.3
- os
- matplotlib version 3.6.0 (we import only matplotlib.pyplot)

### In R

I used the following packages:

- reticulate
- shiny
- shinyMobile
- shinyWidgets
- tidyverse
- leaflet
- leaflet.extras


## Files in the project

### filter_raw_data.ipynb

This notebook filters down the raw data to be able to push it into GitHub.

I filtered the columns to only be the ones necessary for the analysis. I only took the english postcodes.

To save more space, I downcasted the numerical columns. All files are saved in file "data/filtered".

I was able to cut down data size from 1.14GB to 88MB.


### postcode_quality_check.ipynb

This notebook is the Python version of the main file for this analysis. 
It reads the different filtered tables, joins them, and then return some results depending on a postcode input.

The results given are:
- The name of the postcode, LSOA, District and Sector
- The risk of flooding of the postcode
- The elevation of the postcode
- The number of cats in the districts (with histogram and quantile on the country's distribution)
- The average number of dogs per household (with histogram and quantile on the country's distribution)
- A map where the postcode can be found
- The different IMD ranks

### postcode_quality_check.R

This notebook is the R version of the main file for this analysis. 
It reads the different filtered tables, joins them, and then return some results depending on a postcode input in a form of a Shiny App.

The results given are:
- The name of the postcode, LSOA, District and Sector
- The risk of flooding of the postcode
- The elevation of the postcode
- The number of cats in the districts (with histogram and quantile on the country's distribution)
- The average number of dogs per household (with histogram and quantile on the country's distribution)
- A map where the postcode can be found
- The different IMD ranks

### Misc files

The other files are admin files:
- .gitignore: filters the files that will be pushed to GitHub
- LICENSE: the licence for this repo
- moving_postcode_filter.Rproj: The R project file to open Rstudio

### data folder
This folder contains 2 subfolders (only 1 in GitHub):
- Raw, containing the raw data sourced online. These files are too big to be pushed to GitHub.
- filtered, containing the cleaned and filtered data. Outputs of file "filter_raw_data.ipynb"

### venv folder
Folder containing the virtual environment for Python


## Links

### Links to data

- https://www.getthedata.com/flood-map/PE

- https://data.world/

- https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019


### Interesting links to keep when trying to deploy the app

- https://joe-bologna.medium.com/how-to-make-an-r-shiny-progressive-web-app-cba06fdf97e0

- https://developers.google.com/web/tools/lighthouse/

- https://unleash-shiny.rinterface.com/mobile-pwa.html#handle-the-installation

- https://www.shinyapps.io/admin/#/signup


### Interesting links for possible improvements:

- https://joeblogs.technology/2020/03/retrieving-data-from-rightmoves-api/




<!-- 
## In the blog post:

- A clear and engaging title and image.
- Your questions of interest.
- Your findings for those questions with a supporting statistic(s), table, or visual. -->
