import requests
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime

# 台北票房觀測站(年度週末冠軍)
def movie_weekend_champion_crawler(year):
    url = "http://www.taipeibo.com/yearly/" + str(year)
    response = requests.get(url)
    response.encoding ="utf-8"
    soup = BeautifulSoup(response.text, 'lxml')
    crawling_time = datetime.now().strftime('%Y-%m-%d-%H:%M:%S')
    
    all_rows = soup.table.find_all("tr") # 找出所有 tr 的標籤，並存成 list
    
    column_name_tag = all_rows[0] # 標題名稱的標籤就是 all_rows 的第一筆資料
    column_name = [text for text in column_name_tag.stripped_strings] # 使用 strpped_strings 找出 tag 底下所有的文字
    movie_df = pd.DataFrame(columns = column_name)
    for i, row in enumerate(all_rows[1:]): # 從第二個 row 開始 iterate (因為第一個 row 是標題)
        data_want = [s for s in row.stripped_strings]
        movie_df.loc[i] = data_want # 設定 DataFrame 的第 i 個 row 是我們抓下來的資訊
    
    movie_df.columns.values[7] = "冠軍比例"
    movie_df.insert(1, "年度", str(year))
    movie_df['crawling_time'] = crawling_time
    movie_df['crawling_time'] = pd.to_datetime(movie_df['crawling_time'])
    movie_df.columns = [u'週次', u'年度', u'日期', u'週末票房總和', u'漲跌幅', u'冠軍片名', u'英文片名', u'週末票房冠軍', u'冠軍比例', 'crawling_time']
    return(movie_df)
    # 冠軍比例 = 冠軍週末票房 / 北市週末總票房


# 呼叫函數
champion_2017 = movie_weekend_champion_crawler(year = 2017)
champion_2016 = movie_weekend_champion_crawler(year = 2016)
current_year_champion = champion_2017.append(champion_2016)

# 結果存成 CSV
current_year_champion.to_csv("csv_results/movie_weekend_champion.csv", index = False, encoding = "utf-8")

# 結果存進資料庫
import sqlite3
with sqlite3.connect('movie.db') as db:
    current_year_champion.to_sql('weekend_champion', con = db, if_exists = 'replace')

# 從資料庫讀取資料到 DataFrame
with sqlite3.connect('movie.db') as db:
    df = pd.read_sql_query('select * from weekend_champion', con = db)

