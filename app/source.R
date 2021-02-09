### LIBRARIES ###
#####################################################################

if (!require("tidyverse")) {
  install.packages("tidyverse")
  library(tidyverse)
}
if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}
if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}
if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}
if (!require("plotly")) {
  install.packages("plotly")
  library(plotly)
}
if (!require("shinydashboard")) {
  install.packages("shinydashboard")
  library(shinydashboard)
}
if (!require("emojifont")) {
  install.packages("emojifont")
  library(emojifont)
}
if (!require("shinyWidgets")) {
  install.packages("shinyWidgets")
  library(shinyWidgets)
}
if (!require("quantmod")) {
  install.packages("quantmod")
  library(quantmod)
}
if (!require("plotly")) {
  install.packages("plotly")
  library(plotly)
}
if (!require("sparsepca")) {
  install.packages("sparsepca")
  library(sparsepca)
}


### DATA SOURCING ### FOR LONG-TERM STOCKS ###
#####################################################################

# get data via web scraping from yahoo finance
# focus is on 27 companies that were listed in Dow for 2+ years

index <- seq(1, 27, 1)

company_names <- c("3M", "American Express", "Apple", "Boeing", "Caterpillar", "Chevron", "Cisco", "Coca-Cola", "Disney",
                   "ExxonMobil", "Goldman Sachs", "Home Depot", "IBM", "Intel", "Johnson & Johnson", "JP Morgan", "McDonald's", "Merck", 
                   "Microsoft", "Nike", "Procter & Gamble", "Travelers Companies", "UnitedHealth Group", "Verizon", "Visa", "Walgreens", "WalMart")

companies <- c("MMM", "AXP", "AAPL", "BA", "CAT", "CVX", "CSCO", "KO", "DIS",
               "XOM", "GS", "HD", "IBM", "INTC", "JNJ", "JPM", "MCD", "MRK", 
               "MSFT", "NKE", "PG", "TRV", "UNH", "VZ", "V", "WBA", "WMT")

companies_df_list <- rep(NA, length(companies))

for (i in 1:length(companies)){
  assign(paste("data", companies[i], sep = ""), 
         getSymbols(companies[i], auto.assign = F, from ="2017-01-01", to = Sys.Date()))
}

# datasets are labeled as 'data[STOCK]' e.g. dataAAPL

companies_df <- list(dataMMM, dataAXP, dataAAPL, dataBA, dataCAT, dataCVX, dataCSCO, dataKO, dataDIS,
                     dataXOM, dataGS, dataHD, dataIBM, dataINTC, dataJNJ, dataJPM, dataMCD, dataMRK, 
                     dataMSFT, dataNKE, dataPG, dataTRV, dataUNH, dataVZ, dataV, dataWBA, dataWMT)

### DATA CLEANING ### FOR LONG-TERM STOCKS ###
#####################################################################

# 27 stocks (rows) and 252 returns (columns/features/predictors)

dates <- rownames(data.frame(dataMMM))

companies_adjusted <- data.frame(dates)

for (j in 1:length(companies_df)){
  companies_adjusted <- cbind(companies_adjusted, as.numeric(companies_df[[j]][,6])) # adjusted closing prices
}

colnames(companies_adjusted) <- c("date", companies)

