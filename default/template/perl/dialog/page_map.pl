#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPageMapDialog {
# sub GetDialogsDialog {
# sub GetDialogDialog {
# sub GetDialogListDialog {
# sub DialogsList {
# sub DialogsListDialog {
# sub DetDialogList {
# sub GetDialogMenu {
	WriteLog('GetPageMapDialog()');

    if (!GetConfig('setting/admin/js/enable')) {
        #todo make it work without js
        WriteLog('GetPageMapDialog: warning: called while setting/js/enable was FALSE; caller = ' . join(' ', caller));
        return '';
    }

    #todo it should show up on a page that won't have js required to make it work
    #todo it should come pre-filled with all the dialogs that are initially on the page

	my $dialogContent = GetTemplate('html/widget/page_map.template'); # id=lstDialog
	my $dialog = GetDialogX($dialogContent, 'PageMap');

	return $dialog;
} # GetPageMapDialog()

1;
