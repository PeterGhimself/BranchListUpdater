# BranchListUpdater

An attempt to help automate the process of updating branches to Github Enterprise Server slack integration.
The main issue is that there is no feature to select _all_ branches (entering `*` as a wildcard does not seem to work).

Using a headless browser like `selenium` we can start automating the procedure of updating the list of branches being listened to. The idea moving forward is to be able to link this script to a git hook when creating a new local branch or pushing a new branch to origin (this could call for removing the branch from the list when branches are deleted).

Ideally for the hook idea to work the email and password could be saved in a config file so that the user doesn't need always enter their email/password each time. Though my only concern there is that I don't want to encourage storing passwords in plain-text, so this will have to be accounted for maybe by using some en-/decryption method.

## Dependencies

The script is developed/tested with Python 3.6.8.

### Linux

It is suggested to use a virtual environment, as the `selenium` package is needed.

1. Create a new virtual environment with: `virtualenv -p `which python3.6 venv`, activate it with `. venv/bin/activate`. You should see `(venv)` prepended to your `user@hostname`.

2. With your venv activated, install python packages in `requirements.txt`: `pip install -r requirements.txt`

3. Download ChromeDriver and copy to the root of this repo. If you want this script to run it has to be in the same folder as the `chromedriver` executable. Instructions originally found [here](https://blog.testproject.io/2018/02/20/chrome-headless-selenium-python-linux-servers/), how to get chromedriver summarized below.

```
cd /path/to/BranchListUpdater
wget https://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
```

## How to run

If all the dependencies were properly intalled and making sure your virtualenv is activated, you can run the script with: `./branch_list_updater.py`.
