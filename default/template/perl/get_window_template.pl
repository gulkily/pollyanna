#!/usr/bin/perl -T

use strict;
use warnings;

# GetWindowTemplate()
#	 $body = what's inside the dialog
# 	$title = title
# 	$headings
# 		comma-separated list of headings
# 		-or-
# 		number of columns (integer)
# 	$status = what goes in the status bar
# 	$menu = goes at the top of the window, below the title
# 	calls GetWindowTemplate2()

# GetWindowTemplate2()
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

# GetWindowTemplate3()
#	$body
#	$title
#	\%paramHash (see above)

sub GetWindowTemplate { # $body, $title, $headings, $status, $menu ; returns html with window/dialog
#todo this should be renamed to GetDialog()
# sub GetDialog {
# sub GetDialogPage {
	# calls GetWindowTemplate2()
	my %param = ();

	$param{'body'} = shift;
	$param{'title'} = shift || 'Untitled';
	$param{'headings'} = shift || '';
	$param{'status'} =  shift || '';
	$param{'menu'} = shift || '';

	if (!trim($param{'body'})) {
		WriteLog('GetWindowTemplate: warning: body is FALSE; title = ' . $param{'title'} . '; caller = ' . join(',', caller));
	} else {
		#WriteLog('GetWindowTemplate: warning: body is TRUE; title = ' . $param{'title'} . '; caller = ' . join(',', caller));
	}

	WriteLog('GetWindowTemplate: $param{title}: ' . $param{'title'} . '; caller = ' . join(',', caller));

	#hack
	my $id = lc($param{'title'});
	if (
		$id eq 'read' ||
		$id eq 'write' ||
		$id eq 'settings' ||
		$id eq 'help' ||
		$id eq 'profile' ||
		$id eq 'tags' ||
		$id eq 'authors' ||
		$id eq 'upload'
	) {
		$param{'id'} = $id;
	} else {
		if ($param{'title'}) {
			$param{'id'} = $param{'title'};
			$param{'id'} =~ s/[^a-zA-Z0-9]//g;
		}
		# default window's id to hash of title
		#$param{'id'} = substr(md5_hex($param{'title'}), 0, 8);
	}

	WriteLog('GetWindowTemplate: $id = ' . $param{'id'});

	if (!$param{'title'}) {
		WriteLog('GetWindowTemplate: warning: untitled window; caller = ' . join(',', caller));
		$param{'title'} = 'Untitled';
	}

	return GetWindowTemplate2(\%param);
} # GetWindowTemplate()

sub GetWindowTemplate3 { # $body $title \%param
	# use when need several parameters and not much else
	my $body = shift;
	my $title = shift;

	my $paramHashRef = shift;
	my %param;
	if ($paramHashRef) {
		%param = %$paramHashRef;
	}

	WriteLog('GetWindowTemplate3($body = ' . $body . '; $title = ' . $title . '; %param has ' . length(keys(%param)) . ')');

	$param{'body'} = $body;
	$param{'title'} = $title;

	return GetWindowTemplate2(\%param);
} # GetWindowTemplate3()

