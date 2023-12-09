#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetHistoryPage { # returns history page
	require_once('dialog/query_as_dialog.pl');
	#todo if this fails, it is only a warning in log.log/

	my $html =
		GetPageHeader('history') .
		GetTemplate('html/maincontent.template') .
		GetQueryAsDialog('history', 'History') .
		GetPageFooter('history')
	;

	# add InjectJs(...) #todo

	return $html;
}

1;
