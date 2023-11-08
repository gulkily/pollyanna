#!/usr/bin/perl -T

use strict;
use warnings;

sub GetStatsPage { # returns html for stats page
	my $statsPage;

	$statsPage =
		GetPageHeader('stats') .
		GetTemplate('html/maincontent.template') .
		GetStatsTable() . # GetStatsPage()
		(GetConfig('setting/admin/logging/write_chain_log') ? GetChainLogAsDialog() : ' ') .
		GetPageFooter('stats');

	$statsPage = InjectJs($statsPage, qw(utils settings avatar timestamp pingback profile));

	return $statsPage;
}

1;
