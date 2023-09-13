#!/bin/sh

# was previously called by 'hike refresh' command
# not really used anymore, should probably remove it
# #todo
# use template_refresh.pl instead

# notification

echo "use this script only for reference"
exit


echo ==================================
echo Resetting templates from: default/
echo ==================================
echo All queues will also be refreshed.
echo ==================================
echo You have 3 seconds to press Ctrl+C
echo ==================================
echo 3
sleep 1
echo 2
sleep 1
echo 1
sleep 1

mkdir checksum

need_clean_template=0
need_clean_html=0
need_make_php=0
need_clean_query=0
need_clean_theme=0

# default/template
find default/template -type f | sort | xargs sha1sum | sha1sum | cut -d ' ' -f 1 > checksum/default_template_checksum_new
if ! diff checksum/default_template_checksum_new checksum/default_template_checksum
then
	# if checksum doesn't match last recorded, clear template cache
	echo default_template_checksum
	need_clean_template=1
	need_clean_html=1
	mv -v checksum/default_template_checksum_new checksum/default_template_checksum
fi

# default/template/php
find default/template/php -type f | sort | xargs sha1sum | sha1sum | cut -d ' ' -f 1 > checksum/php_templates_checksum_new
if ! diff checksum/php_templates_checksum_new checksum/php_templates_checksum
then
	echo php_templates_checksum
	need_clean_template=1
	need_make_php=1
	mv -v checksum/php_templates_checksum_new checksum/php_templates_checksum
fi

# default/query
find default/query -type f | sort | xargs sha1sum | sha1sum | cut -d ' ' -f 1 > checksum/default_query_checksum_new

if ! diff checksum/default_query_checksum_new_new checksum/default_query_checksum
then
	echo default_query_checksum
	need_clean_query=1
	need_clean_html=1
	mv -v checksum/default_query_checksum_new checksum/default_query_checksum
fi

# default/query
find default/theme -type f | sort | xargs sha1sum | sha1sum | cut -d ' ' -f 1 > checksum/default_theme_checksum_new
if ! diff checksum/default_theme_checksum_new checksum/default_theme_checksum
then
	echo default_theme_checksum
	need_clean_theme=1
	need_clean_html=1
	mv -v checksum/default_theme_checksum_new checksum/default_theme_checksum
fi

# config
find config -type f | sort | xargs sha1sum | sha1sum | cut -d ' ' -f 1 > checksum/config_checksum_new
if ! diff checksum/config_checksum_new checksum/config_checksum
then
	echo config_checksum
	need_clean_html=1
	mv -v checksum/config_checksum_new checksum/config_checksum
fi


if [ $need_clean_template = 1 ]; then
  ./_dev_clean_template.sh;
fi

if [ $need_clean_query = 1 ]; then
  ./_dev_clean_query.sh;
fi

if [ $need_clean_theme = 1 ]; then
  ./_dev_clean_theme.sh;
fi
if [ $need_clean_html = 1 ]; then
  ./_dev_clean_html.sh;
  need_make_php=1;
  need_make_js=1;
fi

if [ $need_make_php = 1 ]; then
  ./pages.pl --php
fi

if [ $need_make_js = 1 ]; then
  ./pages.pl --js
fi



# html/image
find html/image -type f | sort | xargs sha1sum | sha1sum | cut -d ' ' -f 1 > checksum/html_image_checksum_new

if ! diff checksum/html_image_checksum_new checksum/html_image_checksum
then
	echo html_image_checksum
	find html/image -cmin -100 | grep \\.txt$ | xargs ./index.pl
	mv -v checksum/html_image_checksum_new checksum/html_image_checksum
fi

# html/txt
find html/txt -type f | sort | xargs sha1sum | sha1sum | cut -d ' ' -f 1 > checksum/html_txt_checksum_new

if ! diff checksum/html_txt_checksum_new checksum/html_txt_checksum
then
	echo html_txt_checksum
	find html/txt -cmin -100 | grep \\.txt$ | head -n 35 | xargs ./index.pl
	mv -v checksum/html_txt_checksum_new checksum/html_txt_checksum
fi

# access log
sha1sum log/access.log | cut -d ' ' -f 1 > checksum/access_log_checksum_new
if ! diff checksum/access_log_checksum_new checksum/access_log_checksum
then
	echo access_log_checksum
	./access_log_read.pl --all
	mv -v checksum/access_log_checksum_new checksum/access_log_checksum
fi

if [ $need_clean_html = 1 ]; then
  # warm up initial page loads
  ./pages.pl --system
fi
