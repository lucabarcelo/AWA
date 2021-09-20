library(shiny)
library(reshape)
library(ggplot2)
library(readbitmap)
library(jpeg)
library(leaflet)
library(shinydashboard)
library(ggmap)
library(googlesheets)
library(stringr)
library(dplyr)
library(shinyjs)
library(plotly)


options(shiny.sanitize.errors = FALSE)

main_title <- 'MIAS Nitrate'

# number of colors to be chose
NCOLORS_VAL <- 10
NCOLORS_MIN <- 10
NCOLORS_MAX <- 16

#Map properties (coordinates are of new york)
MAP_CENTER_LNG <- -73.935242
MAP_CENTER_LAT <- 40.730610
MAP_ZOOM_LEVEL <- 2

# default plot margins (in cm)
PLOT_MARGINS <- c(1, 1, 1, 1)
# default font size in plots
FONT_BASE_SIZE <- 14

# load model
load("lm.RData")
load("xgb.RData")

USE_MODEL <- "xgb"

#color of dashbord
DASHBORD_COLOR <- "blue"


