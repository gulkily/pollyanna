#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetServerConfigDialog { #$dialogTitle/$formId, $listOfFields# makes a dialog with some checkboxes and other fields
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# CAUTION the dialog title is reused as form id!!!!!!!!!!!!
# #todo
	my $html = '';

	# Server Configuration

	my $dialogTitle = shift;
	my @settingsVisible = @_; # shift

	if (!$dialogTitle) {
		$dialogTitle = 'Configuration';
	}

	foreach my $setting (@settingsVisible) {
		#todo templatify
		my $settingDisplay = str_replace('/', ' / ', $setting);
		my $defaultValue = GetDefault($setting);

		$html .= '<tr>';

		$html .= '<td>';
		$html .= '<label for="' . $setting . '">';
		$html .= $settingDisplay;
		$html .= '</td>';

		$html .= '<td>';
		#todo templatify

		if (GetConfig($setting . '.list') || GetConfig('setting/' . $setting . '.list')) {
			# list / select+option

			$html .= '<select id="'. $setting . '" name="'. $setting . '">';
			my @options = split("\n", GetConfig($setting . '.list') || GetConfig('setting/' . $setting . '.list'));
			my $currentSelection = GetConfig($setting);
			if (!in_array($currentSelection, @options)) {
				push @options, $currentSelection;
			}

			for my $option (@options) {
				#print $option . "\n";
				my $optionToDisplay = $option;
				if ($optionToDisplay =~ m/^([0-9a-f]{8})([0-9a-f]{32})$/) {
					$optionToDisplay = $1 . '..';
				}

				if ($option eq $currentSelection) {
					$html .= '<option value="' . $option . '" selected>' . $optionToDisplay . '</option>';
				} else {
					$html .= '<option value="' . $option . '">' . $optionToDisplay . '</option>';
				}
			}
			$html .= '</select>';
			#$html .= '<input name="' . $setting . '" type=text size=10 value="' . GetConfig($setting) . '">';
		} else {
			if (
				$defaultValue eq '0' ||
				$defaultValue eq '1'
			) {
				#checkbox
				$html .= '<input id="'. $setting . '" name="' . $setting . '" type=checkbox' . (GetConfig($setting) ? ' checked' : '') . '>';
			} else {
				#textbox
				$html .= '<input id="'. $setting . '" name="' . $setting . '" type=text size=10 value="' . GetConfig($setting) . '">';
			}
		}
		$html .= '</td>';

		#$html .= '<td>"';
		#$html .= $defaultValue;
		#$html .= '"</td>';


		$html .= '</tr>';
	}

	$html .= '<tr><td colspan=2 align=center>- <input type=submit value=Preview> -</td></tr>';

	$html = GetDialogX($html, $dialogTitle, 'setting,value');

	my $formId = 'frm' . $dialogTitle; #todo make this smell better
	# frmBackend frmFrontend frmZipFiles frmDebug
	$html .= '<input type=hidden name=form_id value="' . $formId . '">';
	$html = '<form class=admin action="/post.html">' . $html . '</form>';
	#todo move form here

	return $html;
} # GetServerConfigDialog()


1;
