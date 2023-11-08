#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetQueuePage {
	require_once('dialog/query_as_dialog.pl');

	my $html =
		GetPageHeader('queue') .
		GetQueryAsDialog('queue', 'Queue') .
		GetQuerySqlDialog('queue') .
		GetPageFooter('queue')
	;

	if (GetConfig('setting/admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('setting/admin/php/enable')) {
			push @js, 'write_php';
		}
		$html = InjectJs($html, @js);
	}

	return $html;
} # GetQueuePage()

return 1;
