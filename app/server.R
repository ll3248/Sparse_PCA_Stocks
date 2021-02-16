#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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

source("source.R") # for deployment

# load("output/stock_data_local.RData") # used for local testing -- cannot pull data from stocks outside the 27 listed in this state 

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # Tab 1: Welcome
    
    main_list_df <- data.frame(Index = as.integer(index),  Company = company_names, Symbol = companies)
    main_list_columns <- cbind(main_list_df[1:9, ], main_list_df[10:18, ], main_list_df[19:27, ])
    
    output$stock_names <- renderTable(main_list_columns)
    
    # Tab 2: Historical Trend Analysis

    output$historical_trend <- renderPlotly({
        
        companies_adjusted_subset <- companies_adjusted %>% 
            filter((date >= input$trend_date[1]) & (date <= input$trend_date[2]))
        
        
        plotly_line <- plot_ly(data = companies_adjusted_subset, x = ~date, y = ~MMM, name = 'MMM', 
                               type = 'scatter', mode = 'lines',  line = list(color = 'rgb(1, 1, 1)'))
        
        for (i in 2:27){
            plotly_line <- plotly_line %>% add_trace(y = companies_adjusted_subset[,i], name = companies[i], line = list(color = 'rgb(i, i, i)')) 
        }
        
        plotly_line <- plotly_line %>% 
            layout(title = 'Comparing Stocks Prices from Dow Jones Companies',
                   xaxis = list(title = 'Day', zeroline = TRUE, tickangle = -60),
                   yaxis = list(title = 'Adjusted Closing Price ($)'))
        
        # check to see if the input is blank; skip the rest if it is 
        if (input$historical_ticker != ""){
            new_stock_symbol = toupper(input$historical_ticker)
            
            # check to see if the input is already one of the companies listed; skip the rest if it is 
            if (any(new_stock_symbol != companies)){
                data_new_stock =  getSymbols(new_stock_symbol, auto.assign = F, from = input$trend_date[1], to = input$trend_date[2])
                
                data_new_stock_df = data.frame(data_new_stock_dates = companies_adjusted_subset$date, data_new_stock_adjusted = as.numeric(data_new_stock[, 6]))
                
                # 6th column is the adjusted prices 
                # add the 6th column of values as new line onto the plot
                plotly_line <- plotly_line %>% add_trace(data = data_new_stock_df, x = ~data_new_stock_dates, y = ~data_new_stock_adjusted, name = new_stock_symbol, line = list(color = 'rgb(28, 28, 28)')) 
            }
        }
        
        
        plotly_line
    })
    
    # Tab 3: Market Analysis with PCA 
    
    output$pca_biplot <- renderPlotly({
        
        pca_ticker <- toupper(input$pca_ticker)
        
        # check if the input stock ticker is in the list of companies or blank, if so, skip to else-statement
        if (any(pca_ticker == companies) | (pca_ticker == "")) {
            
            # subsetting
            companies_adjusted_subset <- companies_adjusted %>% 
                filter((date >= input$pca_date[1]) & (date <= input$pca_date[2]))
            
            # pca analysis 
            pca_analysis <- prcomp(companies_adjusted_subset[2:ncol(companies_adjusted)], scale = TRUE, center = TRUE)
            
            # extract loadings 
            pca_loadings_df <- data.frame(loading1 = pca_analysis$rotation[, 1], 
                                          loading2 = pca_analysis$rotation[, 2], 
                                          company = colnames(companies_adjusted)[-1])
            
            pca_loadings_df_input <- pca_loadings_df[pca_loadings_df$company == pca_ticker, ]
            
            # create plot 
            pca_biplot = ggplot(pca_loadings_df, aes(loading1, loading2, label = company)) + 
                geom_text(size = 4, position = position_jitter(width = 0.005, height = 0.005)) + 
                geom_point(alpha = 0.25) + 
                geom_vline(xintercept = 0) + 
                geom_hline(yintercept = 0) + 
                labs(x = "PC1", y = "PC2", title = "PCA - Portfolio Correlations") + 
                theme(plot.title = element_text(hjust = 0.5))
                
            # check if the input stock ticker is blank again; add a circle to input stock if not, otherwise, skip
            if (pca_ticker != ""){
                # highlight specific point selected from input above
                pca_biplot = pca_biplot + geom_point(aes(x = pca_loadings_df_input$loading1, pca_loadings_df_input$loading2), color = "red", shape = 1, size = 15)
            }
        
            pca_biplot %>% 
                ggplotly(tooltip = "all", dynamicTicks = TRUE)
                
        } 
        
        else{
            # subsetting
            
            companies_adjusted_subset <- companies_adjusted %>% 
                filter((date >= input$pca_date[1]) & (date <= input$pca_date[2]))
            
            # get adjusted prices for new stock and add onto the companies 
            data_new_stock =  getSymbols(pca_ticker, auto.assign = F, from = input$pca_date[1], to = input$pca_date[2])
            companies_adjusted_subset_new_data <- cbind(companies_adjusted_subset, as.numeric(data_new_stock[, 6]))
            colnames(companies_adjusted_subset_new_data)[29] <- pca_ticker
            
            # pca analysis 
            pca_analysis <- prcomp(companies_adjusted_subset_new_data[2:ncol(companies_adjusted_subset_new_data)], scale = TRUE, center = TRUE)
            
            # extract loadings 
            pca_loadings_df <- data.frame(loading1 = pca_analysis$rotation[, 1], 
                                          loading2 = pca_analysis$rotation[, 2], 
                                          company = colnames(companies_adjusted_subset_new_data)[-1])
            
            pca_loadings_df_input <- pca_loadings_df[pca_loadings_df$company == pca_ticker, ]
            
            # create plot 
            pca_biplot = ggplot(pca_loadings_df, aes(loading1, loading2, label = company)) + 
                geom_text(size = 4, position=position_jitter(width = 0.005, height = 0.005)) + 
                geom_point(alpha = 0.25) + 
                geom_vline(xintercept = 0) + 
                geom_hline(yintercept = 0) + 
                labs(x = "PC1", y = "PC2", title = "PCA - Portfolio Correlations") + 
                theme(plot.title = element_text(hjust = 0.5)) + 
                
                # highlight specific point selected from input above
                geom_point(aes(x = pca_loadings_df_input$loading1, pca_loadings_df_input$loading2), color = "red", shape = 1, size = 15)
            
            
            pca_biplot %>% 
                ggplotly(tooltip = "all", dynamicTicks = TRUE)
            
            }
        
        
    })
    
    # Tab 4: Portfolio Selections with Sparse PCA
    
    output$sparse_pca_biolot <- renderPlotly({
        
        spca_ticker <- toupper(input$spca_ticker)
        
        # check if the input stock ticker is in the list of companies or blank, if so, skip to else-statement
        if (any(spca_ticker == companies) | (spca_ticker == "")) {
            
            # subsetting
            companies_adjusted_subset <- companies_adjusted %>% 
                filter((date >= input$spca_date[1]) & (date <= input$spca_date[2]))
            
            # sparse pca analysis 
            spca_analysis <- spca(companies_adjusted_subset[2:ncol(companies_adjusted)], scale = TRUE, center = TRUE, verbose = FALSE)
            
            # extract loadings
            spca_loadings_df <- data.frame(loading1 = spca_analysis$loadings[, 1], 
                                           loading2 = spca_analysis$loadings[, 2], 
                                           company = colnames(companies_adjusted)[-1])
            
            spca_loadings_df$selected <- ifelse((spca_analysis$loadings[, 1] == 0) | (spca_analysis$loadings[, 2] == 0), "No", "Yes")
            
            spca_loadings_df_input <- spca_loadings_df[spca_loadings_df$company == spca_ticker, ]
            
            # plot 
            spca_biplot = ggplot(spca_loadings_df, aes(loading1, loading2, label = company)) + 
                geom_text(aes(color = selected), size = 4, position = position_jitter(width = 0.005, height = 0.005)) + 
                geom_point(aes(color = selected), alpha = 0.25) + 
                
                geom_vline(xintercept = 0) + 
                geom_hline(yintercept = 0) + 
                labs(x = "PC1", y = "PC2", title = "Sparse PCA - Portfolio Selection", color = "Consider in \n Portfolio?") + 
                theme(plot.title = element_text(hjust = 0.5), legend.position = "right", legend.title = element_text(hjust = 0.5, size = 8)) 
            
            # check if the input stock ticker is blank again; add a circle to input stock if not, otherwise, skip
            if (spca_ticker != ""){
                # highlight specific point selected from input above
                spca_biplot = spca_biplot + geom_point(aes(x = spca_loadings_df_input$loading1, spca_loadings_df_input$loading2), color = "black", shape = 1, size = 15)
            }
            
            spca_biplot %>% 
                ggplotly(tooltip = "all", dynamicTicks = TRUE)
        }
        
        else{
            # subsetting
            companies_adjusted_subset <- companies_adjusted %>% 
                filter((date >= input$spca_date[1]) & (date <= input$spca_date[2]))
            
            # get adjusted prices for new stock and add onto the companies 
            data_new_stock =  getSymbols(spca_ticker, auto.assign = F, from = input$spca_date[1], to = input$spca_date[2])
            companies_adjusted_subset_new_data <- cbind(companies_adjusted_subset, as.numeric(data_new_stock[, 6]))
            colnames(companies_adjusted_subset_new_data)[29] <- spca_ticker
            
            
            # sparse pca analysis 
            spca_analysis <- spca(companies_adjusted_subset_new_data[2:ncol(companies_adjusted_subset_new_data)], scale = TRUE, center = TRUE, verbose = FALSE)
            
            # extract loadings
            spca_loadings_df <- data.frame(loading1 = spca_analysis$loadings[, 1], 
                                           loading2 = spca_analysis$loadings[, 2], 
                                           company = colnames(companies_adjusted_subset_new_data)[-1])
            
            spca_loadings_df$selected <- ifelse((spca_analysis$loadings[, 1] == 0) | (spca_analysis$loadings[, 2] == 0), "No", "Yes")
            
            spca_loadings_df_input <- spca_loadings_df[spca_loadings_df$company == spca_ticker, ]
            
            # plot 
            spca_biplot = ggplot(spca_loadings_df, aes(loading1, loading2, label = company)) + 
                geom_text(aes(color = selected), size = 4, position = position_jitter(width = 0.005, height = 0.005)) + 
                geom_point(aes(color = selected), alpha = 0.25) + 
                
                geom_vline(xintercept = 0) + 
                geom_hline(yintercept = 0) + 
                labs(x = "PC1", y = "PC2", title = "Sparse PCA - Portfolio Selection", color = "Consider in \n Portfolio?") + 
                theme(plot.title = element_text(hjust = 0.5), legend.position = "right", legend.title = element_text(hjust = 0.5, size = 5)) + 
                
                # highlight specific point selected from input above
                geom_point(aes(x = spca_loadings_df_input$loading1, spca_loadings_df_input$loading2), color = "black", shape = 1, size = 8)
            
            spca_biplot %>% 
                ggplotly(tooltip = "all", dynamicTicks = TRUE)
            
            }
        
        
        
    })
    
    # Tab 5: About
    
    
    
})
