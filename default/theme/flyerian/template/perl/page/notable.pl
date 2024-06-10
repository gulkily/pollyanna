#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetNotablePage {
	WriteLog('GetNotablePage()');

	my $html =
		GetPageHeader('notable') .
		GetTemplate('html/maincontent.template') .
		GetDialogX(GetTemplate('html/page/notable.template'), 'Notable') .
		GetPageFooter('notable')
	;

	if (GetConfig('setting/admin/js/enable')) {
		$html = InjectJs($html, qw(settings avatar profile timestamp pingback utils clock));
	}

	return $html;
}

1;