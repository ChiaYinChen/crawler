import requests
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime

# 台北票房觀測站(年度排名)
def movie_year_rank_crawler(year):
    url = "http://www.taipeibo.com/year/{}".format(year)
    response = requests.get(url)
    response.encoding = "utf-8"
    soup = BeautifulSoup(response.text, "lxml")
    crawling_time = datetime.now().strftime('%Y-%m-%d-%H:%M:%S')
    
    column_name = [col for col in soup.table.find("tr").stripped_strings]
    sale_df = pd.DataFrame(columns = column_name)
    all_rows = [row for row in soup.table.find_all("tr")]
    for i, row in enumerate(all_rows[1:]):
        sale_df.loc[i] = [s for s in row.stripped_strings]
    
    sale_df['crawling_time'] = crawling_time
    sale_df['crawling_time'] = pd.to_datetime(sale_df['crawling_time'])
    sale_df.columns = [u'排名', u'中文片名', u'英文片名', u'院數', u'映期', u'上映日期', u'平均票房', u'累積票房', 'crawling_time']
    return(sale_df)

# 呼叫函數
rank_2017 = movie_year_rank_crawler(year = 2017)
rank_2016 = movie_year_rank_crawler(year = 2016)
current_year_rank = rank_2017.append(rank_2016)

# 結果存成 CSV
current_year_rank.to_csv("csv_results/movie_year_rank.csv", index = False, encoding = "utf-8")

# 結果存進資料庫
import sqlite3
with sqlite3.connect('movie.db') as db:
    current_year_rank.to_sql('year_rank', con = db, if_exists = 'replace')

# 從資料庫讀取資料到 DataFrame
with sqlite3.connect('movie.db') as db:
    df = pd.read_sql_query('select * from year_rank', con = db)

