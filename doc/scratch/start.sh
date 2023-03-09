#!/bin/bash

# menu of common tasks

if [ -e ./build.sh ]
	then
		echo "Building..."
		time ./build.sh > /dev/null
		time ./config/template/perl/pages.pl -M welcome --php > /dev/null
		echo
		echo "Build finished."
		echo
fi

while true; do

	#echo "Please type a number and press Enter:"
	#echo "Press ^C (Ctrl+C) to exit"
	#echo
	echo "1. Start local server and open browser"
	echo "2. Clean and rebuild (data is retained)"
	echo "3. Reindex content: index.pl --chain --all"
	echo "4. Read access.log: access_log_read.pl --all"
	echo "5. Rebuild frontend: pages.pl --system"
	echo "6. Database CLI: sqlite3"
	echo "7. Database GUI: sqlitebrowser"
	echo "8. Turn ON debugging"
	echo "0. Install required packages (requires sudo)"

	echo

	if [ -f "config/debug" ]; then
		echo "=== Perl (backend) Debug mode is ON. Enter 9 to turn off. ==="
	fi

	if [ -f "config/setting/admin/js/debug" ]; then
		if grep -q "1" config/setting/admin/js/debug ; then
			echo "=== JavaScript (frontend) Debug mode is ON. Enter 9 to turn off. ==="
		fi
	fi

	if [ -f "config/setting/admin/php/debug" ]; then
		if grep -q "1" config/setting/admin/php/debug ; then
			echo "=== PHP (backend glue) Debug mode is ON. Enter 9 to turn off. ==="
		fi
	fi

	echo "Exit: press Ctrl+C"
	echo "Continue: Type number and press Enter:"

	read opt

	if [ -z $opt ]
		then
			opt=-1
	fi

	if [ $opt = 1 ]
		then
			./hike.sh start &
			./config/template/perl/pages.pl --system &
			sleep 1
			xdg-open http://localhost:2784/ &
	fi

	if [ $opt = 2 ] # rebuild
		then
			start=`date +%s`

			./clean.sh
			./build.sh
			killall lighttpd
			./config/template/perl/pages.pl -M read -M write -M settings -M profile -M help --php --js
			./hike.sh start &
			./index.pl --all --chain
			./config/template/perl/pages.pl -M chain

			end=`date +%s`
			runtime=$((end-start))

			echo Rebuild took $runtime seconds. Thanks!
			echo
	fi

	if [ $opt = 3 ]
		then
			time ./index.pl --all
	fi

	if [ $opt = 4 ]
		then
			time ./default/template/perl/access_log_read.pl --all
	fi

	if [ $opt = 5 ]
		then
			rm -vrf config/template/html
			rm -vrf config/template/js
			rm -vrf config/template/php
			time ./config/template/perl/pages.pl --system
	fi

	if [ $opt = 6 ]
		then
			sqlite3 -echo -cmd ".headers on" -cmd ".timeout 500" -cmd ".mode column" -cmd ".tables" cache/b/index.sqlite3
	fi

	if [ $opt = 7 ]
		then
			sqlitebrowser cache/b/index.sqlite3
	fi

  if [ $opt = 8 ]
  	then
  		echo 1 > config/debug
	fi

  if [ $opt = 9 ]
  	then
  		rm config/debug
  		rm config/setting/admin/js/debug
  		rm config/setting/admin/php/debug
	fi

  if [ $opt = 0 ]
  	then
  		./setup.pl
	fi

done