# BranchListUpdater

An attempt to help automate the process of updating branches to Github Enterprise Server slack integration.
The main issue is that there is no feature to select _all_ branches (entering `*` as a wildcard does not seem to work).

Using a headless browser like `selenium` we can start automating the procedure of updating the list of branches being listened to. The idea moving forward is to be able to link this script to a git hook when creating a new local branch or pushing a new branch to origin (this could call for removing the branch from the list when branches are deleted).

Ideally for the hook idea to work the email and password could be saved in a config file so that the user doesn't need always enter their email/password each time. Though my only concern there is that I don't want to encourage storing passwords in plain-text, so this will have to be accounted for maybe by using some en-/decryption method.

## Cloning

Make sure to run `git update-index --skip-worktree slackconfig.py` after cloning to ensure that the changes to the config file won't be tracked.

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
If you wish to add a specificly named branch to the list, pass it in an argument like so: `./branch_list_updater.py my-awesome-branch-name`.
You may either store your credentials in `slackconfig.py` or type them in when running the program (each time). If the config file is filled those values will be used by default.

**WARNING:** Currently credentials are stored in plain text in `slackconfig.py`. Hopefully this method will be replaced with a slightly more secure feature: Creating this config file dynamically so that the password entered by the user can be encrypted before being saved.
That being said, the changes made to `slackconfig.py` won't be tracked on git (thanks to `git update-index --assume-unchanged <path-to-file>`).
It is however recommended to change the user/group policy for `slackconfig.py` so that it's contents can only be accessed with root access. The file can't be 'shipped' this way since git does not track file ownership changes so you will have to do this manually yourself.
This can be done with: `chmod 111 slackconfig.py` which will only allow the user/group to execute the file. Reading/writing of the file will only work by using root priveleges.
