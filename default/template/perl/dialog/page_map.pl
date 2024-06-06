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
	# sub GetPageMap {
	WriteLog('GetPageMapDialog()');

    if (!GetConfig('setting/admin/js/enable')) {
        #todo make it work without js
        WriteLog('GetPageMapDialog: warning: called while setting/admin/js/enable was FALSE; caller = ' . join(' ', caller));
        return '';
    }

	my $status = GetTemplate('html/widget/layer_controls.template');
	if (GetConfig('setting/admin/js/dragging')) {
		$status .= GetTemplate('html/widget/dialog_controls.template');
	}

	#todo it should show up on a page that won't have js required to make it work
    #todo it should come pre-filled with all the dialogs that are initially on the page

	require_once('widget/menu.pl');

	my $dialogContent =
		GetMenuFromList('menu') .
		'<br>' .
		GetTemplate('html/widget/page_map.template')
	; # id=lstDialog

	my $dialog = GetDialogX($dialogContent, 'PageMap', '', $status);

	return $dialog;
} # GetPageMapDialog()

1;
