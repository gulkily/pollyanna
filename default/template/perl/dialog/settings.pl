#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetSettingsDialog { # returns settings dialog
# sub GetSettingsWindow {
	WriteLog('GetSettingsDialog() BEGIN');

	my $settingsTemplate = GetTemplate('html/form/settings.template');

	if (GetConfig('admin/js/dragging')) {
		# dragging module is enabled, keep the setting available
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
