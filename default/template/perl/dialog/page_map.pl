#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPageMapDialog {
# sub GetDialogsDialog {
# sub GetDialogListDialog {
# sub dialogslist {
# sub dialogslistdialog {
# sub DetDialogList {
# sub GetDialogMenu {
	WriteLog('GetPageMapDialog()');

	my $dialogContent = GetTemplate('html/widget/page_map.template');
	my $dialog = GetDialogX($dialogContent, 'PageMap');

	return $dialog;
} # GetPageMapDialog()

1;
