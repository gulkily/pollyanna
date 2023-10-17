#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetQueuePage {
	require_once('dialog/query_as_dialog.pl');

	my $html =
		GetPageHeader('queue') .
		GetQueryAsDialog('queue') .
		GetQuerySqlDialog('queue') .
		GetPageFooter('queue')
	;

	return $html;

	#todo js inject, etc
}

return 1;
