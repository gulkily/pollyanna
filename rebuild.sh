#!/bin/sh

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
