from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import pandas as pd
import time as time_module

def hahow_course_crawler():
    driver = webdriver.Chrome()
    driver.get("https://hahow.in/")
    driver.maximize_window()
    
    course_link = driver.find_element_by_css_selector(".pull-left li:nth-child(2) a")
    driver.get(course_link.get_attribute("href")) # 前往「線上課程」頁籤
    
    # 擷取不同導覽列及導覽列名稱的 CSS
    navs = []
    navs_text = []
    for i in range(12):
        nav_css = "ul.category-list.large-screen li.ng-scope:nth-child({}) .pad-t-15.pad-rl-10".format(i + 1)
        navs.append(nav_css)
        nav_text_css = "ul.category-list.large-screen li.ng-scope:nth-child({}) .pad-t-15.pad-rl-10 .title".format(i + 1)
        navs_text.append(nav_text_css)
    
    # 建立空的 DateFrame 設定好 columns 名稱 (最終 DateFrame)
    result_course_info_df = pd.DataFrame(columns = [u'課程名稱', u'售價', u"課程時數", u'學生人數', u"課程分類"])
    
    # 連結到不同的導覽列擷取內容
    for nav, nav_text in zip(navs, navs_text):
        driver.find_element_by_css_selector(nav).click() # 前往頁籤
        for i in range(10):  # 進行十次
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")  # 重複往下捲動
            time_module.sleep(1)  # 每次載入的過程小睡 1 秒    
        # time_module.sleep(1)
        
        course_names = []
        course_name = driver.find_elements_by_css_selector(".marg-t-20.marg-b-10")
        for name in course_name:
            course_names.append(name.text)
        
        prices = []
        price = driver.find_elements_by_css_selector(".txt-coral")
        for p in price:
            prices.append(p.text)
        prices_tidy = []
        for p in prices:
            temp = p.replace("NT$", "")
            temp = int(temp)
            prices_tidy.append(temp)
        
        course_times = []
        course_time = driver.find_elements_by_css_selector(".pull-left.ng-binding")
        for time in course_time:
            course_times.append(time.text)
        course_times_tidy = []
        for time in course_times:
            # temp = time.replace("課時 ", "")
            # temp = temp.replace(" 分鐘", "")
            temp = time.split(" ")[1]
            temp = int(temp)
            course_times_tidy.append(temp)
        
        students = []
        student = driver.find_elements_by_css_selector("div.pull-right span.ng-binding")
        for s in student:
            students.append(s.text)
        students_tidy = []
        for s in students:
            # temp = s.replace(" 人", "")
            temp = s.split(" ")[0]
            temp = int(temp)
            students_tidy.append(temp)
        
        course_info_df = pd.DataFrame({"課程名稱": course_names,
                                       "售價": prices_tidy,
                                       "課程時數": course_times_tidy,
                                       "學生人數": students_tidy},
                                      columns = [u'課程名稱', u'售價', u"課程時數", u'學生人數'])
        
        course_info_df['課程分類'] = driver.find_element_by_css_selector(nav_text).text
        
        result_course_info_df = result_course_info_df.append(course_info_df)
    
    
    driver.close()
    return(result_course_info_df)


# 呼叫函數
hahow_course_info = hahow_course_crawler()

# 結果存成 CSV
hahow_course_info.to_csv('csv_results/hahow_course.csv', index = False, encoding = "utf-8")

