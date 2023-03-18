#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
# this welcome page displays all items which have a tag of 'approve' and a score of greater than 0
	my %params;
	$params{'where_clause'} = "WHERE tags_list LIKE '%approve%' AND item_score > 0";
	my @files = DBGetItemList(\%params);

	my $welcomePage =
		GetPageHeader('welcome') .
		GetItemListHtml(\@files) .
		GetPageFooter('welcome')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php'; # write.html
		}
		$welcomePage = InjectJs($welcomePage, @js)
	}

	return $welcomePage
}

1
