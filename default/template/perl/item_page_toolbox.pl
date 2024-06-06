#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetReplyListingEmpty {
	my $html = '<p>No replies found.</p>';
	$html = GetDialogX($html, 'No replies');
	return $html;
}

sub GetReplyListing {
	# if this item has a child_count, we want to print all the child items below
	# keywords: reply replies subitems child parent
	# REPLIES #replies #reply GetItemPage()
	######################################

	if (my $fileHash = shift) {
		my @itemReplies = DBGetItemReplies($fileHash);

		if (@itemReplies) {
			return GetItemListing($fileHash);
		} else {
			#return GetReplyListingEmpty($fileHash);
			return '';
		}
	} else {
		#return GetReplyListingEmpty($fileHash);
		return '';
	}

	WriteLog('GetReplyListing: warning: unreachable reached');
	return '';
} # GetReplyListing()

sub GetSimilarTimestampsListing { # $fileHash, [$existingTimestamp] ; returns dialog of items with similar timestamps
	#todo more sanity checks

	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('GetSimilarTimestampsListing: warning: $fileHash was FALSE');
		return '';
	}
	chomp $fileHash;

	WriteLog("GetSimilarTimestampsListing($fileHash)");

	if (IsItem($fileHash)) {
		# ok
	} else {
		# not ok
		return ''; #todo warning
	}

	my $existingTimestamp = shift;
	if (!$existingTimestamp) {
		$existingTimestamp = SqliteGetValue("SELECT add_timestamp FROM added_time WHERE file_hash = '$fileHash'");
		#todo warning, encourage to pass it in
	}

	if ($fileHash) {
		chomp $fileHash;

		my $query = SqliteGetQueryTemplate('similar_timestamp');
		$query =~ s/\?/'$fileHash'/;
		$query =~ s/\?/'$existingTimestamp'/;
		$query =~ s/\?/'$existingTimestamp'/;

		WriteLog('GetSimilarTimestampsListing: $query = ' . SqliteGetNormalizedQueryString($query));

		my @result = SqliteQueryHashRef($query);

		# this non-working code would remove items from
		# the related items list if they're already in the
		# threads list
		#
		# my $threadListingReference = shift;
		# my @itemsInThreadListing = @{$threadListingReference};
		#
		# for (my $row = 1; $row < scalar(@result); $row++) {
		# 	my $rowReference = $result[$row];
		# 	my %rowHash = %{$rowReference};
		# 	if (in_array($rowHash{'file_hash'}, @itemsInThreadListing)) {
		# 		#@result = splice(@result, $row, 1);
		# 		#$row--;
		# 	}
		# }

		if (scalar(@result) > 2) { # first row is column headers; related
			my $listing = GetResultSetAsDialog(\@result, 'Similar', 'item_title, add_timestamp, file_hash');
			return $listing;
		} else {
			return '';
		}
	}

	WriteLog('GetSimilarTimestampsListing: warning: unreachable reached');
	return '';
} # GetSimilarTimestampsListing()

sub GetRelatedListing { # $fileHash
	# sub GetRelated {
	# sub GetRelatedDialog {
	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('GetRelatedListing: warning: $fileHash was FALSE');
		return '';
	}

	chomp $fileHash;

	WriteLog('GetRelatedListing: $fileHash = ' . $fileHash . '; caller = ' . join(',', caller));

	if ($fileHash) {
		chomp $fileHash;

		my $query = SqliteGetQueryTemplate('related');
		$query =~ s/\?/'$fileHash'/;
		$query =~ s/\?/'$fileHash'/;
		$query =~ s/\?/'$fileHash'/;
		$query =~ s/\?/'$fileHash'/;

		WriteLog('GetRelatedListing: $query = ' . $query);

		my @result = SqliteQueryHashRef($query);

		# this non-working code would remove items from
		# the related items list if they're already in the
		# threads list
		#
		# my $threadListingReference = shift;
		# my @itemsInThreadListing = @{$threadListingReference};
		#
		# for (my $row = 1; $row < scalar(@result); $row++) {
		# 	my $rowReference = $result[$row];
		# 	my %rowHash = %{$rowReference};
		# 	if (in_array($rowHash{'file_hash'}, @itemsInThreadListing)) {
		# 		#@result = splice(@result, $row, 1);
		# 		#$row--;
		# 	}
		# }

		if (scalar(@result) > 2) { # first row is column headers; related
			my %flags;
			$flags{'query'} = $query;
			my $listing = GetResultSetAsDialog(\@result, 'Related', 'item_title, add_timestamp, file_hash, attribute_list, attribute_count', \%flags);
			$listing = AddAttributeToTag($listing, 'table', 'id', 'Related');
			return $listing;
		} else {
			return '';
			#return GetDialogX('No related found. (' . scalar(@result) . ')', 'Related');
		}
	}

	WriteLog('GetRelatedListing: warning: unreachable reached');
	return '';
} # GetRelatedListing()

