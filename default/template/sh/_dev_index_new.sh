#!/bin/sh

find html/image -cmin -3 | xargs ./index.pl
find html/txt -cmin -3 | grep \\.txt$ | xargs ./index.pl

