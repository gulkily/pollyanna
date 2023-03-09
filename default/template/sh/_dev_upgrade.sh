#!/bin/sh








git stash

git fetch

git merge --no-edit

./_dev_clean_ALL_no_delay.sh

./build.sh

./pages.pl --system
