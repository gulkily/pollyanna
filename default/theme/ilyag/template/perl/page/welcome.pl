#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
# this welcome page displays all items which have a tag of 'approve' and a score of greater than 0
	my %params;
	$params{'where_clause'} = "WHERE tags_list LIKE '%approve%' AND score > 0";
	my @files = DBGetItemList(\%params);
	return
		GetPageHeader('welcome') .
		GetItemListHtml(\@files) .
		GetPageFooter('welcome')
	;
}

1
