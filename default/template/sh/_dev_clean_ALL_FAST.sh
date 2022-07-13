#!/bin/sh

# fast clean designed for being run from upgrade script
# leaves system in basic functional state, which is enough for php + lazy mode

echo ====================================
echo Script about to reset configuration!
echo ====================================
echo You have 0 seconds to press Ctrl + C
echo ====================================

# MYDATE=`date +%s`
# mkdir trash
# mkdir trash.$MYDATE

echo "rm -v cron.lock"
rm -v cron.lock

echo "rm -rf cache"
rm -rf cache

echo "rm -rf html/*.html html/*/*.html html/*/*/*.html"
rm -rf html/*.html html/*/*.html html/*/*/*.html

echo "rm -rf html/*.js html/*/*.js html/*/*/*.js"
rm -rf html/*.js html/*/*.js html/*/*/*.js

echo "rm -rf html/*.php html/*/*.php html/*/*/*.php"
rm -rf html/*.php html/*/*.php html/*/*/*.php

echo "rm -rf html/*.xml html/*/*.xml"
rm -rf html/*.xml html/*/*.xml

echo "rm -rf html/.htaccess"
rm -rf html/.htaccess

echo "rm -rf html/*.zip"
rm -rf html/*.zip

echo "rm -rf html/rss.xml html/rss.txt"
rm -rf html/rss.xml html/rss.txt

echo "rm -rf config/template/query/*"
rm -rf config/template/query/*

echo "rm -rf config/string/*"
rm -rf config/string/*

echo "rm -rf config/theme/*"
rm -rf config/theme/*

echo "rm -rf config/admin/my_version"
rm -rf config/admin/my_version

echo "find html -type d -empty -delete"
find html -type d -empty -delete

echo "touch html/post.html"
touch html/post.html

echo "rm -v log/log.log"
rm -v log/log.log

echo "mkdir -p html/txt"
mkdir -p html/txt

echo "================="
echo "Cleanup complete!"
echo "================="

echo "Rebuilding with ./build.pl..."

echo "Running ./build.pl"
perl -T ./build.pl

echo "==============="
echo "Build complete!"
echo "==============="



