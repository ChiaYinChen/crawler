library(rvest)

apple_realtime_news_index_crawler <- function(url) {
  apple_daily_url <- url
  apple_daily <- read_html(apple_daily_url)
  crawling_time <- Sys.time()
  
  apple_realtime_news <- list()
  
  time_css <- ".rtddt time"
  category_css <- "#maincontent h2"
  title_css <- "h2+ h1 font"
  columns <- c(time_css, category_css, title_css)
  
  for (i in 1:length(columns)) {
    content <- apple_daily %>%
      html_nodes(css = columns[i]) %>%
      html_text()
    apple_realtime_news[[i]] <- content
  }
  names(apple_realtime_news) <- c("time", "category", "title")
  
  new_links <- apple_daily %>%
    html_nodes(css = ".rtddt a") %>%
    html_attr("href")
  new_links <- paste("http://www.appledaily.com.tw", new_links, sep = "")
  apple_realtime_news$link <- new_links
  
  apple_realtime_news_df <- data.frame(time = apple_realtime_news$time,
                                       category = apple_realtime_news$category,
                                       title = apple_realtime_news$title,
                                       link = apple_realtime_news$link)
  apple_realtime_news_list <- list(crawling_time = crawling_time,
                                   apple_realtime_news = apple_realtime_news_df)
  return(apple_realtime_news_list)
  
}

apple_realtime_news_crawler <- function(start_page, end_page) {
  index_infos <- list()
  start_end_pages <- start_page:end_page
  urls <- paste0("http://www.appledaily.com.tw/realtimenews/section/new/", start_end_pages)
  for (i in 1:length(urls)) {
    index_infos[[i]] <- apple_realtime_news_index_crawler(urls[i])
  }
  names(index_infos) <- paste0("realtime_page", start_end_pages)
  return(index_infos)
}

# 呼叫函數
current_apple_realtime_news <- apple_realtime_news_crawler(start_page = 2, end_page = 6)
current_apple_realtime_news$realtime_page2$crawling_time
View(current_apple_realtime_news$realtime_page2$apple_realtime_news)

