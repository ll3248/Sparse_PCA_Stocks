#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# load(source.R)
# load("~/GitHub/Sparse_PCA_Stocks/output/raw_stock_prices_27_companies_2018-01-01_to_2021-01-31.RData")
# load("../output/raw_stock_prices_27_companies_2018-01-01_to_2021-01-31.RData")
load("../output/stock_data_02_04_2021.RData")

library(shiny)
library(shinydashboard)

library(quantmod)
library(plotly)
library(sparsepca)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # Tab 1: Welcome
    
    output$stock_names <- renderTable(data.frame(index, companies, company_names))
    
    # Tab 2: Historical Trend Analysis
    
    
    
    output$historical_trend <- renderPlotly({
        
        companies_adjusted_subset <- companies_adjusted %>% 
            filter((date > input$trend_date[1]) & (date < input$trend_date[2]))
        
        
        plotly_line <- plot_ly(data = companies_adjusted_subset, x = ~date, y = ~MMM, name = 'MMM', 
                               type = 'scatter', mode = 'lines',  line = list(color = 'rgb(1, 1, 1)'))
        
        for (i in 2:27){
            plotly_line <- plotly_line %>% add_trace(y = companies_adjusted_subset[,i], name = companies[i], line = list(color = 'rgb(i, i, i)')) 
        }
        
        plotly_line <- plotly_line %>% 
            layout(title = 'Historical Analysis of Select Companies from Dow Jones Index',
                   xaxis = list(title = 'Day', zeroline = TRUE, tickangle = -60),
                   yaxis = list(title = 'Adjusted Closing Price ($)'))
        
        plotly_line
    })
    
    # Tab 3: Market Analysis with PCA 
    
    output$pca_biplot <- renderPlot({
        companies_adjusted_subset <- companies_adjusted %>% 
            filter((date > input$pca_date[1]) & (date < input$pca_date[2]))
        
        pca_analysis <- prcomp(companies_adjusted_subset[2:ncol(companies_adjusted)], scale = TRUE, center = TRUE)
        
        pca_loadings_df <- data.frame(loading1 = pca_analysis$rotation[, 1], 
                                       loading2 = pca_analysis$rotation[, 2], 
                                       company = colnames(companies_adjusted)[-1])
        
        pca_loadings_df_input <- pca_loadings_df[pca_loadings_df$company == input$pca_ticker, ]
        
        ggplot(pca_loadings_df, aes(loading1, loading2, label = company)) + 
            geom_text() + 
            geom_point(alpha = 0.40) + 
            geom_vline(xintercept = 0) + 
            geom_hline(yintercept = 0) + 
            labs(x = "PC1", y = "PC2", title = "PCA - Portfolio Correlations") + 
            theme(plot.title = element_text(hjust = 0.5)) + 
            
            # highlight specific point selected from input above
            geom_point(aes(x = pca_loadings_df_input$loading1, pca_loadings_df_input$loading2), 
                       color = "red", shape = 1, size = 15)
        
    })
    
    # Tab 4: Portfolio Selections with Sparse PCA
    
    output$sparse_pca_biolot <- renderPlot({
        companies_adjusted_subset <- companies_adjusted %>% 
            filter((date > input$spca_date[1]) & (date < input$spca_date[2]))
        
        spca_analysis <- spca(companies_adjusted_subset[2:ncol(companies_adjusted)], scale = TRUE, center = TRUE, verbose = FALSE)
        
        spca_loadings_df <- data.frame(loading1 = spca_analysis$loadings[, 1], 
                                       loading2 = spca_analysis$loadings[, 2], 
                                       company = colnames(companies_adjusted)[-1])
        
        spca_loadings_df$selected <- ifelse((spca_analysis$loadings[, 1] == 0) | (spca_analysis$loadings[, 2] == 0), "No", "Yes")
        
        spca_loadings_df_input <- spca_loadings_df[spca_loadings_df$company == input$spca_ticker, ]
        
        ggplot(spca_loadings_df, aes(loading1, loading2, label = company)) + 
            geom_text(aes(color = selected)) + 
            geom_point(aes(color = selected), alpha = 0.40) + 

            geom_vline(xintercept = 0) + 
            geom_hline(yintercept = 0) + 
            labs(x = "PC1", y = "PC2", title = "Sparse PCA - Portfolio Correlations", color = "Stock to Consider?") + 
            theme(plot.title = element_text(hjust = 0.5)) + 
            
            # highlight specific point selected from input above
            geom_point(aes(x = spca_loadings_df_input$loading1, spca_loadings_df_input$loading2), 
                       color = "black", shape = 1, size = 15)
        
    })
    
    # Tab 5: Returns Analysis 

    
    # Tab 6: About
    
    
    
})
