#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetTopicsPage { # /topics.html
	my %flags;
	$flags{'no_empty'} = 1;

    #PageIntro
	#my $introDialog = GetStringNoFallback('page_intro/topics');
	#if ($introDialog) {
	#	$introDialog = '<fieldset><p>' . FormatForWeb($introDialog) . '</fieldset></p>';
	#	$introDialog = GetDialogX($introDialog, 'Introduction');
	#}

	state $topicsPage = 
		GetPageHeader('topics') .
		GetQueryAsDialog('topics', 'Topics') .
		#$introDialog . #PageIntro
		GetQuerySqlDialog('topics') .
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
