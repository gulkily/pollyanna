#!/bin/sh

rm -vrf config/template/
rm -vrf config/theme/*/template/
rm -vrf config/theme/*/additional.css
rm -vrf *.pl
rm -vrf cache/
rm -vrf html/*.html html/*/*.html html/*/*/*.html html/*/*/*/*.html
rm -vrf html/*.php html/*.js
rm -vrf log/log.log
find html -type d -empty -delete

echo ===
echo Verify:
ls config/template config/theme/*/template/ *.pl cache/ html/*.html html/*.php log/log.log

echo ===
echo To rebuild, use "./build.sh" or "source hike.sh"

if [ -e config/debug ]
	then
		echo DEBUG MODE IS ON \$ find config \| grep debug\$
fi
