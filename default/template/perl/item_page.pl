#!/usr/bin/perl -T

# GetItemPage()
# GetHtmlToolboxes()
# GetPublishForm()
# GetReplyListingEmpty()
# GetReplyListing()
# GetRelatedListing()
# GetItemAttributesDialog()
# GetItemAttributesDialog2()
# GetPublishForm()

use strict;
use warnings;
use utf8;
use 5.010;

require_once('dialog.pl');

my @foundArgs;
while (my $argFound = shift) {
	push @foundArgs, $argFound;
}

use lib qw(lib);
#use HTML::Entities qw(encode_entities);
use Digest::MD5 qw(md5_hex);
use POSIX qw(strftime ceil);
use Data::Dumper;
use File::Copy;
# use File::Copy qw(copy);
use Cwd qw(cwd);

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
			'<a href="https://teddit.net/r/all/search?q=' .
			$urlParam .
			'&nsfw=on' .
			'">' .
			'Teddit' .
			'</a><br>' . "\n"
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

		#my $logWindow = GetDialogX($log, 'Log');
		my $logWindow = GetDialogX($log, $logType);
		# my $logWindow = GetDialogX($log, 'IndexFile(' . $shortHash . ')');
		if ($logType ne 'run_log') {
			$logWindow = '<span class=advanced>' . $logWindow . '</span>';
		}
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

