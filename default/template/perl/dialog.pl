#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

require_once('dialog/chain_log.pl');
require_once('dialog/access.pl');

sub GetTosDialog {
	my $tosText = GetString('tos');
	#$tosText = str_replace("\n", '<br>', $tosText); #todo improve this

	$tosText = '<p class=txt>' . $tosText . '</p>';
	#$tosText .= '<p><a href="/post.html?comment=tos">[Do You Agree?]</a></p>';
	my $tosWindow = GetWindowTemplate(
		$tosText,
		'Terms of Service',
	);
	#	my @tosItems
	return $tosWindow;
}

sub GetWriteForm { # $dialogTitle ; returns write form (for composing text message)
# sub GetWriteDialog {
# sub GetWriteWindow {
	my $dialogTitle = shift;
	if (!$dialogTitle) {
		$dialogTitle = 'Write';
	} else {
		#todo sanity check
	}

	my $prompt = shift;
	if (!$prompt) {
		$prompt = 'Write something here:';
	} else {
		#todo sanity check
	}

	#my $writeForm = GetWindowTemplate(GetTemplate('html/form/write/write.template'), $dialogTitle);
	my $writeForm = GetTemplate('html/form/write/write.template');
	# my $writeForm = GetWindowTemplate(GetTemplate('html/form/write/write.template'), 'Write');
	WriteLog('GetWriteForm()');

	if ($prompt ne 'Write something here:') { #todo templatize this
		$writeForm = str_replace('Write something here:', $prompt, $writeForm);
	}

	if (GetConfig('admin/php/enable')) {
		WriteLog('GetWriteForm: php is ON');
		my $writeLongMessage = GetTemplate('html/form/write/long_message.template');
		if ($writeLongMessage) {
			my $targetElement = '<span id=writefooter>';
			$writeForm = str_replace($targetElement, $targetElement . $writeLongMessage, $writeForm);
		}

		if (GetConfig('admin/php/enable') && !GetConfig('admin/php/rewrite')) {
			# if php is enabled but rewrite is disabled
			# change submit target to post.php
			#my $postHtml = 'post.html'; # post.html
			WriteLog('GetWriteForm: replacing post.html post.php');
			$writeForm = str_replace('post.html', 'post.php', $writeForm);
			#$writeForm =~ s/$postHtml/post.php/;
		} else {
			WriteLog('GetWriteForm: NOT replacing post.html post.php');
		}

			# this is how auto-save to server would work (with privacy implications) #autosave
		# $submitForm =~ s/\<textarea/<textarea onkeyup="if (this.length > 2) { document.forms['compose'].action='\/post2.php'; }" /;
	} else {
		WriteLog('GetWriteForm: php is OFF');
	}

	my $initText = '';
	#
	# # these are not present in the template
	# $writeForm =~ s/\$extraFields/poop/g;
	$writeForm =~ s/\$initText/$initText/g;

	if (GetConfig('admin/js/enable')) {
		# javascript is enabled, add event hooks
		my $writeOnChange = "if (window.CommentOnChange) { return CommentOnChange(this, 'compose'); } else { return true; }";
		$writeForm = AddAttributeToTag($writeForm, 'textarea', 'onchange', $writeOnChange);
		$writeForm = AddAttributeToTag($writeForm, 'textarea', 'onkeyup', $writeOnChange);
		if (GetConfig('admin/js/translit')) {
			$writeForm = AddAttributeToTag(
				$writeForm,
				'textarea',
				'onkeydown',
				'if (window.translitKey) { translitKey(event, this); } else { return true; }'
			);
		}

		if (GetConfig('admin/js/write_form_optimize_for_delivery')) {
			$writeForm = AddAttributeToTag(
				$writeForm,
				'input type=submit',
				'onclick',
				"this.value = 'Meditate...'; if (window.writeSubmit) { setTimeout('writeSubmit();', 100); return true; } else { return true; }" #write #optimize_for_delivery = true
			);
		} else {
			$writeForm = AddAttributeToTag(
				$writeForm,
				'input type=submit',
				'onclick',
				"this.value = 'Meditate...'; if (window.writeSubmit) { return writeSubmit(); } else { return true; }" #write #optimize_for_delivery = false
			);
		}
	} # js stuff in write form

	my $writeDialog = GetWindowTemplate($writeForm, $dialogTitle);

	return $writeDialog;
	#return $writeForm;
} # GetWriteForm()

sub GetPuzzleDialog { # returns write form (for composing text message)
	return 'GetPuzzleDialog() is not finished'; #draft
	my $puzzleForm = GetWindowTemplate(GetTemplate('html/form/puzzle.template'), 'Puzzle?');
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
	my $searchWindow = GetWindowTemplate($searchForm, 'Public Search');
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
	my $contentWindow = GetWindowTemplate(
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
	my $operatorWindow = GetWindowTemplate($operatorTemplate, 'Operator');
	$operatorWindow = '<form id=frmOperator name=frmOperator class=admin>' . $operatorWindow . '</form>';
	return $operatorWindow;
	#return 'hi';
}

sub GetAnnoyancesDialog { # returns settings dialog
# sub GetAnnoyancesWindow {
	WriteLog('GetAnnoyancesDialog() BEGIN');
	return '<form>' . GetWindowTemplate(GetTemplate('html/form/annoyances.template'), 'Annoyances') . '</form>';
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

	my $settingsWindow = GetWindowTemplate($settingsTemplate, 'Settings');
	$settingsWindow =
		'<form action="/settings.html" id=frmSettings name=frmSettings>' .
			GetWindowTemplate($settingsTemplate, 'Settings') .
			'</form>'
	;
	#todo template this, and fill in the current page url

	WriteLog('GetSettingsDialog: return $settingsWindow = ' . length($settingsWindow) . ' bytes');

	return $settingsWindow;
} # GetSettingsDialog()

1;
