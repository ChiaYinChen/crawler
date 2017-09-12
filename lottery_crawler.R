library(rvest)

lottery_crawler <- function(year) {
  url <- paste0("http://lotto.auzonet.com/biglotto/list_", year, "_all.html")
  html_doc <- read_html(url)
  
  index_css <- ".history_view_table span"
  date_css <- ".history_view_table_tit+ tr td:nth-child(1)"
  ball1_css <- "li:nth-child(1) p+ .history_ball_link"
  ball2_css <- "li:nth-child(1) .history_ball_link:nth-child(3)"
  ball3_css <- "li:nth-child(1) .history_ball_link:nth-child(4)"
  ball4_css <- "li:nth-child(1) .history_ball_link:nth-child(5)"
  ball5_css <- "li:nth-child(1) .history_ball_link:nth-child(6)"
  ball6_css <- "li:nth-child(1) .history_ball_link:nth-child(7)"
  sball_css <- ".history_view_table_tit+ tr td:nth-child(3)"
  total_sale_css <- ".history_view_table_tit+ tr td:nth-child(4)"
  first_prize_n_css <- ".awards_head+ tr td:nth-child(2)"
  first_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(2)"
  second_prize_n_css <- ".awards_head+ tr td:nth-child(3)"
  second_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(3)"
  third_prize_n_css <- ".awards_head+ tr td:nth-child(4)"
  third_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(4)"
  fourth_prize_n_css <- ".awards_head+ tr td:nth-child(5)"
  fourth_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(5)"
  fifth_prize_n_css <- ".awards_head+ tr td:nth-child(6)"
  fifth_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(6)"
  sixth_prize_n_css <- ".awards_head+ tr td:nth-child(7)"
  sixth_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(7)"
  seventh_prize_n_css <- ".awards_head+ tr td:nth-child(8)"
  seventh_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(8)"
  general_prize_n_css <- ".awards_head+ tr td:nth-child(9)"
  general_prize_bonus_css <- ".awards_head~ tr+ tr td:nth-child(9)"
  
  lottery_info <- list()
  columns <- c(index_css, date_css, ball1_css, ball2_css, ball3_css, ball4_css, ball5_css, ball6_css, sball_css, total_sale_css,
               first_prize_n_css, first_prize_bonus_css, second_prize_n_css, second_prize_bonus_css,
               third_prize_n_css, third_prize_bonus_css, fourth_prize_n_css, fourth_prize_bonus_css,
               fifth_prize_n_css, fifth_prize_bonus_css, sixth_prize_n_css, sixth_prize_bonus_css,
               seventh_prize_n_css, seventh_prize_bonus_css, general_prize_n_css, general_prize_bonus_css)
  
  for (i in 1:length(columns)) {
    content <- html_doc %>%
      html_nodes(css = columns[i]) %>%
      html_text()
    lottery_info[[i]] <- content
  }
  names(lottery_info) <- c("期別", "開獎完整日期", "號碼1", "號碼2", "號碼3", "號碼4", "號碼5", "號碼6", "特別號", "銷售總額",
                         "頭獎中獎注數", "頭獎每注獎金", "貳獎中獎注數", "貳獎每注獎金",
                         "參獎中獎注數", "參獎每注獎金", "肆獎中獎注數", "肆獎每注獎金",
                         "伍獎中獎注數", "伍獎每注獎金", "陸獎中獎注數", "陸獎每注獎金",
                         "柒獎中獎注數", "柒獎每注獎金", "普獎中獎注數", "普獎每注獎金")
  
  # 清理開獎完整日期
  lottery_info$開獎日期 <- lottery_info$開獎完整日期 %>%
    gsub(pattern = "\r\n.+[0-9]{1,20}\r\n\\s{0,20}\r\n\\s{0,20}", ., replacement = "") %>% # 去頭
    gsub(pattern = "\r.+", ., replacement = "") # 去尾
  lottery_info$開獎年 <- lottery_info$開獎日期 %>%
    substr(start = 1, stop = 4)
  lottery_info$開獎月 <- lottery_info$開獎日期 %>%
    substr(start = 6, stop = 7)
  lottery_info$開獎日 <- lottery_info$開獎日期 %>%
    substr(start = 9, stop = 10)
  lottery_info$開獎星期 <- lottery_info$開獎完整日期 %>%
    gsub(pattern = "\r\n.+\\(", ., replacement = "") %>% # 去頭
    gsub(pattern = ")", ., replacement = "") # 去尾
  
  
  lottery_df <- data.frame(期別 = lottery_info$期別, 開獎日期 = lottery_info$開獎日期, 開獎星期 = lottery_info$開獎星期, 開獎年 = lottery_info$開獎年, 開獎月 = lottery_info$開獎月, 開獎日 = lottery_info$開獎日,
                             號碼1 = lottery_info$號碼1, 號碼2 = lottery_info$號碼2, 號碼3 = lottery_info$號碼3, 號碼4 = lottery_info$號碼4, 號碼5 = lottery_info$號碼5, 號碼6 = lottery_info$號碼6, 特別號 = lottery_info$特別號,
                             銷售總額 = lottery_info$銷售總額, 頭獎中獎注數 = lottery_info$頭獎中獎注數, 頭獎每注獎金 = lottery_info$頭獎每注獎金, 貳獎中獎注數 = lottery_info$貳獎中獎注數, 貳獎每注獎金 = lottery_info$貳獎每注獎金,
                             參獎中獎注數 = lottery_info$參獎中獎注數, 參獎每注獎金 = lottery_info$參獎每注獎金, 肆獎中獎注數 = lottery_info$肆獎中獎注數, 肆獎每注獎金 = lottery_info$肆獎每注獎金,
                             伍獎中獎注數 = lottery_info$伍獎中獎注數, 伍獎每注獎金 = lottery_info$伍獎每注獎金, 陸獎中獎注數 = lottery_info$陸獎中獎注數, 陸獎每注獎金 = lottery_info$陸獎每注獎金,
                             柒獎中獎注數 = lottery_info$柒獎中獎注數, 柒獎每注獎金 = lottery_info$柒獎每注獎金, 普獎中獎注數 = lottery_info$普獎中獎注數, 普獎每注獎金 = lottery_info$普獎每注獎金)
  
  return(lottery_df)
  
}

# 呼叫函數
current_lottery <- data.frame()
for(i in 2017:2004){
  single_year_lottery <- lottery_crawler(year = i)
  current_lottery <- rbind(current_lottery, single_year_lottery)
}
View(current_lottery)