sub GetHashComparisonDialog {
	my $fileHash = shift;
	#todo sanity

	my $query = "SELECT attribute, value FROM item_attribute WHERE file_hash = '$fileHash' AND attribute IN('sha1', 'sha1sum', 'chain_hash')";

	my %params;
	$params{'no_heading'} = 1;
	$params{'no_status'} = 1;
	$params{'id'} = 'Hashes';

	my $dialog = GetQueryAsDialog($query, 'Hashes', '', \%params);
	$dialog = '<span class=advanced>' . $dialog . '</span>';

	return $dialog;
} # GetHashComparisonDialog()

sub GetTimestampsDialog {
	my $fileHash = shift;
	#todo sanity

	my $query = "SELECT attribute, value FROM item_attribute WHERE file_hash = '$fileHash' AND attribute LIKE '%_timestamp'";

	my %params;
	$params{'no_heading'} = 1;
	$params{'no_status'} = 1;
	$params{'id'} = 'Timestamps';

	my $dialog = GetQueryAsDialog($query, 'Timestamps', '', \%params);
	$dialog = '<span class=advanced>' . $dialog . '</span>';

	return $dialog;
} # GetTimestampsDialog()

sub GetNextPreviousDialog {
	# sub GetChainDialog {
	# sub get_chain {
	# sub GetChainNextPrev {
	# sub GetChainNextPrevious {
	# this displays the next and previous item in chain.log
	my $fileHash = shift;

	if ($fileHash = IsItem($fileHash)) {
		# sanity check passed
	} else {
		WriteLog('GetNextPreviousDialog: warning: $fileHash failed sanity check');
		return '';
	}

	WriteLog('GetNextPreviousDialog: $fileHash = ' . $fileHash . '; caller = ' . join(',', caller));

	my $query = "
		SELECT
			attribute,
			value
		FROM
			item_attribute
			JOIN item_flat ON (item_attribute.file_hash = item_flat.file_hash)
		WHERE
			item_attribute.file_hash = '$fileHash' AND
			attribute IN ('chain_next', 'chain_previous', 'chain_sequence')
		ORDER BY
			NOT (attribute = 'chain_sequence')
	"; # the resason for the ORDER BY being this way is to put the chain_sequence field first

	#todo #bug if the next or previous item is missing, the link goes to a 404
	#todo 1. the attribute value should match an item in item_flat x
	#todo 2. it should really look for the next available item
	#todo 3. if this item is first in chain, make this known

	my %params;
	$params{'no_heading'} = 1;
	$params{'no_status'} = 1;
	$params{'no_no_results'} = 1;
	$params{'id'} = 'Chain';

	return GetQueryAsDialog($query, 'Chain', '', \%params);
} # GetNextPreviousDialog()

sub GetItemAttributesDialog { # %file
	# sub GetAttributesDialog {
	# sub GetItemAttributesWindow {
	my $itemInfoTemplate = '';
	WriteLog('GetItemAttributesDialog: my $itemInfoTemplate; caller = ' . join(',', caller));

	my $fileRef = shift;
	my %file = %{$fileRef};
	#	my %file = %{shift @_};

	my $fileHash = trim($file{'file_hash'});
	if (IsItem($fileHash)) { #sanity
		$fileHash = IsItem($fileHash);
		#todo ===
		#my $query = "SELECT DISTINCT attribute, value FROM item_attribute WHERE file_hash LIKE '$fileHash'";
		#my @queryArguments; #todo
		#push @queryArguments, $fileHash;
		#===
		#todo: my $query = "SELECT DISTINCT attribute, value, source FROM item_attribute WHERE file_hash LIKE '$fileHash%' ORDER BY attribute";
		my $query = "SELECT DISTINCT attribute, value FROM item_attribute WHERE attribute not in ('cookie', 'client') AND file_hash LIKE '$fileHash%' ORDER BY attribute";
		#todo there shouldn't be duplicate items, maybe?
		$itemInfoTemplate = GetQueryAsDialog($query, 'ItemAttributes'); # GetResultSetAsDialog() --> RenderField()
		#note: GetResultSetAsDialog() has some special conditions for GetAttributesDialog()

		$itemInfoTemplate = AddAttributeToTag($itemInfoTemplate, 'table', 'id', 'ItemAttributes');
		$itemInfoTemplate = '<span class=advanced>' . $itemInfoTemplate . '</span>';
		return $itemInfoTemplate;
		#for debug/compare
		#return $itemInfoTemplate . GetItemAttributesDialog2($fileRef);
	}
} # GetItemAttributesDialog();

