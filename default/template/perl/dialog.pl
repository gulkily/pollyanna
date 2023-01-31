#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

require_once('dialog/chain_log.pl');
require_once('dialog/access.pl');
require_once('get_dialog.pl');

sub GetTosDialog {
	my $tosText = GetString('tos');
	#$tosText = str_replace("\n", '<br>', $tosText); #todo improve this

	$tosText = '<p class=txt>' . $tosText . '</p>';
	#$tosText .= '<p><a href="/post.html?comment=tos">[Do You Agree?]</a></p>';
	my $tosWindow = GetDialogX(
		$tosText,
		'Terms of Service',
	);
	#	my @tosItems
	return $tosWindow;
}

require_once('dialog/write.pl');

sub GetPuzzleDialog { # returns write form (for composing text message)
	return 'GetPuzzleDialog() is not finished'; #draft
	my $puzzleForm = GetDialogX(GetTemplate('html/form/puzzle.template'), 'Puzzle?');
	#dirty hack
	#$writeForm =~ s/textarea/input type=hidden/g;
	WriteLog('GetPuzzleDialog()');

	if (GetConfig('admin/php/enable')) {
		if (GetConfig('admin/php/enable') && !GetConfig('admin/php/rewrite')) {
			# if php is enabled but rewrite is disabled
			# change submit target to post.php
			my $postHtml = 'post\\.html'; # post.html
			$puzzleForm =~ s/$postHtml/post.php/; #todo is this necessary?
		}
	}

	my $initText = '';
	$puzzleForm =~ s/\$initText/$initText/g;

	$puzzleForm = '<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' . $puzzleForm . '</form>';

	return $puzzleForm;
} # GetPuzzleDialog ()

sub GetSearchDialog { # search dialog for search page
	my $searchForm = GetTemplate('html/form/search.template');
	my $searchWindow = GetDialogX($searchForm, 'Public Search');
	return $searchWindow;
} # GetSearchDialog()

sub GetSimpleDialog { # dialogType ; gets simple dialog based on template/html/page/$dialogType.template
	# sub GetSimpleWindow {
	my $dialogType = shift;

	WriteLog('GetSimpleDialog: $dialogType = ' . $dialogType);

	#todo sanity
	my $html = '';
	my $pageContent = GetTemplate("html/page/$dialogType.template");
	if (!$pageContent) {
		WriteLog('GetSimpleDialog: warning: empty template, sanity check failed');
		return '';
	}
	my $contentWindow = GetDialogX(
		$pageContent,
		ucfirst($dialogType)
	);

	if ($dialogType =~ m/^[0-9a-z]+$/) {
		$contentWindow = AddAttributeToTag($contentWindow, 'table', 'id', $dialogType);
	}

	return $contentWindow;
} # GetSimpleDialog()

sub GetOperatorDialog {

	my $operatorTemplate = GetTemplate('html/form/operator.template');
	my $operatorWindow = GetDialogX($operatorTemplate, 'Operator');
	$operatorWindow = '<form id=frmOperator name=frmOperator class=admin>' . $operatorWindow . '</form>';
	return $operatorWindow;
	#return 'hi';
}

sub GetAnnoyancesDialog { # returns settings dialog
# sub GetAnnoyancesWindow {
	WriteLog('GetAnnoyancesDialog() BEGIN');
	return '<form>' . GetDialogX(GetTemplate('html/form/annoyances.template'), 'Annoyances') . '</form>';
} # GetAnnoyancesDialog()

sub GetSettingsDialog { # returns settings dialog
# sub GetSettingsWindow {
	WriteLog('GetSettingsDialog() BEGIN');

	my $settingsTemplate = GetTemplate('html/form/settings.template');

	if (GetConfig('admin/js/dragging')) {
	} else {
		# kind of a hack
		# dragging is disabled, so make the option unavailable
		$settingsTemplate = AddAttributeToTag($settingsTemplate, 'input id=chkDraggable', 'disabled', '');
		$settingsTemplate = str_replace('Allow dialog reposition', '<span disabled>Allow dialog reposition (N/A)</span>', $settingsTemplate);
		#$settingsTemplate = str_replace('Enable draggable interface<noscript><b>*</b></noscript>', '<span </span>', $settingsTemplate);

		#		$settingsTemplate = str_replace(
		#			'<input type=checkbox id=chkDraggable name=chkDraggable onchange="if (window.SaveCheckbox) { SaveCheckbox(this, \'draggable\'); }">',
		#			'<input type=checkbox id=chkDraggable name=chkDraggable disabled>',
		#			$settingsTemplate
		#		);
	}

	my $settingsWindow = GetDialogX($settingsTemplate, 'Settings');
	$settingsWindow =
		'<form action="/settings.html" id=frmSettings name=frmSettings>' .
			GetDialogX($settingsTemplate, 'Settings') .
			'</form>'
	;
	#todo template this, and fill in the current page url

	WriteLog('GetSettingsDialog: return $settingsWindow = ' . length($settingsWindow) . ' bytes');

	return $settingsWindow;
} # GetSettingsDialog()

1;
