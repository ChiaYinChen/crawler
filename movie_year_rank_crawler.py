import requests
from bs4 import BeautifulSoup
import pandas as pd

# 台北票房觀測站(年度排名)
def movie_year_rank_crawler(year):
    url = "http://www.taipeibo.com/year/" + str(year)
    response = requests.get(url)
    response.encoding = "utf-8"
    soup = BeautifulSoup(response.text, "lxml")

    column_name = [col for col in soup.table.find("tr").stripped_strings]
    sale_df = pd.DataFrame(columns = column_name)
    all_rows = [row for row in soup.table.find_all("tr")]
    for i, row in enumerate(all_rows[1:]):
        sale_df.loc[i] = [s for s in row.stripped_strings]
    
    return(sale_df)

# 呼叫函數
rank_2017 = movie_year_rank_crawler(year = 2017)
rank_2016 = movie_year_rank_crawler(year = 2016)
current_year_rank = rank_2017.append(rank_2016)

current_year_rank.to_csv("csv_results/movie_year_rank.csv", index = False, encoding = "utf-8")
