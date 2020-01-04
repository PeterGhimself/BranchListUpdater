#!/usr/bin/env bash

new_branch_rgx="[new branch]"
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
PATH_TO_UPDATER="$SCRIPT_PATH/branch_list_updater.py"
NEW_BRANCHES="$SCRIPT_PATH/new_branches.txt"
LAST_PULL_LOG="SCRIPT_PATH/last_pull_result.log"

function join_by {
  local IFS="$1"
  shift
  echo "$*"
}

while :
do
  # loop infinitely
  pull_result=$(git pull 2>&1)
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

    echo "New branches detected: $branches"
    echo "Running branch_list_updater.py with arg: $branches"
    python $PATH_TO_UPDATER "$branches"
  else
    echo "No new branches detected"
  fi

  echo "sleeping for a minute"
  echo "zzzzzzzZzzzzzzzzzzzzz"
  sleep 1m
done

