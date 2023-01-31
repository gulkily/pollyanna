#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetRecentItemsDialog {
	my $dialog = GetQueryAsDialog('recent_items', 'Recently Posted');

	return $dialog;
} # GetRecentItemsDialog()

1;