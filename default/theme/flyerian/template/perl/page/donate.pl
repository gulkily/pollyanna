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

	if (GetConfig('setting/admin/js/enable')) {
		$html = InjectJs($html, qw(settings avatar profile timestamp pingback utils clock));
	}

	return $html;
} # GetDonatePage()

1;
