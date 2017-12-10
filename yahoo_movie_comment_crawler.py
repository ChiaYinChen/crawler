import requests
from bs4 import BeautifulSoup
import pandas as pd
# import re
from datetime import datetime

def movie_comment_crawler():
    
    # 尋找排行榜中所有的 link
    movie_links = movie_link_crawler()
        
    # 建立空 DataFrame 設定好 columns 名稱
    result_comment_df = pd.DataFrame(columns =  ["movie", "comments", "star"])

    
    for link in range(len(movie_links)):        
        url = movie_links[link]
        url = str(url)
        url = url.replace("main", "review")
        response = requests.get(url)
        soup = BeautifulSoup(response.text, "lxml")        
        
        # 找到該電影共有幾頁評論
        page = int(soup.find("div", {"class":"page_numbox"}).find_all("a")[-2].text)
        
        # 建立空 list，準備儲存所有的評論文字及星等
        comment_all = []
        star_all = []
        
        # 建立空 DataFrame 設定好 columns 名稱
        comment_df = pd.DataFrame(columns =  ["movie", "comments", "star"])
        
        # 對每頁的評論送 requests，並把評論文字、星等抓下來，存進剛剛建好的空 list
        for i in range(1, (page + 1)):
            response = requests.get(str(url) + "?sort=update_ts&order=desc&page=" + str(i) )
            soup = BeautifulSoup(response.text, "lxml")
            
            # 評論文字存在 span 標籤裡，把每個人的評論先存成 list，再把這個 list 放進 comment_all 裡面
            comment = [x.find("span", {"class":None}).text for x in soup.find_all("div", {"class":"usercom_inner _c"})]
            comment_all.extend(comment)
            
            # 要抓取評論星等，首先定位出每個評論所在的位置，觀察後發現在 div 標籤，屬性 class=usercom_inner _c，評論星等就在這個 div 裡的 inputs 標籤
            star = [comment.find("input", {"name":"score"})['value'] for comment in soup.find_all("div", {"class":"usercom_inner _c"})]
            star_all.extend(star)
            
        # 電影名稱的則是在 div 標籤，屬性 class=inform_title
        movie_name = soup.find("div", {"class":"inform_title"}).text
        movie_name = movie_name.replace("\n", "")
        
        # 建立 DataFrame
        comment_df = pd.DataFrame({"comments": comment_all,
                                   "movie": movie_name,
                                   "star": star_all})   
        result_comment_df = result_comment_df.append(comment_df)
    
    
    crawling_date = datetime.now().strftime('%Y-%m-%d')
    result_comment_df['crawling_date'] = crawling_date
    result_comment_df['crawling_date'] = pd.to_datetime(result_comment_df['crawling_date'])
    return(result_comment_df)

    
def movie_link_crawler():
    response = requests.get("https://movies.yahoo.com.tw/chart.html?cate=year")
    soup = BeautifulSoup(response.text, "lxml")
    
    links = []
    for link in soup.select("a[href] dl.rank_list_box"):
        temp = link.find_parent("a", href=True)
        links.append(temp["href"])
    
    for link in soup.select("a[href] div.rank_txt"):
        temp = link.find_parent("a", href=True)
        links.append(temp["href"])
    
    return(links)


# 呼叫函數
current_comment = movie_comment_crawler()

# 結果存成 CSV
current_comment.to_csv("csv_results/yahoo_movie_comment.csv", index = False, encoding = "utf-8")

# 結果存進資料庫
import sqlite3
with sqlite3.connect('movie.db') as db:
    current_comment.to_sql('yahoo_comment', con = db, if_exists = 'replace')

# 從資料庫讀取資料到 DataFrame
with sqlite3.connect('movie.db') as db:
    df = pd.read_sql_query('select * from yahoo_comment', con = db)

