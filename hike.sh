#!/bin/bash

# hike.sh is the script that lets you do most things
# if using bash, run `source hike.sh` to activate the "hike" command
# run `hike help` to see available commands

# set -x
# uncomment for debugging

if [ ! $1 ]
	then
		set 1=help
fi

# if user precedes command with 'debug'
# set debug flag to 1, so that we can remember to turn it off at the end of this script
# write a 1 to the config/debug file
# shift all arguments forward by one
# if log/log.log exists, rename it to log/log.log.`date +%s`
if [ $1 = debug ]
  then
    debug=1
    if [ -e log/log.log ]
      then
        mv log/log.log log/log.log.`date +%s`
    fi
    echo 1 > config/debug
    shift
fi

if [ ! $1 ]
	then
		set 1=help
fi

# hike set
if [ $1 = set ]
	then
		default/template/perl/script/set.pl $2 $3
		exit
fi

if [ $1 = test ]
	then
		echo testing 1 2 3
fi

if [ $1 = stats ] # hike stats
	then
		echo text files: `find html/txt -type f -name '*.txt' | wc -l`
		echo image files: `find html/image -type f | wc -l`
		echo item table: `sqlite3 ./cache/b/index.sqlite3 "select count(*) from item"`
		echo chain log: `wc -l html/chain.log`
		echo "commit: $(git log -1 --format=%cd)"
		echo "age: $(( ($(date +%s) - $(git log -1 --format=%at)) / 86400 )) days"
		echo space usage: `du -sh .`
		#echo chain table: `count(*) from item_attribute where attribute = 'chain_sequence';` entries
		echo ==================
fi

if [ $1 = status ]
	then
		ps aux | grep lighttpd
fi

if [ $1 = version ]
	then
		sqlite3 --version
		git --version
		perl --version
		php --version
		bash --version
		#perl -e 'print "Perl " . $^V . "\n"'
		echo '==='
		git rev-parse HEAD
    echo ==================
    echo "pollyanna" `git rev-parse HEAD | cut -c 1-8`
    echo ==================
fi

if [ $1 = build ] # hike build
	then
		./default/template/sh/build.sh
		echo
		echo "                            ==============="
		echo "                            build complete!"
		echo "              ==============="
		echo "              build complete!"
		echo "==============="
		echo "build complete!"
fi

if [ $1 = clean ] # hike clean
	then
	  if [ "$2" = all ] # hike clean all
	    then
        ./default/template/sh/clean.sh
        echo ""
        echo "==============="
        echo "clean complete!"
        echo "                            ==============="
        echo "                            clean complete!"
    fi
	  if [ "$2" = html ] # hike clean html
	    then
        ./default/template/sh/_dev_clean_html.sh
        echo ""
        echo "==============="
        echo "clean html complete!"
        echo "                            ===================="
        echo "                            clean html complete!"
    fi
    if [ ! "$2" ]
      then
        echo "########################################################## "
        #echo "AAAAA TTTTT TTTTT EEEEE N   N TTTTT IIIII OOOOO N   N !!!  "
        #echo "A   A   T     T   E     NN  N   T     I   O   O NN  N !!!  "
        #echo "AAAAA   T     T   EEEEE N N N   T     I   O   O N N N !!!  "
        #echo "A   A   T     T   E     N  NN   T     I   O   O N  NN      "
        #echo "A   A   T     T   EEEEE N   N   T   IIIII OOOOO N   N !!!  "
        #echo "########################################################## "
        echo clean all = clean entire installation, including log files
        echo clean html = clean html frontend files only
        echo "########################################################## "
    fi
fi

if [ $1 = rebuild ] # hike rebuild
	then
		./default/template/sh/rebuild.sh
fi