sub GetItemAttributesDialog2 {
	# sub GetItemAttributesDialog {
	# sub GetItemAttributesTable {
	# sub GetDialogItemAttributes {

	#my $itemInfoTemplate = GetTemplate('html/item_info.template');
	my $itemInfoTemplate;
	WriteLog('GetItemAttributesDialog2: my $itemInfoTemplate; ');

	my $fileRef = shift;
	my %file = %{$fileRef};
	#	my %file = %{shift @_};

	my $fileHash = trim($file{'file_hash'});

	if (!IsItem($fileHash)) {
		WriteLog('GetItemAttributesDialog2: warning: IsItem($fileHash) returned FALSE; caller = ' . join(',', caller));
		return '';
	}

	#WriteLog('GetItemAttributesDialog2: %file = ' . Dumper(%file));
	#WriteLog('GetItemAttributesDialog2: $fileHash = ' . $fileHash);

	my $itemAttributesRef = DBGetItemAttributes($fileHash);
	my %itemAttributes = %{$itemAttributesRef};

	my $itemAttributesTable = '';
	{ # arrange into table nicely
		foreach my $itemAttribute (keys %itemAttributes) {
			if ($itemAttribute) {
				my %attributeRowHash = %{$itemAttribute};
				my $iaName = $itemAttribute;
				my $iaValue = $itemAttributes{$itemAttribute};

				{
					# this part formats some values for output
					if ($iaName =~ m/_timestamp/) {
						# timestamps
						$iaValue = $iaValue . ' (' . GetTimestampWidget($iaValue) . ')';
					}
					if ($iaName =~ m/file_size/) { # it was like this before, for some reason
						# file size
						$iaValue = $iaValue . ' (' . GetFileSizeWidget($iaValue) . ')';
					}
					if ($iaName eq 'author_key' || $iaName eq 'cookie_id' || $iaName eq 'gpg_id') {
						# turn author key into avatar
						$iaValue = '<tt>' . $iaValue . '</tt>' . ' (' . trim(GetAuthorLink($iaValue)) . ')';
					}
					if ($iaName eq 'title') {
						# title needs to be escaped
						$iaValue = HtmlEscape($iaValue);
					}
					if ($iaName eq 'gpg_alias') {
						# aka signature / username, needs to be escaped
						$iaValue = HtmlEscape($iaValue);
					}
					if ($iaName eq 'file_path') {
						# link file path to file
						state $HTMLDIR = GetDir('html');
						WriteLog('GetItemAttributesDialog2: $HTMLDIR = ' . $HTMLDIR); #todo
						#problem here is GetDir() returns full path, but here we already have relative path
						#currently we assume html dir is 'html'

						WriteLog('GetItemAttributesDialog2: $iaValue = ' . $iaValue); #todo
						if (GetConfig('html/relativize_urls')) { #todo add version for php without rewrite
							$iaValue =~ s/^html\//.\//;
						} else {
							$iaValue =~ s/^html\//\//;
						}
						WriteLog('GetItemAttributesDialog2: $iaValue = ' . $iaValue);

						$iaValue = HtmlEscape($iaValue);
						$iaValue = '<a href="' . $iaValue . '">' . $iaValue . '</a>';
						#todo sanitizing #security
					}
					if (
						$iaName eq 'git_hash_object' ||
							$iaName eq 'sha1' ||
							$iaName eq 'md5' ||
							$iaName eq 'chain_hash'
					) { #todo make it match on _hash and use _hash on the names
						$iaValue = '<tt>' . $iaValue . '</tt>';
					}
					if ($iaName eq 'chain_previous') {
						$iaValue = GetItemHtmlLink($iaValue, DBGetItemTitle($iaValue, 32));
					}
					if ($iaName eq 'chain_next') {
						$iaValue = GetItemHtmlLink($iaValue, DBGetItemTitle($iaValue, 32));
					}
					if ($iaName eq 'url') {
						my $displayValue = '';
						if (length($iaValue) > 127) {
							$displayValue = substr($iaValue, 0, 124) . '...';
						} else {
							$displayValue = $iaValue;
						}
						$iaValue = '<a href="' . $iaValue . '">' . $displayValue . '</a>';
						#todo sanity
					}
				}

				if ($iaValue eq '') {
					$iaValue = '-';
				}

				$itemAttributesTable .= '<tr><td>';
				$itemAttributesTable .= GetString("item_attribute/$iaName") . ':';
				$itemAttributesTable .= '</td><td>';
				$itemAttributesTable .= $iaValue;
				$itemAttributesTable .= '</td></tr>';
			}
		}

		if (defined($file{'labels_list'})) { # bolt on tags list as an attribute
			$itemAttributesTable .= '<tr><td>';
			$itemAttributesTable .= GetString('item_attribute/labels_list');
			$itemAttributesTable .= '</td><td>';
			$itemAttributesTable .= GetTagsListAsHtmlWithLinks($file{'labels_list'});
			$itemAttributesTable .= '</td></tr>';
		}

		if (defined($file{'item_score'})) { # bolt on item score
			$itemAttributesTable .= '<tr><td>';
			$itemAttributesTable .= GetString('item_attribute/item_score');
			$itemAttributesTable .= '</td><td>';
			$itemAttributesTable .= $file{'item_score'};
			$itemAttributesTable .= '</td></tr>';
		}

		$itemAttributesTable = '<tbody class=content>' . $itemAttributesTable . '</tbody>';

		my $itemAttributesWindow = GetDialogX($itemAttributesTable, 'ItemAttributes2', 'attribute,value'); #deprecated
		$itemAttributesWindow = '<span class=advanced>' . $itemAttributesWindow . '</span>';

		my $accessKey = GetAccessKey('ItemAttributes');
		if ($accessKey) {
			$itemAttributesWindow = AddAttributeToTag($itemAttributesWindow, 'a href=#', 'accesskey', $accessKey);
			$itemAttributesWindow = AddAttributeToTag($itemAttributesWindow, 'a href=#', 'name', 'ia');
		}

		return $itemAttributesWindow;
	}
} # GetItemAttributesDialog2()

