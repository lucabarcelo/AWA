## prepare the OAuth token and set up the target sheet:
##  - do this interactively
##  - do this EXACTLY ONCE

# library(googlesheets)
# shiny_token <- gs_auth() # authenticate w/ your desired Google identity here
# saveRDS(shiny_token, "shiny_app_token.rds")
# files <- gs_ls()
# sheet_key <- files[files$sheet_title=="MIAS Nitrate",]$sheet_key
# put the value of sheet_key below!

#readRDS("../shiny_app_token.rds")
#sheet_key <- "1h0nrOlNymJ8nLQfd8SFFVr6hVt6D4LtX_pZOdnwD8Io"
sheet_key <- "1zfRJT2hcbJlTiLEPqre1o6Sq8Fkmu1ErZ--eujadOFg"
sheet <- gs_key(sheet_key)
