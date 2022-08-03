#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetContentFilterDialog () {
	my $list = GetTemplate('list/content_filter_ui_tags');
	return $list;
}

1;
