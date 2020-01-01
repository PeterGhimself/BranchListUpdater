#!/usr/bin/env bash

new_branch_rgx="[new branch]"
PATH_TO_UPDATER="/home/$USER/Programming/fun/BranchListUpdater/branch_list_updater.py"

while :
do
  # loop infinitely
  pull_result=$(git pull 2>&1)
  echo "$pull_result"
  echo "$pull_result" > example.txt

  if [[ $pull_result == *"$new_branch_rgx"* ]]; then
    #@TODO: handle multiple branch names

    new_branch_dirty=$(echo "$pull_result" | grep -o -P '(?<= ).*(?= ->)')

    echo "new_branch_dirty: $new_branch_dirty" > new_branch.txt

    # remove trailing whitespace
    sed -i '' -e's/[ \t]*$//' "new_branch.txt"
    # get just the last word
    sed -i 's/.* //' "new_branch.txt"
    new_branch=`cat new_branch.txt`
    echo "New branch detected: $new_branch"
    echo "Running branch_list_updater.py with arg: $new_branch"
    python $PATH_TO_UPDATER $new_branch
  else
    echo "No new branches detected"
  fi

  echo "sleeping for a minute"
  echo "zzzzzzzZzzzzzzzzzzzzz"
  sleep 1m
done

