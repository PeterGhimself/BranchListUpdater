#!/usr/bin/env python3
import os
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import getpass

current_dir = os.path.dirname(os.path.realpath(__file__)) + '/'
chromedriver_path = current_dir + 'chromedriver'
print('chromedriver_path: ', chromedriver_path)

# Option 1 - with ChromeOptions
chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no=sandbox") # required when running as root user. otherwise you would get no sandbox errors.

driver = webdriver.Chrome(executable_path=chromedriver_path, chrome_options=chrome_options, service_args=['--verbose', '--log-path=/tmp/chromedriver.log'])

# Option 2 - with pyvirtualdisplay
'''
from pyvirtualdisplay import Display
display = Display(visible=0, size=(1024, 768))
display.start()
driver = webdriver.Chrome(driver_path=chromedriver_path, service_args=['--verbose', '--log-path=/tmp/chromedriver.log'])
'''
# Log path added via service args to see errors if something goes wrong

# And now you can add your website / app testing functionality:

#target_url = 'https://spaceconcordiateam.slack.com'
# directly to github enterprise server integration settings page, which will first redirect to login page
# after succesful login we should hit the 'Github Enterprise Server | Slack App Directory' page
target_url = 'https://spaceconcordiateam.slack.com/services/B2ZGUM4MV'

driver.get(target_url)
print('driver.title: ', driver.title)

signed_in = False

# check if already logged in
try:
    elem = driver.find_element_by_class_name('p-classic_nav__team_header__user__name__truncate')
    print('elem: ', elem)

except Exception as err:
    print('Error encountered!')
    print(err)

email = ''
password = ''

if not signed_in:
    try:
        email = driver.find_element_by_id('email')
        print('email: ', email)
        password = driver.find_element_by_id('password')
        print('password: ', password)

    except NoSuchElementException as err:
        print('Error encountered!')
        print(err)


print('Enter email: ')
user_email = input()

email.clear()
email.send_keys(user_email)

user_password = getpass.getpass('Enter password: ')

password.clear()
password.send_keys(user_password)
password.send_keys(Keys.RETURN)

elem = ''

# check to see if login worked
try:
    assert driver.page_source.find('GitHub Enterprise Server')
    print('driver.title: ', driver.title)

except NoSuchElementException as err:
    print('Error encountered!')
    print(err)




print('closing driver...')
driver.close()
print('driver closed')
