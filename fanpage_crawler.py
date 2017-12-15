import requests
import pandas as pd
from dateutil.parser import parse

# 從 Facebook Graph API Exploer 取得 token
token = 'your token'


def fanpage_post_crawler(fanpage):
    
    fanpage_info = []
    
    for element in fanpage:
        response = requests.get('https://graph.facebook.com/v2.11/{}/posts?limit=100&access_token={}'.format(element, token))
        
        # API最多一次呼叫 100 筆資料，因此使用 while 迴圈去翻頁取得所有的資料
        while 'paging' in response.json(): 
            for information in response.json()['data']:
                if 'message' in information:
                    fanpage_info.append([fanpage[element], information['id'], information['message'], parse(information['created_time']).date()])
            
            if 'next' in response.json()['paging']:
                response = requests.get(response.json()['paging']['next'])
            else:
                break
    
    
    fanpage_info_df = pd.DataFrame(fanpage_info, columns = ['fanpage', '貼文id', '貼文內容', '貼文時間'])
    return(fanpage_info_df)


# 呼叫函數
# 取得粉絲專頁的 id 與名稱
fanpage = {'585816068201402':'靠北男友',
           '1507004499528332':'Kaobei女友'} 
fanpage_post_df = fanpage_post_crawler(fanpage)


# 結果存成 CSV
fanpage_post_df.to_csv('csv_results/fanpage_post_information.csv', index = False, encoding = "utf-8")

