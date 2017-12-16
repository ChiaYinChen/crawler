from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import pandas as pd
import time as time_module

def hahow_code_block_crawler():
    driver = webdriver.Chrome()
    driver.get("https://hahow.in/")
    driver.maximize_window()
    
    course_link = driver.find_element_by_css_selector(".pull-left li:nth-child(2) a")
    driver.get(course_link.get_attribute("href")) # 前往「線上課程」頁籤
    driver.find_element_by_css_selector(".ng-scope:nth-child(12) .pad-rl-10").click() # 前往「程式」頁籤
    
    for i in range(10): # 進行十次
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);") # 重複往下捲動
        time_module.sleep(1) # 每次載入的過程小睡 1 秒
    
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
    
    driver.close()
    
    course_info_df = pd.DataFrame({"課程名稱": course_names,
                                   "售價": prices_tidy,
                                   "課程時數": course_times_tidy,
                                   "學生人數": students_tidy},
                                  columns = [u'課程名稱', u'售價', u"課程時數", u'學生人數'])
    return(course_info_df)


# 呼叫函數
hahow_code_course_info = hahow_code_block_crawler()

# 結果存成 CSV
hahow_code_course_info.to_csv('csv_results/hahow_code_course.csv', index = False, encoding = "utf-8")

