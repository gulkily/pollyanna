#!/bin/sh

./index.pl --all
./pages.pl -M read
./pages.pl --queue
./pages.pl --system

