#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAboutPage {
	my $html =
		GetPageHeader('about') .
		GetDialogX(GetTemplate('html/page/about.template'), 'About') .
		'<br>' .
		GetStatsTable() .
		GetDialogX(GetTemplate('html/page/help.template'), 'Help') .
		GetDialogX(GetTemplate('html/page/help_diagnostics.template'), 'Toys') .
		GetDialogX(GetTemplate('html/page/help_views.template'), 'Views') .
		GetPageFooter('about')
	;
	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils);
		$html = InjectJs($html, @js)
	}

	return $html;
} # GetAboutPage()

1;
