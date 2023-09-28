#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetTopicsPage {
	my %flags;
	$flags{'no_empty'} = 1;

	my $explainDialog = GetStringNoFallback('page_intro/topics');
	if ($explainDialog) {
		$explainDialog = '<fieldset><p>' . FormatForWeb($explainDialog) . '</fieldset></p>';
		$explainDialog = GetDialogX($explainDialog, 'Topics');
	}

	state $topicsPage = 
		GetPageHeader('topics') .
		GetQueryAsDialog('topics', 'Tags') .
		GetQueryAsDialog("SELECT item_title, file_hash FROM item_flat WHERE labels_list LIKE '%topic%'", 'Threads', '', \%flags) .
		$explainDialog .
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