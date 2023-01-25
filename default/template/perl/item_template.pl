#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

require_once('get_window_template.pl');

sub GetItemTemplateBody {
# sub GetItemText {
# sub FormatMessage {
# sub GetContainer {
# sub GetItemContainer {
# sub GetItemContent {
	my %file = %{shift @_};
	my $itemTemplateBody = '';
	my $itemText = '';

	WriteLog('GetItemTemplateBody() BEGIN');

	if (!$file{'item_type'}) {
		WriteLog('GetItemTemplateBody: warning: $file{item_type} is FALSE! caller = ' . join(',', caller));
		return '';
	}

	my $fileHash = $file{'item_type'};
	WriteLog('GetItemTemplateBody: $fileHash = image');

	if ($file{'item_type'} eq 'image') {
		WriteLog('GetItemTemplateBody: item_type = ' . $file{'item_type'});
		my $imageContainer = GetImageContainer($file{'file_hash'}, $file{'item_name'}, 0);
		$itemTemplateBody = GetTemplate('html/item/item.template'); # GetItemTemplate()
		$itemTemplateBody = str_replace('$itemText', $imageContainer, $itemTemplateBody); #todo #bug $itemText is always empty here
	}

	if ($file{'item_type'} eq 'txt') {
		WriteLog('GetItemTemplateBody: item_type = txt');

		my $isTextart = 0;
		if (GetConfig('html/format_item/textart')) {
			if (-1 != index(','.$file{'tags_list'}.',', ',textart,')) {
				WriteLog('GetItemTemplateBody: $isTextart = 1');
				$isTextart = 1;
			}
		}

		my $isPubKey = 0;
		if (-1 != index(','.$file{'tags_list'}.',', ',pubkey,')) {
			$isPubKey = 1;
			WriteLog('GetItemTemplateBody: $isPubKey = 1');
		}

		my $isTooLong = 0;
		my $itemLongThreshold = GetConfig('html/item_long_threshold') || 1024;
		if (length($itemText) > $itemLongThreshold && exists($file{'trim_long_text'}) && $file{'trim_long_text'}) {
			#todo this never gets called ??
			$isTooLong = 1;
		}

		my $isPhone = 0;
		if (GetConfig('html/format_item/phone')) {
			if (-1 != index(','.$file{'tags_list'}.',', ',phone,')) {
				WriteLog('GetItemTemplateBody: $isPhone = 1');
				$isPhone = 1;
			}
		}

		my $isAdress = 0;
		if (GetConfig('html/format_item/address')) {
			if (-1 != index(','.$file{'tags_list'}.',', ',address,')) {
				$isAdress = 1;
				WriteLog('GetItemTemplateBody: $isAdress = 1');
			}
		}

		#todo allow textart and address together

		if ($isTextart) {
			$itemText = TextartForWeb(GetCache('message/' . $file{'file_hash'} . '_gpg'));
			if (!$itemText) {
				$itemText = TextartForWeb(GetFile($file{'file_path'}));
			}
		} elsif ($isPhone) {
			$itemText = PhoneForWeb(GetCache('message/' . $file{'file_hash'} . '_gpg'));
			if (!$itemText) {
				$itemText = PhoneForWeb(GetFile($file{'file_path'}));
			}
		} elsif ($isAdress) {
			$itemText = AddressForWeb(GetCache('message/' . $file{'file_hash'} . '_gpg'));
			if (!$itemText) {
				$itemText = AddressForWeb(GetFile($file{'file_path'}));
			}
		} elsif ($isPubKey) {
			$itemText = '[This item is a public key.]';
		} else {
			$itemText = GetItemDetokenedMessage($file{'file_hash'}, $file{'file_path'});
			$itemText =~ s/\r//g;

			if ($file{'remove_token'}) {
				# if remove_token is specified, remove it from the message
				WriteLog('GetItemTemplateBody: ' . $file{'file_hash'} . ': $file{remove_token} = ' . $file{'remove_token'});

				$itemText = str_replace($file{'remove_token'}, '', $itemText);
				$itemText = trim($itemText);

				#todo there is a #bug here, but it is less significant than the majority of cases
				#  the bug is that it removes the token even if it is not by itself on a single line
				#  this could potentially be mis-used to join together two pieces of a forbidden string
				#todo make it so that post does not need to be trimmed, but extra \n\n after the token is removed
			} else {
				WriteLog('GetItemTemplateBody: ' . $file{'file_hash'} . ': $file{remove_token} is not set');
			}

			if ($isTooLong) {
				if (length($itemText) > $itemLongThreshold) {
					$itemText = substr($itemText, 0, $itemLongThreshold) . "\n" . '[...]';
					# if item is long, trim it
				}
			}

			$itemText = FormatForWeb($itemText);

			$itemText =~ s/([a-f0-9]{40})/GetItemHtmlLink($1, DBGetItemTitle($1, 16))/eg;
			#$itemText =~ s/([a-f0-9]{8})/GetItemHtmlLink($1, DBGetItemTitle($1, 16))/eg;

			if (GetConfig('html/hide_dashdash_signatures')) { # -- \n
				if (index($itemText, "<br>-- <br>") != -1) {
					$itemText =~ s/(.+)<br>-- <br>(.+)/$1<span class=admin><br>\n-- <br>\n$2<\/span>/smi;
					# /s = single-line (changes behavior of . metacharacter to match newlines)
					# /m = multi-line (changes behavior of ^ and $ to work on lines instead of entire file)
					# /i = case-insensitive
				}
			}

			if ($file{'format_avatars'}) {
				$itemText =~ s/([A-F0-9]{16})/GetHtmlAvatar($1)/eg;
			}

			if (GetConfig('html/item_remove_first_line_if_matches_title')) {
				if ($file{'item_title'}) {
					if (substr($itemText, 0, length($file{'item_title'}))) {
						my $firstLine = GetFirstLine($itemText);
						if (
							(trim($itemText) ne $firstLine)
								&&
							(trim($file{'item_title'}) eq $firstLine)
						) {
							$itemText = substr($itemText, length($firstLine));
							while (substr($itemText, 0, 1) eq "\n") {
								$itemText = substr($itemText, 1);
							}
						}
					}
				}
			}
		} # not $isTextart

		$itemTemplateBody = GetTemplate('html/item/item.template'); # GetItemTemplate()
		$itemTemplateBody = str_replace('$itemText', $itemText, $itemTemplateBody);
	} # 'txt'

	if ($file{'item_type'} eq 'cpp') {
		WriteLog('GetItemTemplateBody: item_type = cpp');

		$itemText = CppForWeb(GetFile($file{'file_path'}));

		$itemTemplateBody = GetTemplate('html/item/item.template'); # GetItemTemplate()
		$itemTemplateBody = str_replace('$itemText', $itemText, $itemTemplateBody);
	} # 'cpp'

	if ($file{'item_type'} eq 'py') {
		WriteLog('GetItemTemplateBody: item_type = py');

		$itemText = PyForWeb(GetFile($file{'file_path'}));

		$itemTemplateBody = GetTemplate('html/item/item.template'); # GetItemTemplate()
		$itemTemplateBody = str_replace('$itemText', $itemText, $itemTemplateBody);
	} # 'py'

	if (!$itemTemplateBody) {
		WriteLog('GetItemTemplateBody: warning: $itemTemplateBody is FALSE; caller = ' . join(',', caller));
	}

	if ($file{'item_type'} eq 'perl') {
		WriteLog('GetItemTemplateBody: item_type = perl');

		$itemText = PerlForWeb(GetFile($file{'file_path'}));

		$itemTemplateBody = GetTemplate('html/item/item.template'); # GetItemTemplate()
		$itemTemplateBody = str_replace('$itemText', $itemText, $itemTemplateBody);
	} # 'perl'

	if ($file{'item_type'} eq 'zip') {
		WriteLog('GetItemTemplateBody: item_type = zip');

		#$itemText = ZipForWeb(GetFile($file{'file_path'}));
		$itemText = ZipForWeb('#todo'); #todo get some kind of friendly display of file, not binary content

		$itemTemplateBody = GetTemplate('html/item/item.template'); # GetItemTemplate()
		$itemTemplateBody = str_replace('$itemText', $itemText, $itemTemplateBody);
	} # 'zip'

	if (!$itemTemplateBody) {
		WriteLog('GetItemTemplateBody: warning: $itemTemplateBody is FALSE; caller = ' . join(',', caller));
	}

	return $itemTemplateBody;
} # GetItemTemplateBody()