sub GetItemPage { # %file ; returns html for individual item page. %file as parameter
# sub GetThreadPage {
# sub GetPageItem {
	# %file {
	#		file_hash = git's file hash
	#		file_path = path where text file is stored
	#		item_title = title, if any
	#		author_key = author's fingerprint
	#		vote_buttons = 1 to display vote buttons
	#		display_full_hash = 1 to display full hash for permalink (otherwise shortened)
	#		show_vote_summary = 1 to display all votes recieved separately from vote buttons
	#		show_quick_vote = 1 to display quick vote buttons
	#		format_avatars = 1 to format fingerprint-looking strings into avatars
	#		child_count = number of child items for this item
	#		template_name = name of template to use (item.template is default)
	#		remove_token = reply token to remove from message (used for displaying replies) #todo this is passed into GetItemTemplate()?
	#	}

	# we're expecting a reference to a hash as the first parameter

	my $hashRef = shift;
	my %file;

	if ($hashRef && (ref($hashRef) eq 'HASH')) {
		%file = %{$hashRef};
	} else {
		WriteLog('GetItemPage: warning: sanity check failed on $hashRef; caller: ' . join(',', caller));
		return '';
	}

	# keyword: ItemInfo {

	# create $fileHash and $filePath variables, since we'll be using them a lot
	my $fileHash = $file{'file_hash'};
	my $filePath = $file{'file_path'};

	my $title = '';

	if (!$fileHash || !$filePath) {
		WriteLog('GetItemPage: warning: sanity check failed ...');
		return '';
	}

	WriteLog("GetItemPage($fileHash, $filePath); caller = " . join(',', caller));

	# initialize variable which will contain page html
	my $txtIndex = "";

	{
		my $debugOut = '';
		foreach my $key (keys (%file)) {
			$debugOut .= '$file{' . $key . '} = ' . ($file{$key} ? $file{$key} : 'FALSE');
			$debugOut .= "\n";
		}
		WriteLog('GetItemPage: ' . $debugOut);
	}

	# SET PAGE TITLE #####################
	if (0) {} # this is here to make the below statements consistent
	elsif (defined($file{'item_title'}) && $file{'item_title'}) {
		WriteLog("GetItemPage: title: defined(item_title) = true!");
		$title = HtmlEscape($file{'item_title'});
	}
	elsif (defined($file{'item_name'}) && $file{'item_name'}) {
		WriteLog("GetItemPage: title: defined(item_name) = true!");
		$title = HtmlEscape($file{'item_name'});
	}
	else {
		my $fileHashShort = substr($file{'file_hash'}, 0, 8);
		WriteLog("GetItemPage: title: defined(item_title) = false!");
		$title = 'Untitled (' . $fileHashShort . ')'; #todo shouldn't be hard-coded here
	}
	# / SET PAGE TITLE #####################

	# AUTHOR ALIAS?
	if (defined($file{'author_key'}) && $file{'author_key'}) {
		my $alias = GetAlias($file{'author_key'});
		if ($alias) {
			$alias = HtmlEscape($alias);
			$title .= " by $alias";
		} else {
			WriteLog('GetItemPage: warning: author_key was defined, but $alias is FALSE');
			#$alias = '...';
			#$title .= ' by ...'; #guest...
			$alias = 'Guest';
			$title .= ' by Guest';
		}
	}
	# / AUTHOR ALIAS

	# FEATURE FLAGS
	$file{'display_full_hash'} = 1;
	$file{'show_vote_summary'} = 1;
	# $file{'show_quick_vote'} = 1;
	$file{'vote_buttons'} = 1;
	$file{'format_avatars'} = 1;
	if (!$file{'item_title'}) {
		$file{'item_title'} = 'Untitled';
	}
	$file{'image_large'} = 1;
	# / FEATURE FLAGS

	##########################
	## HTML MAKING BEGINS

	# Get the HTML page template
	my $htmlStart = GetPageHeader('item', $title);
	$txtIndex .= $htmlStart;
	if (GetConfig('setting/admin/expo_site_mode')) {
		#$txtIndex .= GetMenuTemplate(); # menu at the top on item page
	}
	$txtIndex .= GetTemplate('html/maincontent.template');




	# ITEM TEMPLATE
	# item template #searchable
	# item body #searchable

	my $addMavo = 0; #todo refactor
	my $addMermaid = 0; #todo refactor

	my $itemTemplate = '';
	if (index(',' . $file{'labels_list'} . ',', ',pubkey,') != -1) {
		#$itemTemplate = GetAuthorInfoBox($file{'file_hash'});
		#this is missing a link to the profile, so remove it for now
		$itemTemplate = GetItemTemplate(\%file); # GetItemPage()
	}
	elsif (
		index(',' . $file{'labels_list'} . ',', ',mavo,') != -1 &&
		GetConfig('setting/admin/js/mavo')
	) {
		$itemTemplate = GetMavoItemTemplate(\%file);
		#push @extraJs, 'mavo';
		$addMavo = 1;
	}
	else {
		#		if ( $file{'item_type'} eq 'image' && GetConfig('setting/admin/image/enable') ) {
		#			#todo get link for full size image
		#			my $imageLink = '';
		#		}
		#

		#todo if it is item page, it should link to full image, not itself?
		$itemTemplate = GetItemTemplate(\%file); # GetItemPage()
	}
	WriteLog('GetItemPage: child_count: ' . $file{'file_hash'} . ' = ' . $file{'child_count'});

	# ITEM TEMPLATE
	if ($itemTemplate) {
		$txtIndex .= $itemTemplate;
	} else {
		WriteLog('GetItemPage: warning: $itemTemplate was FALSE');
		$itemTemplate = '';
	}

	if ($file{'item_type'} eq 'image' && GetConfig('setting/html/item_page/image_full_size_link')) { # todo feature flag using GetConfig()
		my $linkToFullImage = GetFileLink(\%file, 'Image');
		$txtIndex .= GetDialogX($linkToFullImage, 'Full Image'); # full size image
	}

	# REPLY FORM
	if (GetConfig('setting/reply/enable')) {
		$txtIndex .= GetReplyForm($file{'file_hash'});
	}

	if (GetConfig('setting/html/item_page/attributes_list')) {
		$txtIndex .= GetItemAttributesDialog(\%file);
	}

	if (GetConfig('setting/admin/token/problem')) {
		if (index($file{'labels_list'}, ',problem,') != -1) {
			require_once('dialog/upload.pl');
			$txtIndex .= GetUploadDialog('html/form/upload_reply.template', $file{'file_hash'});
		}
	}

	# REPLY CART
	#if (GetConfig('setting/html/reply_cart')) {
	#	require_once('dialog/reply_cart.pl');
	#	$txtIndex .= GetReplyCartDialog(); # GetItemPage()
	#}

	if (GetConfig('setting/html/item_page/thread_listing')) {
		WriteLog('GetItemPage: found thread_listing = TRUE');
		require_once('widget/thread_listing.pl');

		my $fileHash = $file{file_hash};

		my $threadListingDialog = GetThreadListingDialog($fileHash); # 'Thread'
		#$threadListingDialog .= '<span class=advanced>' . $threadListingDialog . '</span>';
		if ($threadListingDialog) {
			$txtIndex .= $threadListingDialog;
		} else {
			WriteLog('GetItemPage: thread_listing: warning: tried to find a listing, but failed; $fileHash = ' . $fileHash);
			#todo warning
		}
	}

	if (index($file{'labels_list'}, 'pubkey') != -1) {
		my $pubKeyFingerprint = $file{'author_key'};
		my $pubKeyHash = $file{'file_hash'};

		#todo sanity check on vars above

		my $pubKeyMessage = "
			<fieldset><p>
				This is a public key, <br>
				which creates a profile placeholder, <br>
				and allows verifying other posts. <br>
			</p></fieldset>
		";#todo templatify and make a table with a caption above?

		$txtIndex .= GetDialogX(
			#'Public key allows verifiable signatures.',
			$pubKeyMessage,
			'Information'
		);

		$txtIndex .= GetAuthorInfoBox($file{'author_key'});
		#todo templatify + use GetString()
	}

	my @result = SqliteQueryHashRef('item_url', $fileHash);
	#todo move to default/query
	if (scalar(@result) > 1) { # urls
		my $queryText = SqliteGetNormalizedQueryString('item_url', $fileHash);
		my %flags;
		$flags{'no_heading'} = 1;
		$flags{'query'} = $queryText;

		my $linksToolbox = GetResultSetAsDialog(\@result, 'Links', 'value', \%flags);
		$linksToolbox = AddAttributeToTag($linksToolbox, 'table', 'id', 'Links');
		$txtIndex .= $linksToolbox;
	}


	# TOOLBOX
	my $htmlToolbox = GetHtmlToolboxes(\%file);
	$txtIndex .= $htmlToolbox;

	# $txtIndex .= '<hr>';


	##
	##
	##
	###############
	### /REPLY DEPENDENT FEATURES BELOW##########

	$txtIndex .= '<br>';

	#VOTE BUTTONS are below, inside replies


	if (GetConfig('setting/reply/enable')) {
		my $voteButtons = '';
		if (GetConfig('setting/admin/expo_site_mode')) {
			if (GetConfig('setting/admin/expo_site_edit')) {
				#$txtIndex .= GetReplyForm($file{'file_hash'});
			}
			# do nothing
		} else { # additional dialogs on items page
			# REPLY FORM
			#$txtIndex .= GetReplyForm($file{'file_hash'});

#
#			# VOTE  BUTTONS
#			# Vote buttons depend on reply functionality, so they are also in here
#			$voteButtons .=
#				GetItemLabelButtons($file{'file_hash'}) .
#				'<hr>' .
#				GetTagsListAsHtmlWithLinks($file{'labels_list'}) .
#				'<hr>' .
#				GetString('item_attribute/item_score') . $file{'item_score'}
#			;

			if (GetConfig('setting/html/item_page/toolbox_classify')) {
				my $classifyForm = GetTemplate('html/item/classify.template');
				$classifyForm = str_replace(
					'<span id=itemLabelsList></span>',
					'<span id=itemLabelsList>' . (GetTagsListAsHtmlWithLinks($file{'labels_list'}) || '(none)') . '</span>',
					$classifyForm
				);
				WriteLog('GetItemPage: toolbox_classify: $file{\'labels_list\'} = ' . $file{'labels_list'});

				$classifyForm = str_replace(
					'<span id=itemAddLabelButtons></span>',
					'<span id=itemAddLabelButtons>' . GetItemLabelButtons($file{'file_hash'}) . '</span>',
					$classifyForm
				);

				$classifyForm = str_replace(
					'<span id=itemScore></span>',
					'<span id=itemScore>' . $file{'item_score'} . '</span>',
					$classifyForm
				);

				# CLASSIFY BOX
				$txtIndex .= '<span class=advanced>'.GetDialogX($classifyForm, 'Classify').'</span>';
			}
		}

		#my @itemReplies = DBGetItemReplies($fileHash);
		my @itemReplies = DBGetItemReplies($fileHash);

#
#		my $query = '';
#		if (ConfigKeyValid("query/template/related")) {
#			$query = SqliteGetQueryTemplate("related");
#			$query =~ s/\?/'$fileHash'/;
#			$query =~ s/\?/'$fileHash'/;
#			$query =~ s/\?/'$fileHash'/;
#		}
#
#		my @itemReplies = SqliteQueryHashRef($query);


		if (GetConfig('setting/html/item_page/replies_listing')) {
			WriteLog('GetItemPage: replies_listing: scalar(@itemReplies) = ' . scalar(@itemReplies));
			# REPLIES LIST
			foreach my $itemReply (@itemReplies) {
				WriteLog('GetItemPage: replies_listing: $itemReply = ' . $itemReply);

				if ($itemReply->{'labels_list'} && index($itemReply->{'labels_list'}, 'hide') != -1) {
					next;
				}

				if (GetConfig('setting/html/item_page/replies_listing_remove_tokens')) {
    				$itemReply->{'remove_token'} = '>>' . $file{'file_hash'};
                }

				if (GetConfig('setting/html/item_page/replies_listing_no_titles')) {
    				$itemReply->{'item_title'} = '';
    				#todo this actually results in 'Untitled' items, which is not right
                }

				if ($itemReply->{'labels_list'} && index($itemReply->{'labels_list'}, 'notext') != -1) {
					my $itemReplyTemplate = GetItemTemplate($itemReply); # GetItemPage() reply #notext
					$txtIndex .= '<span class=advanced>' . $itemReplyTemplate . '</span>';
				} else {
					# does not #hastext
					my $itemReplyTemplate = GetItemTemplate($itemReply); # GetItemPage() reply not #notext
					#$itemReplyTemplate = '<span class=advanced>' . $itemReplyTemplate . '</span>';
					$txtIndex .= $itemReplyTemplate;
				}
			}
		}

		# REPLY FORM
		#if (GetConfig('reply/enable')) {
		#	$txtIndex .= GetReplyForm($file{'file_hash'});
		#}

		# RELATED LIST
		my $showRelated = GetConfig('setting/html/item_page/toolbox_related');
		if (index(',' . $file{'labels_list'} . ',', ',pubkey,') != -1) {
			$showRelated = 0;
		}
		if ($showRelated) {
			my $relatedListing = GetRelatedListing($file{'file_hash'});
			$relatedListing = '<span class=advanced>' . $relatedListing . '</span>';
			if ($relatedListing) {
				$txtIndex .= $relatedListing;
			} else {
				if (GetConfig('debug')) {
					# $txtIndex .= GetDialogX('No related items for $file{\'file_hash\'} =  ' . $file{'file_hash'}, 'Debug');
					$txtIndex .= GetDialogX('Did not find any related items.', 'Debug Notice');
				} else {
					# nothing to do
				}
			}
		} else {
			# nothing to do
		}

		# SIMILAR TIMESTAMP LIST
		my $showSimilarTimestamps = GetConfig('setting/html/item_page/toolbox_similar_timestamp');
		if ($showSimilarTimestamps) {
			my $similarTimestampsListing = GetSimilarTimestampsListing($file{'file_hash'});
			$similarTimestampsListing = '<span class=advanced>' . $similarTimestampsListing . '</span>';
			if ($similarTimestampsListing) {
				$txtIndex .= $similarTimestampsListing;
			} else {
				if (GetConfig('debug')) {
					$txtIndex .= GetDialogX('Did not find any items with similar timestamps.', 'Debug Notice');
				} else {
					# nothing to do
				}
			}
		} else {
			# nothing to do
		}
	}

	## FINISHED REPLIES
	## FINISHED REPLIES
	## FINISHED REPLIES

	if (GetConfig('setting/html/item_page/applied_labels')) {
		my @parameters;
		push @parameters, $file{'file_hash'}; #it's an item, it's a file
		my $query = SqliteGetNormalizedQueryString('item_applied_labels', @parameters);
		my %param;
		$param{'no_empty'} = 1;
		$param{'no_heading'} = 1;
		$param{'no_status'} = 1;
		my $dialogAppliedLabels = '<span class=advanced>' . GetQueryAsDialog($query, 'AppliedLabels', 0, \%param) . '</span>';
		$dialogAppliedLabels = AddAttributeToTag($dialogAppliedLabels, 'table', 'id', 'AppliedLabels');
		$txtIndex .= $dialogAppliedLabels;
	}

	if (GetConfig('setting/html/item_page/toolbox_chain_next_previous')) {
		#todo optimize by joining with above
		$txtIndex .= '<span class=advanced>' . GetNextPreviousDialog($file{'file_hash'}) . '</span>';
	}

	if (GetConfig('setting/html/item_page/toolbox_timestamps')) {
		$txtIndex .= GetTimestampsDialog($file{'file_hash'});
	}

	if (GetConfig('setting/html/item_page/toolbox_hashes')) {
		$txtIndex .= GetHashComparisonDialog($file{'file_hash'});
	}

	if (GetConfig('setting/admin/debug_dialogs')) { #todo
		$txtIndex .= GetDialogX(GetFileMessageCachePath($file{'file_hash'}), 'GetFileMessageCachePath()');
	}

	if (GetConfig('html/item_page/parse_log')) {
		$txtIndex .= GetItemIndexLog($file{'file_hash'});
		if (
			(index($file{'labels_list'}, ',cpp,') != -1 && GetConfig('setting/admin/cpp/enable'))
			||
			(index($file{'labels_list'}, ',python3,') != -1 && GetConfig('setting/admin/python3/enable'))
			||
			(index($file{'labels_list'}, ',py,') != -1 && GetConfig('setting/admin/python3/enable'))
			||
			(index($file{'labels_list'}, ',perl,') != -1 && GetConfig('setting/admin/perl/enable'))
			||
			(index($file{'labels_list'}, ',zip,') != -1 && GetConfig('setting/admin/zip/enable'))
		) {
			# cpp / py / perl / zip file
			$txtIndex .= GetItemIndexLog($file{'file_hash'}, 'run_log');
			$txtIndex .= GetItemIndexLog($file{'file_hash'}, 'compile_log');
		}
		if (index($file{'labels_list'}, ',python3,') != -1 && !GetConfig('setting/admin/python3/enable')) {
			$txtIndex .= GetDialogX('Note: Python module is off, this file was not parsed.', 'Notice');
		}
		if (index($file{'labels_list'}, ',perl,') != -1 && !GetConfig('setting/admin/perl/enable')) {
			$txtIndex .= GetDialogX('Note: Perl module is off, this file was not parsed.', 'Notice');
		}
		#todo same as above for zip
	}

	if (GetConfig('setting/html/item_page/gpg_stderr')) {
		#$txtIndex .= GetItemIndexLog($file{'file_hash'});
		if (
			index($file{'labels_list'}, ',gpg,') != -1
			||
			index($file{'labels_list'}, ',pubkey,') != -1
			||
			index($file{'labels_list'}, ',signed,') != -1
		) {
			#WriteLog("GetItemIndexLog($file{'file_hash'}, 'gpg_stderr') abcdefghijklmnopqr");
			$txtIndex .= GetItemIndexLog($file{'file_hash'}, 'gpg_stderr');
		}
	}

	if (GetConfig('admin/js/enable') && GetConfig('setting/html/reply_cart')) {
		require_once('dialog/reply_cart.pl');
		$txtIndex .= GetReplyCartDialog();
	}

	# end page with footer
	$txtIndex .= GetPageFooter('item');

	# INJECT JS ######
	if (GetConfig('reply/enable')) {
		# if replies is on, include write.js and write_buttons.js
		my @js = qw(settings avatar voting utils profile translit write write_buttons timestamp itsyou);
		if (GetConfig('setting/html/reply_cart')) {
			push @js, 'reply_cart';
		}
		if (GetConfig('setting/admin/js/openpgp')) {
			#push @js, 'encrypt_comment';
		}
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php'; # reply form
		}
		$txtIndex = InjectJs($txtIndex, @js);
	} else {
		$txtIndex = InjectJs($txtIndex, qw(settings avatar voting utils profile translit timestamp itsyou));
	}
	# FINISH INJECT JS ######

	if ($addMavo) {
		$txtIndex = str_replace('</head>', '<script src="https://get.mavo.io/stable/mavo.es5.js"></script><link rel="stylesheet" href="https://get.mavo.io/stable/mavo.css"></link></head>', $txtIndex);
	}

	if ($addMermaid) {
		$txtIndex = str_replace('</head>', '<script src="https://iperez319.github.io/mermaid-js-component/src/LivePreview.js"></script></head>', $txtIndex);
	}

	#	my $scriptsInclude = '<script src="/openpgp.js"></script><script src="/crypto2.js"></script>';
#	$txtIndex =~ s/<\/body>/$scriptsInclude<\/body>/;

	return $txtIndex;
} # GetItemPage()

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

1;
