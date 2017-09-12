library(rvest)

yahoo_stock_price_rank <- function(n, is_counter = FALSE) {
  if (is_counter == TRUE) {
    ## 載入上櫃html document
    yahoo_stock_url <- "https://tw.stock.yahoo.com/d/i/rank.php?t=pri&e=otc&n=50"
    stock_info <- read_html(yahoo_stock_url)
    
    ## 解析網頁
    # 使用CSS選擇將股票代號/名稱與成交價抓出來
    stock_name_idx <- stock_info %>% 
      html_nodes(css = ".name a") %>%
      html_text()
    stock_price <- stock_info %>% 
      html_nodes(css = ".name+ td") %>%
      html_text() %>%
      as.numeric()
    
    # 使用XPath選擇將股票代號/名稱與成交價抓出來
    stock_name_idx <- stock_info %>% 
      html_nodes(xpath = "//td[@class='name']/a") %>%
      html_text()
    stock_price <- stock_info %>% 
      html_nodes(xpath = "//table[2]/tbody/tr/td[3]") %>%
      html_text() %>%
      as.numeric()
    
    
    name_split <- strsplit(stock_name_idx, split = "\\s")
    stock_idx <- c()
    stock_name <- c()
    for (i in 1:length(name_split)){
      stock_idx[i] <- name_split[[i]][1]
      stock_name[i] <- name_split[[i]][2]
    }
    
    stock_df <- data.frame(ticker = stock_idx, name = stock_name, price = stock_price, type = "上櫃")
    return(head(stock_df, n = n))
  } else {
    ## 載入上市html document
    yahoo_stock_url <- "https://tw.stock.yahoo.com/d/i/rank.php?t=pri&e=tse&n=50"
    stock_info <- read_html(yahoo_stock_url)
    
    ## 解析網頁
    # 使用CSS選擇將股票代號/名稱與成交價抓出來
    stock_name_idx <- stock_info %>% 
      html_nodes(css = ".name a") %>%
      html_text()
    stock_price <- stock_info %>% 
      html_nodes(css = ".name+ td") %>%
      html_text() %>%
      as.numeric()
    
    # 使用XPath選擇將股票代號/名稱與成交價抓出來
    stock_name_idx <- stock_info %>% 
      html_nodes(xpath = "//td[@class='name']/a") %>%
      html_text()
    stock_price <- stock_info %>% 
      html_nodes(xpath = "//table[2]/tbody/tr/td[3]") %>%
      html_text() %>%
      as.numeric()
    
    
    name_split <- strsplit(stock_name_idx, split = "\\s")
    stock_idx <- c()
    stock_name <- c()
    for (i in 1:length(name_split)){
      stock_idx[i] <- name_split[[i]][1]
      stock_name[i] <- name_split[[i]][2]
    }
    
    stock_df <- data.frame(ticker = stock_idx, name = stock_name, price = stock_price, type = "上市")
    return(head(stock_df, n = n))
  }
}

# 呼叫函數
counter_rank <- yahoo_stock_price_rank(n = 50, is_counter = TRUE)
market_rank <- yahoo_stock_price_rank(n = 50)
mix_rank <- rbind(market_rank, counter_rank)
View(mix_rank)

