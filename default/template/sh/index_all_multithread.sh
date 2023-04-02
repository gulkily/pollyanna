#!/bin/sh

# multi-threaded indexing of all .txt files in html/txt

echo this script may lock up your system, so it is disabled by default
exit

./index.pl --chain

N=256
C=0
(
for thing in `find html/txt | grep \\\.txt$` ; do
   ((i=i%N)); ((i++==0)) && wait
   ./index.pl "$thing" &
   ((C++))
   echo $i $C
done
)
