library(jsonlite)
library(magrittr)

rent591_crawler <- function(region, section){
  url <- paste0("https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=", region,
                "&section=", section,
                "&shType=host")
  house_info <- fromJSON(url)
  total_rows <- as.integer(house_info$records)
  page_nums <- seq(from = 0, to = total_rows, 30)
  
  urls <- paste0("https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=", region,
                 "&section=", section,
                 "&shType=host&firstRow=", page_nums,
                 "&totalRows=", total_rows)
  post_id <- c()
  bedroom <- c()
  area <- c()
  price <- c()
  floor <- c()
  total_floor <- c()
  kind_name <- c()
  
  for (i in 1:length(urls)){
    single_page_query <- fromJSON(urls[i])
    post_id <- c(post_id, single_page_query$data$data$post_id)
    bedroom <- c(bedroom, single_page_query$data$data$room)
    area <- c(area, single_page_query$data$data$area)
    price <- c(price, single_page_query$data$data$price)
    floor <- c(floor, single_page_query$data$data$floor)
    total_floor <- c(total_floor, single_page_query$data$data$allfloor)
    kind_name <- c(kind_name, single_page_query$data$data$kind_name)
    Sys.sleep(sample(2:5, size = 1))
  }
  
  renthouse_result_df <- data.frame(post_id = factor(post_id),
                                    bedroom = bedroom,
                                    area = area,
                                    price = price,
                                    floor = floor,
                                    total_floor = total_floor,
                                    kind_name = kind_name)
  renthouse_result_df$price <- renthouse_result_df$price %>% 
    as.character() %>%
    gsub(pattern = ",", ., replacement = "") %>%
    as.numeric()
  return(renthouse_result_df)
}

# 呼叫函數
rent591_neihu <- rent591_crawler(region = 1, section = 10)