sub GetPublishForm {
	# sub GetPublishDialog {
	my $template = GetTemplate('html/form/publish.template');

	my $textEncoded = 'abc';

	$template = str_replace('?comment=', '?comment=' . $textEncoded);

	return $template;
}


sub GetHtmlToolboxes {
	# 'toolbox' >toolbox<
	my $fileHashRef = shift;
	my %file;
	if ($fileHashRef) {
		%file = %{$fileHashRef};
	}

	my $html = '';

	my $urlParam = '';
	if ($file{'item_title'}) {
		$urlParam = $file{'item_title'};
		$urlParam = uri_escape($urlParam);
		$urlParam = str_replace(' ', '+', $urlParam);
		$urlParam = str_replace('+', '%2b', $urlParam);
		$urlParam = str_replace('#', '%23', $urlParam);
	}

	#if ((index($file{'labels_list'}, ',search,') != -1) && GetConfig('setting/html/item_page/toolbox_search') && $urlParam) {
	# search toolbox not displayed unless #search label is applied

	if (GetConfig('setting/html/item_page/toolbox_search') && $urlParam) {
		#todo 'notext' items should also not get a search toolbox
		#sub SearchToolbox {
		#sub SearchDialog {
		my $htmlToolbox = '';

		#$htmlToolbox .= '<b>Search:</b><br>';

		$htmlToolbox .=
			'<a href="http://www.google.com/search?q=' .
				$urlParam .
				'" ' .
				'target=_blank' .
				'>' .
				'Google' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			'<a href="https://www.perplexity.ai/search?q=' .
				$urlParam .
				'"' .
				'>' .
				'Perplexity' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			'<a href="http://html.duckduckgo.com/html?q=' .
				$urlParam .
				'">' .
				'DuckDuckGo' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			'<a href="https://www.bing.com/search?q=' .
				$urlParam .
				'">' .
				'Bing' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			'<a href="https://search.brave.com/search?q=' .
				$urlParam .
				'">' .
				'Brave' .
				'</a><br>' . "\n"
		;
		#			$htmlToolbox .=
		#				'<a href="http://yandex.ru/yandsearch?text=' .
		#				$urlParam .
		#				'">' .
		#				'Yandex' .
		#				'</a><br>' . "\n"
		;
		$htmlToolbox .=
			'<a href="http://www.google.com/search?q=' .
				$urlParam .
				'+teddit"' .
				'target=_blank' .
				'>' .
				'Google+Teddit' .
				'</a><br>' . "\n"
		;
		$htmlToolbox .=
			'<a href="https://hn.algolia.com/?q=' .
				$urlParam .
				'">' .
				'A1go1ia' .
				'</a><noscript>*</noscript><br>' . "\n"
		;
		$htmlToolbox .=
			'<a href="https://en.wikipedia.org/w/index.php?search=' .
				$urlParam .
				'">' .
				'Wikipedia English' .
				'</a><br>' . "\n"
		;
		$htmlToolbox .=
			'<a href="https://ru.wikipedia.org/w/index.php?search=' .
				$urlParam .
				'">' .
				'Wikipedia Russian' .
				'</a><br>' . "\n"
		;
		$htmlToolbox .=
			'<a href="https://uk.wikipedia.org/w/index.php?search=' .
				$urlParam .
				'">' .
				'Wikipedia Ukrainian' .
				'</a><br>' . "\n"
		;
		$htmlToolbox .=
			'<a href="https://tildes.net/search?q=' .
				$urlParam .
				'">' .
				'Tildes' .
				'</a><br>' . "\n"
		;
		$htmlToolbox .=
			'<a href="https://lobste.rs/search?q=' .
				$urlParam .
				'&what=stories&order=relevance' .
				'">' .
				'Lobsters' .
				'</a><br>' . "\n"
		;

		my $htmlToolboxWindow = GetDialogX($htmlToolbox, 'Search');
		$htmlToolboxWindow = '<span class=advanced>' . $htmlToolboxWindow . '</span>';
		$html .= $htmlToolboxWindow;
	} # if ($file{'item_title'})


	if (GetConfig('setting/html/item_page/toolbox_publish') && $file{'file_path'} && $file{'item_type'} eq 'txt') {
		require_once('dialog/toolbox_item_publish.pl');
		my $dialogToolboxPublish = GetDialogToolboxItemPublish($file{'file_path'}, $file{'file_hash'});
		if ($dialogToolboxPublish) {
			$dialogToolboxPublish = '<span class=advanced>' . $dialogToolboxPublish . '</span>';
			$html .= $dialogToolboxPublish;
		}
	}
	#elsif (GetConfig('setting/html/item_page/toolbox_publish') && $file{'file_path'} && $file{'item_type'} eq 'image') {
	# include image_publish.js
	#} #todo

	if (GetConfig('setting/html/item_page/toolbox_share')) {
		my $htmlToolbox = '';

		#$htmlToolbox .= "<p>";
		#$htmlToolbox .= "<b>Share:</b><br>";

		$htmlToolbox .=
			# http://twitter.com/share?text=text goes here&url=http://url goes here&hashtags=hashtag1,hashtag2,hashtag3
			# https://stackoverflow.com/questions/6208363/sharing-a-url-with-a-query-string-on-twitter
			'<a href="http://mastodon.social/share?text=' .
				$urlParam .
				'">' .
				'Mastodon' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			# http://twitter.com/share?text=text goes here&url=http://url goes here&hashtags=hashtag1,hashtag2,hashtag3
			# https://stackoverflow.com/questions/6208363/sharing-a-url-with-a-query-string-on-twitter
			'<a href="http://kik.com/share?text=' .
				$urlParam .
				'">' .
				'Kik' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			# http://twitter.com/share?text=text goes here&url=http://url goes here&hashtags=hashtag1,hashtag2,hashtag3
			# https://stackoverflow.com/questions/6208363/sharing-a-url-with-a-query-string-on-twitter
			'<a href="http://instagram.com/share?text=' .
				$urlParam .
				'">' .
				'Instagram' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			# http://twitter.com/share?text=text goes here&url=http://url goes here&hashtags=hashtag1,hashtag2,hashtag3
			# https://stackoverflow.com/questions/6208363/sharing-a-url-with-a-query-string-on-twitter
			'<a href="http://tiktok.com/share?text=' .
				$urlParam .
				'">' .
				'TikTok' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			# http://twitter.com/share?text=text goes here&url=http://url goes here&hashtags=hashtag1,hashtag2,hashtag3
			# https://stackoverflow.com/questions/6208363/sharing-a-url-with-a-query-string-on-twitter
			'<a href="http://twitter.com/share?text=' .
				$urlParam .
				'">' .
				'X/Twitter' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			# https://www.facebook.com/sharer/sharer.php?u=http://example.com?share=1&cup=blue&bowl=red&spoon=green
			# https://stackoverflow.com/questions/19100333/facebook-ignoring-part-of-my-query-string-in-share-url
			'<a href="https://www.facebook.com/sharer/sharer.php?u=' . # what does deprecated mean?
				$urlParam .
				'">' .
				'Facebook' .
				'</a><br>' . "\n"
		;

		$htmlToolbox .=
			# https://www.facebook.com/sharer/sharer.php?u=http://example.com?share=1&cup=blue&bowl=red&spoon=green
			# https://stackoverflow.com/questions/19100333/facebook-ignoring-part-of-my-query-string-in-share-url
			'<a href="https://www.snapchat.com/sharer/sharer.php?u=' . # what does deprecated mean?
				$urlParam .
				'">' .
				'Snapchat' .
				'</a><br>' . "\n"
		;

		$htmlToolbox = '<fieldset>' . $htmlToolbox . '</fieldset>';

		my $htmlToolboxWindow = '<span class=advanced>' . GetDialogX($htmlToolbox, 'Share') . '</span>';
		$html .= $htmlToolboxWindow;
	} # if (GetConfig('toolbox_share'))

	if ($html) {
		return $html;
	} else {
		return '';
	}
} # GetHtmlToolboxes()

