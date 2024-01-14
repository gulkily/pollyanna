#!/bin/sh

txtCount=$(find html/txt -type f | wc -l) #Count files and store in a variable
if [ "$txtCount" -ge 200 ] && [ -e cache/b/index.sqlite3 ] ;
	then
		echo =======================================================
		echo ATTENTION! ATTENTION! ATTENTION! ATTENTION! ATTENTION!
		echo Refusing to rebuild because more than 100 files of data
		echo Use these: \`hike clean\; hike build\; hike index\'
		echo If this is what you really want to do.
		echo =======================================================
		echo \$ find html/txt -type f \| wc -l
		find html/txt -type f | wc -l
		echo =======================================================
		exit 1
fi

./default/template/sh/clean.sh
sleep 1
./default/template/sh/build.sh
echo Indexing chain...
sleep 1
perl -T ./index.pl --chain
echo Indexing data...
sleep 1
perl -T ./index.pl --all
echo Making frontend essentials...
sleep 1
./config/template/perl/pages.pl --php -M chain --listing -M new
