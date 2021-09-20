# This script will create a supervised model given a list of images. The model can be used to predict the nitrate level. 
# First, it will create a dataframe with all rgb values of the colours in an image. Each row represents an image.

library(jpeg)
library(reshape)

NUMBER_OF_COLOURS <- 20

path <- "www/"
files <- paste0(path, c("Red Value - 181 - 10ppm of nitrate.jpg", 
                        "Red Value - 193 - 20ppm of Nitrate.jpg", 
                        "Red Value - 204 - 50ppm of Nitrate.jpg", 
                        "Red Value - 221 - 70 ppm of Nitrate.jpg", 
                        "Red Value - 239 - 100ppm of Nitrate.jpg"))

# get RGB values for a given filename (jpg) and number of colours
getRGB <- function(filename, numberOfColours){
  image <- readJPEG(filename)
  longImage <- melt(image)
  rgbImage <- reshape(longImage, timevar = "X3", idvar = c("X1", "X2"), direction = "wide")
  rgbImage$X1 <- -rgbImage$X1
  kMeans <- kmeans(rgbImage[, 3:5], centers = numberOfColours)
  approximateColor <- kMeans$centers[kMeans$cluster, ]
  col = rgb(approximateColor)
  sortedCols <- sort(table(col))
  colName <- names(sortedCols)
  rgbValues <- col2rgb(colName)
  return(rgbValues)
}

# create image dataframe given filenames and number of colors
# Each row will contain the data about an image. The columns are the rgb values for the colors in the image
getImageDataframe <- function(fileNames, numberOfColours){
  result_df <- NULL
  for (fileName in fileNames){
    rgbValues <- getRGB(fileName, numberOfColours)
    image_df <- data.frame(t(data.frame(rgbValues[,1])))
    for(i in 2:ncol(rgbValues)){
      for (j in 1:3){
        if (j ==1){
          colName <- paste0("red", i)
        } else if(j ==2){
          colName <- paste0("green", i)
        } else if(j ==3){
          colName <- paste0("blue", i)
        }
        image_df[1, colName] <- rgbValues[j,i]
      }
    }
    if(is.null(result_df)) {
      result_df <- data.frame(matrix(ncol = length(colnames(image_df)), nrow = 0))
      colnames(result_df) <- colnames(image_df)
    }
    result_df <- rbind(result_df, image_df)
  }
  rownames(result_df) <- NULL
  result_df
}


#181 -> 10
#193 -> 20
#204 -> 50
#221 -> 70
#239 -> 100

#df <- getImageDataframe(files, NUMBER_OF_COLOURS)
# add nitrate level fied
#df$nlevel <- c(10, 20, 50, 70, 100)
# create a linear model
#df.lm = lm(nlevel ~ ., data=df) 

# predict on training data -> this will give the nlevels above of course..
#print(predict(df.lm, df))
# TODO predict on test data (new images)