if [ $1 = reindex ]
  # remove all 'file has been indexed' flags in cache/b/indexed/
  # reindex all data files
  then
    echo this will remove item_attributes table. are you sure?
    sleep 3
    sqlite3 cache/b/index.sqlite3 "delete from item_attribute";
    rm -v cache/b/indexed/*
    perl -T ./config/template/perl/index.pl --chain
    perl -T ./config/template/perl/index.pl --all
fi

if [ $1 = index ]
  # if a parameter is specified, it looks for that file/data
	then
		if [ $2 ]
			then
				perl -T ./config/template/perl/index.pl $2
		fi
		if [ ! $2 ]
		  # if no parameter is specified, it does a full index
			then
				perl -T ./config/template/perl/index.pl --chain
				sleep 1
				perl -T ./config/template/perl/index.pl --all
		fi
fi

if [ $1 = refresh ] # hike refresh
	then
		perl -T default/template/perl/script/template_refresh.pl

		if [ ! -e config/template/perl/pages.pl ]
			then
				cp -v default/template/perl/pages.pl config/template/perl/pages.pl
		fi
		if [ ! -e pages.pl ]
			then
				ln -sv config/template/perl/pages.pl pages.pl
		fi

		if [ ! -e config/template/perl/index.pl ]
			then
				cp -v default/template/perl/index.pl config/template/perl/index.pl
		fi
		if [ ! -e index.pl ]
			then
				ln -sv config/template/perl/index.pl index.pl
		fi

		if [ ! -e config/template/perl/utils.pl ]
			then
				cp -v default/template/perl/utils.pl config/template/perl/utils.pl
		fi
		if [ ! -e utils.pl ]
			then
				ln -sv config/template/perl/utils.pl utils.pl
		fi

		./default/template/sh/_dev_clean_html.sh
		./pages.pl --php #todo this should not be necessary
fi

if [ $1 = frontend ]
	then
		default/template/sh/_dev_clean_html.sh
		./config/template/perl/pages.pl --system
		#todo every item in the menu should be built here
fi

if [ $1 = pages ] # hike pages
	then
		perl -T ./config/template/perl/pages.pl --queue
		# should it be config? #todo
fi

if [ $1 = page ] # hike page
	then
    perl -T ./config/template/perl/pages.pl -M $2 $3
fi

if [ $1 = info ]
  then
    find . | grep $2 | xargs cat | less
fi

if [ $1 = start ] # hike start #
	then
		if [ ! -e config/template/perl/server_local_lighttpd.pl ]
			then
				/bin/sh ./default/template/sh/build.sh
		fi
		echo 1 > config/setting/admin/lighttpd/server_started
		perl -T config/template/perl/server_local_lighttpd.pl
		rm config/setting/admin/lighttpd/server_started
fi

if [ $1 = setup ] # hike setup
  then
    /bin/sh ./default/template/sh/enable_features.sh
fi

if [ $1 = startpython ] # hike startpython
	then
		if [ ! -e config/template/perl/server_local_python.pl ]
			then
				/bin/sh ./default/template/sh/build.sh
		fi
		#todo echo 1 > config/setting/admin/lighttpd/server_started
		perl -T config/template/perl/server_local_python.pl
		#todo rm config/setting/admin/lighttpd/server_started
fi

if [ $1 = stop ]
	then
		killall -v lighttpd
fi

if [ $1 = alog ]
	then
		./default/template/perl/script/access_log_read.pl --all
		echo About to index and build pages...
		sleep 3
		perl -T ./config/template/perl/index.pl --all
		./config/template/perl/pages.pl --all
fi
if [ "$1" = iplog ]; then  # Added quotes around $1 for safer comparison and a semicolon
    if [ -z "$2" ]; then  # Changed !$2 to -z "$2" to check if $2 is empty
        echo "usage: hike iplog [load|drop]"
    else
        if [ "$2" = load ]; then  # Added quotes around $2 and a semicolon
            echo loading remote address log into sqlite table
            perl -T default/template/perl/script/remote_addr_ip_log_load.pl
            echo use 'hike remote drop' to remove remote address table
        elif [ "$2" = drop ]; then  # Changed second 'if' to 'elif'
            echo dropping remote address table
            perl -T default/template/perl/script/remote_addr_ip_log_drop.pl
        fi  # Added this 'fi' to close the inner 'if/elif' block
    fi
else
    # This part seems to be intentionally left empty to handle cases where $1 is not 'iplog'
    :  # A null command (colon) can be used as a placeholder if desired
fi

if [ $1 = db ]
	then
		sqlite3 -echo -cmd ".headers on" -cmd ".timeout 500" -cmd ".mode column" -cmd ".tables" cache/b/index.sqlite3
fi

if [ $1 = guidb ]
	then
		echo 'Opening database browser...'
		sqlitebrowser cache/b/index.sqlite3
fi

if [ $1 = sweep ]
	then
		perl -T ./config/template/perl/index.pl --sweep
fi

if [ $1 = open ]
	then
		./default/template/perl/browser_open.pl
		#todo reduce hard-coding
fi

if [ $1 = 'archive' ]
	then
	  if [ "$2" = all ] # archive all
      then
        ./default/template/perl/script/_dev_archive.pl
        sleep 1
        perl -T ./config/template/perl/index.pl --sweep
        perl -T ./config/template/perl/index.pl --all
        perl -T ./config/template/perl/index.pl --all
        ./hike.sh frontend
    fi

    if [ "$2" = list ] # archive list
      then
        mc ./archive html/txt
        echo Indexing new items...
        sleep 1
        perl -T ./config/template/perl/index.pl --all
        perl -T ./config/template/perl/index.pl --all
    fi

    if [ ! "$2" ]
      then
        echo archive all = archive all
        echo archive list = list archive
    fi
fi

if [ ! $1 ]
	then
		echo source hike.sh = enable these commands
		echo hike clean = clean including templates
		echo hike build = build base
		echo hike start = start local server
		echo hike archive = display archiving commands
		echo hike help = see more commands
fi

if [ $1 = help ]
	then
    echo ==================
    echo "pollyanna" `git rev-parse HEAD | cut -c 1-8`
    echo ==================
		echo source hike.sh = enable these commands
		echo hike clean = clean including templates
		echo hike build = build base
		echo hike setup = enable commonly-used features
		echo hike start = start local server
		echo hike archive = display archiving commands
		echo hike help = see more commands
		echo hike index = index chain and data
		echo hike reindex = reindex all data
		echo hike info = info on item by hash
		echo hike frontend = refresh frontend
		echo hike refresh = refresh templates
		echo hike alog = import access log
		echo hike iplog = import/drop remote ip log
		echo hike help = see more commands
		echo hike db = open sqlite3 command line
		echo hike guidb = open sqlitebrowser
		echo hike sweep = sweep deleted items
		echo hike open = open browser
		echo hike rebuild = clean, build, and index
		echo hike test = testing 1 2 3
		echo hike version = show version
fi

# if debug flag is set, turn it off
if [ $debug ]
  then
    rm config/debug
fi

alias hike='bash hike.sh'
