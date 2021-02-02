#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# load(source.R)
# load("~/GitHub/Sparse_PCA_Stocks/output/raw_stock_prices_27_companies_2018-01-01_to_2021-01-31.RData")
load("../output/raw_stock_prices_27_companies_2018-01-01_to_2021-01-31.RData")

library(shiny)
library(shinydashboard)

library(quantmod)
library(plotly)
library(sparsepca)


# Define UI for application that draws a histogram
shinyUI(dashboardPage(
    dashboardHeader(title = "Stock Market Analysis"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Welcome", tabName = "welcome", icon = icon("dashboard")),
            menuItem("Historical Trends", tabName = "history", icon = icon("dashboard")),
            menuItem("PCA", tabName = "pca", icon = icon("dashboard")),
            menuItem("Sparse PCA", tabName = "spca", icon = icon("dashboard")),
            menuItem("Returns Analysis", tabName = "returns", icon = icon("dashboard")),
            menuItem("Meme Stocks", tabName = "memes", icon = icon("dashboard")),
            menuItem("About", tabName = "about", icon = icon("th"))
        )
    ),
    dashboardBody(
        tabItems(
            # Tab 1: Welcome
            tabItem(tabName = "welcome",
                    h2("Welcome")
            ), 
            
            # Tab 2: Historical Trend Analysis
            tabItem(tabName = "history",
                    h2("Historical Trends"), 
                    
                    helpText("Select a date range of interest by indicating a start and end date.", 
                             br(), 
                             "End date should follow start date.", 
                             br()), 
                    
                    fluidRow(
                        box(align = "center", 
                            dateRangeInput("trend_date", strong("Select Data Range:"),
                                           start = "2021-01-01", end = "2021-01-31",
                                           min = "2018-01-01", max = "2021-01-31"))
                    ), 
                    
                    helpText("Click once on the company name on the legend to hind its respective line.", 
                             br(), 
                             "Double click on a company to isolate it.", 
                             br(), 
                             "Use the buttons on the top right of the plot to zoom, pan, navigate, and compare closing prices for companies.", 
                             br()), 
                    
                    fluidRow(    
                        box(plotlyOutput("historical_trend"))
                    )
            ), 
            
            # Tab 3: Market Analysis with PCA 
            tabItem(tabName = "pca",
                    h2("PCA"), 
                    fluidRow(
                        box(align = "center",
                            textInput(inputId = "pca_ticker", label = "Input Ticker:", value = "MMM"),
                            dateRangeInput("pca_date", strong("Select Data Range:"),
                                           start = "2021-01-01", end = "2021-01-31",
                                           min = "2018-01-01", max = "2021-01-31"))
                    ), 
                    
                    fluidRow(    
                        box(plotOutput("pca_biplot"))
                    )
                    
                    
            ), 
            
            # Tab 4: Portfolio Selections with Sparse PCA
            tabItem(tabName = "spca",
                    h2("Sparse PCA"), 
                    fluidRow(
                        box(align = "center",
                            textInput(inputId = "spca_ticker", label = "Input Ticker:", value = "MMM"),
                            dateRangeInput("spca_date", strong("Select Data Range:"),
                                           start = "2021-01-01", end = "2021-01-31",
                                           min = "2018-01-01", max = "2021-01-31"))
                    ), 
                    
                    fluidRow(    
                        box(plotOutput("sparse_pca_biolot"))
                    )
            ),
            
            # Tab 5: Returns Analysis
            tabItem(tabName = "returns",
                    h2("Returns Analysis")
            ), 
            
            # Tab 6: Meme Stocks
            tabItem(tabName = "memes",
                    h2("Meme Stocks")
            ), 
            
            # Tab 7: Returns Analysis
            tabItem(tabName = "about",
                    h2("About")
            )
        )
    )
))
