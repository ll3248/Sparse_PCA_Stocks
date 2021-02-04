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

index <- range(1, 27)

company_names <- c("3M", "American Express", "Apple", "Boeing", "Caterpillar", "Chevron", "Cisco", "Coca-Cola", "Disney", 
                   "ExxonMobil", "Goldman Sachs", "Home Depot", "IBM", "Intel", "Johnson & Johnson", "JP Morgan", "McDonald's", "Merck", 
                   "Microsoft", "Nike", "Procter & Gamble", "Travelers Companies", "UnitedHealth Group", "Verizon", "Visa", "WalMart", "Walgreens")

companies <- c("MMM", "AXP", "AAPL", "BA", "CAT", "CVX", 
               "CSCO", "DIS", "KO", "XOM", "GS", "HD", 
               "IBM", "INTC", "JNJ", "JPM", "MCD", "MRK", 
               "MSFT", "NKE", "PG", "TRV", "UNH", 
               "VZ", "V", "WMT", "WBA")
companies_df_list <- rep(NA, length(companies))

for (i in 1:length(companies)){
  assign(paste("data", companies[i], sep = ""), 
         getSymbols(companies[i], auto.assign = F, from ="2018-01-01", to = Sys.Date()))
}

# datasets are labeled as 'data[STOCK]' e.g. dataAAPL

companies_df <- list(dataMMM, dataAXP, dataAAPL, dataBA, dataCAT, dataCVX, 
                     dataCSCO, dataDIS, dataKO, dataXOM, dataGS, dataHD, 
                     dataIBM, dataINTC, dataJNJ, dataJPM, dataMCD, dataMRK, 
                     dataMSFT, dataNKE, dataPG, dataTRV, dataUNH, 
                     dataVZ, dataV, dataWMT, dataWBA)

### DATA CLEANING ### FOR LONG-TERM STOCKS ###
#####################################################################

# 27 stocks (rows) and 252 returns (columns/features/predictors)

dates <- rownames(data.frame(dataMMM))

companies_adjusted <- data.frame(dates)

for (j in 1:length(companies_df)){
  companies_adjusted <- cbind(companies_adjusted, as.numeric(companies_df[[j]][,6])) # adjusted closing prices
}

colnames(companies_adjusted) <- c("date", companies)



### DATA SOURCING ### FOR INDEX PORTFOLIOS ###
#####################################################################

# datasets are labeled as 'data[STOCK]' e.g. dataAAPL

dataDJI <- getSymbols("DJI", auto.assign = F, from ="2021-01-01", to = Sys.Date())

### DATA CLEANING ### FOR INDEX PORTFOLIOS ###
#####################################################################

DJI_dates <- rownames(data.frame(dataDJI))
DJI_adjusted <- as.numeric(dataDJI$DJI.Adjusted)

DJI_returns_dates <- DJI_dates[-1]
DJI_adjusted_returns <- DJI_adjusted[-1] - DJI_adjusted[-length(DJI_adjusted)]


### DATA SOURCING ### FOR SHORT-TERM MEME STOCKS ###
#####################################################################

meme_companies <- c("AMC", "BB", "EXPR", "GME", "GNUS", "KOSS", "NAKD", "NOK")

meme_companies_df_list <- rep(NA, length(meme_companies))

for (i in 1:length(meme_companies)){
  assign(paste("data", meme_companies[i], sep = ""), 
         getSymbols(meme_companies[i], auto.assign = F, from ="2021-01-01", to = Sys.Date()))
}

# datasets are labeled as 'data[STOCK]' e.g. dataAAPL

meme_companies_df <- list(dataAMC, dataBB, dataEXPR, dataGME, dataGNUS, dataKOSS, dataNAKD, dataNOK)

### DATA CLEANING ### FOR SHORT-TERM MEME STOCKS ###
#####################################################################

meme_dates <- rownames(data.frame(dataAMC))

meme_companies_adjusted <- data.frame(meme_dates)

for (j in 1:length(meme_companies_df)){
  meme_companies_adjusted <- cbind(meme_companies_adjusted, as.numeric(meme_companies_df[[j]][,6])) # adjusted closing prices
}

colnames(meme_companies_adjusted) <- c("date", meme_companies)


#prcomp(meme_companies_adjusted[,-1], scale = TRUE, center = TRUE)
#biplot(prcomp(meme_companies_adjusted[,-1], scale = TRUE, center = TRUE))


# save.image(file = "../output/stock_data.RData")
