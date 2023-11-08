#!/usr/bin/perl -T

use strict;
use warnings;

sub GetInspectorPage { # returns html for settings page (/settings.html)
	my $txtIndex = "";

	$txtIndex = GetPageHeader('inspector');

	$txtIndex .= GetDialogX(GetTemplate('html/widget/inspector.template'), 'Inspector');

	$txtIndex .= GetPageFooter('inspector');

	if (GetConfig('setting/admin/js/enable')) {
		$txtIndex = InjectJs($txtIndex, qw(settings dragging utils));
	}

	return $txtIndex;
} # GetInspectorPage()

1;
