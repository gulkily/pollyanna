#!/bin/sh

# use this script to update the queues on macOS
# lighttpd = 1; php = 0

./hike.sh alog
time ./index.pl --all
./hike.sh frontend
./pages.pl -M new -M chain -M settings -M stats -M threads
./pages.pl --all
