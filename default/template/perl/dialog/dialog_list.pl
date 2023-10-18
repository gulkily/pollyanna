#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDialogListDialog {
# sub GetDialogsDialog {
# sub dialogslist {
# sub dialogslistdialog {
# sub DetDialogList {
# sub GetDialogMenu {
	WriteLog('GetDialogListDialog()');

	my $dialogContent = GetTemplate('html/widget/dialog_list.template');
	my $dialog = GetDialogX($dialogContent, 'PageMap');

	return $dialog;
} # GetDialogListDialog()

1;
