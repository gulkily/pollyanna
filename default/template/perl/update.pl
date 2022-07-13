#!/usr/bin/perl

# update.pl
# the purpose of this script is to
#   find new items
#   run IndexTextFile() on them
#   re-generate affected pages
#		via the task table

use strict;
use warnings FATAL => 'all';
use utf8;
use 5.010;

require './utils.pl';

# look for anything new in access log
system('./access_log_read.pl --all');

# index any files which haven't been indexed already
#system('./index.pl --all');

system('time find html/image -cmin -100 | grep \\\\.txt$ | head -n 20 | xargs ./index.pl');
system('time find html/txt -cmin -100 | grep \\\\.txt$ | head -n 20 | xargs ./index.pl');


# rebuild static html files if necessary
if (
	GetConfig('admin/pages/lazy_page_generation') &&
	GetConfig('admin/pages/rewrite') eq 'all' &&
	GetConfig('admin/php/enable')
) {
	system('./pages.pl --system');
} else {
	# regenerate all pages (may take a while)
	#system('./pages.pl --all');
	#system('./pages.pl --system');
	system('./pages.pl -M read');
	system('./pages.pl -M write');
	system('./pages.pl -M settings');
	system('./pages.pl --settings');
	system('./pages.pl -M profile');
	system('./pages.pl -M help');
	system('./pages.pl --system');
	WriteLog('update.pl: warning: not calling --all because it takes too long');
}

# update status of page queue
system('./query/page_touch.sh');

# update displayed timestamp
UpdateUpdateTime();

1;
