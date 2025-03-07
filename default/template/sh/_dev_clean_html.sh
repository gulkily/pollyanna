#!/bin/sh

#./_dev_clean_html.sh

# this script will clean html to make room for new html

# mkdir trash
# mkdir trash.`date +%s`
# #todo first move to trash, then rm. reason: rm takes longer than mv
#echo this script is currently disabled because we are now parsing html files as data, and there is test data i want to keep
#exit;

echo _dev_clean_html.sh

echo "touch -t 197001010000 html/*.html html/*/*.html html/*/*/*.html"
touch -t 197001010000 html/*.html html/*/*.html html/*/*/*.html 2>/dev/null

echo "touch -t 197001010000 html/*.js html/*/*.js html/*/*/*.js"
touch -t 197001010000 html/*.js html/*/*.js html/*/*/*.js 2>/dev/null

echo find html -iname '*.html' -type f -exec rm {} \;
find html -iname '*.html' -type f -exec rm {} \;

echo rm -vf cache/b/pages/\*
rm -fv cache/b/pages/*

#echo find html -iname '*.html' -type f -mtime +5 -exec rm {} \;
#find html -iname '*.html' -type f -mtime +5 -exec rm {} \;

#echo find html -mtime +5 -exec ls {} \;
#find html -mtime +5 -exec ls {} \;

echo "================="
echo "Cleanup complete!"
echo "================="
#echo "Rebuilding with ./generate_html_frontend.pl in 3...";
#sleep 2

#echo "2... "
#sleep 2

#echo "1... "
#sleep 2

#echo "Running ./generate_html_frontend.pl"
#./generate_html_frontend.pl
#perl -T ./pages.pl --php --js -M welcome
