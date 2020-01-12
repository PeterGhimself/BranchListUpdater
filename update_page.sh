#!/usr/bin/env bash

# the only dependency needed for this script to work properly is sshpass
# which can be installed with yum/dnf/apt-get install sshpass
# tested on ubuntu 16.04

EVENTS_LOG="events.log"
PROPERTIES=".app.properties"

if [ -f "$EVENTS_LOG" ]
then
    echo "$EVENTS_LOG found"
else
    echo "$EVENTS_LOG not found, exiting script"
    exit 1
fi

# since (Bourne) shell variables cannot contain dots they can be replaced by underscores
if [ -f "$PROPERTIES" ]
then
    echo "$PROPERTIES found"
    . "$PROPERTIES"
    echo "... and loaded"
else
    echo "$PROPERTIES not found, exiting script"
    exit 1
fi

MAIN_PAGE="index.php"
events_str=""
# save current version of page
current_page=$(wget "$url/~$username" -q -O -)
echo "$current_page" > "$MAIN_PAGE"

while read line; do
    events_str+="$line\n"
done < $EVENTS_LOG

echo "events.log:"
cat "$EVENTS_LOG"
echo ""

# this works for now since there's only one pre tag pair on the page on separate lines
# first delete everything between <pre>s
awk '/<pre>/{p=1;print}/<\/pre>/{p=0}!p' "$MAIN_PAGE" > tmp && mv tmp "$MAIN_PAGE"
sed -i 's/\<pre>.*/pre>/' "$MAIN_PAGE" # remove everything after <pre>
sed -i 's/^.*<\/pre>/<\/pre>/p' "$MAIN_PAGE" # remove everything before </pre>
sed -i -e '0,/^<\/pre>/{//d;}' "$MAIN_PAGE" # clean up extra <pre> added from previous sed call
sed -i -e '0,/^<\/pre>/{//d;}' "$MAIN_PAGE" # get rid of last one
sed -i 's/\<pre>/<pre><\/pre>/' "$MAIN_PAGE" # add </pre> after <pre> on same line for next sed call to work
sed -i -e 's/\(<pre>\).*\(<\/pre>\)/<pre>'"$events_str"'<\/pre>/' "$MAIN_PAGE" # insert the new branch logs
sed -i -e 's/\([<]\)\1\+/\1/g' "$MAIN_PAGE" # final clean up (not sure why this happens)

echo "new page:"
cat "$MAIN_PAGE"
echo ""

sshpass -p "$password" scp $MAIN_PAGE $username@$host:$apache_dir/$username

exit 0