sub GetMavoItemTemplate { # \%file
	my $hashRef = shift; # reference to hash
	my %file;            # actual hash
	if ($hashRef) {
		# if reference exists, set %file
		%file = %{$hashRef};
	} else {
		WriteLog('GetMavoItemTemplate: warning: argument missing, returning');
		#todo output something anyway?
		return '';
	}

	my $itemText = GetFile($file{'file_path'});

	if (index($itemText, "\n-- \n") != -1) {
		# kind of a #hack, but it's necessary for now
		$itemText = substr($itemText, 0, index($itemText, "\n-- \n"));
	}

	my $itemDialog = GetDialogX($itemText);

	return $itemDialog;
}

sub GetItemTemplateFromHash { # $ hash
	my $hash = shift;
	#todo sanity

	WriteLog('GetItemTemplateFromHash: $hash = ' . $hash);

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE file_hash LIKE '" . $hash . "%'";
	my @items = DBGetItemList(\%queryParams);
	#shift @items;
	my $firstItemRef = shift @items;

	if ($firstItemRef) {
		my %firstItem = %{$firstItemRef};
		my $itemTemplate = GetItemTemplate(\%firstItem);
		return $itemTemplate;
	} else {
		WriteLog('GetItemTemplateFromHash: warning: $firstItemRef was FALSE');
		return '';
	}
} # GetItemTemplateFromHash()

