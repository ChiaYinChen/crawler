import requests
import pandas as pd
from urllib.request import urlretrieve
import math

# 從 Facebook Graph API Exploer 取得 token
token = 'your token'


def get_albums(token):
    
    fanpage = {'110958532292955':'田馥甄 Hebe'}
    
    albums_id = []
    albums_name = []
    for element in fanpage:
        response = requests.get('https://graph.facebook.com/v2.11/{}/?fields=albums&access_token={}'.format(element, token))
    
        for albums in response.json()['albums']['data']:
            albums_id.append(albums['id'])
            albums_name.append(albums['name'])
    
    albums_df = pd.DataFrame({'album_id': albums_id,
                              'album_name': albums_name},
                             columns = ['album_id', 'album_name'])     
    return(albums_df)



def get_albums_photos(token):
    albums = get_albums(token)
    
    photo_info_result_df = pd.DataFrame(columns = ['album_id', 'album_name', 'photo_id'])
    
    for album_id, album_name in zip(albums['album_id'], albums['album_name']):
        response = requests.get('https://graph.facebook.com/v2.11/{}/?fields=photos,photo_count&access_token={}'.format(album_id, token))
        
        photos_id = []
        
        for count in range(math.ceil(response.json()['photo_count'] / 25)):
            if 'photos' in response.json():
                for information in response.json()['photos']['data']:
                    photos_id.append(information['id'])
                if 'next' in response.json()['photos']['paging']:
                    response = requests.get(response.json()['photos']['paging']['next'])
                else:
                    break
            else:
                for information in response.json()['data']:
                    photos_id.append(information['id'])
        
                if 'next' in response.json()['paging']:
                    response = requests.get(response.json()['paging']['next'])
                else:
                    break
        
        photo_info_df = pd.DataFrame({'photo_id': photos_id})
        photo_info_df['album_id'] = album_id
        photo_info_df['album_name'] = album_name
        photo_info_result_df = photo_info_result_df.append(photo_info_df)
        
        
    return(photo_info_result_df)


def replace_name(album_name):    
    replace_name = []
    for text in album_name:        
        replace_name.append(text.replace("/", " "))
    
    return(replace_name)


def photos_download(token):
    photos = get_albums_photos(token)
    photos_list = photos['album_name'].tolist()
    photos['album_name'] = replace_name(photos_list)
    
    for photo_id, album_name in zip(photos['photo_id'], photos['album_name']):
        response = requests.get('https://graph.facebook.com/v2.11/{}/?fields=images&access_token={}'.format(photo_id, token))
        url = response.json()['images'][0]['source']
        urlretrieve(url, "fb_album_photo_download/{}_{}.jpg".format(album_name, photo_id))
    

# 呼叫函數
photos_download(token)

