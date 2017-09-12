library(jsonlite)
# 網站動態利用JavaScript去後端資料庫查詢的例子，資料多半會在XHR/JS裡面
# 資料放在HTML裡面的例子，多半會在Doc/WS裡面

pchome_crawler <- function(query, pages) {
  url <- paste0("http://ecshweb.pchome.com.tw/search/v3.3/all/results?q=", query, "&page=1&sort=rnk/dc")
  product_info <- fromJSON(url)
  page_nums <- 1:product_info$totalPage
  
  urls <- paste0("http://ecshweb.pchome.com.tw/search/v3.3/all/results?q=", query, "&page=", page_nums, "&sort=rnk/dc")
  product_names <- c()
  product_descriptions <- c()
  product_prices <- c()
  
  for (i in 1:pages){
    single_page_query <- fromJSON(urls[i])
    product_names <- c(product_names, single_page_query$prods$name)
    product_descriptions <- c(product_descriptions, single_page_query$prods$describe)
    product_prices <- c(product_prices, single_page_query$prods$price)
    Sys.sleep(sample(2:5, size = 1))
  }
  
  product_result_df <- data.frame(name = product_names, description = product_descriptions, price = product_prices)
  return(product_result_df)
}

# 呼叫函數
current_pchome_product <- pchome_crawler(query = "macbook", pages = 6)
View(current_pchome_product)


