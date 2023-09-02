#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetTopicsPage {
	my %flags;
	$flags{'no_empty'} = 1;

	state $topicsPage = 
		GetPageHeader('topics') . 
		GetQueryAsDialog('topics', 'Topics') .
		GetQueryAsDialog("SELECT item_title, file_hash FROM item_flat WHERE tags_list like '%topic%'", 'Topics', '', \%flags) .
		GetPageFooter('topics')
	;

	my @js = qw(utils settings avatar voting table_sort profile timestamp);
	if (GetConfig('setting/html/reply_cart')) {
		push @js, 'reply_cart';
	}
	$topicsPage = InjectJs($topicsPage, @js);

	return $topicsPage;
} # GetTopicsPage()

1;