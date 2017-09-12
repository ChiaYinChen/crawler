library(rvest)

lottery_jackpot_stores_crawler <- function(page) {
  url <- paste0("http://lotto.bestshop.com.tw/649/where.asp?PgNo=", page, "&s=0")
  html_doc <- read_html(url)
  
  index_css <- ".TDLine1 b"
  date_css <- ".TDLine1:nth-child(3)"
  week_css <- ".TDLine1:nth-child(4)"
  sale_city_css <- ".TDLine1:nth-child(5)"
  sale_country_css <- ".TDLine1:nth-child(6)"
  sale_address_css <- ".TDLine1:nth-child(7)"
  sale_store_css <- ".TDLine1:nth-child(8)"
  
  lottery_stores_info <- list()
  columns <- c(index_css, date_css, week_css, 
               sale_city_css, sale_country_css, sale_address_css, sale_store_css)
  
  for (i in 1:length(columns)) {
    content <- html_doc %>%
      html_nodes(css = columns[i]) %>%
      html_text()
    lottery_stores_info[[i]] <- content
  }
  names(lottery_stores_info) <- c("開獎期別", "售出日期", "星期", "售出縣市", "售出鄉鎮", "售出地址", "售出商號")
  
  
  lottery_stores_df <- data.frame(開獎期別 = lottery_stores_info$開獎期別, 售出日期 = lottery_stores_info$售出日期, 星期 = lottery_stores_info$星期,
                                      售出縣市 = lottery_stores_info$售出縣市, 售出鄉鎮 = lottery_stores_info$售出鄉鎮, 售出地址 = lottery_stores_info$售出地址, 售出商號 = lottery_stores_info$售出商號)
  
  return(lottery_stores_df)
  
}

# 呼叫函數
current_lottery_stores <- data.frame()
for(i in 1:16){
  single_page_lottery <- lottery_jackpot_stores_crawler(page = i)
  current_lottery_stores <- rbind(current_lottery_stores, single_page_lottery)
}
View(current_lottery_stores)
