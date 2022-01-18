import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options


class Browser:
    def __init__(self):
        options = Options()
        options.add_argument('--headless')
        options.add_argument('--disable-gpu')  # Last I checked this was necessary.
        self.browser = webdriver.Chrome('./package/chromedriver.exe', chrome_options=options)


        self.hospital_url = 'https://tandem.hosp.ncku.edu.tw/Tandem/RegQueryUI.aspx?Lang='

    def close(self):
        self.browser.close()

    def login(self, user_data):
        self.browser.get(self.hospital_url)
        print('查詢：'+str(user_data))

        id_blank = self._locate_element(By.XPATH, '//input[@id="ctl00_ctl00_MainContent_MainContent_tbIdno"]')
        year_blank = self._locate_element(By.XPATH, '//input[@id="ctl00_ctl00_MainContent_MainContent_txtBirthYear"]')
        month_blank = self._locate_element(By.XPATH, '//input[@id="ctl00_ctl00_MainContent_MainContent_txtBirthMonth"]')
        day_blank = self._locate_element(By.XPATH, '//input[@id="ctl00_ctl00_MainContent_MainContent_txtBirthDate"]')
        submit_btn = self._locate_element(By.XPATH, '//input[@id="ctl00_ctl00_MainContent_MainContent_btnSubmit"]')

        id_blank.send_keys(user_data['ID_number'])
        time.sleep(0.1)
        year_blank.send_keys(user_data['year'])
        time.sleep(0.1)
        month_blank.send_keys(user_data['month'])
        time.sleep(0.1)
        day_blank.send_keys(user_data['day'])
        time.sleep(0.1)

        submit_btn.click()
        time.sleep(1)
        
    def extract_data(self):
        table = self.browser.find_element_by_id('tResult')
        trs = table.find_elements_by_tag_name('tr')[1:-1]
        
        if trs[0].text == '查無預約掛號的資料！':
            print('查無預約掛號的資料！')
            return []
        
        appointments = []
        
        for tr in trs:
            tds = tr.find_elements_by_tag_name('td')
            detail = self._analyze(tds)
            appointments.append(detail)
        
        return appointments
        
        
    def _analyze(self, tds):
        detail = {}
        detail['date'] = tds[1].text
        detail['interval'] = tds[2].text
        detail['type id'] = tds[3].text.split('\n')[0]
        detail['type name'] = tds[3].text.split('\n')[1]
        detail['doctor_name'] = tds[4].text
        detail['number'] = tds[5].text
        detail['time range'] = tds[6].text
        idx = tds[7].text.rfind('樓')
        detail['location'] = tds[7].text[:idx+1]
        detail['room'] = tds[7].text[idx+1:]

        idx = detail['time range'].find('　')
        if idx != -1:
            detail['else'] = detail['time range'][idx+1:]
            detail['time range'] = detail['time range'][:idx]
        else:
            detail['else'] = ''

        return detail

    def _locate_element(self, by, what):
        return WebDriverWait(self.browser, 15).until(EC.presence_of_element_located((by, what)))

    def _locate_all_elements(self, by, what):
        return WebDriverWait(self.browser, 15).until(EC.presence_of_all_elements_located((by, what)))
