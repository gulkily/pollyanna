#!/usr/bin/perl -T

use strict;
use warnings;

sub GetAccessPage { # returns html for compatible mode page, /access.html
	my $html = GetPageHeader('access') .
	GetTemplate('html/maincontent.template') .
	GetDialogX(GetTemplate('html/access.template'), 'Light Mode') .
	GetPageFooter('access');

	if (GetConfig('setting/admin/js/enable')) {
		$html = InjectJs($html, qw(settings utils));
	}

	return $html;
}

1;
