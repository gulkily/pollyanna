#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetSearchDialog { # search dialog for search page
	my $searchForm = GetTemplate('html/form/search.template');
	my $searchWindow = GetDialogX($searchForm, 'Public Search');
	return $searchWindow;
} # GetSearchDialog()

1;