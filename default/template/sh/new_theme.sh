#!/bin/sh

# create directories for a new theme

if [ ! $1 ] ; then
	echo theme name not specified, exiting
	exit
fi

if [ -e default/theme/$1 ] ; then
	echo theme already seems to exist: default/theme/$1
	exit;
fi

echo creating new theme $1

mkdir -v default/theme/$1
mkdir -v default/theme/$1/setting
mkdir -v default/theme/$1/string
mkdir -v default/theme/$1/string/en
mkdir -v default/theme/$1/string/en/item_attribute
mkdir -v default/theme/$1/string/en/menu
mkdir -v default/theme/$1/string/en/page_intro
mkdir -v default/theme/$1/template
mkdir -v default/theme/$1/template/css
mkdir -v default/theme/$1/template/html
mkdir -v default/theme/$1/template/html/dialog
mkdir -v default/theme/$1/template/html/form
mkdir -v default/theme/$1/template/html/form/write
mkdir -v default/theme/$1/template/html/item
mkdir -v default/theme/$1/template/html/page
mkdir -v default/theme/$1/template/html/page/faq
mkdir -v default/theme/$1/template/html/page/thanks
mkdir -v default/theme/$1/template/html/widget
mkdir -v default/theme/$1/template/html/window
mkdir -v default/theme/$1/template/js
mkdir -v default/theme/$1/template/list
mkdir -v default/theme/$1/template/perl
mkdir -v default/theme/$1/template/perl/page
mkdir -v default/theme/$1/template/perl/dialog
mkdir -v default/theme/$1/template/query
mkdir -v default/theme/$1/template/sh
mkdir -v default/theme/$1/template/tagset

touch default/theme/$1/additional.css ; ls default/theme/$1/additional.css