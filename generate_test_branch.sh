#!/usr/bin/env bash
branch_name="test$1"

git checkout master
git branch $branch_name
git checkout $branch_name
push_result=$(git push -u origin $branch_name 2>&1)

echo "$push_result"
echo "$push_result" > exp.txt

echo "new branch line:"
echo "$push_result" | grep -o -P '(?<=[new branch]).*(?=->)'

new_branch_dirty=$(echo "$push_result" | grep -o -P '(?<= ).*(?= ->)')

echo "new_branch_dirty: $new_branch_dirty" > new_branch.txt
echo "new_branch_dirty: $new_branch_dirty" > new_branch_backup.txt
echo "cat new_branch.txt: $new_branch_dirty"

#echo "$new_branch_dirty" > new_branch.txt

sed -i 's/.* //' "new_branch.txt"
new_branch_clean=`cat new_branch.txt`
echo "new_branch_clean: $new_branch_clean"

#new_branch_clean=$(echo "$new_branch_dirty" | cut -32-)
#echo "new_branch_clean?: $new_branch_clean"

git checkout master
