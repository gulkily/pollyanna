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

    if (GetConfig('setting/js/enable')) {
        #todo make it work without js
        WriteLog('GetPageMapDialog: warning: called while setting/js/enable was TRUE; caller = ' . join(' ', caller));
        return '';
    }

	my $dialogContent = GetTemplate('html/widget/page_map.template');
	my $dialog = GetDialogX($dialogContent, 'PageMap');

	return $dialog;
} # GetPageMapDialog()

1;
