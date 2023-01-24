#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDialogListDialog {
	my $dialogContent = GetTemplate('html/widget/dialog_list.template');
	my $dialog = GetDialogX($dialogContent, 'Dialogs');

	return $dialog;
}

1;
