#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDialogListDialog {
# sub GetDialogsDialog {
	WriteLog('GetDialogListDialog()');

	my $dialogContent =
		GetTemplate('html/widget/dialog_list.template') .
		# GetTemplate('html/form/settings.template')
	;
	my $dialog = GetDialogX($dialogContent, 'Dialogs');

	return $dialog;
} GetDialogListDialog()

1;
