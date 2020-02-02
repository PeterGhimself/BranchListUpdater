#!/usr/bin/env bash

join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

timestamp() {
  date +"%Y-%m-%d %T"
}

new_branch_rgx="[new branch]"
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
PATH_TO_UPDATER="$SCRIPT_PATH/branch_list_updater.py"
NEW_BRANCHES="$SCRIPT_PATH/new_branches.txt"
LAST_PULL_LOG="$SCRIPT_PATH/last_pull_result.log"
# log events on branch detection
EVENTS_LOG="$SCRIPT_PATH/events.log"
# log extra (optional) post-event scripts
POST_EVENTS_LOG="$SCRIPT_PATH/post_events.log"

# extra custom scripts to be run when new branches detected
# the script names are assumed to be provided line by line
# as well as providing their respective shebang lines
SCRIPTS="$SCRIPT_PATH/scripts.txt"

# will default to the BranchListUpdater repo if none given
TARGET_REL_PATH="$1"
TARGET_REPO="$SCRIPT_PATH/$TARGET_REL_PATH"

# default is 1m
SLEEP_TIME="1m"

# for fun
SLEEPY_DOG="💤(-ᴥ-ʋ)"

# flag for updating the list of branches
FLAG_NO_UPDATE="--no-update"
FLAG_NO_UPDATE_SHORTCUT="-n"
NO_UPDATE_MSG="Running without updating"
update=true

USAGE="usage: ./new_branch_watchdog.sh [relpath] [-2m] [--no-update|-n]
            relpath: relative path to repository root
            2m: check at 2 minute intervals (default: 1m)
            $FLAG_NO_UPDATE or $FLAG_NO_UPDATE_SHORTCUT: for not updating the branch list but still logging new branch events

The arguments must be provided in the order shown.
"

if [[ $# -eq 2 ]]
then
    #@TODO: add validation?
    SLEEP_TIME="$2"
    echo "Using provided sleep time: $SLEEP_TIME"
else
    echo "Using default sleep time: $SLEEP_TIME"
fi

if [ -d "$TARGET_REPO" ]
then
    echo "Using target repo: $TARGET_REPO"
else
    echo "Error: Directory $TARGET_REPO does not exist, aborting."
    echo "$USAGE"
    exit 1
fi

# check if flag --no-update or -n are present
while test $# -gt 0
do
    case "$1" in
        --no-update) echo "$NO_UPDATE_MSG"; update=false
            ;;
        -n) echo "$NO_UPDATE_MSG"; update=false
            ;;
    esac
    shift
done

while :
do
  # loop infinitely
  cd "$TARGET_REPO"
  # ensure we always pull from master
  git checkout master
  pull_result=$(git pull 2>&1)
  cd "$SCRIPT_REPO"
  echo "$pull_result"
  echo "$pull_result" > $LAST_PULL_LOG

  if [[ $pull_result == *"$new_branch_rgx"* ]]; then
    # initial parse
    new_branch_dirty=$(echo "$pull_result" | grep -o -P '(?<= ).*(?= ->)')

    # temp storage
    echo "$new_branch_dirty" > $NEW_BRANCHES

    # remove trailing whitespace
    sed -i '' -e's/[ \t]*$//' $NEW_BRANCHES
    # get just the last word
    sed -i 's/.* //' $NEW_BRANCHES

    # handle multiple branch names (as they appear line by line)
    branches=()
    while read branch;
      do branches+=($branch);
    done < $NEW_BRANCHES
    # join by delimiter ',' as branch_list_updater.py expects it
    branches=`join_by , ${branches[@]}`

    feedback="New branches detected: $branches"

    # return back home to run optional scripts
    cd $SCRIPT_PATH

    if [[ $update = true ]]; then
        feedback+=$'\nRunning branch_list_updater.py with arg: '
        feedback+="$branches"
        feedback+=$'\nStarted job at: '
        feedback+=`timestamp`
        #feedback+=$'\n'
        echo "$feedback" >> $EVENTS_LOG ; echo "$feedback"
        python $PATH_TO_UPDATER "$branches"
        feedback="Finished job at: "
        feedback+=`timestamp`
        feedback+=$'\n'
        echo "$feedback" >> $EVENTS_LOG ; echo "$feedback"
        
        if [ -f "$SCRIPTS" ]
        then
            echo "$SCRIPTS found, running custom jobs"
            while read p; do
                . "$SCRIPT_PATH/$p" > $POST_EVENTS_LOG
            done <"$SCRIPTS"
        else
	    echo "$SCRIPTS not found, no custom jobs to run"
	fi
    fi
  else
    echo "No new branches detected"
  fi

  echo "sleeping for: $SLEEP_TIME"
  echo "$SLEEPY_DOG"
  echo "zzzzzzzzzzZzZzZzzzzz"
  sleep "$SLEEP_TIME"
done

