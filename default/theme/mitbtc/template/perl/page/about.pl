#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAboutPage {
	my $html =
		GetPageHeader('about') .
		GetDialogX('Welcome to the About page!') .
		GetPageFooter('about')
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
