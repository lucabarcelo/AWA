source("global.R")

dbHeader <- dashboardHeader(title = main_title)

shinyUI(dashboardPage(skin = DASHBORD_COLOR,
  
  dbHeader,
  dashboardSidebar(
      hr(),p(),
      fileInput('file', 'Upload image', accept=c('jpg')),
      hr(),p(),
      sliderInput("ncolors", 
                  "Number of colors:", 
                  min = NCOLORS_MIN, 
                  max = NCOLORS_MAX, 
                  value = NCOLORS_VAL),
      hr(),p(),
      actionButton("submit", "Submit data"),
      hr(),p(),
      actionButton("refresh", "Refresh overview"),
      hr(),p(),
      actionButton("fbShareBtn", "Share on facebook"),
      hr(),p(),
      h4("Contact us", align = "center"),
      p("Tel: 2039795464", align = "center"),
      width = "250px"
    ),
    
  dashboardBody(
      shinyjs::useShinyjs(), 
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
        includeScript("www/fb.js")
      ),
      tabsetPanel(
        tabPanel("Overview", 
                 fluidRow(leafletOutput("mapoverview")),
                 fluidRow(column(10,textOutput("nlevelLocation")))
        ),
        tabPanel("Input",
                  fluidRow(
                    box(leafletOutput("map")),
                    box(textAreaInput("explain", paste(main_title, "readme"), paste("Please select a location on the map and upload the (jpeg) image. After that click submit to store the data.")))),
                  fluidRow(textOutput('text')), 
                  fluidRow(
                    column(6,plotOutput("plotDetect", height = "400px")), 
                    fluidRow(
                      column(6,plotlyOutput("plotcolors", height = "380px" )),
                      column(6,textOutput("nlevel"))
                    )
                  )
        )
      )
    )
  )
)