sub GetItemTemplate { # \%file ; returns HTML for outputting one item WITH DIALOG FRAME
# sub GetItemDialog {
	WriteLog('GetItemTemplate: caller = ' . join(',', caller));

	# returns HTML for outputting one item WITH DIALOG FRAME
	# uses GetDialogX()

	# %file(hash for each file)
	# file_path = file path including filename
	# file_hash = git's hash of the file's contents
	# author_key = gpg key of author (if any)
	# add_timestamp = time file was added as unix_time
	# child_count = number of replies
	# display_full_hash = display full hash for file
	# template_name = item/item.template by default
	# remove_token = token to remove (for reply tokens)
	# show_vote_summary = shows item's list and count of tags
	# show_quick_vote = displays quick vote buttons
	# item_title = override title
	# item_statusbar = override statusbar
	# tags_list = comma-separated list of tags the item has
	# is_textart = set <tt><code> tags for the message itself
	# no_permalink = do not link to item's permalink page

	# item_type = 'txt' or 'image'
	# vote_return_to = page to redirect user to after voting, either item hash or url
	# trim_long_text = trim text if it is longer than config/html/item_long_threshold

	# get %file hash from supplied parameters

	#my %file = %{shift @_};
	my $hashRef = shift; # reference to hash
	my %file;            # actual hash
	if ($hashRef) {
		# if reference exists, set %file
		%file = %{$hashRef};
	} else {
		WriteLog('GetItemTemplate: warning: argument missing, returning; caller = ' . join(',', caller));
		#todo output something anyway?
		return '';
	}

	my $sourceFileHasGoneAway = 0;

	# verify that referenced file path exists
	if (-e $file{'file_path'}) {
		#cool
	}
	else {
		WriteLog('GetItemTemplate: warning: -e $file{file_path} was FALSE; $file{file_path} = ' . $file{'file_path'});
		$sourceFileHasGoneAway = 1;
	}

	if (1) {
		my $itemHash = $file{'file_hash'}; # file hash/item identifier
		my $gpgKey = $file{'author_key'}; # author's fingerprint

		my $alias; # stores author's alias / name
		my $isAdmin = 0; # author is admin? (needs extra styles)

		my $itemType = '';

		my $isSigned = 0; # is signed by user (also if it's a pubkey)
		if ($gpgKey) { # if there's a gpg key, it's signed
			$isSigned = 1;
		} else {
			$isSigned = 0;
		}

		if (
			$isSigned
				&&
			IsAdmin($gpgKey)
		) {
			# if item is signed, and the signer is an admin, set $isAdmin = 1
			$isAdmin = 1;
		}


		# escape the alias name for outputting to page
		$alias = HtmlEscape($alias);

		my $fileHash = '';
		if ($file{'file_path'}) {
			$fileHash = GetFileHash($file{'file_path'}); # get file's hash
		} else {
			if ($itemHash) {
				$fileHash = $itemHash;
			} else {
				WriteLog('GetItemTemplate: warning: cannot get a $fileHash');
				return '';
			}
		}

		# initialize $itemTemplate for storing item output
		my $itemTemplate = '';
		{ ### this is the item template itself, including the window

			##########################################################
			### this is the item template itself, including the window
			### this is the item template itself, including the window
			### this is the item template itself, including the window
			### this is the item template itself, including the window
			### this is the item template itself, including the window
			##########################################################

			#return GetDialogX($param{'body'}, $param{'title'}, $param{'headings'}, $param{'status'}, $param{'menu'});
			my %windowParams;

			{
				# WINDOW BODY / ITEM CONTENT
				# WINDOW BODY / ITEM CONTENT
				my $windowBody = '';
				$windowBody = GetItemTemplateBody(\%file);
				$windowParams{'body'} = $windowBody;
				#$windowParams{'body'} = htmlspecialchars($windowBody);
				#$windowParams{'body'} = $windowBody;
				#$windowParams{'body'} = 'fuck you';
			}

			# TITLE
			# TITLE
			if (GetConfig('admin/expo_site_mode')) { #todo #debug #expo
				$windowParams{'title'} = HtmlEscape($file{'item_name'});
			} else {
				$windowParams{'title'} = HtmlEscape($file{'item_title'});
			}

			# GUID
			$windowParams{'guid'} = substr(sha1_hex($file{'file_hash'}), 0, 8);

			# TAGS LIST AKA HEADING
			# TAGS LIST AKA HEADING
			# TAGS LIST AKA HEADING
			if ($file{'tags_list'}) { # GetItemTemplate() -- tags list
				my $headings = GetTagsListAsHtmlWithLinks($file{'tags_list'});
				$windowParams{'headings'} = $headings;
			} # $file{'tags_list'}

			# STATUS BAR
			# STATUS BAR
			# STATUS BAR
			my $statusBar = '';
			{
				$statusBar = GetTemplate('html/item/status_bar.template');

				my $fileHashShort = substr($fileHash, 0, 8);
				$statusBar = str_replace('<span class=fileHashShort></span>;', "<span class=fileHashShort>" . $fileHashShort . "</span>;", $statusBar);
				#$statusBar =~ s/\$fileHashShort/$fileHashShort/g;

				if ($gpgKey) {
					# get author link for this gpg key
					my $authorLink = trim(GetAuthorLink($gpgKey));
					$statusBar =~ s/\$authorLink/$authorLink/g;
				} else {
					# if no author, no $authorLink
					$statusBar =~ s/\$authorLink;//g;
				}
				WriteLog('GetItemTemplate: $statusBar 1.5 = ' . $statusBar);

				if (GetConfig('setting/html/reply_cart')) {
					if (GetConfig('setting/admin/js/enable')) {
						require_once('widget/add_to_reply_cart.pl');
						$statusBar .= '; ';
						$statusBar .= '<span class=advanced>' . GetAddToReplyCartButton($fileHash) . '</span>';
					} else {
						$statusBar .= '<!-- add_to_reply_cart button requires js, but it is not enabled -->';
					}
				}
			}

			#$statusBar = s/\$permalinkHtml/$permalinkHtml/g;

			if ($file{'item_statusbar'}) {
				$statusBar = $file{'item_statusbar'};
			}

			WriteLog('GetItemTemplate: $statusBar 2 = ' . $statusBar);
			if ($itemType eq 'image') {
				$windowParams{'status'} = $statusBar;
				#$windowParams{'status'} = $statusBar . '<hr>' . GetQuickVoteButtonGroup($file{'file_hash'}, $file{'vote_return_to'});
			} else {
				$windowParams{'status'} = $statusBar;
			}

			#$windowParams{'status'} = GetQuickVoteButtonGroup($file{'file_hash'}, $file{'vote_return_to'});

			# if (GetConfig('admin/expo_site_mode') && !GetConfig('admin/expo_site_edit')) {
			# 	#todo
			# 	if ($file{'item_name'} eq 'Information') {
			# 		WriteLog('GetItemTemplate: expo_site_mode: setting window status to blank');
			# 		$windowParams{'status'} = '';
			# 	}
			# }

			if (defined($file{'show_quick_vote'})) {
				$windowParams{'menu'} = GetQuickVoteButtonGroup($file{'file_hash'}, $file{'vote_return_to'});
			}

			$windowParams{'id'} = substr($file{'file_hash'}, 0, 8);
			$windowParams{'table_sort'} = 0; #disable table sort

			$itemTemplate = GetDialogX2(\%windowParams);
			$itemTemplate .= '<replies></replies>';
		} ### this is the item template itself, including the window

		# $itemTemplate = str_replace(
		# 	'<span class=more></span>',
		# 	GetWidgetExpand(2, '#'),
		# 	$itemTemplate
		# );#todo fix broken

		# my $widgetExpandPlaceholder = '<span class=expand></span>';
		# if (index($itemTemplate, $widgetExpandPlaceholder) != -1) {
		# 	WriteLog('GetItemTemplate: $widgetExpandPlaceholder found in item: ' . $widgetExpandPlaceholder);
		#
		# 	if (GetConfig('admin/js/enable')) {
		# 		# js on, insert widget
		#
		# 		my $widgetExpand = GetWidgetExpand(5, GetHtmlFilename($itemHash));
		# 		$itemTemplate = str_replace(
		# 			'<span class=expand></span>',
		# 			'<span class=expand>' .	$widgetExpand .	'</span>',
		# 			$itemTemplate
		# 		);
		#
		# 		# $itemTemplate = AddAttributeToTag(
		# 		# 	$itemTemplate,
		# 		# 	'a href="/etc.html"', #todo this should link to item itself
		# 		# 	'onclick',
		# 		# 	"if (window.ShowAll && this.removeAttribute) { this.removeAttribute('onclick'); return ShowAll(this, this.parentElement.parentElement.parentElement.parentElement.parentElement); } else { return true; }"
		# 		# );
		# 	} else {
		# 		# js off, remove placeholder for widget
		# 		$itemTemplate = str_replace($widgetExpandPlaceholder, '', $itemTemplate);
		# 	}
		# } # $widgetExpandPlaceholder

		#my $authorUrl; # author's profile url
		#my $authorAvatar; # author's avatar
		my $permalinkTxt = $file{'file_path'};

		{
			#todo still does not work perfectly, this
			# set up $permalinkTxt, which links to the .txt version of the file

			# strip the 'html/' prefix on the file's path, replace with /
			#todo relative links
			state $HTMLDIR = GetDir('html');
			$permalinkTxt =~ s/$HTMLDIR\//\//;
			$permalinkTxt =~ s/^html\//\//;
		}

		# set up $permalinkHtml, which links to the html page for the item
		#my $permalinkHtml = '/' . GetHtmlFilename($itemHash);

		#my $permalinkHtml = '/' . GetHtmlFilename($itemHash); # ItemTemplate()
		my $permalinkHtml = '/' . GetItemUrl($itemHash); # ItemTemplate()

		my $linkPath = $permalinkHtml;
		if (GetConfig('admin/php/enable') && GetConfig('admin/php/url_alias_friendly')) {
			$linkPath = '/' . substr($itemHash, 0, 8);
			$permalinkHtml = $linkPath;
			#todo rewrite this
		}


		# my $permalinkHtml = '/' . substr($itemHash, 0, 2) . '/' . substr($itemHash, 2) . ".html";
		# $permalinkTxt =~ s/^\.//;

		my $itemAnchor = substr($fileHash, 0, 8);
		my $itemName; # item's 'name'

		if ($file{'display_full_hash'} && $file{'display_full_hash'} != 0) {
			# if display_full_hash is set, display the item's entire hash for name
			$itemName = $fileHash;
		} else {
			# if display_full_hash is not set, truncate the hash to 8 characters
			#$itemName = substr($fileHash, 0, 8) . '..';
			$itemName = $file{'item_name'};
		}

		my $replyCount = $file{'child_count'};
		my $borderColor = '#' . substr($fileHash, 0, 6); # item's border color
		my $addedTime = DBGetAddedTime($fileHash);
		if (!$addedTime) {
			WriteLog('GetItemTemplate: warning: $addedTime was FALSE');
			$addedTime = 0;
		}
		$addedTime = ceil($addedTime);
		my $addedTimeWidget;
		if ($addedTime) {
			$addedTimeWidget = GetTimestampWidget($addedTime); #todo optimize
		} else {
			$addedTimeWidget = 'no timestamp';
		}
		my $itemTitle = $file{'item_title'};

		{ #todo refactor this to not have title in the template
			if ($file{'item_title'}) {
				my $itemTitle = HtmlEscape($file{'item_title'});
				$itemTemplate =~ s/\$itemTitle/$itemTitle/g;
			} else {
				$itemTemplate =~ s/\$itemTitle/Untitled/g;
			}
		}

		my $replyLink = $permalinkHtml . '#reply'; #todo this doesn't need the url before #reply if it is on the item's page

		# if (GetConfig('admin/expo_site_mode')) {
		# 	# do nothing
		# } else {
		# 	if (index($itemText, '$') > -1) {
		# 		# this is a kludge, should be a better solution
		# 		#$itemText = '<code>item text contained disallowed character</code>';
		# 		$itemText =~ s/\$/%/g;
		# 	}
		# }

		#my $itemClass = 'foobar';

		$itemTemplate =~ s/\$borderColor/$borderColor/g;
		#$itemTemplate =~ s/\$itemClass/$itemClass/g;
		$itemTemplate =~ s/\$permalinkTxt/$permalinkTxt/g;
		$itemTemplate =~ s/\$permalinkHtml/$permalinkHtml/g;
		$itemTemplate =~ s/\$fileHash/$fileHash/g;
		$itemTemplate =~ s/\$addedTime/$addedTimeWidget/g;
		$itemTemplate =~ s/\$replyLink/$replyLink/g;
		$itemTemplate =~ s/\$itemAnchor/$itemAnchor/g;

		if ($replyCount) {
			$itemTemplate =~ s/\$replyCount/$replyCount/g;
		} else {
			$itemTemplate =~ s/\$replyCount/0/g;
		}

		# if show_vote_summary is set, show a count of all the tags the item has
		if ($file{'show_vote_summary'}) {
			#this displays the vote summary (tags applied and counts)
			my $voteTotalsRef = DBGetItemVoteTotals2($file{'file_hash'});
			my %voteTotals = %{$voteTotalsRef};
			my $votesSummary = '';
			foreach my $voteTag (keys %voteTotals) {
				$votesSummary .= "$voteTag (" . $voteTotals{$voteTag} . ")\n";
				#todo templatize this
			}
			if ($votesSummary) {
				$votesSummary .= '<br>';
				#todo templatize
			}
			$itemTemplate =~ s/\$votesSummary/$votesSummary/g;
		} else {
			$itemTemplate =~ s/\$votesSummary//g;
		}

		my $itemFlagButton = '';
		if (defined($file{'vote_return_to'}) && $file{'vote_return_to'}) {
			WriteLog('GetItemTemplate: $file{\'vote_return_to\'} = ' . $file{'vote_return_to'});
			$itemFlagButton = GetItemTagButtons($file{'file_hash'}, 'all', $file{'vote_return_to'}); #todo refactor to take vote totals directly
		} else {
			# WriteLog('GetItemTemplate: $file{\'vote_return_to\'} = ' . $file{'vote_return_to'});
			$itemFlagButton = GetItemTagButtons($file{'file_hash'}, 'all'); #todo refactor to take vote totals directly
		}

		$itemTemplate =~ s/\$itemFlagButton/$itemFlagButton/g;

		WriteLog('GetItemTemplate: return $itemTemplate = ' . length($itemTemplate) . ' bytes');

		return $itemTemplate;
	} # (1)

	WriteLog('GetItemTemplate: warning: unreachable reached!');
	return '';
} # GetItemTemplate()

1;
