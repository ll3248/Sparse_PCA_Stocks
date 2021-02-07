#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

shinyUI(dashboardPage(
    dashboardHeader(title = "Stock Market Analysis"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("PCAPB", tabName = "welcome", icon = icon("desktop")),
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
                    
                    h2("Welcome to the PCA Portfolio Builder!"),
                    
                    fluidPage(
                        
                        fluidRow(box(
                            HTML(
                                "<p>Thanks for visiting! This website has many tools to help all investors, regardless of background and their experience.</p>", 
                                "<p>You will find data visualization and machine learning tools to help visualize and simplify the high dimensionality of stock price data. 
                                For the purposes of this analysis, we focus on the 27 stocks from the Dow Jones Index (see table below), but users will be able to inquire about stocks beyond those listed below. </p>", 
                                
                                "<p><br/></p>", 
                                
                                "<p> <b>Historical Trend Analysis:</b> an interactive line plot detailing adjusted closing prices of selected stocks<br/></p>", 
                                "<p> <b>Market Analysis:</b>  a plot summarizing market trends of stocks using Principal Components Analysis (PCA)<br/></p>", 
                                "<p> <b>Portfolio Selection:</b>  a plot providing users recommendations on which stocks to invest in to reduce risk using sparse PCA<br/></p>", 
                                
                                "<p><br/></p>", 
                                
                                "<p>Warning: The data takes a few minutes to load. Please do not begin the analysis until values appear in the table below.</p>"
                            ), 
                        )), 
                        
                        fluidRow(box(
                            titlePanel("Selected Stocks from the Dow Jones Index"),
                            
                            tableOutput('stock_names'))
                        ), 
                        
                        fluidRow(box(
                            titlePanel("Disclaimer"),
                            HTML(
                                "<p>This project was created for educational purposes only and does not constitute as professional financial advice.</p>", 
                                "<p>Investments are risky, and one could potentially lose their initial principal (if not more).</p>"
                            )
                        ))
                        
                    )
                    
            ), 
            
            # Tab 2: Historical Trend Analysis
            tabItem(tabName = "history",
                    h2("Historical Trends"), 

                    fluidRow(
                        
                        box(helpText("Choose any stock of interest (including beyond the 27 stocks) and enter the corresponding stock symbol below.", br(), 
                             "Select a date range of interest by indicating a start and an end date.", br(), 
                             "End date should come after start date.")
                            )
                    ), 
                    
                    fluidRow(
                        
                        box(align = "center", 
                            textInput(inputId = "historical_ticker", label = "Input Ticker:", value = ""),
                            dateRangeInput("trend_date", strong("Select Date Range:"),
                                           start = Sys.Date()-30, end = Sys.Date(),
                                           min = "2018-01-01", max = Sys.Date()))
                    ), 
                    
                    fluidRow(
                        box(helpText("Click once on the company name on the legend to hind its respective line.", br(), 
                             "Double click on a company to isolate it.", br(), 
                             "Use the buttons on the top right of the plot to zoom, pan, navigate, and compare closing prices for companies.",  br())
                            )
                        ), 
                    
                    fluidRow(    
                        box(plotlyOutput("historical_trend"))
                    ), 
                
            ), 
            
            # Tab 3: Market Analysis with PCA 
            tabItem(tabName = "pca",
                    h2("Market Analysis with Principal Components Analysis (PCA)"), 
                    
                    fluidRow(
                        box(h5("Principal Components Analysis (PCA) is an unsupervised machine learning technique. 
                               It helps reduce the high dimensionality of stock data down to principal components and can be thought of as latent variables. 
                               The meaning of these latent variables can change over time and require market research to interpret.
                               Only a few are usually needed to understand the data, and here we choose to analyze only the first two principal components, which are plotted for each stock below.
                               PCA is also used as a clustering technique and the stocks that are clustered together are therefore correlated.")
                            )
                        ), 
                    
                    fluidRow(
                        box(helpText("Choose any stock of interest (including those beyond the 27 stocks listed) and enter the corresponding stock symbol below.", br()),
                            HTML("<p>Feel free to use the stock lookup tool on <a href='https://www.marketwatch.com/tools/quotes/lookup.asp'>MarketWatch</a></li> as needed.</p>"), 
                            helpText("Select a date range of interest by indicating a start and an end date. End date should come after start date.", br())
                            
                            )
                        ), 
                    
                    fluidRow(
                        box(align = "center",
                            textInput(inputId = "pca_ticker", label = "Input Ticker:", value = ""),
                            dateRangeInput("pca_date", strong("Select Date Range:"),
                                           start = Sys.Date()-30, end = Sys.Date(),
                                           min = "2018-01-01", max = Sys.Date()))
                    ), 
                    
                    fluidRow(
                        box(helpText("The circle below indicates the inputted stock symbol from above (if any).", br(),  
                             "PC1 and PC2 are considered latent variables, and interpretation requires market research.", br(), 
                             "Stocks clustered together are considered correlated with each other.", br())
                            )
                        ), 
                    
                    fluidRow(    
                        box(plotOutput("pca_biplot"))
                        )
                ), 
                
            # Tab 4: Portfolio Selections with Sparse PCA
            tabItem(tabName = "spca",
                    
                    h2("Portfolio Selection with Sparse Principal Components Analysis (Sparse PCA)"), 
                    
                    fluidRow(
                        box(h5("Sparse Principal Components Analysis (Sparse PCA) does everything that regular PCA can do, but it also adds a regularization term in its algorithm. 
                        This is a penalty term that reduces the number of stocks to be considered for the analysis. 
                        In the plot below, some stocks are now pushed to the axes (and perhaps the origin), and these would no longer be considered for the portfolio.")
                            )
                        ), 
                    
                    fluidRow(
                        box(helpText("Choose any stock of interest (including those beyond the 27 stocks listed) and enter the corresponding stock symbol below.", br()),
                            HTML("<p>Feel free to use the stock lookup tool on <a href='https://www.marketwatch.com/tools/quotes/lookup.asp'>MarketWatch</a></li> as needed.</p>"), 
                            helpText("Select a date range of interest by indicating a start and an end date. End date should come after start date.", br())
                            )
                        ), 
                    
                    fluidRow(
                        box(align = "center",
                            textInput(inputId = "spca_ticker", label = "Input Ticker:", value = ""),
                            dateRangeInput("spca_date", strong("Select Date Range:"),
                                           start = Sys.Date()-30, end = Sys.Date(),
                                           min = "2018-01-01", max = Sys.Date()))
                        ), 
                    
                    fluidRow(
                        box(helpText("The circle below indicates the inputted stock symbol from above (if any).", br(), 
                             "Stocks in teal are stocks to consider. Stocks in red are stocks to avoid.", br(), 
                             "Choosing stocks in different quadrants help to diversify one's portfolio and reduce risk.", br())
                            )
                        ), 
                    
                    fluidRow(    
                        box(plotOutput("sparse_pca_biolot"))
                    )
            ),
            
            # Tab 5: About
            tabItem(tabName = "about",
                    
                    h2("About"), 
                    
                    fluidPage(
                        
                        fluidRow(box(
                            titlePanel("Project"),
                            
                            HTML(
                                "<p>The following R packages were used in to build this RShiny application:</p>", 
                                "<p>
                                <code>shiny</code> <code>shinydashboard</code> <code>quantmod</code> <code>plotly</code>
                                <code>sparsepca</code> <code>ggplot2</code> <code>baser</code>
                                </p>", 
                                
                                "<p>Using the <code>quantmod</code> package, data was pulled from <a href='https://finance.yahoo.com/'>Yahoo! Finance</a></li>.</p>",
                                "<p>This website was developed as the capstone project for The Data Incubator's Winter 2021 Cohort.</p>",
                                "<p>Source Code: <a href='https://github.com/ll3248/Sparse_PCA_Stocks'>https://github.com/ll3248/Sparse_PCA_Stocks</a></li></p>", 
                                "<p>For other questions, please email me at levi[dot]lee[at]mg.thedataincubator[dot]com.</p>"
                                
                                )
                            ) ), 
                        
                        
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
                                )
                            ) ), 
                        
                        fluidRow(box(
                            titlePanel("References"),
                            
                            HTML(
                                "<p>Users can find introductory information online about PCA and Sparse PCA below. Please take a look at the list of references on each respective page for additional reading.</p>", 
                                "<p><li> PCA: <a href='https://en.wikipedia.org/wiki/Principal_component_analysis'>https://en.wikipedia.org/wiki/Principal_component_analysis</a></li></p>",
                                "<p><li> Sparse PCA: <a href='https://en.wikipedia.org/wiki/Sparse_PCA'>https://en.wikipedia.org/wiki/Sparse_PCA</a></li></p>"
                                )
                            ) ), 
          
                        fluidRow(box(
                            titlePanel("Disclaimer (Again)"),
                            
                            HTML(
                                "<p>I am not a financial advisor.</p>",
                                "<p>This project was created for educational purposes only and does not constitute as professional financial advice.</p>", 
                                "<p>Investments are risky, and one could potentially lose their initial principal (if not more).</p>"
                                )
                            ) ), 

                    ) # fluid page

            ) # tab page
        ) # tab items
    ) # dashboard body
))
