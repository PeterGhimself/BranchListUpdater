#!/usr/bin/env python3
import os
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import getpass
import re
import time
import sys
import slackconfig as cfg

# set default name if none passed in args
new_branch_name = 'testy'

if len(sys.argv) > 1:
    new_branch_name = sys.argv[1]

current_dir = os.path.dirname(os.path.realpath(__file__)) + '/'
chromedriver_path = current_dir + 'chromedriver'
print('chromedriver_path: ', chromedriver_path)

# Option 1 - with ChromeOptions
chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no=sandbox") # required when running as root user. otherwise you would get no sandbox errors.

driver = webdriver.Chrome(executable_path=chromedriver_path, chrome_options=chrome_options, service_args=['--verbose', '--log-path=/tmp/chromedriver.log'])

# directly go to github enterprise server integration settings page, which will first redirect to login page
# after succesful login we should hit the 'Github Enterprise Server | Slack App Directory' page
target_url = 'https://spaceconcordiateam.slack.com/services/B2ZGUM4MV'

driver.get(target_url)
print('driver.title: ', driver.title)

email = ''
password = ''

try:
    # get instances
    email = driver.find_element_by_id('email')
    password = driver.find_element_by_id('password')

except Exception as err:
    print('Error encountered!')
    print(err)

# check config file
if cfg.user['email'] and cfg.user['password']:
    print('Using user config set in slackconfig.py')
    user_email = cfg.user['email']
    user_password = cfg.user['password']

    print('email:', user_email)
    print('password:', len(user_password) * '*')

    email.clear()
    email.send_keys(user_email)
    password.clear()
    password.send_keys(user_password)
    password.send_keys(Keys.RETURN)

else:
    print('Config file either missing user, password, or both')
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
    print('driver.title: ', driver.title)

    '''
    # One way of checking the page source for matches
    src = driver.page_source
    text_found = re.search(r'class="branches small"', src)
    print('text_found', text_found)
    '''

    # append branch name to branch list
    print('locating branches')

    # this method doesn't seem to be working
    #branch_list = driver.find_element_by_class_name('branches')
    #branch_list.send_keys(', test!')

    # so let's try javscripting this instead
    print('inserting value: ', new_branch_name)
    branches_val = "document.getElementsByName('branches[]')[1].value"
    set_branches = branches_val + " += ', " + new_branch_name + "'"
    print('set_branches', set_branches)
    get_branches = "return " + branches_val
    driver.execute_script(set_branches)

    # visual confirmation
    print('updated branch list: ', driver.execute_script(get_branches))

    # necessary wait, otherwise save button gets clicked too fast to actually work
    time.sleep(0.5)

    # only parent is clickable with selenium driver
    # although in js child is clickable
    print('locating save button')
    save = driver.find_element_by_id('add_integration_parent')
    save.click()

except Exception as err:
    print('Error encountered!')
    print(err)

print('closing driver...')
driver.close()
print('driver closed')
