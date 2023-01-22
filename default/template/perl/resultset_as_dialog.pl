#!/usr/bin/perl

# use strict;
use warnings;

sub GetResultSetAsDialog {# \@result, $title, $columns, \%flags
# \@result is an array of hash references
# $title = dialog title
# $columns = comma-separated column names. use '' if you don't want to specify
# %flags = flags
# no_no_results = returns empty string if no results
#
# ATTENTION: the first member of the @result array is the list of columns
# this list (and order) of columns is used if $columns parameter is not specified

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
	# GetWindowTemplate() actually prints the columns!
	# DON'T LOOK FOR COLUMN PRINTING HERE!
	# $columnsDisplay is passed into GetWindowTemplate() later!
	# $columnsDisplay is a comma-delimited string
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

	# $columnsDisplay will be passed to GetWindowTemplate() below

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
			if ($row->{'tags_list'} && (index($row->{'tags_list'}, 'mourn') != -1)) {
					$rowBgColor = '#000000';
			}

			if (0 && $row->{'this_row'}) {
				# selected row, highlight it
				$content .= '<tr bgcolor="' . GetThemeColor('highlight_alert') . '">';
			} else {
				# use specified bg color
				$content .= '<tr bgcolor="' . $rowBgColor . '">';
			}

			# row color above

			my @fieldAdvanced = GetConfigListAsArray('field_advanced');

			foreach my $column (split(',', $columns)) {
				#print $column . ',' . $row->{$column} . "\n";
				if (in_array($column, @fieldAdvanced)) { #  advanced column column_advanced
					#this hides the file_hash column from non-advanced users
					$content .= '<td class=advanced>';
				} else {
					$content .= '<td>';
				}

				$checkColumnCount++;

				WriteLog('GetResultSetAsDialog: calling RenderField($column = ' . ($column ? $column : 'N/A') . ', $row->{$column} = ' . ($row->{$column} ? $row->{$column} : 'N/A') . ', $row = ' . ($row ? $row : 'N/A') . ')');

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

		if ($flags{'query'} && GetConfig('setting/html/resultset_dialog_print_query')) {
			my $columnsCount = scalar(@columnsArray);
			my $query = SqliteGetQueryTemplate($flags{'query'});
			$content .= '<tr class=advanced><td colspan=' . $columnsCount . '>';
			$content .= HtmlEscape($query) . '<br>';
			#$content .= '<pre>' . HtmlEscape($query) . '<br></pre>';
			$content .= '</td></tr>';
		}

		if ($checkColumnCount % scalar(@columnsArray)) {
			WriteLog('GetResultSetAsDialog: warning: column count sanity check failed; $columnsParam = ' . ($columnsParam ? $columnsParam : 'FALSE'));
			WriteLog('GetResultSetAsDialog: warning: number of printed row-columns does not evenly divide into number of columns');
		}

		my $statusText = $resultCount . ' item(s)';

		#return GetWindowTemplate($content, $title, $columnsDisplay, $statusText);

		my %param;
		$param{'headings'} = $columnsDisplay;
		$param{'status'} = $statusText;

		$param{'no_heading'} = $flags{'no_heading'}; # doing it this way so that the column count is still correct
		$param{'no_status'} = $flags{'no_status'}; # meh
		if ($flags{'id'}) {
			# pass id on to the window id
			$param{'id'} = $flags{'id'};
		}

		require_once('get_window_template.pl');
		return GetWindowTemplate3($content, $title, \%param);
	} else {
		# empty results
		if ($flags{'no_no_results'}) {
			return '';
		} else {
			require_once('get_window_template.pl');
			return GetWindowTemplate('This space reserved for future content.', $title);
		}
	}
} # GetResultSetAsDialog()



1;
