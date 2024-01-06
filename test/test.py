#!/usr/bin/python3

# basic script to do a smoke test using selenium webdriver

### begin firefox setup
from selenium import webdriver
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options
import os

# Set up Firefox options
firefox_options = Options()
firefox_options.headless = True  # Run Firefox in headless mode

# Path to GeckoDriver executable
geckodriver_path = '/snap/bin/geckodriver'  # Replace with the actual path to geckodriver
### end firefox setup

### begin chrome setup
# from selenium import webdriver
# from selenium.webdriver.chrome.service import Service as ChromeService
# from selenium.webdriver.chrome.options import Options
# import os
#
# # Set up Chrome options
# chrome_options = Options()
# chrome_options.add_argument('--headless')  # Run Chrome in headless mode
#
# # Path to ChromeDriver executable
# # chromedriver_path = '/usr/lib/chromium-browser/chromedriver'
# chromedriver_path = '/usr/bin/chromedriver'
### end chrome setup

# Path to the directory containing text files
directory_path = '/home/wsl/pollyanna/default/theme/gpt/string/en/concept'

# Iterate over each text file in the directory
for filename in os.listdir(directory_path):
	# Set up the WebDriver
	# driver = webdriver.Chrome(executable_path=chromedriver_path, options=chrome_options)
	firefox_service = FirefoxService(executable_path=geckodriver_path)
	driver = webdriver.Firefox(service=firefox_service, options=firefox_options)

	if (filename.endswith('.txt')):
		# Construct the URL based on the filename
		page_url = f'http://admin:admin@localhost:2784/{filename[:-4]}.html'

		# Navigate to the page
		driver.get(page_url)

		# Take a screenshot
		driver.save_screenshot(f'{filename[:-4]}.png')
	# } if (filename.endswith('.txt')
# } for filename in os.listdir(directory_path):

# Close the WebDriver
driver.quit()
