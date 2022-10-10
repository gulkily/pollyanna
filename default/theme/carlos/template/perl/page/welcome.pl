#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	require_once('item_list_as_gallery.pl');
	my %params;
	$params{'where_clause'} = "WHERE tags_list like '%,image,%'";
	my @items = DBGetItemList(\%params);

	my $html = 
		GetPageHeader('welcome') .
		GetItemListAsGallery(\@items) .
		GetPageFooter('welcome')
	;

	return $html;
}

1;
