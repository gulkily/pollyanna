#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

# modern theme

# GetDialogX2()
# 	\%paramHash (reference to a hash of parameters
# 		body
# 		title
# 		anchor
# 		headings
# 		columns_lookup
# 		status
# 		menu
# 		form_action
# 		id

sub GetDialogX2 { # \%paramHash ; returns dialog
	# returns html-table-based-"window"
	my $paramHashRef = shift;
	my %param = %{$paramHashRef};

	#return GetDialogX($param{'body'}, $param{'title'}, $param{'headings'}, $param{'status'}, $param{'menu'});

	# returns template for html-table-based-"window"

	# $windowBody
	# what goes inside the biggest table cell in the middle
	# it is wrapped in <tr><td>...</td></tr> if does not contain "<tr"

	# $windowTitle = title bar, typically at the top of the window

	# $columnHeadings = column headings,
	# in format: col1,col2,col3
	# rendered as: <tr><td>col1</td><td>col2</td><td>col3</td>
	# each column name can contain html, e.g. link to sort by that column

	# $windowStatus
	# thing typically at the bottom of the window, as html

	# $windowMenubar
	# thing typically at the top of the window, as html

	# NOT IMPLEMENTED $windowId = if set, id=foo parameter is added to top-level tag

	WriteLog('GetDialogX2: modern theme');
	WriteLog('GetDialogX2: %param: ' . join(',', keys(%param)));
	WriteLog('GetDialogX2: caller: ' . join(',', caller));

	my $windowBody = $param{'body'};
	my $windowTitle = $param{'title'};
	my $dialogAnchor = $param{'anchor'};
	my $columnHeadings = $param{'headings'};
	my $columnHeadingsAdvanced = $param{'headings_advanced'}; # add class=advanced to headings
	my $columnHeadingsLookup = $param{'columns_lookup'};
	my $windowStatus =  $param{'status'};
	my $windowMenubarContent = $param{'menu'};
	my $formAction = $param{'form_action'};
	my $windowId = $param{'id'};
	my $dialogIconKey = $param{'icon'} || $param{'id'} || $param{'title'} || '';

	if (!$dialogAnchor) {
		WriteLog('GetDialogX2: warning: $dialogAnchor is FALSE, activating fallback; caller = ' . join(',', caller));
		if (!$dialogAnchor && $windowId) {
			$dialogAnchor = $windowId;
		}
		if (!$dialogAnchor && $windowTitle) {
			$dialogAnchor = str_replace(' ', '', $windowTitle);
			$dialogAnchor =~ s/[^a-zA-Z0-9]//g;
			#todo
		}
		if (!$dialogAnchor && $windowBody) {
			$dialogAnchor = substr(md5_hex($windowBody), 0, 8);
		}
		if (!$dialogAnchor) {
			WriteLog('GetDialogX2: warning: $dialogAnchor is FALSE after fallbacks; caller = ' . join(',', caller));
		}
	}

	my $tableSort; # it is on by default, contingent on settings
	if (exists $param{'table_sort'}) {
		$tableSort = $param{'table_sort'} ? 1 : 0;
	} else {
		$tableSort = 1;
	}

	#WriteLog('GetDialogX2: $windowTitle = ' . $windowTitle . '; $tableSort = ' . $tableSort);

	my $contentColumnCount = 1;
	# stores number of columns if they exist
	# if no columns, remains at 0
	# whether there are columns or not determines:
	# * column headers are added or no?
	# * colspan= in non-column cells

	# base template
	my $windowTemplate = GetTemplate('html/window/standard.template');

	if (GetConfig('setting/html/debug')) { #todo separate debug setting for html templating
		my $debugComment = '<!-- GetDialogX2: caller = ' . join(',', caller) . ' -->';

		#todo go 2 levels up, since this is probably called from GetDialogX()
		if ($param{'debug_message'}) {
			$debugComment = '<!-- ' . $param{'debug_message'} . ' -->';
		}

		$windowTemplate = "\n" . $debugComment . "\n" . $windowTemplate;
	}

	if ($windowId) {
		if ($windowId =~ m/^([0-9a-zA-Z_]+)$/) {
			$windowId = $1;
			WriteLog('GetDialogX2: $windowId = ' . $windowId);
			#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'id', $windowId);
			$windowTemplate = AddAttributeToTag($windowTemplate, 'div class="dialog"', 'id', $windowId);
		} else {
			WriteLog('GetDialogX2: warning: sanity check failed: $windowId = ' . $windowId);
		}
	} else {
		WriteLog('GetDialogX2: $windowId is FALSE');
	}

	if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmousedown', 'this.style.zIndex = ++window.draggingZ;');

		#todo this should actually be done with js modern methods
		$windowTemplate = AddAttributeToTag($windowTemplate, 'div class="dialog"', 'onmouseenter', 'if (window.SetActiveDialogDelay) { return SetActiveDialogDelay(this); }'); #SetActiveDialog() GetDialogX2()
		$windowTemplate = AddAttributeToTag($windowTemplate, 'div class="dialog"', 'onmousedown', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetDialogX2()
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'ontouchstart', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetDialogX2()
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onfocus', 'if (window.SetActiveDialog) { SetActiveDialog(this); return true; }'); #SetActiveDialog()
	}

	my $showButtons = GetConfig('html/window_titlebar_buttons'); # titlebar hide and skip buttons;
	WriteLog('GetDialogX2: $showButtons = ' . $showButtons);

	if (!$windowTitle) {
		#WriteLog('GetDialogX2: warning: title missing, using Untitled');
		#$windowTitle = 'Untitled';
		#todo this doesn't look right and should be improved upon

		$windowTitle = '';
	}

	# titlebar, if there is a title
	if ($windowTitle) {
		WriteLog('GetDialogX2: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle);

		if ($showButtons && GetConfig('setting/admin/js/dragging')) {
			WriteLog('GetDialogX2: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('setting/admin/js/dragging'));

			my $btnCloseCaption = '#'; # needs to match one other place in dragging.js #collapseButton
			my $windowTitlebar = GetTemplate('html/window/titlebar_with_button.template'); #window_titlebar_buttons

			if (index($windowTitlebar, '<b>') != -1) {
				# ok, sanity check passed
			} else {
				WriteLog('GetDialogX2: warning: $windowTitlebar was missing <b>; caller = ' . join(',', caller));
			}

			if (GetConfig('setting/admin/js/enable')) {
				#$windowTitlebar = AddAttributeToTag($windowTitlebar, 'button title=skip', 'onclick', "if (window.CollapseWindowFromButton) { return !CollapseWindowFromButton(this); } return false;");
				#skip button

				$windowTitlebar = AddAttributeToTag($windowTitlebar, 'button title=expand', 'onclick', "if (window.ShowAll && window.GetParentDialog) { return !ShowAll(this, GetParentDialog(this)); } return false;"); #todo add colla
				#expand button

				$windowTitlebar = AddAttributeToTag($windowTitlebar, 'button title=close', 'onclick', "if (window.CloseDialog) { return CloseDialog(this) }");
				#close button

				# $windowTitlebar = AddAttributeToTag($windowTitlebar, 'button title=close', 'onclick', "if (window.GetParentDialog) { GetParentDialog(this).remove(); if (window.UpdateDialogList) { UpdateDialogList(); } }");
				#old close button

				$windowTitlebar = AddAttributeToTag($windowTitlebar, 'td', 'ondblclick', "
					if (window.CollapseWindowFromButton) {
						var button = this.getElementsByClassName('skip');
						button = button[0];
						return CollapseWindowFromButton(button);
					}
					return false;
				");
				require_once('inject_js.pl');
				$windowTitlebar = InjectJs($windowTitlebar, qw(titlebar_with_button)); #todo this should not warn, it does not need a <body> tag
			}

			#todo this should use str_replace
			#todo this should use <span id=></span> instead of $ placeholders
			$windowTitlebar =~ s/\$windowTitle/$windowTitle/g;
			$windowTitlebar =~ s/\$dialogAnchor/$dialogAnchor/g;
			$windowTemplate =~ s/\$windowTitlebar/$windowTitlebar/g;
			$windowTemplate =~ s/\$btnCloseCaption/$btnCloseCaption/g;

			my $dialogIcon = GetDialogIcon($dialogIconKey);
			if (!$dialogIcon) {
				WriteLog('GetDialogX2: $dialogIcon is FALSE; $windowTitle = ' . $windowTitle . '; caller = ' . join(',', caller));
				$dialogIcon = '🌌';
			}

			if (GetConfig('setting/html/dialog_emoji_icon')) {
				my $spanDialogIcon = '<span class=dialogIcon>' . $dialogIcon . '</span>';
				if (GetConfig('setting/admin/js/enable')) {
					#$spanDialogIcon = AddAttributeToTag($spanDialogIcon, 'span', 'onclick', 'alert()');
					#$spanDialogIcon = AddAttributeToTag($spanDialogIcon, 'span', 'style', 'cursor:pointer');
				}
				$windowTemplate = str_replace('<span class=dialogIcon></span>', $spanDialogIcon, $windowTemplate);
			} else {
				$windowTemplate = str_replace('<span class=dialogIcon></span>', '', $windowTemplate);
			}
			#$contentColumnCount = 2;
		}
		else {
			WriteLog('GetDialogX2: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('setting/admin/js/dragging'));
			my $windowTitlebar = GetTemplate('html/window/titlebar.template');

			if (index($windowTitlebar, '<b>') != -1) {
				# ok, sanity check passed
			} else {
				WriteLog('GetDialogX2: warning: $windowTitlebar was missing <b>; caller = ' . join(',', caller));
			}

			#
			#if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
			#	$windowTitlebar = AddAttributeToTag($windowTemplate, 'a href=#$dialogAnchor', 'onfocus', 'document.title=this.innerHTML;');
			#	$windowTitlebar = AddAttributeToTag($windowTemplate, 'a href=#$dialogAnchor', 'onclick', 'document.title=this.innerHTML;');
			#}
			#$windowTitlebar = str_replace('<!-- note: dragging.js looks for a "b" inside of a class=titlebar -->', '', $windowTitlebar); #UtilityComment

			$windowTitlebar =~ s/\$windowTitle/$windowTitle/g;
			$windowTitlebar =~ s/\$dialogAnchor/$dialogAnchor/g;
			$windowTemplate =~ s/\$windowTitlebar/$windowTitlebar/g;

			if (GetConfig('setting/admin/js/enable')) {
				WriteLog('GetDialogX2: calling AddAttributeToTag; $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('setting/admin/js/dragging'));
				#todo maybe should depend on another setting?
				$windowTemplate = AddAttributeToTag($windowTemplate, 'a', 'onclick', "if (window.ShowAll && window.GetParentDialog) { return !ShowAll(this, GetParentDialog(this)); } return false;");
			}
			else {
				WriteLog('GetDialogX2: NOT calling AddAttributeToTag; $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('setting/admin/js/dragging'));
			}
		}
	} else {
		$windowTemplate =~ s/\$windowTitlebar//g;
	}

	# menubar, if there is menubar content
	if ($windowMenubarContent) {
		my $windowMenubar = GetTemplate('html/window/menubar.template');
		$windowMenubar =~ s/\$windowMenubarContent/$windowMenubarContent/;
		$windowMenubar = '<span class=advanced>' . $windowMenubar . '</span>';

		$windowTemplate =~ s/\$windowMenubar/$windowMenubar/g;
	} else {
		$windowTemplate =~ s/\$windowMenubar//g;
	}

	#if ($columnHeadings && int($columnHeadings) > 0 && int($columnHeadings) eq $columnHeadings) {
	if ($columnHeadings && ($columnHeadings =~ m/^[0-9]+/)) { #todo improve on this
		# typically, column headings are specified as a comma-separated list
		# but sometimes we just want the dialog to have columns without headings
		# (for example, the author information dialog)
		# in this case, we specify the number of columns as an integer
		# this allows the title bar and status bar to have the proper value for colspan=
		WriteLog('GetDialogX2: $columnHeadings is NUMERIC');
		$contentColumnCount = int($columnHeadings);
		$columnHeadings = '';
	} else {
		WriteLog('GetDialogX2: $columnHeadings is NOT numeric; $columnHeadings = ' . ($columnHeadings ? $columnHeadings : 'FALSE'));
		#$columnHeadings = '';
	}

	# column headings
	if ($columnHeadings) {
		WriteLog('GetDialogX2: modern: has $columnHeadings: $columnHeadings = ' . $columnHeadings);
		my $windowHeaderTemplate = GetTemplate('html/window/header_wrapper.template');
		my $windowHeaderColumns = '';
		my @columnsArray = split(',', $columnHeadings);

		my $printedColumnsCount = 0;
		my @fieldAdvanced = split("\n", GetTemplate('list/field_advanced'));
		my @fieldAdmin = split("\n", GetTemplate('list/field_admin'));
		# fields_advanced advanced_fields advancedfields

		if ($columnHeadingsAdvanced) {
			$windowHeaderTemplate = str_replace('<tr class="heading">', '<tr class="heading advanced">', $windowHeaderTemplate);
		}

		foreach my $columnCaption (@columnsArray) {
			$printedColumnsCount++;
			my $columnHeaderTemplate = GetTemplate('html/window/header_column.template'); # <td></td>

			if (in_array($columnCaption, @fieldAdvanced)) {
				#todo caption and field name should be different things
				$columnHeaderTemplate = AddAttributeToTag(
					$columnHeaderTemplate,
					'th',
					'class',
					'advanced'
				);
			}
			elsif (in_array($columnCaption, @fieldAdmin)) {
				#todo caption and field name should be different things
				$columnHeaderTemplate = AddAttributeToTag(
					$columnHeaderTemplate,
					'th',
					'class',
					'admin'
				);
			}

			if ($tableSort && GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/table_sort')) {
				$columnHeaderTemplate = AddAttributeToTag(
					$columnHeaderTemplate,
					'th',
					'onclick',
					'if (window.SortTable) { SortTable(this); } else { }'
				);
				$columnHeaderTemplate = AddAttributeToTag(
					$columnHeaderTemplate,
					'th',
					'style',
					'cursor: pointer'
				);
			}
			if (0 && $columnHeadingsLookup) { #todo
				WriteLog('GetDialogX2: $columnHeadingsLookup is TRUE');

				my $columnString = GetString('column_name/' . $columnCaption);
				if ($columnString && ($columnString ne $columnCaption)) {
					$columnCaption = $columnString;
					$columnHeaderTemplate = AddAttributeToTag(
						$columnHeaderTemplate,
						'th',
						'title',
						$columnCaption
					);
				}
			}
			if ($printedColumnsCount >= scalar(@columnsArray)) {
				# only printed after the last column
				# adds a <br> for browsers without table support
				$columnCaption .= '<br>'; # for no-table browsers
			}
			#			my $columnCaptionString = GetString('field_name/' . $columnCaption);
			#			if ($columnCaptionString) {
			#				$columnHeaderTemplate =~ s/\$headerCaption/$columnCaptionString/;
			#			} else {
			$columnHeaderTemplate =~ s/\$headerCaption/$columnCaption/;
			#			}

			$windowHeaderColumns .= $columnHeaderTemplate;
		}
		$windowHeaderTemplate =~ s/\$windowHeadings/$windowHeaderColumns/;
		if ($param{'no_heading'}) {
			WriteLog('GetDialogX2: modern: no_heading');
			$windowTemplate =~ s/\$windowHeader//g;
		} else {
			WriteLog('GetDialogX2: modern: has $windowHeader');
			$windowTemplate =~ s/\$windowHeader/$windowHeaderTemplate/;
		}
		$contentColumnCount = scalar(@columnsArray);
	} # / column headings
	else {
		WriteLog('GetDialogX2: modern: does NOT have $columnHeadings');
		$windowTemplate =~ s/\$windowHeader//g;
	}

	# main window content, aka body
	# this accounts for two different scenarios
	# may need to be split into different subs
	# but for now, it's only these two
	# one scenario is if the content already has tr's and td's
	# in this case, nothing else is needed
	# the other scenario is if it is not enclosed in tr and td
	# in this case we need to do it, because the dialog is a table
	if ($windowBody) {
		WriteLog('GetDialogX2: modern: has $windowBody');
		#if (
		#	!$columnHeadings &&
		#		(index(lc($windowBody), '<table') == -1) &&
		#		(index(lc($windowBody), '<tr') == -1)
		#) {
		#	$windowBody = '<tr class=content><td>' . $windowBody . '</td></tr>';
		#}
		#elsif (index(lc($windowBody), '<tr') == -1) {
		#	if ($contentColumnCount > 1) {
		#		#todo templatize?
		#		$windowBody = '<tr class=content><td colspan=$contentColumnCount>' . $windowBody . '</td></tr>';
		#	} else {
		#		$windowBody = '<tr class=content><td>' . $windowBody . '</td></tr>';
		#	}
		#} else {
		#	$windowBody = str_replace('$contentColumnCount', $contentColumnCount, $windowBody);
		#}

		# if $windowBody contains table content, add table tags around it
		if (index($windowBody, '<tr') != -1) {
			# this is kind of a hack, but it works
			WriteLog('GetDialogX2: modern: $windowBody has <tr');

			if ($columnHeadings) {
				my @columnsArray = split(',', $columnHeadings);
				my $printedColumnsCount = 0;
				my @fieldAdvanced = split("\n", GetTemplate('list/field_advanced'));
				my @fieldAdmin = split("\n", GetTemplate('list/field_admin'));

				my $windowBodyHeading = '';

				for my $column (@columnsArray) {
					my $th = '<th>' . $column . '</th>';


					if (in_array($column, @fieldAdvanced)) {
						#todo caption and field name should be different things
						$th = AddAttributeToTag(
							$th,
							'th',
							'class',
							'advanced'
						);
					}
					elsif (in_array($column, @fieldAdmin)) {
						#todo caption and field name should be different things
						$th = AddAttributeToTag(
							$th,
							'th',
							'class',
							'admin'
						);
					}

					if ($tableSort && GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/table_sort')) {
						# #todo this should probably be done more modern-like with js-based bindings
						$th = AddAttributeToTag(
							$th,
							'th',
							'onclick',
							'if (window.SortTable) { SortTable(this); } else { }'
						);
						# #todo this should probably be done more modern-like with stylesheet
						$th = AddAttributeToTag(
							$th,
							'th',
							'style',
							'cursor: pointer'
						);
					}

					$windowBodyHeading .= $th;
				}

				$windowBodyHeading = '<tr>' . $windowBodyHeading . '</tr>';

				$windowBody = $windowBodyHeading . $windowBody;
			}

			$windowBody = '<table>' . $windowBody . '</table>';
		} else {
			WriteLog('GetDialogX2: modern: $windowBody does NOT have <tr');
		}

		$windowTemplate =~ s/\$windowBody/$windowBody/g;
	} else {
		WriteLog('GetDialogX2: modern: does NOT have $windowBody');
		$windowTemplate =~ s/\$windowBody//g;
	}

	# statusbar
	if ($windowStatus) {
		my $windowStatusTemplate = GetTemplate('html/window/status.template');
		$windowBody = str_replace('$contentColumnCount', $contentColumnCount, $windowBody);
		$windowStatusTemplate =~ s/\$windowStatus/$windowStatus/g;

		if ($param{'no_status'}) {
			$windowTemplate =~ s/\$windowStatus//g;
		} else {
			$windowTemplate =~ s/\$windowStatus/$windowStatusTemplate/g;
		}
	} else {
		$windowTemplate =~ s/\$windowStatus//g;
	}

	# fill in column counts if necessary
	if ($contentColumnCount && $contentColumnCount != 1) {
		$windowTemplate =~ s/\$contentColumnCount/$contentColumnCount/g;
	} else {
		$windowTemplate =~ s/\ colspan=\$contentColumnCount//g;
	}

	if ($showButtons) {#todo review this area
		my $windowGuid = GetMD5($windowTemplate);
		if (defined($param{'guid'})) {
			if ($param{'guid'} =~ m/^[0-9a-f]{8}$/) {
				$windowGuid = $param{'guid'};
			} else {
				WriteLog('GetDialogX2: warning: $param{guid} failed sanity check');
			}
		}

		my $itemEndAnchor = substr($windowGuid, 0, 8);
		WriteLog('GetDialogX2: length($windowTemplate) = ' . length($windowTemplate) . '; $windowGuid = ' . $windowGuid);
		$windowTemplate =~ s/\$itemEndAnchor/$itemEndAnchor/g;
		$windowTemplate .= "<a name=$itemEndAnchor></a>";
	}

	if ($formAction) {
		#todo sanity checks
		my $formName = 'frm' . $windowTitle; #todo only first word, no spaces
		$formName =~ s/\s//g;

		$windowTemplate = "<form name=$formName id=$formName action=\"$formAction\">" . $windowTemplate . '</form>';
	}

	return $windowTemplate;
} # GetDialogX2()

1;
