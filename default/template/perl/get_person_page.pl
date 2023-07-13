#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPersonPage { # $personName
	my $personName = shift;

	if ($personName =~ m/^([a-zA-Z0-9]+)$/) { # #todo use a validator function instead of regex
		$personName = $1;
		WriteLog('GetPersonPage: sanity check passed, $personName = ' . $personName);
	} else {
		WriteLog('GetPersonPage: warning: sanity check failed on $personName; caller = ' . join(',', caller));
		return '';
	}

	#todo add person.template

	my %params;
	$params{'where_clause'} = "WHERE file_hash IN (SELECT file_hash FROM item_flat WHERE author_key IN(SELECT author_key FROM author_flat WHERE author_alias = '$personName'))";
	my @files = DBGetItemList(\%params);

	my $itemList = GetItemListHtml(\@files);

	my $html =
		GetPageHeader('person') .
		$itemList .
		GetPageFooter('person')
	;

	my @jsToInject = qw(settings timestamp voting utils profile);
	if (GetConfig('setting/admin/js/fresh')) {
		push @jsToInject, 'fresh';
	}
	if (GetConfig('setting/html/reply_cart')) {
		push @jsToInject, 'reply_cart';
	}
	$html = InjectJs($html, @jsToInject);

	return $html;
} # GetPersonPage()

1;
