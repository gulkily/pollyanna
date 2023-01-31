#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetAnnoyancesDialog { # returns settings dialog
	# sub GetAnnoyancesWindow {
	WriteLog('GetAnnoyancesDialog() BEGIN');
	return '<form>' . GetDialogX(GetTemplate('html/form/annoyances.template'), 'Annoyances') . '</form>';
} # GetAnnoyancesDialog()

1;
