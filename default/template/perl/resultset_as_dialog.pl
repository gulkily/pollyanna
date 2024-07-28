#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use utf8;

sub GetResultSetAsDialog {# \@result, $title, $columns, \%flags
# \@result is an array of hash references
# $title = dialog title
# $columns = comma-separated column names. use '' if you don't want to specify
# %flags = flags
# no_no_results = returns empty string if no results
# query_sql = prints query in dialog (advanced layer) #todo
#
# ATTENTION: the first member of the @result array is the list of columns
# this list (and order) of columns is used if $columns parameter is not specified
#
# sub GetResultSet {

	##############################################################
	# PARAMETERS FISHING BEGINS

	my $resultRef = shift;
	my @result = @{$resultRef};

	my $title = shift;
	my $columnsParam = shift;
	my $columns = $columnsParam;

	my %flags;
	my $flagsRef = shift;
	if ($flagsRef) {
		%flags = %{$flagsRef};
		#todo sanity checks and check against list of allowed/supported
	}

	WriteLog('GetResultSetAsDialog($title = ' . ($title ? $title : 'FALSE') . '; caller: ' . join(', ', caller) . '; $columns = ' . ($columns ? $columns : 'FALSE') . ')');

	# PARAMETERS FISHING ENDS
	##############################################################


	##############################################################
	# COLUMN HEADERS SETUP BEGINS

	# IMPORTANT NOTE ABOUT COLUMN HEADERS
	# IMPORTANT NOTE ABOUT COLUMN HEADERS
	#
	# GetDialogX() actually prints the columns!
	# DON'T LOOK FOR COLUMN PRINTING HERE!
	# $columnsDisplay is passed into GetDialogX() later!
	# $columnsDisplay is a comma-delimited string
	# @fieldAdmin @fieldAdvanced
	#

	my $columnsRef = shift @result; # (reference) columns returned as first line of result

	my @columnsArray;

	if (!$columnsRef) {
		WriteLog('GetResultSetAsDialog: warning: $columnsRef is FALSE; caller = ' . join(',', caller));
	} else {
		@columnsArray = @{$columnsRef}; # columns returned as first line of result
	}

	my $columnsDisplay = '';

	if ($columns) {
		# columns specified in the sub call
		# trim any whitespace and rejoin
		my @columnsSpecified = split(',', $columns);
		my @columnsNew;
		for my $columnText (@columnsSpecified) {
			$columnText = trim($columnText);
			if ($columnText =~ m/^([0-9a-zA-Z_]+)$/) {
				#todo restrict length of column?
				$columnText = $1;
				push @columnsNew, trim($columnText);
			} else {
				WriteLog('GetResultSetAsDialog: warning: column name failed sanity check: ' . $columnText);
				push @columnsNew, 'untitled';
			}
		}
		$columns = join(',', @columnsNew);

		$columnsDisplay = $columns;
	} else {
		# if columns not specified, get them from resultset
		$columns = join(',', @columnsArray);
		if ($columns) {
			my $columnsComma = '';
			foreach my $columnItem (@columnsArray) {
				#my $columnString = GetString('field_name/' . $columnItem) || $columnItem;
				$columnsDisplay .= $columnsComma;
				#$columnsDisplay .= $columnString;
				$columnsDisplay .= $columnItem;
				if (!$columnsComma) {
					$columnsComma = ',';
				}
			}
		}
	}

	# $columnsDisplay will be passed to GetDialogX() below

	# COLUMN HEADERS SETUP ENDS
	##############################################################

	my $resultCount = scalar(@result); #count rows

	WriteLog('GetResultSetAsDialog: $title = ' . ($title ? $title : 'FALSE') . '; $resultCount = ' . ($resultCount ? $resultCount : 'FALSE (or 0)') . '; $columnsDisplay = ' . ($columnsDisplay ? $columnsDisplay : 'FALSE'));


	if (@result) {
		##############################################################
		# SETUP BEGINS

		my $colorRow0Bg = GetThemeColor('row_0');
		my $colorRow1Bg = GetThemeColor('row_1');
		my $rowBgColor = $colorRow0Bg;

		my $content = '';
		my $checkColumnCount = 0;

		my $modernMode = 0;
		if (in_array('modern', GetActiveThemes())) {
			#todo this is a hard-coded hack, pls fix #hack #fixme
			#todo this should be memoized, and the memo clearing should be linked to GetActiveThemes()
			$modernMode = 1;
		}

		# SETUP ENDS
		##############################################################

		foreach my $row (@result) {
			if (GetConfig('html/hash_color_table_rows') && $row->{'file_hash'}) {
				# hash-colored table rows
				$rowBgColor = GetStringHtmlColor($row->{'file_hash'});
				$rowBgColor = substr($rowBgColor, 1);
				$rowBgColor = LightenColor($rowBgColor);
				$rowBgColor = '#' . $rowBgColor;
			} else {
				# theme-colored alternating row colors
				if ($rowBgColor eq $colorRow0Bg) {
					$rowBgColor = $colorRow1Bg;
				} else {
					$rowBgColor = $colorRow0Bg;
				}
			}
			if ($row->{'this_row'}) {
				$rowBgColor = GetThemeColor('highlight_alert');
			}
			if ($row->{'labels_list'} && (index($row->{'labels_list'}, 'mourn') != -1)) {
				$rowBgColor = '#000000';
			}

			if ($modernMode) {
				$content .= '<tr>';
			}
			else {
				if (0 && $row->{'this_row'}) {
					# selected row, highlight it, selected_row, row_selected
					$content .= '<tr bgcolor="' . GetThemeColor('highlight_alert') . '">';
				}
				else {
					# use specified bg color
					$content .= '<tr bgcolor="' . $rowBgColor . '">';
				}
			}

			# row color above

			my @fieldAdvanced = GetConfigListAsArray('field_advanced');
			my @fieldAdmin = GetConfigListAsArray('field_admin');
			# fields_advanced advanced_fields advancedfields

			foreach my $column (split(',', $columns)) {
				#print $column . ',' . $row->{$column} . "\n";
				if (in_array($column, @fieldAdvanced)) { #  advanced column column_advanced
					#this hides the file_hash column from non-advanced users
					$content .= '<td class=advanced>';
				}
				elsif (in_array($column, @fieldAdmin)) { #  admin column admin_advanced
					#this hides the file_hash column from non-admin users
					$content .= '<td class=admin>';
				}
				else {
					$content .= '<td>';
				}

				$checkColumnCount++;

				WriteLog('GetResultSetAsDialog: calling RenderField($column = ' . ($column ? $column : 'N/A') . ', $row->{$column} = ' . ($row->{$column} ? $row->{$column} : 'N/A') . ', $row = ' . ($row ? $row : 'N/A') . ')');

				if (!defined($row->{$column})) {
					WriteLog('GetResultSetAsDialog: warning: $row->{$column} is UNDEFINED; $column = ' . $column . '; caller = ' . join(',', caller));
				}

				my $renderedField = RenderField($column, $row->{$column}, $row);

				#todo if $renderedField is only one <a href=></a>, add display:block to it

				if ($renderedField) {
					$content .= $renderedField;
				} else {
					WriteLog('GetResultSetAsDialog: warning: $renderedField is FALSE. caller = ' . join(',', caller));
				}

				$content .= '</td>';
				$content .= "\n";
			}
			$content .= '</tr>';
			$content .= "\n";
		} # foreach $row (@result)

		if ($flags{'query'} && GetConfig('setting/html/debug_resultset_dialog_print_query')) {
			my $columnsCount = scalar(@columnsArray);
			my $query = SqliteGetQueryTemplate($flags{'query'});
			$content .= '<tr class=advanced><td class=sql colspan=' . $columnsCount . '>';
			$content .= SqlForWeb($query) . '<br>';
			#$content .= '<pre>' . HtmlEscape($query) . '<br></pre>';
			$content .= '</td></tr>';
		}

		if ($checkColumnCount % scalar(@columnsArray)) {
			WriteLog('GetResultSetAsDialog: warning: column count sanity check failed; $columnsParam = ' . ($columnsParam ? $columnsParam : 'FALSE'));
			WriteLog('GetResultSetAsDialog: warning: number of printed row-columns does not evenly divide into number of columns');
		} # if ($checkColumnCount % scalar(@columnsArray))

		#todo
		my $statusText = ''; #todo
		#my $resultsUrl = "/" . lc($title) . ".html";
		#my $resultsLink = RenderLink($resultsUrl, $title);
		#my $statusText = $resultCount . ' item(s); full results: ' . $resultsLink;
		#if ($flags{'query'}) {
		#	$statusText .= ' (query: ' . $flags{'query'} . ')';
		#}
		#if ($flags{'page_current'}) {
		#	$statusText .= ' (page ' . $flags{'page_current'} . ' of ' . $flags{'page_item_count'} . ')';
		#} #todo

		if (GetConfig('setting/html/resultset_dialog_footer_link')) {
			if ($flags{'query'}) {
				#todo link full results page, display how many results there are
				my $queryCount = $flags{'query'};
				if ($queryCount =~ m/(LIMIT [0-9]+)$/i) {
					$queryCount =~ s/(LIMIT [0-9]+)$//i;
				}
				$queryCount = "SELECT COUNT(*) FROM ($queryCount)";
				my $resultCount = SqliteGetValue($queryCount);

				if ($resultCount) {
					$statusText = $resultCount . ' item(s)';
					if ($flags{'results_page'}) {
						WriteLog('GetResultSetAsDialog: $flags{results_page} = ' . $flags{'results_page'} . '; caller = ' . join(',', caller));
						#$statusText .= '<a href="/' . $flags{'results_page'} . '">' . $flags{'results_page'} . '</a>';
						$statusText = ' <a href="/' . $flags{'results_page'} . '">' . $statusText . '</a>';
					}

					$statusText = $resultCount . ' item(s)';
					if ($flags{'results_page'}) {
						WriteLog('GetResultSetAsDialog: $flags{results_page} = ' . $flags{'results_page'} . '; caller = ' . join(',', caller));
						#$statusText .= '<a href="/' . $flags{'results_page'} . '">' . $flags{'results_page'} . '</a>';
						$statusText = ' <a href="/' . $flags{'results_page'} . '">' . $statusText . '</a>';
					}
				}
			}
		}

		#return GetDialogX($content, $title, $columnsDisplay, $statusText);

		my %param;
		$param{'headings'} = $columnsDisplay;
		$param{'status'} = $statusText;

		$param{'no_heading'} = $flags{'no_heading'}; # doing it this way so that the column count is still correct
		$param{'no_status'} = $flags{'no_status'}; # meh
		if ($flags{'id'}) {
			# pass id on to the window id
			$param{'id'} = $flags{'id'};
		}

		if (0) { #todo pagination
			$flags{'page_query'} = 'compost';
			$flags{'page_current'} = 1;
			$flags{'page_item_count'} = 500;
			$flags{'page_items_per_page'} = 25;

			if ($flags{'page_query'} && $flags{'page_current'} && $flags{'page_item_count'} && $flags{'page_items_per_page'}) { # #pagination
				require_once('pagination_links.pl');
				my $paginationLinks = GetPaginationLinks($flags{'page_query'}, $flags{'page_current'}, $flags{'page_item_count'}, $flags{'page_items_per_page'});
				$param{'status'} = $paginationLinks;
			}
		}

		if (GetConfig('debug')) {
			#todo
			#$param{'debug_message'} = 'GetResultSetAsDialog: caller = ' . join(',', caller);
		}

		require_once('dialog.pl');
		return GetDialogX3($content, $title, \%param);
	} else {
		# empty results
		# no_results
		if ($flags{'no_no_results'}) {
			WriteLog('GetResultSetAsDialog: no_results: returning empty string due to $flags{no_no_results}');
			return '';
		} else {
			WriteLog('GetResultSetAsDialog: no_results: returning space reserved for future content dialog; caller = ' . join(',', caller));
			require_once('dialog.pl');
			my %flagsNoResults = (
				'status' => '<fieldset><description>Query took 0.00031415952 second(s)<span class=advanced>:</span></description><span class=advanced><br><code class=sql><tt>' . SqlForWeb($flags{'query'}) . '</tt></code></span></fieldset>'
			);
			return GetDialogX3('<fieldset><p>This space reserved for future content...</p></fieldset>', $title, \%flagsNoResults); # GetResultSetAsDialog()
		}
	}
} # GetResultSetAsDialog()



1;
