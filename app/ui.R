#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(quantmod)
library(plotly)
library(sparsepca)

shinyUI(dashboardPage(
    dashboardHeader(title = "PCAPB"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Welcome", tabName = "welcome", icon = icon("desktop")),
            menuItem("Historical Trends", tabName = "history", icon = icon("chart-line")),
            menuItem("Market Analysis", tabName = "pca", icon = icon("search-dollar")),
            menuItem("Portfolio Selection", tabName = "spca", icon = icon("folder")),
            menuItem("About", tabName = "about", icon = icon("address-card"))
        )
    ),
    
    dashboardBody(
        tabItems(
            # Tab 1: Welcome
            tabItem(tabName = "welcome",
                    
                    h2("Welcome to the Principal Components Analysis Portfolio Builder (PCAPB)!"),
                    
                    fluidPage(
                        
                        fluidRow(box(
                            HTML(
                                "<p>This website has many tools to help all investors get an unique perspective on the stock market and help guide in their decision-making, regardless of background and prior experience.</p>", 
                                "<p>This site provides data visualization and machine learning tools to help simplify the high dimensionality of stock price data. 
                                This analysis includes 27 stocks from the Dow Jones Index (see table below), but users can inquire about additional stocks as well. </p>", 
                                "<p> <b>Historical Trend Analysis:</b> an interactive line plot detailing adjusted closing prices of selected stocks<br/></p>", 
                                "<p> <b>Market Analysis:</b>  an interactive plot grouping correlated stocks together and summarizing market trends using principal components analysis (PCA)<br/></p>", 
                                "<p> <b>Portfolio Selection:</b>  an interactive plot providing users recommendations on which stocks to invest in to reduce risk using sparse PCA<br/></p>", 
                            ), 
                            
                            width = 10)
                        
                        ), 
                        
                        
                        fluidRow(box(
                            titlePanel("About the Data"),
                            
                            
                            HTML(
                                "<p>Using R's <code>quantmod</code> package and an API, data was pulled from <a href='https://finance.yahoo.com/'>Yahoo! Finance</a></li>.
                                This data consists of 27 stocks from the Dow Jones Index and the adjusted closing prices of each company between 2017 and 2021.</p>", 
                                 "<p>The choice in focusing on adjusted closing prices is to account for any corporate actions--such as splits and dividends--to allow for a standardized comparision in historical analyses. 
                                 The choice in the 27 stocks stems from a focus on long-term investment, rather than a short-term investment, where stock prices tend to be more volitile. 
                                 However, users can include short-term stocks in their analyses (but not cryptocurrencies, as they are considered as different investmenets here).
                                The choice in the alloted time period is arbitrary and assumes that users would not consider data that is too far in the past because of concerns about nonstationarity.</p>", 
                                "<p><b>Warning</b>: The data can take a few minutes to load. Please do not begin the analysis until values appear in the table below.</p>"
                                
                            ), 
                            
                           
                            
                            width = 10)
                        ), 
                        

                        fluidRow(box(
                            titlePanel("Selected Stocks from the Dow Jones Index"),
                            
                            tableOutput('stock_names'), 
                            
                            width = 10)
                        ), 
                        
                        fluidRow(box(
                            titlePanel("Disclaimer"),
                            HTML(
                                "<p>This project was created for educational purposes only and does not constitute as professional financial advice.</p>", 
                                "<p>Investments are risky, and one could potentially lose their initial principal (if not more).</p>"
                            ), 
                            
                            width = 10) # box
                        ) # fluid row
                        
                    ) # fluid page
                    
            ), 
            
            # Tab 2: Historical Trend Analysis
            tabItem(tabName = "history",
                    h2("Historical Trends"), 

                    fluidRow(
                        box(helpText("Choose any stock of interest (including those beyond the 27 stocks listed) and enter the corresponding stock symbol below.", br()),
                            HTML("<p>Feel free to use the stock lookup tool on <a href='https://www.marketwatch.com/tools/quotes/lookup.asp'>MarketWatch</a></li> as needed.</p>", 
                                 "<p>Note again that this website does not support cryptocurreny symbols for this analysis. While they are considered investements, they are inherently different from stocks.</p>"), 
                            helpText("Select a date range of interest by indicating a start and an end date. Start date will only go as far back as January 1st, 2017. End date should come after start date.", br()), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE), 
                    ), 
                    
                    fluidRow(
                        
                        box(align = "center", 
                            textInput(inputId = "historical_ticker", label = "Input Ticker:", value = ""),
                            dateRangeInput("trend_date", strong("Select Date Range:"),
                                           start = Sys.Date()-30, end = Sys.Date(),
                                           min = "2017-01-01", max = Sys.Date()),
                            
                            width = 8)
                    ), 
                    
                    fluidRow(
                        box(helpText("Click on a company name in the legend once to hide its corresponding line. Click once again to reset. 
                                     Double click on a company name in the legend to isolate its corresponding line and hide all others. Double click again to reset.", br(), 
                                     "Use the cursor to hover over the lines on the graph to see the corresponding company stock symbols.", br(), 
                                     "Use the buttons on the top right of the plot to zoom, pan, navigate, and compare closing prices for companies.
                                     It is also possible to use the cursor to select on the chart itself to select an area of the plot to zoom.",  br(),
                                     "If an error message appears below, it means the inputted stock symbol is not valid or not available for analysis.", br()), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                        ), 
                    
                    fluidRow(    
                        box(plotlyOutput("historical_trend"), 
                            
                            width = 8)
                    ), 
                
            ), 
            
            # Tab 3: Market Analysis with PCA 
            tabItem(tabName = "pca",
                    h2("Market Analysis with Principal Components Analysis (PCA)"), 
                    
                    fluidRow(
                        box(h5("Principal Components Analysis (PCA) is an unsupervised machine learning technique. 
                               It helps reduce the high dimensionality of stock data down to principal components (PC). These can be thought of as latent variables. 
                               The meaning of these latent variables can change over time and require market research to interpret.
                               Only a principal components are usually needed to understand the data, and this analysis uses only the first two principal components (PC1 and PC2). 
                               The values of these components (called loadings) are plotted for each stock below.
                               Stocks that are clustered together are considered to be similar or correlated with each other
                               The reason for why they are correlated also requires market research."), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                        ), 
                    
                    fluidRow(
                        box(helpText("Choose any stock of interest (including those beyond the 27 stocks listed) and enter the corresponding stock symbol below.", br()),
                            HTML("<p>Feel free to use the stock lookup tool on <a href='https://www.marketwatch.com/tools/quotes/lookup.asp'>MarketWatch</a></li> as needed.</p>", 
                                 "<p>Note again that this website does not support cryptocurreny symbols for this analysis. While they are considered investements, they are inherently different from stocks.</p>"), 
                            helpText("Select a date range of interest by indicating a start and an end date. Start date will only go as far back as January 1st, 2017. End date should come after start date.", br()), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                    ), 
                    
                    fluidRow(
                        box(align = "center",
                            textInput(inputId = "pca_ticker", label = "Input Ticker:", value = ""),
                            dateRangeInput("pca_date", strong("Select Date Range:"),
                                           start = Sys.Date()-30, end = Sys.Date(),
                                           min = "2017-01-01", max = Sys.Date()), 
                            
                            width = 8), 
                    ), 
                    
                    fluidRow(
                        box(helpText("Use the cursor to hover over the points on the graph to see the corresponding company stock symbols should there be any overlaps in text.", br(), 
                                     "Use the buttons on the top right of the plot to zoom, pan, navigate, and compare closing prices for companies.
                                     It is also possible to use the cursor to select on the chart itself to select an area of the plot to zoom.",  br(),
                                     "If an error message appears below, it means the inputted stock symbol is not valid or not available for analysis.", br()), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                    ), 
                    
                    fluidRow(    
                        box(plotlyOutput("pca_biplot"), 
                            
                            width = 8)
                    ), 
                    
                    fluidRow(
                        box(helpText("The circle indicates the inputted stock symbol from above (if any). Use this to keep track of your stock relative to others.", br(), 
                                     "PC1 and PC2 are considered latent variables and its interpretation requires individual market research. This interpretation can change over time.", br(), 
                                     "Stocks clustered together are considered correlated with each other.", br()), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                    ) 
                    
                ), 
                
            # Tab 4: Portfolio Selections with Sparse PCA
            tabItem(tabName = "spca",
                    
                    h2("Portfolio Selection with Sparse Principal Components Analysis (Sparse PCA)"), 
                    
                    fluidRow(
                        box(h5("Sparse Principal Components Analysis (Sparse PCA) follows the same procedure as regular PCA, but it also adds a penalty term in its algorithm. 
                        This penalty term reduces the number of stocks to be considered for the portfolio by eliminating redundancies in the data. 
                        This analysis will also only focus on the first two principal components (PC1 and PC2). 
                        In the plot below, some stocks are now pushed to the axes (and perhaps the origin) compared to the plot in the previous tab, and these would no longer be considered for the portfolio."), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                        ), 
                    
                    fluidRow(
                        box(helpText("Choose any stock of interest (including those beyond the 27 stocks listed) and enter the corresponding stock symbol below.", br()),
                            HTML("<p>Feel free to use the stock lookup tool on <a href='https://www.marketwatch.com/tools/quotes/lookup.asp'>MarketWatch</a></li> as needed.</p>", 
                                 "<p>Note again that this website does not support cryptocurreny symbols for this analysis. While they are considered investements, they are inherently different from stocks.</p>"), 
                            helpText("Select a date range of interest by indicating a start and an end date. Start date will only go as far back as January 1st, 2017. End date should come after start date.", br()), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                    ), 
                    
                    fluidRow(
                        box(align = "center",
                            textInput(inputId = "spca_ticker", label = "Input Ticker:", value = ""),
                            dateRangeInput("spca_date", strong("Select Date Range:"),
                                           start = Sys.Date()-30, end = Sys.Date(),
                                           min = "2017-01-01", max = Sys.Date()), 
                            
                            width = 8)
                        ), 
                    
                    fluidRow(
                        box(helpText("Click on a group in the legend once to hide its corresponding points. Click once again to reset. 
                                     Double click on a group in the legend to isolate its corresponding points and hide all others. Double click again to reset.", br(), 
                                    "Use the cursor to hover over the points on the graph to see the corresponding company stock symbols should there be any overlaps in text.", br(), 
                                     "Use the buttons on the top right of the plot to zoom, pan, navigate, and compare closing prices for companies.
                                     It is also possible to use the cursor to select on the chart itself to select an area of the plot to zoom.",  br(),
                                     "If an error message appears below, it means the inputted stock symbol is not valid or not available for analysis.", br()), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                    ), 

                    
                    fluidRow(    
                        box(plotlyOutput("sparse_pca_biolot"), 
                            
                            width = 8)
                    ), 
                    
                    fluidRow(
                        box(helpText("The circle indicates the inputted stock symbol from above (if any). Use this to keep track of your stock relative to others.", br(), 
                                     "Stocks in teal are stocks to consider for the portfolio. Stocks in red are stocks to avoid for the portfolio.", br(), 
                                     "Choosing stocks in different quadrants help to diversify one's portfolio and reduce risk.", br(), 
                                     "Individual market analysis is required to decide which of the remaining stocks ought to be selected.", br(), 
                                     "These recommendations can change over time, so check back often to readjust the portfolio."), 
                            
                            width = 8, collapsible = TRUE, collapsed = FALSE)
                    ), 
            ),
            
            # Tab 5: About
            tabItem(tabName = "about",
                    
                    h2("About"), 
                    
                    fluidPage(
                        
                        fluidRow(box(
                            titlePanel("Project"),
                            
                            HTML(
                                "<p>Thanks for visiting!</p>", 
                                "<p>The following R packages were used in to build this RShiny application:</p>", 
                                "<p>
                                <code>shiny</code> <code>shinythemes</code> <code>shinydashboard</code> <code>emojifont</code> <code>shinyWidgets</code> <code>quantmod</code> 
                                <code>sparsepca</code> <code>plotly</code> <code>ggplotly</code>  <code>ggplot2</code> <code>baser</code>
                                </p>", 
                                "<p>This website was developed as the capstone project for The Data Incubator's Winter 2021 Cohort.</p>",
                                "<p>Source Code: <a href='https://github.com/ll3248/Sparse_PCA_Stocks'>https://github.com/ll3248/Sparse_PCA_Stocks</a></li></p>", 
                                "<p>For other questions, please email me at levi[dot]lee[at]mg.thedataincubator[dot]com.</p>"
                                
                                ), 
                            
                            width = 10) 
                            
                            ), 
                        
                        
                        fluidRow(box(
                            titlePanel("Developer"),
                            
                            HTML(
                                "<p>Levi Lee recently received his Master's in Statistics at Columbia University with foci in both Data Science and Finance. 
                                During his graduate career, he was a teaching assistant at Columbia University for a special topics course about Finance Technology 
                                and a data science mentor at City University of New York, teaching undergraduates the basics of R/R-Studio. 
                                He is currently part of The Data Incubator's Winter 2021 East Coast cohort. For more information, please see the following links.</p>",
                                    
                                "<p><li> Resume: <a href='https://drive.google.com/file/d/1RRENekwiRR6c1qMlLV0KxgfzmnkZiw_j/view?usp=sharing'>https://drive.google.com/file/d/1RRENekwiRR6c1qMlLV0KxgfzmnkZiw_j/view?usp=sharing</a></li></p>",
                                "<p><li> LinkedIn: <a href='https://www.linkedin.com/in/ll3248'>https://www.linkedin.com/in/ll3248</a></li></p>",
                                "<p><li> GitHub: <a href='https://github.com/ll3248'>https://github.com/ll3248</a></li></p>",
                                "<p><li> Twitter: <a href='https://twitter.com/ll3248'>https://twitter.com/ll3248</a></li></p>"
                                ), 
                            
                            width = 10)
                            
                            ), 
                        
                        fluidRow(box(
                            titlePanel("References"),
                            
                            HTML(
                                "<p>Users can find introductory information online about investing, PCA, and sparse PCA below. 
                                Search up unfamiliar terms used in this site on Investopedia and take a look at the list of references on each respective Wikipedia page for additional reading on these methods.</p>", 
                                "<p><li> Investopedia: <a href='https://www.investopedia.com/'>https://www.investopedia.com/</a></li></p>",
                                "<p><li> Wikipedia - PCA: <a href='https://en.wikipedia.org/wiki/Principal_component_analysis'>https://en.wikipedia.org/wiki/Principal_component_analysis</a></li></p>",
                                "<p><li> Wikipedia - Sparse PCA: <a href='https://en.wikipedia.org/wiki/Sparse_PCA'>https://en.wikipedia.org/wiki/Sparse_PCA</a></li></p>"
                                ), 
                            
                            width = 10) 
                            
                            ), 
          
                        fluidRow(box(
                            titlePanel("Disclaimer (Again)"),
                            
                            HTML(
                                "<p>The developer is not a financial advisor.</p>",
                                "<p>This project was created for educational purposes only and does not constitute as professional financial advice.</p>", 
                                "<p>Investments are risky, and one could potentially lose their initial principal (if not more).</p>"
                                ), 
                            
                            width = 10)
                            
                            ), 

                    ) # fluid page

            ) # tab page
        ) # tab items
    ) # dashboard body
))
