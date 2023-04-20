#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetSchedulePage {
	my $html =
		GetPageHeader('schedule') .
		GetDialogX('Welcome to the Schedule page!') .
		GetPageFooter('schedule')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php'; # write.html
		}
		$html = InjectJs($html, @js)
	}

	return $html;
}

1;
