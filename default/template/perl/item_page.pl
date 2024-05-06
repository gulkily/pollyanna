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

	if (GetConfig('setting/zip/thread')) {
		#todo should only happen if thread has no parents?
		my @hasParents = DBGetItemParents($fileHash);
		WriteLog('GetItemPage: zip/thread: @hasParents = ' . scalar(@hasParents));
		if (!scalar(@hasParents)) {
			my @itemsInThread = DBGetAllItemsInThreadAsArray($fileHash);
			# make zip file of all items in thread
			my $zipFile = "thread_" . substr($fileHash, 0, 8) . ".zip";
			require_once('make_zip.pl');
			MakeZipFromItemList($zipFile, \@itemsInThread);
			my $HTMLDIR = GetDir('html');
			my $zipSize = -s "$HTMLDIR/$zipFile"; #todo GetFileSize()
			my $fileSize = GetFileSizeWidget($zipSize);
			$txtIndex .= GetDialogX("<fieldset><a href='/$zipFile'>$zipFile</a> $fileSize</fieldset>", 'Thread');
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

	if (GetConfig('setting/html/item_page/toolbox_links')) {
		my @result = SqliteQueryHashRef('item_url', $fileHash);
		#todo move to default/query
		if (scalar(@result) > 1) {
			# urls
			# links toolbox
			my $queryText = SqliteGetNormalizedQueryString('item_url', $fileHash);
			my %flags;
			#$flags{'no_heading'} = 1;
			$flags{'query'} = $queryText;

			my $linksToolbox = GetResultSetAsDialog(\@result, 'Links', 'value', \%flags);
			#my $linksToolbox = GetResultSetAsDialog(\@result, 'Links', 'value,item_title,file_hash', \%flags);
			$linksToolbox = AddAttributeToTag($linksToolbox, 'table', 'id', 'Links');
			$txtIndex .= $linksToolbox;
		}
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

require_once('item_page_toolbox.pl');

1;
