library(rvest)
library(httr)

ptt_index_crawler <- function(url){
  url <- GET(url, set_cookies(over18 = 1))
  html_doc <- read_html(url)
  
  # nrec_xpath <- "//div[@class='nrec']"
  # title_xpath <- "//div[@class='title']"
  # id_xpath <- "//div[@class='meta']/div[@class='author']"
  nrec_css <- ".nrec"
  title_css <- ".title a"
  id_css <- ".author"
  
  index_info <- list()
  columns <- c(nrec_css, title_css, id_css)
  
  for (i in 1:length(columns)) {
    content <- html_doc %>%
      html_nodes(css = columns[i]) %>%
      html_text()
    index_info[[i]] <- content
  }
  
  index_links <- html_doc %>%
    html_nodes(css = title_css) %>%
    html_attr("href")
  index_links <- paste("https://www.ptt.cc", index_links, sep = "")
  index_info[[4]] <- index_links
  
  names(index_info) <- c("recs", "titles", "author_id", "links")
  index_info$titles <- gsub(pattern = "\n\t+", index_info$titles, replacement = "")
  return(index_info)
}

ptt_board_index_crawler <- function(board_name, start_page, end_page){
  index_infos <- list()
  articles <- list()
  start_end_pages <- start_page:end_page
  urls <- paste0("https://www.ptt.cc/bbs/", board_name, "/index", start_end_pages, ".html")
  for (i in 1:length(urls)) {
    index_infos[[i]] <- ptt_index_crawler(urls[i])
    for (j in 1:length(index_infos[[i]]$links)) {
      index_infos[[i]]$articles[[j]] <- article_detail_crawler(index_infos[[i]]$links[j])
    }
  }
  names(index_infos) <- paste0("page", start_end_pages)
  return(index_infos)
}

article_detail_crawler <- function(url){
  url <- GET(url, set_cookies(over18 = 1))
  html_doc <- read_html(url)
  
  article_detail_info <- list()
  
  author_css <- ".article-metaline:nth-child(1) .article-meta-value"
  title_css <- ".article-metaline-right+ .article-metaline .article-meta-value"
  time_css <- ".article-metaline+ .article-metaline .article-meta-value"
  main_content_css <- "#main-content"
  # ip_css <- ".article-metaline+ .f2"    # 方法一：ip的CSS位置每個板好像都不一樣
  ip_css <- "#main-content"    # 方法二：從整個內文中尋找ip
  push_css <- ".push-tag"
  push_id_css <- ".push-userid"
  push_content_css <- ".push-content"
  push_time_css <- ".push-ipdatetime"
  columns <- c(author_css, title_css, time_css, main_content_css, ip_css, push_css, push_id_css, push_content_css, push_time_css)
  
  for (i in 1:length(columns)){
    article_content <- html_doc %>%
      html_nodes(css = columns[i]) %>%
      html_text()
    article_detail_info[[i]] <- article_content
  }
  
  names(article_detail_info) <- c("author", "title", "time", "main_content", "ip", "push", "push_id", "push_content", "push_time")
  
  # 清理內文
  article_detail_info$main_content <- article_detail_info$main_content %>%
    gsub(pattern = "\n", ., replacement = "") %>% # 清理斷行符號
    gsub(pattern = "作者.+:[0-9]{2}\\s[0-9]{4}", ., replacement = "") %>% # 去頭
    gsub(pattern = "※ 發信站.+", ., replacement = "") # 去尾
  
  # # 清理IP方法一
  # ip_start <- regexpr(pattern = "[0-9]+", article_detail_info$ip)
  # article_detail_info$ip <- gsub(pattern = "\n", article_detail_info$ip, replacement = "") # 清理斷行符號
  # ip_end <- nchar(article_detail_info$ip)
  # article_detail_info$ip <- substr(article_detail_info$ip, start = ip_start, stop = ip_end)
  # 清理IP方法二
  article_detail_info$ip <- article_detail_info$ip %>%
    gsub(pattern = "作者.+來自: ", ., replacement = "") %>% # 去頭
    gsub(pattern = "\n※ 文章網址:.+", ., replacement = "") # 去尾
  
  
  # 清理推文
  article_detail_info$push <- gsub(pattern = "\\s", article_detail_info$push, replacement = "")
  # 清理推文ID
  article_detail_info$push_id <- gsub(pattern = "\\s", article_detail_info$push_id, replacement = "")
  # 清理推文內容
  article_detail_info$push_content <- article_detail_info$push_content %>%
    gsub(pattern = "\\s", ., replacement = "") %>%
    gsub(pattern = ":", ., replacement = "")
  # 清理推文時間
  article_detail_info$push_time <- article_detail_info$push_time %>%
    gsub(pattern = "^\\s", ., replacement = "") %>%
    gsub(pattern = "\n", ., replacement = "")
  
  return(article_detail_info)
}

# 呼叫函數
result <- ptt_board_index_crawler(board_name = "Gossiping", start_page = 5200, end_page = 5203)
result$page5200$articles[[20]]
# nba_index <- ptt_index_crawler("https://www.ptt.cc/bbs/NBA/index.html")
# articles <- list()
# for (i in 1:length(result$page5200$links)) {
#   articles[[i]] <- article_detail_crawler(result$page5200$links[i])
# }
# articles



single_page_crawler <- function(page_url) {
  n_recs_css <- ".hl"
  article_title_css <- ".title a"
  article_date_css <- ".date"
  author_css <- ".author"
  
  html_doc <- read_html(page_url)
  page_content <- list()
  cols <- c(n_recs_css, article_title_css, article_date_css, author_css)
  for (i in 1:length(cols)) {
    page_content[[i]] <- html_doc %>%
      html_nodes(css = cols[i]) %>%
      html_text
  }
  return(page_content)
}

multi_page_crawler <- function(page_url, n_pages) {
  # get last_page_number
  last_page <- ".wide:nth-child(2)"
  last_page_url <- read_html(url) %>%
    html_nodes(css = last_page) %>%
    html_attr("href")
  
  number_pattern <- "[0-9]+"
  regexpr_m <- gregexpr(pattern = number_pattern, last_page_url)
  last_page_number <- last_page_url %>%
    regmatches(m = regexpr_m) %>%
    as.numeric
  
  page_numbers <- c((last_page_number - n_pages + 2):last_page_number, "")
  page_urls <- paste0("https://www.ptt.cc/bbs/NBA/index", page_numbers, ".html")
  
  pages_list <- list()
  for (i in 1:length(page_urls)) {
    pages_list[[i]] <- single_page_crawler(page_urls[i])
  }
  return(pages_list)
}

# 呼叫函數
url <- "https://www.ptt.cc/bbs/NBA/index.html"
nba_5_pages <- multi_page_crawler(url, n_pages = 5)
