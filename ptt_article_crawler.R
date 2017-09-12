library(rvest)
library(httr)

article_detail <- function(url){
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

# article_url <- "https://www.ptt.cc/bbs/NBA/M.1500708665.A.EF4.html"
# nba_article <- article_detail(article_url)


board_url <- "https://www.ptt.cc/bbs/Salary/index.html"
html_doc <- read_html(board_url)
article_links <- html_doc %>%
  html_nodes(css = ".title a") %>%
  html_attr("href")
article_links <- paste("https://www.ptt.cc", article_links, sep = "")
article_lists <- list()
for (i in 1:length(article_links)){
  article_lists[[i]] <- article_detail(article_links[i])
}

