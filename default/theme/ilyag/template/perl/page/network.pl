#!/usr/bin/perl -T

use strict;
use warnings;
use 5.000;

sub GetNetworkPage {
	my $networkNews = GetQueryAsDialog('network_news', 'News');
	my $networkAuthors = GetQueryAsDialog('network_authors', 'Authors');

	my $html =
		GetPageHeader('network') .
		$networkNews .
		$networkAuthors .
		GetPageFooter('network')
	;
}




1;
