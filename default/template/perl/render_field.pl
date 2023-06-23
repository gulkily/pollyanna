#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub RenderField { # $fieldName, $fieldValue, [%rowData] ; outputs formatted data cell
# sub fieldformat {
# sub formatfield {
# sub FieldFormat {
# sub FormatField {
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
	#
	# if (!$itemRowRef) {
	# 	WriteLog('RenderField: warning: missing $itemRowRef; caller = ' . join(',', caller));
	# 	return '';
	# }

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

	if (0) {} # placeholder to make all the elsif statements below consistent

	elsif (
		$fieldName eq 'author_id' ||
		$fieldName eq 'cookie_id' ||
		$fieldName eq 'gpg_id'
	) {
		# author identifier as 16-character uppercase hexadecimal
		# example: A0B1C2D3E4F56789

		if ($fieldValue) {
			# turn author key into linked avatar
			require_once('widget/author_link.pl');
			if ($longMode) {
				$fieldValue = GetAuthorLink($fieldValue) . ' <tt class=advanced> ' . $fieldValue . '</tt>';
			} else {
				$fieldValue = GetAuthorLink($fieldValue);
			}
		} else {
			WriteLog('RenderField: warning: $fieldValue was FALSE, not calling GetAuthorLink()');
			$fieldValue = 'Guest'; #todo is this right?
		}
	}

	elsif (
		$fieldName eq 'vote_value'
	) {
		# vote_value field should contain one tag
		# example: good
		#todo redo and sanity check

		my $tagColor = GetStringHtmlColor($fieldValue);
		my $link = "/tag/" . $fieldValue . ".html";
		my $linkText = '<font color="' . $tagColor . '">#</font>' . $fieldValue;
		$fieldValue = RenderLink($link, $linkText);
	}

	elsif (
		$fieldName =~ m/.+timestamp$/ ||
		$fieldName =~ m/.+start$/ ||
		$fieldName =~ m/.+finish$/ ||
		$fieldName eq 'last_seen'
	) {
		# timestamp in epoch format, displayed as a timestamp widget
		# example: 1675297480

		if ($longMode) {
			$fieldValue = GetTimestampWidget($fieldValue) . ' <tt class=advanced> ' . $fieldValue . '</tt>';
		} else {
			$fieldValue = GetTimestampWidget($fieldValue);
		}
	}

	elsif (
		$fieldName eq 'git_hash_object' ||
		$fieldName eq 'sha1' ||
		$fieldName eq 'sha1sum' ||
		$fieldName eq 'sha256sum' ||
		$fieldName eq 'md5' ||
		$fieldName eq 'chain_hash' ||
		$fieldName eq 'message_hash'
	) {
		# various hashes, displayed in fixed-width font
		#todo make it match on _hash and use _hash on the names

		$fieldValue = '<tt>' . $fieldValue . '</tt>';
	}

	elsif (
		$fieldName eq 'item_url' ||
		$fieldName eq 'https' ||
		$fieldName eq 'http' ||
		$fieldName eq 'url'
	) {
		# url, displayed as hyperlink, and shortened to 60 characters if necessary
		# example: http://www.yavista.com/
		# example: https://www.yavista.com/

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

	elsif (
		$fieldName eq 'file_hash'
	) {
		# file hash, displayed as first 8 characters
		#
		# not sure why this is handled differently from all the other hashes above,
		# BUT i think it because file_hash is used mainly in tabular listings,
		# where horizontal space is at a premium, while the above fields are
		# mainly used in vertical listings in item attributes dialog
		#
		# <tt> is not used here because it would add a lot to page weight
		# when there is a long list of results

		if ($fieldValue) {
			$fieldValue = substr($fieldValue, 0, 8);
		} else {
			$fieldValue = '';
		}
	}

	elsif (
		$fieldName eq 'item_title'
	) {
		# item title, displayed as shortened version
		# if row also includes file_hash field, it is linked to item's page

		if (%itemRow && $itemRow{'file_hash'}) {
			if ($itemRow{'this_row'}) {
				$fieldValue = '<b>' . HtmlEscape($fieldValue) . '</b>';
				#todo there's a bug here
				#Use of uninitialized value in concatenation (.) or string at ...render_field.pl line 138.
			} else {
				require_once('widget/item_html_link.pl');

				# this is a bit hacky, but it works
				# includes small thumbnail of image
				if ($itemRow{'item_type'} && ($itemRow{'item_type'} eq 'image')) {
					#todo use GetImageContainer()
					my $fileHash = $itemRow{'file_hash'};
					my $imageSmallUrl = "/thumb/thumb_42_$fileHash.gif";
					my $imageContainer = "<img border=1 src=$imageSmallUrl style=height:1em;vertical-align:middle;margin-right:0.3em>";
					$fieldValue = $imageContainer . HtmlEscape($fieldValue);
				} else {
					$fieldValue = HtmlEscape($fieldValue);
				}

				my %flags;
				$flags{'do_not_escape_html_characters'} = 1;
				$fieldValue = '<b>' . GetItemHtmlLink($itemRow{'file_hash'}, $fieldValue, 0, \%flags) . '</b>';
			}
		}
	}

	elsif (
		$fieldName eq 'tags_list'
	) {
		# list of tags, to be displayed as links to tag pages
		# preceding and trailing commas are ignored
		# example: ,like,good,flag,approve,interesting,

		if ($fieldValue) {
			$fieldValue = GetTagsListAsHtmlWithLinks($fieldValue);
		} else {
			$fieldValue = '';
		}
	}

	elsif (
		$fieldName eq 'chain_next' ||
		$fieldName eq 'chain_previous'
	) {
		# links to previous and next items in notarization chain
		# this field has a performance hit, since there is a lookup
		# something to do here would be to allow chain_next_title and chain_previous_title
		#   as complementary fields in the resultset

		if ($fieldValue) {
			my $itemHash = substr($fieldValue, 0, 40); #todo unhack
			$fieldValue = GetItemHtmlLink($itemHash, DBGetItemTitle($itemHash, 16));
		} else {
			$fieldValue = '';
		}
	}

	elsif (
		$fieldName eq 'local_path'
	) {
		# local file path, usually useful when running local instance
		# example: /home/username/hike/html/txt/aa/bb/aabbccddeeff00112233445566778899.txt
		# becomes prefixed with file:// for direct navigation if browser supports it
		# (most browsers block this type of link nowadays, even on localhost)
		# depends on local_path attribute being added to item_attribute table,
		# which is controlled by: config/setting/admin/index/index_local_path_as_attribute
		#todo templatize

		#$fieldValue = '<a href="file://' . HtmlEscape($fieldValue) . '">' . HtmlEscape($fieldValue) . '</a>';
		$fieldValue = '<form><input onclick="if (this.select) { this.select() }" spellcheck=false type=text size=60 value="' . HtmlEscape($fieldValue) . '"></form>';
	}

	elsif (
		$fieldName eq 'file_path'
	) {
		# path to source file, which should become hyperlink

		state $HTMLDIR = GetDir('html'); #todo this is not currently used
		#problem here is GetDir() returns full path, but here we already have relative path
		#currently we assume html dir is 'html'

		my $fileLocalPath = 'html/' . $fieldValue;
		my $fileClientPath = $fieldValue;
		$fileClientPath =~ s/^html\//\//; #dirty #hack #bughere

		WriteLog('RenderField: warning: file_path is using hard-coded path to HTML dir; caller: ' . join(',', caller));
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
			WriteLog('RenderField: warning: file_path: file does not exist: ' . $fileLocalPath . '; caller = ' . join(',', caller));
		}

	}

	# if ($itemRow{'file_size'}) {
	# 	if ($itemRow{'file_size'} > 1024) {
	# 		$fieldValue .= GetFileSizeWidget($itemRow{'file_size'}) . ' <tt class=advanced>' . $itemRow{'file_size'} . '</tt>';
	# 	} else {
	# 		$fieldValue .= GetFileSizeWidget($itemRow{'file_size'});
	# 	}
	# }

	elsif (
		substr($fieldName, 0, 7) eq 'tagset_' && !$fieldValue
	) {
		# placeholder field for voting buttons from tagset
		#
		# in the query, it should look like this:
		# 	SELECT
		#		'' AS tagset_compost,
		#		...
		#	FROM
		#		...
		#
		# above would create voting buttons for all tags in config/template/tagset/compost

		if (length($fieldName) > 7) {
			my $tagsetName = substr($fieldName, 7);
			if (GetTemplate('tagset/' . $tagsetName)) {
				if ($tagsetName eq 'inbox') {
					# special case for inbox button, which would hide the row
					# but it currently keeps the actual vote from happening, so that's why
					# the AddAttributeToTag() below is commented out
					#todo make this dependent on the inbox feature
					my $voteButton = GetItemTagButtons($itemRow{'file_hash'}, $tagsetName);
					#$voteButton = AddAttributeToTag($voteButton, 'a', 'onmouseup', "if (window.GetParentElement) { var pe = GetParentElement(this, 'TR'); if (pe) { pe.remove() } }");
					#this works, but keeps the actual voting from firing
					$fieldValue .= $voteButton;
				} else {
					if ($itemRow{'file_hash'} && IsItem($itemRow{'file_hash'})) {
						$fieldValue .= GetItemTagButtons($itemRow{'file_hash'}, $tagsetName);
						if (GetConfig('setting/html/reply_cart')) {
							require_once('widget/add_to_reply_cart.pl');
							#$fieldValue .= '; ';
							#$fieldValue =~ s|</a>([^;])|</a>;$1|;
							$fieldValue .= GetAddToReplyCartButton($itemRow{'file_hash'});
						} else {
							WriteLog('RenderField: warning: $itemRow{\'file_hash\'} failed sanity check; caller = ' . join(',', caller));
							# do nothing
						}
					}
				}
			}
		}
	}

	elsif (
		$fieldName eq 'cart' && !$fieldValue
	) {
		# +cart button placeholder field
		#
		# in the query, it should look like this:
		# 	SELECT
		#		'' AS cart,
		#		...
		#	FROM
		#		...
		if (GetConfig('setting/html/reply_cart')) {
			require_once('widget/add_to_reply_cart.pl');
			$fieldValue .= GetAddToReplyCartButton($itemRow{'file_hash'});
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

			my $specialName = substr($fieldName, 8); # remove 'special_' prefix from field name

			if (0) {} # placeholder to make all other elsif statements consistent
			elsif ($specialName eq 'title_tags_list') {
				# title, tags list, and author avatar (if any)
				# special_title_tags_list
				# this should become a template

				#todo sanity check for all required fields being present

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
			elsif ($specialName eq 'title_tags_list_author') {
				# title, tags list, and author avatar (if any)
				# special_title_tags_list_author
				# this should become a template

				#todo sanity check for all required fields being present

				require_once('widget/author_link.pl');
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
			else {
				WriteLog('RenderField: warning: unknown field type: $fieldName = ' . $fieldName . '; caller = ' . join(',', caller));
				return '';
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
		# these are just valid fields which can be displayed as is
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
		$fieldName eq 'file_size' || # RenderField() not to be confused with field_advanced (this is for banana theme)
		0 # this is here to make formatting above more consistent
	) {
		# leave the field value as is
	}

	else {
		# unknown field name, generate a warning and html-escape it just in case

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