sub GetItemIndexLog { # $itemHash, $logType = index_log
	# $logType = gpg_stderr
	my $itemHash = shift;

	my $logType = shift;
	if (!$logType) {
		$logType = 'index_log'
	}
	my $logSuffix = '';
	if ($logType eq 'gpg_stderr') {
		WriteLog('GetItemIndexLog: $logType = gpg_stderr; setting $logSuffix = .txt');
		$logSuffix = '.txt';
	}

	if (!IsItem($itemHash)) {
		WriteLog('GetItemIndexLog: warning: not an item: $itemHash = ' . $itemHash);
		return '';
	}

	my $shortHash = substr($itemHash, 0, 8);

	my $logPath = $logType . '/' . $itemHash . $logSuffix;
	my $log = GetCache($logPath);

	WriteLog('GetItemIndexLog: $itemHash = ' . $itemHash . '; $logType = ' . $logType . '; $logPath = ' . $logPath . '; $log is ' . ($log ? 'TRUE' : 'FALSE') . '; caller = ' . join(',', caller));

	if ($log) {
		$log = HtmlEscape($log);

		$log = str_replace("\n", "<br>\n", $log);
		if ($logType eq 'index_log') {
			$log = str_replace('declined:', '<font color=red>declined:</font>', $log);
			$log = str_replace('allowed:', '<font color=green>allowed:</font>', $log);
			$log = str_replace('removing item:', '<font color=orange>removing item:</font>', $log);
		}

		if ($logType eq 'gpg_stderr') {
			#$log = str_replace('gpg: ', '<font color=red>gpg: </font>', $log);
			$log = str_replace('gpg: Good signature from ', 'gpg: <font color=green>Good signature</font> from ', $log);
			#$log = str_replace('gpg: WARNING: This key is not certified with a trusted signature!', '', $log);
			#$log = str_replace('gpg: There is no indication that the signature belongs to the owner.', '', $log);
		}

		#my $logWindow = GetDialogX($log, 'Log');
		my $logWindow = GetDialogX($log, $logType);
		# my $logWindow = GetDialogX($log, 'IndexFile(' . $shortHash . ')');
		#if ($logType ne 'run_log') {
		#	$logWindow = '<span class=advanced>' . $logWindow . '</span>';
		#}
		return $logWindow;
	} else {
		if ($logType eq 'run_log') {
			return GetDialogX('<fieldset><p>This code has not been run yet.</p></fieldset>', 'Information');
		} else {
			#todo what to do here?
		}
	}

	return '';
} # GetItemIndexLog()

1;