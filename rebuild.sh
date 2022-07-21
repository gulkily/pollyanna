#!/bin/sh

txtCount=$(find html/txt -type f | wc -l) #Count files and store in a variable
#if ((txtCount -ge 10000));
if [ "$txtCount" -ge 100 ];
	then
		echo ===
		echo Refusing to rebuild because more than 100 files of data
		echo Use --override or -O to override NOT IMPLEMENTED YET
		echo ===
		exit
fi

./clean.sh
sleep 1
./build.sh
echo Indexing chain...
sleep 1
./index.pl --chain
echo Indexing data...
sleep 1
./index.pl --all
echo Making frontend essentials...
sleep 1
./pages.pl --system -M chain --listing
