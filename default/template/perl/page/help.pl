#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetHelpPage { # returns html for help page (/help.html)
# sub GetHelpDialog()
	my $txtIndex = "";

	$txtIndex =
		GetPageHeader('help') .
		GetTemplate('html/maincontent.template') .
		GetWindowTemplate(GetTemplate('html/page/help.template'), 'Help') .
		GetWindowTemplate(GetTemplate('html/page/help_diagnostics.template'), 'Toys') .
		GetWindowTemplate(GetTemplate('html/page/help_views.template'), 'Views') .
		GetStatsTable() .
		GetPageFooter('help')
	;

	if (GetConfig('admin/js/enable')) {
		$txtIndex = InjectJs($txtIndex, qw(settings avatar profile timestamp pingback utils clock));
	}

	return $txtIndex;
} # GetHelpPage()

1;
