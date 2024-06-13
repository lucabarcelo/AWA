## prepare the OAuth token and set up the target sheet:
##  - do this interactively
##  - do this EXACTLY ONCE

# library(googlesheets)
# shiny_token <- gs_auth() # authenticate w/ your desired Google identity here
# saveRDS(shiny_token, "shiny_app_token.rds")
# files <- gs_ls()
# sheet_key <- files[files$sheet_title=="",]$sheet_key
# put the value of sheet_key below!

#readRDS("../shiny_app_token.rds")
#sheet_key <- ""
sheet_key <- ""
sheet <- gs_key(sheet_key)
