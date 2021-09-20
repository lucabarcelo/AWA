source("global.R")
source("load_data.R")
source("image_rgb.R")

# server part
shinyServer(function(input, output, session) {
  
  values <- reactiveValues()
  
  # plot image
  output$plotDetect <- renderPlot({
    inFile <- input$file
    
    if (is.null(inFile))
      return(NULL)
    
    readImage <- readJPEG(inFile$datapath)
    longImage <- melt(readImage)
    rgbImage <- reshape(longImage, timevar = "X3", idvar = c("X1", "X2"), direction = "wide")
    rgbImage$X1 <- -rgbImage$X1
    kColors <- (input$ncolors)  # Number of palette colors
    kMeans <- kmeans(rgbImage[, 3:5], centers = kColors)
    approximateColor <- kMeans$centers[kMeans$cluster, ]
    col = rgb(approximateColor)
    barvy <- sort(table(col))
    barva <- row.names(barvy)
    barplot(barvy, col=barva, horiz=TRUE)
    approximateColor <- kMeans$centers[kMeans$cluster, ]
    with(rgbImage, plot(X2, X1, col = rgb(approximateColor), asp = 1, pch = "."))
  })
  
  output$plotcolors <- renderPlotly({
    inFile <- input$file
    
    if (is.null(inFile))
      return(NULL)
    
    readImage <- readJPEG(inFile$datapath)
    longImage <- melt(readImage)
    rgbImage <- reshape(longImage, timevar = "X3", idvar = c("X1", "X2"), direction = "wide")
    rgbImage$X1 <- -rgbImage$X1
    kColors <- (input$ncolors)  # Number of palette colors
    kMeans <- kmeans(rgbImage[, 3:5], centers = kColors)
    approximateColor <- kMeans$centers[kMeans$cluster, ]
    col = rgb(approximateColor)
    barvy <- sort(table(col))
    barva <- row.names(barvy)
    #store colors and values
    values$input_colors <<- rev(barva)
    values$input_values <<- rev(barvy)

    #plot
    if(length(barvy) > 1){
      df <- data.frame(values= barvy)
      colnames(df) <- c("colors", "values")
    } else{
      df <- data.frame(colors = names(barvy), values= barvy[1])
    }
    return(plotColors(df, "Image colors"))
  })
  
  # map
  output$map <- renderLeaflet({
    leaflet()  %>% setView(lng = MAP_CENTER_LNG, lat = MAP_CENTER_LAT, zoom = MAP_ZOOM_LEVEL) %>% addTiles()
  })
  
  observeEvent(input$map_click,{
    ## Get the click info
    click <- input$map_click
    loc  <- c(click$lng, click$lat)
    address <- revgeocode(loc)
    #store 
    values$input_lat  <<- round(click$lat,3)
    values$input_lng  <<- round(click$lng,3)
    values$input_address  <<- address

    ## clear previous markers and add new marker for clicked position  
    leafletProxy('map') %>% # use the proxy to save computation
      clearMarkers() %>%    # clear previous markers
      addMarkers(lng=click$lng, lat=click$lat, popup=address)
  })
  
  data <- eventReactive({input$submit | input$refresh}, data.frame(gs_read(sheet)), ignoreNULL = FALSE)
  
  # overview map
  output$mapoverview <- renderLeaflet({
    leaflet()  %>% 
      setView(lng = MAP_CENTER_LNG, lat = MAP_CENTER_LAT, zoom = MAP_ZOOM_LEVEL) %>% 
      addTiles() %>% 
      addMarkers(lng=data()$lng, lat=data()$lat)
  })
  
  # handle the click on a marker (=location)
  observe({
    click<-input$mapoverview_marker_click
    if(is.null(click))
      return()
    df <- data()
    selected_row <- df %>% filter(str_detect(lat, as.character(click$lat))) %>% filter(str_detect(lng, as.character(click$lng)))
    values$selection <<- selected_row
    leafletProxy('mapoverview') %>% 
      clearPopups() %>%
      addPopups(click$lng, click$lat, selected_row$address)
  })
  
  #handle submit button
  observeEvent(
    input$submit, {
      #disable button and enable on exit
      disable('submit')
      on.exit(enable('submit'))
      
      #check values
      if(!is.null(values$input_lat) & !is.null(values$input_colors)){
        submitData <- c(values$input_lat, values$input_lng, values$input_address, paste(values$input_colors,collapse=" "), paste(values$input_values,collapse=" "), values$input_nlevel)
        gs_edit_cells(sheet, input = submitData, byrow = TRUE, anchor = paste0("A", as.character(nrow(data()) + 2)))
        updateTextAreaInput(session, "explain", value = paste("Image data submitted for location:", values$input_address))
      } else{
        updateTextAreaInput(session, "explain", value = paste("Missing data! Please select a location and upload a (jpeg) image."))
      }
  })
  
  # output nlevel of selected location
  output$nlevelLocation <-renderText({
    if (is.null(values$selection)){
      ""
    } else{
      paste0("The predicted nitrate level for location: ", values$selection$address, ",using model ", USE_MODEL, ", is: ",values$selection$nlevel, " ppm")
    }
  }) 
  
  # Create a bar chart. Each bar represents a color, the length of the bar is the value related to the color.
  plotColors <- function(df, plotTitle){
    df <- df[order(df$values, decreasing = TRUE),]
    plotcolors <- rev(as.character(df$colors))
    
    p <- ggplot(df, aes(x = colors, y = values, fill = colors)) + 
      geom_bar(stat = "identity") + 
      coord_flip() + 
      scale_fill_manual(values=plotcolors) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      labs(title=plotTitle) + labs(x="", y="") +                                         # set titles and labels at axis
      theme_grey(base_size = FONT_BASE_SIZE) +
      theme(legend.position = "none") +                                                  # no legend
      theme(plot.margin=unit(PLOT_MARGINS, "cm"))                                        # add a margin around the plot
    return(ggplotly(p) %>% config(displayModeBar = F))                                                                     
  }
  
  # predict nitrate level
  predictNitrateLevel <- function(file, ncolors){
    df <- getImageDataframe(c(file), ncolors)
    df[] <- lapply(df, as.numeric)
    if(USE_MODEL == "xgb"){
      nlevel <- predict(xgb, data.matrix(df))
    } else{
      nlevel <- predict(df.lm, df)
    }
    # round the nlevel and store, before returning it
    nlevel <- round(nlevel)
    values$input_nlevel <<- nlevel
    return(nlevel)
  }
  
  output$nlevel <-renderText({
    if(is.null(input$file)) {
      ""
    } else{
      paste("The predicted nitrate level is:", predictNitrateLevel(input$file$datapath, input$ncolors))
    }
  }) 
  
  # if no image uploaded and no location selected disable submit button
  observe(toggleState('submit', !is.null(values$input_lat) & !is.null(values$input_colors)))
  
})