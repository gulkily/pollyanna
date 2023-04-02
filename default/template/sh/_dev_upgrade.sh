#!/bin/sh

# this script performs an in-place upgrade, using git stash and git fetch
# shouldn't really be used, because it's easy enough to do it manually

echo this script should probably not be used
exit;

git stash

git fetch

git merge --no-edit

./_dev_clean_ALL_no_delay.sh

./build.sh

./pages.pl --system
