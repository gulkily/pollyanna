#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDonatePage {
	WriteLog('GetDonatePage()');

	my $html =
		GetPageHeader('donate') .
		GetTemplate('html/maincontent.template') .
		GetDialogX(GetTemplate('html/page/donate.template'), 'Donate') .
		GetPageFooter('donate')
	;

	#todo js inject
	

	return $html;
} # GetDonatePage()

1;
