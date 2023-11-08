#!/usr/bin/perl -T

use strict;
use warnings;
use utf8;

sub GetMenuPage { # /menu.html
# sub GetHelpDialog()
# sub GetMenuPage()
	my $txtIndex = "";

	require_once('page/menu.pl');
	require_once('page/upload.pl');
	require_once('dialog/upload.pl');

	$txtIndex =
		GetPageHeader('menu') .
		GetTemplate('html/maincontent.template') . #for accessibility
		GetQueryAsDialog('labels', 'Labels') . # GetLabelsDialog() .
		GetQueryAsDialog('people_pending', 'There are new authors awaiting approval...', '') .
		GetDialogX(GetTemplate('html/page/help.template'), 'Help') .
		GetDialogX(GetTemplate('html/page/help_diagnostics.template'), 'Toys') .
		GetDialogX(GetTemplate('html/page/help_views.template'), 'Views') .
		GetStatsTable() .
		# GetIntroDialog('menu') .
		# GetWelcomeDialog() .
		GetSettingsDialog() .
		GetAnnoyancesDialog() .
		# GetProfileDialog() .
		GetQueryAsDialog('random', 'Random') . # GetLabelsDialog() .
		GetQueryAsDialog('people', 'People') . # GetLabelsDialog() .
		GetQueryAsDialog('Authors', 'Authors') . # GetLabelsDialog() .
		# GetWriteDialog() . #this causes a problem because it steals focus
		GetUploadDialog() .
		# GetPasteDialog() . # needs js which conflicts with write dialog #todo
		GetQueryAsDialog('image', 'Images') .
		GetQueryAsDialog('threads', 'Threads') .
		GetPageFooter('menu')
	;

	if (GetConfig('setting/admin/js/enable')) {
		$txtIndex = InjectJs($txtIndex, qw(settings avatar profile timestamp pingback utils clock));
	}

	return $txtIndex;
} # GetMenuPage()

1;