sub GetWindowTemplate2 { # \%paramHash ; returns window
	# returns html-table-based-"window"
	my $paramHashRef = shift;
	my %param = %{$paramHashRef};

	#return GetWindowTemplate($param{'body'}, $param{'title'}, $param{'headings'}, $param{'status'}, $param{'menu'});

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

	WriteLog('GetWindowTemplate2: %param: ' . join(',', keys(%param)));
	WriteLog('GetWindowTemplate2: caller: ' . join(',', caller));

	my $windowBody = $param{'body'};
	my $windowTitle = $param{'title'};
	my $windowAnchor = $param{'anchor'};
	my $columnHeadings = $param{'headings'};
	my $columnHeadingsLookup = $param{'columns_lookup'};
	my $windowStatus =  $param{'status'};
	my $windowMenubarContent = $param{'menu'};
	my $formAction = $param{'form_action'};
	my $windowId = $param{'id'};

	if (!$windowAnchor) {
		WriteLog('GetWindowTemplate2: warning: $windowAnchor is FALSE, activating fallback; caller = ' . join(',', caller));
		if (!$windowAnchor && $windowId) {
			$windowAnchor = $windowId;
		}
		if (!$windowAnchor && $windowTitle) {
			$windowAnchor = str_replace(' ', '', $windowTitle);
			$windowAnchor =~ s/[^a-zA-Z0-9]//g;
			#todo
		}
		if (!$windowAnchor && $windowBody) {
			$windowAnchor = substr(md5_hex($windowBody), 0, 8);
		}
		if (!$windowAnchor) {
			WriteLog('GetWindowTemplate2: warning: $windowAnchor is FALSE after fallbacks; caller = ' . join(',', caller));
		}
	}

	my $tableSort; # it is on by default, contingent on settings
	if (exists $param{'table_sort'}) {
		$tableSort = $param{'table_sort'} ? 1 : 0;
	} else {
		$tableSort = 1;
	}

	#WriteLog('GetWindowTemplate2: $windowTitle = ' . $windowTitle . '; $tableSort = ' . $tableSort);

	my $contentColumnCount = 1;
	# stores number of columns if they exist
	# if no columns, remains at 0
	# whether there are columns or not determines:
	# * column headers are added or no?
	# * colspan= in non-column cells

	# base template
	my $windowTemplate = GetTemplate('html/window/standard.template');

	if ($windowId) {
		if ($windowId =~ m/^([0-9a-zA-Z_]+)$/) {
			$windowId = $1;
			WriteLog('GetWindowTemplate2: $windowId = ' . $windowId);
			$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'id', $windowId);
		} else {
			WriteLog('GetWindowTemplate2: warning: sanity check failed: $windowId = ' . $windowId);
		}
	} else {
		WriteLog('GetWindowTemplate2: $windowId is FALSE');
	}

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmousedown', 'this.style.zIndex = ++window.draggingZ;');

		$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmouseenter', 'if (window.SetActiveDialogDelay) { return SetActiveDialogDelay(this); }'); #SetActiveDialog() GetWindowTemplate2()
		$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmousedown', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetWindowTemplate2()
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'ontouchstart', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetWindowTemplate2()
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onfocus', 'if (window.SetActiveDialog) { SetActiveDialog(this); return true; }'); #SetActiveDialog()
	}

	my $showButtons = GetConfig('html/window_titlebar_buttons'); # titlebar hide and skip buttons;
	WriteLog('GetWindowTemplate2: $showButtons = ' . $showButtons);

	if (!$windowTitle) {
		WriteLog('GetWindowTemplate2: warning: title missing, using Untitled');
		$windowTitle = 'Untitled';
	}

	# titlebar, if there is a title
	if ($windowTitle) {
		WriteLog('GetWindowTemplate2: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle);

		if ($showButtons && GetConfig('admin/js/dragging')) {
			WriteLog('GetWindowTemplate2: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('admin/js/dragging'));

			my $btnCloseCaption = '#'; # needs to match one other place in dragging.js #collapseButton
			my $windowTitlebar = GetTemplate('html/window/titlebar_with_button.template'); #window_titlebar_buttons

			$windowTitlebar = AddAttributeToTag($windowTitlebar, 'button title=skip', 'onclick', "if (window.CollapseWindowFromButton) { return !CollapseWindowFromButton(this); } return false;");
			$windowTitlebar = AddAttributeToTag($windowTitlebar, 'td', 'ondblclick', "
				if (window.CollapseWindowFromButton) {
					var button = this.getElementsByClassName('skip');
					button = button[0];
					return CollapseWindowFromButton(button);
				} return false;
			");

			$windowTitlebar = InjectJs($windowTitlebar, qw(titlebar_with_button));

			$windowTitlebar =~ s/\$windowTitle/$windowTitle/g;
			$windowTitlebar =~ s/\$windowAnchor/$windowAnchor/g;
			$windowTemplate =~ s/\$windowTitlebar/$windowTitlebar/g;
			$windowTemplate =~ s/\$btnCloseCaption/$btnCloseCaption/g;
			#$contentColumnCount = 2;
		} else {
			my $windowTitlebar = GetTemplate('html/window/titlebar.template');
			#
			#			if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
			#				$windowTitlebar = AddAttributeToTag($windowTemplate, 'a href=#$windowAnchor', 'onfocus', 'document.title=this.innerHTML;');
			#				$windowTitlebar = AddAttributeToTag($windowTemplate, 'a href=#$windowAnchor', 'onclick', 'document.title=this.innerHTML;');
			#			}
			#
			$windowTitlebar =~ s/\$windowTitle/$windowTitle/g;
			$windowTitlebar =~ s/\$windowAnchor/$windowAnchor/g;
			$windowTemplate =~ s/\$windowTitlebar/$windowTitlebar/g;
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
		WriteLog('GetWindowTemplate: $columnHeadings is NUMERIC');
		$contentColumnCount = int($columnHeadings);
		$columnHeadings = '';
	} else {
		WriteLog('GetWindowTemplate: $columnHeadings is not numeric');
		#$columnHeadings = '';
	}

	# column headings
	if ($columnHeadings) {
		my $windowHeaderTemplate = GetTemplate('html/window/header_wrapper.template');
		my $windowHeaderColumns = '';
		my @columnsArray = split(',', $columnHeadings);

		my $printedColumnsCount = 0;
		my @fieldAdvanced = split("\n", GetTemplate('list/field_advanced'));
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
			if ($tableSort && GetConfig('admin/js/enable') && GetConfig('admin/js/table_sort')) {
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
				WriteLog('GetWindowTemplate2: $columnHeadingsLookup is TRUE');

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
			$windowTemplate =~ s/\$windowHeader//g;
		} else {
			$windowTemplate =~ s/\$windowHeader/$windowHeaderTemplate/;
		}
		$contentColumnCount = scalar(@columnsArray);
	} # / column headings
	else {
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
		if (
			!$columnHeadings &&
				(index(lc($windowBody), '<table') == -1) &&
				(index(lc($windowBody), '<tr') == -1)
		) {
			$windowBody = '<tr class=content><td>' . $windowBody . '</td></tr>';
		}
		elsif (index(lc($windowBody), '<tr') == -1) {
			if ($contentColumnCount > 1) {
				#todo templatize?
				$windowBody = '<tr class=content><td colspan=$contentColumnCount>' . $windowBody . '</td></tr>';
			} else {
				$windowBody = '<tr class=content><td>' . $windowBody . '</td></tr>';
			}
		} else {
			$windowBody = str_replace('$contentColumnCount', $contentColumnCount, $windowBody);
		}

		if (index(lc($windowBody), '<tbody') == -1) {
			$windowBody = '<tbody class=content>' . $windowBody . '</tbody>';
		}

		$windowTemplate =~ s/\$windowBody/$windowBody/g;
	} else {
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
		my $windowGuid = md5_hex($windowTemplate);
		if (defined($param{'guid'})) {
			if ($param{'guid'} =~ m/^[0-9a-f]{8}$/) {
				$windowGuid = $param{'guid'};
			} else {
				WriteLog('GetWindowTemplate2: warning: $param{guid} failed sanity check');
			}
		}

		my $itemEndAnchor = substr($windowGuid, 0, 8);
		WriteLog('GetWindowTemplate2: length($windowTemplate) = ' . length($windowTemplate) . '; $windowGuid = ' . $windowGuid);
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
} # GetWindowTemplate2()

1;