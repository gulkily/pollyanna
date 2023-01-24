#!/usr/bin/perl -T

use strict;
use warnings;

sub GetSpyPage { # returns html for settings page (/settings.html)
	my $txtIndex = "";

	$txtIndex = GetPageHeader('spy');

	$txtIndex .= GetDialogX(GetTemplate('html/widget/spy.template'), 'Dialog');

	$txtIndex .= GetPageFooter('spy');

	if (GetConfig('admin/js/enable')) {
		$txtIndex = InjectJs($txtIndex, qw(settings dragging utils));
	}

	return $txtIndex;
} # GetSpyPage()

1;
