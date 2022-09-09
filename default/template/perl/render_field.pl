use strict;
use warnings;
use 5.010;

sub RenderField { # $fieldName, $fieldValue, [%rowData] ; outputs formatted data cell
# outputs $fieldValue after formatting it as needed
# formatting is based on value of $fieldName
# if additional datapoint is needed for output, it's read from %rowData
# has some special conditions for GetItemAttributesDialog() which should be not here but how?
	my $fieldName = shift;
	my $fieldValue = shift;

	#todo if special_* is present, then the included fields should not be printed by default

	WriteLog('RenderField()');

	if (!defined($fieldName) || !defined(!$fieldValue)) {
		WriteLog('RenderField: warning: missing $fieldName or $fieldValue; caller = ' . join(',', caller));
		#return '';
	}

	if (defined($fieldName)) {
		WriteLog('RenderField: $fieldName = ' . $fieldName);
	} else {
		WriteLog('RenderField: warning: $fieldName NOT DEFINED; caller = ' . join(', ', caller));
	}
	if (defined($fieldValue)) {
		WriteLog('RenderField: $fieldValue = ' . $fieldValue);
	} else {
		WriteLog('RenderField: warning: $fieldValue NOT DEFINED; caller = ' . join(', ', caller));
	}

	#todo more sanity

	my $itemRowRef = shift;

#	if (!$itemRowRef) {
#		WriteLog('RenderField: warning: missing $itemRowRef; caller = ' . join(',', caller));
#		return '';
#	}

	my %itemRow;
	if ($itemRowRef) {
		%itemRow = %{$itemRowRef};
	}

	my $longMode = 0; #attrmode #attributes #itemattributes
	if ($itemRow{'attribute'} && $itemRow{'value'}) { #attrmode #attributes #itemattributes
		##### this is special hack for item attributes dialog
		##### this is special hack for item attributes dialog
		##### this is special hack for item attributes dialog
		##### this is special hack for item attributes dialog
		##### this is special hack for item attributes dialog
		# GetItemAttributesDialog {
		if ($fieldName eq 'attribute') {
			$fieldValue = '<span title="' . $itemRow{'attribute'} . '">' . GetString('item_attribute/' . $itemRow{'attribute'}) . '</span>' . ':';
		}
		if ($fieldName eq 'value') {
			$fieldName = $itemRow{'attribute'};

			if ($fieldName eq 'title') {
				$fieldValue = HtmlEscape($fieldValue);
			}

			if ($fieldName eq 'chain_checksum_good') {
				if ($fieldValue eq '0') {
					$fieldValue = '<font color=red>No</font>';
				} else {
					$fieldValue = '<font color=green>Yes</font>';
				}
			}
		}
		$longMode = 1;
	}

	if (0) { # just a placeholder to make all the elsif statements look similar
	}

	elsif ($fieldName eq 'last_seen') {
		$fieldValue = GetTimestampWidget($fieldValue);
	}

	elsif (
		$fieldName eq 'author_id' ||
		$fieldName eq 'cookie_id' ||
		$fieldName eq 'gpg_id'
	) {
		# turn author key into linked avatar
		if ($longMode) {
			$fieldValue = GetAuthorLink($fieldValue) . ' <tt class=advanced> ' . $fieldValue . '</tt>';
		} else {
			$fieldValue = GetAuthorLink($fieldValue);
		}
	}

	elsif ($fieldName eq 'vote_value') {
		#todo redo
		my $tagColor = GetStringHtmlColor($fieldValue);
		my $link = "/top/" . $fieldValue . ".html";
		my $linkText = '<font color="' . $tagColor . '">#</font>' . $fieldValue;
		$fieldValue = RenderLink($link, $linkText);
	}

	elsif ($fieldName =~ /.+timestamp/) {
		if ($longMode) {
			$fieldValue = GetTimestampWidget($fieldValue) . ' <tt class=advanced> ' . $fieldValue . '</tt>';
		} else {
			$fieldValue = GetTimestampWidget($fieldValue);
		}
	}

	elsif (
		$fieldName eq 'git_hash_object' ||
		$fieldName eq 'normalized_hash' ||
		$fieldName eq 'sha1' ||
		$fieldName eq 'sha1sum' ||
		$fieldName eq 'sha256sum' ||
		$fieldName eq 'md5' ||
		$fieldName eq 'chain_hash' ||
		$fieldName eq 'message_hash'
	) { #todo make it match on _hash and use _hash on the names
		$fieldValue = '<tt>' . $fieldValue . '</tt>';
	}

	elsif (
		$fieldName eq 'item_url' ||
		$fieldName eq 'https' ||
		$fieldName eq 'http' ||
		$fieldName eq 'url'
	) { #url
		if (length($fieldValue) < 64) {
			$fieldValue = '<a href="' . HtmlEscape($fieldValue) . '">' . HtmlEscape($fieldValue) . '';
		} else {
			$fieldValue =
				'<a href="' .
					HtmlEscape($fieldValue) .
				'">' .
					HtmlEscape(
						substr(
							$fieldValue,
							0,
							60
						) .
						'...'
					) .
				''
			;
		}
	}

	elsif ($fieldName eq 'item_title') {
		if (%itemRow && $itemRow{'file_hash'}) {
			if ($itemRow{'this_row'}) {
				$fieldValue = '<b>' . HtmlEscape($fieldValue) . '</b>';
				#todo there's a bug here
				#Use of uninitialized value in concatenation (.) or string at ...render_field.pl line 138.
			} else {
				$fieldValue = '<b>' . GetItemHtmlLink($itemRow{'file_hash'}, $fieldValue) . '</b>';
			}
		}
	}

	elsif ($fieldName eq 'file_hash') {
		if ($fieldValue) {
			$fieldValue = substr($fieldValue, 0, 8);
		} else {
			$fieldValue = '';
		}
	}

	elsif ($fieldName eq 'tags_list') {
		if ($fieldValue) {
			$fieldValue = GetTagsListAsHtmlWithLinks($fieldValue);
		} else {
			$fieldValue = '';
		}
	}

	elsif ($fieldName eq 'chain_previous') {
		if ($fieldValue) {
			my $itemHash = substr($fieldValue, 0, 40); #todo unhack
			$fieldValue = GetItemHtmlLink($itemHash, DBGetItemTitle($itemHash, 16));
		} else {
			$fieldValue = '';
		}
	}

	elsif ($fieldName eq 'chain_next') {
		if ($fieldValue) {
			my $itemHash = substr($fieldValue, 0, 40); #todo unhack
			$fieldValue = GetItemHtmlLink($itemHash, DBGetItemTitle($itemHash, 16));
		} else {
			$fieldValue = '';
		}
	}

	elsif ($fieldName eq 'local_path') {
		#todo templatize
		$fieldValue = '<a href="file://' . HtmlEscape($fieldValue) . '">' . HtmlEscape($fieldValue) . '</a>';
	}

	elsif ($fieldName eq 'file_path') {
		# link file path to file
		state $HTMLDIR = GetDir('html'); #todo
		#problem here is GetDir() returns full path, but here we already have relative path
		#currently we assume html dir is 'html'

		my $fileLocalPath = 'html/' . $fieldValue;
		my $fileClientPath = $fieldValue;
		$fileClientPath =~ s/^html\//\//; #dirty #hack #bughere

		WriteLog('RenderField: warning: file_path is using hard-coded path to HTML dir');

		$fieldValue = ''; # initialize/reset

		$fieldValue .= '<a href="' . HtmlEscape($fileClientPath) . '">' . HtmlEscape($fileClientPath) . '</a>';

		#hack #dirty #todo #performance
		if (-e $fileLocalPath) {
			if (GetConfig('admin/index/stat_file')) { #todo put this somewhere else?
				my @fileStat = stat($fileLocalPath);
				my $fileSize =    $fileStat[7];
				my $fileModTime = $fileStat[9];

				if ($fileModTime) {
					$fieldValue .= '<br>';
					$fieldValue .= GetTimestampWidget($fileModTime) . ' <tt class=advanced>' . $fileModTime . '</tt>';
					$fieldValue .= '; ';
					$fieldValue .= GetFileSizeWidget($fileSize) . ($fileSize > 1024 ? ' <tt class=advanced>' . $fileSize . '</tt>' : '');
				}
			}
		} else {
			WriteLog('RenderField: warning: file_path: file does not exist: ' . $fileLocalPath);
		}

	}

#
#	if ($itemRow{'file_size'}) {
#		if ($itemRow{'file_size'} > 1024) {
#			$fieldValue .= GetFileSizeWidget($itemRow{'file_size'}) . ' <tt class=advanced>' . $itemRow{'file_size'} . '</tt>';
#		} else {
#			$fieldValue .= GetFileSizeWidget($itemRow{'file_size'});
#		}
#	}

	elsif (substr($fieldName, 0, 7) eq 'tagset_' && !$fieldValue) {
		if (length($fieldName) > 7) {
			my $tagsetName = substr($fieldName, 7);
			if (GetTemplate('tagset/' . $tagsetName)) {
				$fieldValue .= GetItemTagButtons($itemRow{'file_hash'}, $tagsetName);
				if (GetConfig('setting/html/reply_cart')) {
					require_once('widget/add_to_reply_cart.pl');
					#$fieldValue .= '; ';
					#$fieldValue =~ s|</a>([^;])|</a>;$1|;
					$fieldValue .= GetAddToReplyCartButton($itemRow{'file_hash'});
				}
			}
		}
	}
	elsif (
		substr($fieldName, 0, 8) eq 'special_' &&
		!$fieldValue &&
		length($fieldName) > 8 &&
		%itemRow
	) {
		# special field name which produces several things joined together
		# it's a bit of a hack, but it works
		#
		# the field value should be empty
		#
		# in the query, it looks like this:
		#    SELECT
		#		'' AS special_title_tags_list, <-- special field
		#		file_hash, <-- used for populating special field
		#		item_title, <-- used for populating special field
		#		tags_list, <-- used for populating special field
		#		author_id <-- used for populating special field
		#	FROM
		#		item_flat
		#	WHERE ...

		if (1) {
			#todo add #sanity

			my $specialName = substr($fieldName, 8);
			if ($specialName eq 'title_tags_list') {
				# title, tags list, and author avatar (if any)
				# special_title_tags_list
				# this should become a template
				$fieldValue =
					'<b>' .
						GetItemHtmlLink($itemRow{'file_hash'}, $itemRow{'item_title'}) .
					'</b>' .
					($itemRow{'tags_list'} ? # only print this part if there's something in tags_list
						'<br>'.
						'<span style="float:right">' .
							GetTagsListAsHtmlWithLinks($itemRow{'tags_list'}) .
						'</span>'
						:'' # otherwise print nothing
					)
				;
			}
			if ($specialName eq 'title_tags_list_author') {
				# title, tags list, and author avatar (if any)
				# special_title_tags_list_author
				# this should become a template
				$fieldValue =
					'<b>' .
						GetItemHtmlLink($itemRow{'file_hash'}, $itemRow{'item_title'}) .
					'</b>' .
					($itemRow{'tags_list'} ? # only print this part if there's something in tags_list
						'<br>'.
						'<span style="float:right">' .
							GetTagsListAsHtmlWithLinks($itemRow{'tags_list'}) .
							($itemRow{'author_id'} ? '; ' . GetAuthorLink($itemRow{'author_id'}) : '') .
						'</span>'
						:'' # otherwise print nothing
					)
				;
			}
		}
	}
	#
	#	if ($fieldName eq 'tagset_compost') {
	#		if (%itemRow && $itemRow{'file_hash'}) {
	#			$fieldValue .= GetItemTagButtons($itemRow{'file_hash'}, 'compost');
	#		}
	#	}
	#
	#	if ($fieldName eq 'tagset_author') {
	#		if (%itemRow && $itemRow{'file_hash'}) {
	#			$fieldValue .= GetItemTagButtons($itemRow{'file_hash'}, 'author');
	#		}
	#	}

	elsif (
		# these are just valid fields!

		$fieldName eq 'attribute' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'author_key' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'chain_order' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'chain_sequence' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'gpg_alias' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'item_count' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'item_score' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'item_type' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'this_row' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'title' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'url_domain' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'vote_count' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'author_score' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'chain_checksum_good' || # RenderField() not to be confused with field_advanced
		$fieldName eq 'boxes' || # RenderField() not to be confused with field_advanced (this is for banana theme)
		0 # this is here to make above more consistent
	) {
		#cool
	}


	else {
		#if (trim($fieldValue) eq '' || (!$fieldValue && $fieldValue != 0 && $fieldValue ne '0')) {
		if (!$fieldValue) {
			WriteLog('RenderField: warning: unhandled $fieldValue is also missing; $fieldName = ' . $fieldName . '; caller: ' . join(', ', caller));
			$fieldValue = '-';
		} else {
			WriteLog('RenderField: warning: unhandled $fieldName = ' . (($fieldName || $fieldName == 0) ? $fieldName : 'FALSE') . '; $fieldValue = ' . (($fieldValue || $fieldValue == 0) ? $fieldValue : 'FALSE') . '; caller: ' . join(', ', caller));
			$fieldValue = htmlspecialchars($fieldValue);
		}
	}
	
	return $fieldValue;
} # RenderField()

1;
