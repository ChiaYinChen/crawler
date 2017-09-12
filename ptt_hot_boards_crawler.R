library(rvest)

ptt_hot_boards_crawler <- function() {
  # 載入html document
  url <- "https://www.ptt.cc/bbs/hotboards.html"
  html_doc <- read_html(url)
  crawling_time <- Sys.time()
  
  ptt_hot_boards <- list()
  
  boards_css <- ".board-name"
  viewers_css <- ".hl"
  classes_css <- ".board-class"
  titles_css <- ".board-title"
  columns <- c(boards_css, viewers_css, classes_css, titles_css)
  
  for (i in 1:length(columns)) {
    content <- html_doc %>%
      html_nodes(css = columns[i]) %>%
      html_text()
    ptt_hot_boards[[i]] <- content
  }
  
  names(ptt_hot_boards) <- c("boards", "viewers", "classes", "titles")
  ptt_hot_boards$viewers <- as.integer(ptt_hot_boards$viewers)
  
  board_links <- html_doc %>%
    html_nodes(css = ".board") %>%
    html_attr("href")
  board_links <- paste("https://www.ptt.cc", board_links, sep = "")
  ptt_hot_boards$links <- board_links
  
  # return(ptt_hot_boards)
  
  ptt_hot_boards_df <- data.frame(boards = ptt_hot_boards$boards, 
                                  viewers = ptt_hot_boards$viewers,
                                  classes = ptt_hot_boards$classes,
                                  titles = ptt_hot_boards$titles,
                                  links = ptt_hot_boards$links)
  ptt_hot_boards_list <- list(crawling_time = crawling_time,
                              ptt_hot_boards = ptt_hot_boards_df)
  return(ptt_hot_boards_list)
  
}

# 呼叫函數
current_ptt_hotties <- ptt_hot_boards_crawler()
current_ptt_hotties$crawling_time
View(current_ptt_hotties$ptt_hot_boards)

