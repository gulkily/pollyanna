#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

require_once('dialog.pl');

sub GetReadPage { # $pageType, $parameter1, $parameter2 ; generates page with item listing based on parameters
	# GetReadPage
	#   $pageType, $parameter1, $parameter2
	#		author, key/hash
	#		tag, tag name/value
	#		date, date in YYYY-MM-DD format
	#		random, (none)
	#		label, label name

	# sub MakeAuthorPage {
	# sub GetAuthorPage {
	# sub GetAuthors {
	# sub MakeReadPage {
	# sub PrintReadPage {
	# sub GetTagPage {
	# sub GetLabelPage {
	# sub GetHashtagPage {
	# sub GetUserPage {
	# sub GetDatePage { # sub GetReadPage {
	# sub GetTagListing {
	# sub GetApprovePage { # /tag/approve.html

	my $title; # plain-text title for <title>
	my $titleHtml; # title which can have html formatting

	my $pageType = shift; # page type parameter
	my $pageParam; # parameter for page type, optionally looked up later

	my @files; # will contain array of hash-refs, one for each file

	my $authorKey; # stores author's key, if page type is author
	# #todo figure out why this is needed here

	my $zipName = '';
	my $queryDisplay = '';

	if (defined($pageType)) {
		WriteLog('GetReadPage($pageType = ' . $pageType . '); caller = ' . join(',', caller));

		#$pageType can be 'author', 'tag', 'date'

		if ($pageType eq 'author') {
			# AUTHOR PAGE ##############################################################

			$pageParam = shift;
			$authorKey = $pageParam;

			if (!IsFingerprint($authorKey)) {
				WriteLog('GetReadPage(author) called with invalid parameter');
				return;
			}

			my $whereClause = "WHERE author_key = '$authorKey' AND item_score >= 0";

			my $authorAliasHtml = GetAlias($authorKey);

			#require_once('widget/avatar.pl');
			my $authorAvatarHtml = GetAvatar($authorKey);

			if (IsAdmin($authorKey)) {
				$title = "Admin's Blog (Posts by or for $authorAliasHtml)";
				$titleHtml = "Admin's Blog ($authorAvatarHtml)";
			} else {
				if (!$authorAliasHtml) {
					WriteLog('GetReadPage: warning: $authorAliasHtml is FALSE, substituting Guest');
					$authorAliasHtml = 'Guest';
				}
				$title = "Posts by or for $authorAliasHtml";
				$titleHtml = "$authorAvatarHtml";
			}

			my %queryParams;
			$queryParams{'where_clause'} = $whereClause;
			$queryParams{'order_clause'} = 'ORDER BY add_timestamp DESC';
			$queryParams{'limit_clause'} = "LIMIT 100"; #todo fix hardcoded limit #todo pagination

			@files = DBGetItemList(\%queryParams); #used below in listing

			if (GetConfig('setting/zip/author')) {
				$zipName = "author/$authorKey.zip";
				#todo move this somewhere else
				if ($zipName) {
					require_once('make_zip.pl');
					my %zipOptions;
					$zipOptions{'where_clause'} = "WHERE author_key = '$authorKey'";
					my @zipFiles = DBGetItemList(\%zipOptions);
					MakeZipFromItemList($zipName, \@zipFiles);
				}
			}
		} # $pageType eq 'author'

		if ($pageType eq 'date') {
			#sub GetDatePage { # if ($pageType eq 'date') {
			$pageParam = shift;
			my $pageDate = $pageParam; # example: '2022-10-07'
			chomp($pageDate);

			#todo make a prettier title
			$title = $pageDate;
			$titleHtml = $pageDate;

			my %queryParams;

			#todo parametrize
			$queryParams{'where_clause'} = "
		WHERE
			file_hash IN (
				SELECT file_hash
				FROM item_flat
				WHERE
					item_score >= 0 AND
					(
						SUBSTR(DATETIME(add_timestamp, 'unixepoch', 'localtime'), 0, 11) = '$pageDate'
						OR
						file_hash IN (
							SELECT file_hash FROM item_attribute where attribute = 'date' AND value = '$pageDate'
						)
					)
				)
			";
			#todo optimize this query
			@files = DBGetItemList(\%queryParams);

			$queryDisplay = DBGetItemListQuery(\%queryParams);

			$zipName = "$pageDate.zip";
		} # $pageType eq 'date'

		if ($pageType eq 'label') { #'/label/label.html' #'/label/' GetLabelPage { GetLabelListing {
			# LABEL PAGE ############################################################
			#todo tell user how many items we found

			$pageParam = shift;
			my $labelName = $pageParam;
			chomp($labelName);

			if ($labelName =~ m/[^a-zA-Z0-9_]/) { #labelName
				WriteLog('GetReadPage: warning: sanity check failed on $labelName');
				return '';
			}


			$title = "$labelName, posts with label";
			$titleHtml = $title;

			my %queryParams;


			$queryParams{'where_clause'} = "
		WHERE
			item_flat.file_hash IN (
				SELECT
					file_hash
				FROM
					item_label
				WHERE
					label = '$labelName' OR
					label IN (
						SELECT label
						FROM label_parent
						WHERE label_parent = '$labelName'
				)
			)
			AND item_flat.item_score >= 0
			";
			$queryParams{'order_clause'} = "ORDER BY item_flat.add_timestamp DESC";
			$queryParams{'limit_clause'} = "LIMIT 100"; #todo fix hardcoded limit #todo pagination
			#todo this code is old-style and should be replaced
			#it should use a query template in ../template/query/

			$queryDisplay = DBGetItemListQuery(\%queryParams);

			@files = DBGetItemList(\%queryParams);

			if (GetConfig('setting/zip/label')) {
				$zipName = "label/$labelName.zip";
				#todo move this somewhere else
				if ($zipName) {
					require_once('make_zip.pl');
					my %zipOptions;
					$zipOptions{'where_clause'} = "
						WHERE
							item_flat.file_hash IN (
								SELECT
									file_hash
								FROM
									item_label
								WHERE
									label = '$labelName' OR
									label IN (
										SELECT label
										FROM label_parent
										WHERE label_parent = '$labelName'
								)
							)
					";
					my @zipFiles = DBGetItemList(\%zipOptions);
					MakeZipFromItemList($zipName, \@zipFiles);
				} # if ($zipName)
			} # if (GetConfig('setting/zip/label'))







		} # if ($pageType eq 'label')


		if ($pageType eq 'tag') { #'/tag/tag.html' #'/tag/tag.html' '/tag/' GetTagPage GetTagListing {
			# TAG PAGE ##############################################################
			#todo tell user how many items we found

			$pageParam = shift;
			my $tagName = $pageParam;
			chomp($tagName);

			if ($tagName =~ m/[^a-zA-Z0-9_]/) { #tagName
				WriteLog('GetReadPage: warning: sanity check failed on $tagName');
				return '';
			}

			$title = "$tagName, posts with tag";
			$titleHtml = $title;

			my %queryParams;
			#$queryParams{'join_clause'} = "JOIN item_label ON (item_flat.file_hash = item_label.file_hash)";
			#$queryParams{'group_by_clause'} = "GROUP BY item_label.file_hash";
			#$queryParams{'where_clause'} = "WHERE item_label.label = '$tagName'";

			# if (GetConfig('admin/expo_site_mode') && !GetConfig('admin/expo_site_edit')) {
			# 	$queryParams{'where_clause'} = "WHERE ','||labels_list||',' LIKE '%,$tagName,%'";
			# } else {
			# 	my $scoreThreshold = -100;
			# 	if ($tagName eq 'flag' || $tagName eq 'scunthorpe') {
			# 		# the flag page should show almost everything
			# 		# all other pages should have a filter
			# 		$scoreThreshold = -100;
			# 	}
			# 	#$queryParams{'where_clause'} = "WHERE ','||labels_list||',' LIKE '%,$tagName,%' AND item_score > 0";
			# 	#$queryParams{'where_clause'} = "WHERE ','||labels_list||',' LIKE '%,$tagName,%' AND item_score >= 0";
			# 	$queryParams{'where_clause'} = "WHERE ','||labels_list||',' LIKE '%,$tagName,%' AND item_score >= $scoreThreshold";
			# }

			#weird indentation here because we want it to look nice in the query dialog on the page
			$queryParams{'where_clause'} = "
		WHERE
			item_flat.file_hash IN (
				SELECT
					file_hash
				FROM
					item_label
				WHERE
					label = '$tagName' OR
					label IN (
						SELECT label
						FROM label_parent
						WHERE label_parent = '$tagName'
				)
			)
			AND item_flat.item_score >= 0
			";
			$queryParams{'order_clause'} = "ORDER BY item_flat.add_timestamp DESC";
			$queryParams{'limit_clause'} = "LIMIT 100"; #todo fix hardcoded limit #todo pagination
			#todo this code is old-style and should be replaced
			#it should use a query template in ../template/query/

			$queryDisplay = DBGetItemListQuery(\%queryParams);

			@files = DBGetItemList(\%queryParams);

			if (GetConfig('setting/zip/tag')) {
				$zipName = "tag/$tagName.zip";
				#todo move this somewhere else
				if ($zipName) {
					require_once('make_zip.pl');
					my %zipOptions;
					$zipOptions{'where_clause'} = "
						WHERE
							item_flat.file_hash IN (
								SELECT
									file_hash
								FROM
									item_label
								WHERE
									label = '$tagName' OR
									label IN (
										SELECT label
										FROM label_parent
										WHERE label_parent = '$tagName'
								)
							)
					";
					my @zipFiles = DBGetItemList(\%zipOptions);
					MakeZipFromItemList($zipName, \@zipFiles);
				} # if ($zipName)
			} # if (GetConfig('setting/zip/tag'))
		} # $pageType eq 'tag'
		if ($pageType eq 'random') { #'/random.html'
			WriteLog('GetReadPage: random');
			# RANDOM  PAGE ##############################################################

			$pageParam = shift;

			$title = 'Random';
			$titleHtml = $title;

			my %queryParams;

			$queryParams{'where_clause'} = "WHERE item_score >= 0";
			$queryParams{'order_clause'} = "ORDER BY RANDOM() DESC";
			$queryParams{'limit_clause'} = "LIMIT 100";

			@files = DBGetItemList(\%queryParams);
		} # $pageType eq 'random'
	} else {
		return; #this code is deprecated
		#		$title = GetConfig('html/home_title') . ' - ' . GetConfig('logo_text');
		#		$titleHtml = GetConfig('html/home_title');
		#
		#		my %queryParams;
		#
		#		@files = DBGetItemList(\%queryParams);
	}

	# GENERATE PAGE ######

	my $txtIndex = ""; # contains html output

	# this will hold the title of the page
	if (!$title) {
		$title = GetConfig('html/home_title');
	}

	chomp $title;
	$title = HtmlEscape($title);

	my $htmlStart = '';

	#require_once('get_page_header.pl');
	#$htmlStart .= GetPageHeader('read_' . $pageType);
	$htmlStart = GetPageHeader($title);

	if ($pageType eq 'tag') {
		# fill in tag placeholder at top of page
		# this is where it says, "this page shows all items with tag $tagSelected

		$htmlStart =~ s/\$tagSelected/$pageParam/;

		# $pageParam is the chosen tag for this page

		# is this still needed?
	}

	$txtIndex .= $htmlStart;

	#todo
	#<span class="replies">last reply at [unixtime]</span>
	#javascript foreach span class=replies { get time after "last reply at" and compare to "last visited" cookie

	my $needUploadJs = 0;
	if ($pageType eq 'tag') {
		# add tag buttons with selected tag emphasized
		$txtIndex .= '<span class=advanced>' . GetTagPageHeaderLinks($pageParam) . '</span>';

		my $tagInfo = GetString('tag_info/' . $pageParam);
		if ($tagInfo && ($tagInfo ne $pageParam)) {
			# don't show tag info if it matches page param
			# as that provides no additional useful information
			$txtIndex .= GetDialogX(FormatForWeb($tagInfo), 'Tag Information');
		}
		# this would add a list of all the items on the page
		# 		$txtIndex .= GetQueryAsDialog($queryDisplay);

		if (GetConfig('setting/zip/tag')) {
			if (scalar(@files) > 0) {
				my $zipLink = '<a href="/tag/' . $pageParam . '.zip">' . $pageParam . '.zip</a>'; #todo use RenderLink()
				$zipLink = '<fieldset>' . $zipLink . '</fieldset>';
				$txtIndex .= '<span class=advanced>' . GetDialogX($zipLink, 'Archive') . '</span>'; # tag.zip
			} else {
				$txtIndex .= GetDialogX('This tag has no items yet, <br>so no archive is available.', 'Archive');
			}
		}

		if ($pageParam eq 'image') { # GetReadPage()
			#$txtIndex .= GetUploadDialog();

			if (GetConfig('admin/js/enable')) {
				$txtIndex .= GetDialogX('<a href=# onclick="if (window.UnmaskBlurredImages) { UnmaskBlurredImages() }">Show Masked Images</a>', 'One Lonesome Link');
			}

			$needUploadJs = 1;
		}
	} # if ($pageType eq 'tag')

	$txtIndex .= GetTemplate('html/maincontent.template');
	if ($pageType eq 'author') {
		# sub GetAuthorPage {
		# author info box
		$txtIndex .= GetAuthorInfoBox($authorKey);

		my $queryAuthorThreads = SqliteGetQueryTemplate('author_threads');
		$queryAuthorThreads =~ s/\?/'$authorKey'/;
		my %queryFlags;
		$queryFlags{'no_no_results'} = 1;
		$txtIndex .= GetQueryAsDialog(
			$queryAuthorThreads,
			'Topics by Author ' . GetAlias($authorKey),
			'',
			\%queryFlags
		);

		# $txtIndex .= GetQueryAsDialog(
		# 	"
		# 		SELECT
		# 			item_title,
		# 			add_timestamp,
		# 			file_hash,
		# 			item_score
		# 		FROM
		# 			item_flat
		# 			LEFT JOIN author_score ON (item_flat.author_key = author_score.author_key)
		# 		WHERE
		# 			item_flat.author_key = '$authorKey'
		# 	",
		# 	'Items by Author'
		# );

		{
			#todo templatize and improve
			#liked by author and flagged by author

			my %queryFlags;
			$queryFlags{'no_no_results'} = 1;

			if (!IsFingerprint($authorKey)) {
				#something is wrong
				WriteLog('GetReadPage: warning: ...'); #todo
			} else {
				#todo templatize this
				my $query = "
					SELECT
						item_flat.file_hash AS file_hash,
						item_flat.item_title AS item_title
					FROM
						item_flat,
						(
							SELECT
								file_hash,
								ballot_time
							FROM
								item_label
							WHERE
								item_label.author_key = '$authorKey'
								AND label = 'like'
						) AS like
					WHERE
						item_flat.file_hash = like.file_hash
						AND item_flat.author_key != '$authorKey'
					;
				";
				$txtIndex .= GetQueryAsDialog($query
					,
					'Posts Liked by Author',
					'',
					\%queryFlags
				);
			}

			if (!IsFingerprint($authorKey)) {
				#something is wrong
				WriteLog('GetReadPage: warning: ...'); #todo
			} else {
				#todo fix this
				#my $query = "select file_hash, item_title from
				#		item_flat where file_hash in (select file_hash from item_label where item_label.author_key = '$authorKey' AND label = 'flag');";
				#$txtIndex .= GetQueryAsDialog($query
				#	,
				#	'Posts Flagged By Author',
				#	'',
				#	\%queryFlags
				#);
			}
		}

		if (GetConfig('setting/zip/author')) {
			if (scalar(@files) > 0) {
				my $zipLink = '<a href="/author/' . $authorKey . '.zip">' . $authorKey . '.zip</a>'; #todo use RenderLink()
				$zipLink = '<fieldset>' . $zipLink . '</fieldset>';
				$txtIndex .= GetDialogX($zipLink, 'Archive'); # author.zip
			} else {
				$txtIndex .= GetDialogX('This author has not posted anything yet, <br>so no archive is available.', 'Archive');
			}
		}

		$txtIndex .= '<hr 5>';
	} # if ($pageType eq 'author')

	my $itemComma = '';

	if (scalar(@files) > 0) {
		$txtIndex .= '<span class=advanced>' . GetDialogX('Items on page: ' . scalar(@files), 'Count') . '</span>';
	}
	WriteLog('GetReadPage: scalar(@files) = ' . scalar(@files));

	# LISTING ITEMS BEGINS HERE
	# LISTING ITEMS BEGINS HERE
	# LISTING ITEMS BEGINS HERE
	# LISTING ITEMS BEGINS HERE
	# LISTING ITEMS BEGINS HERE

	my %params;
	if ($pageType eq 'tag') {
		$params{'vote_return_to'} = '/tag/' . $pageParam . '.html'; #todo unhardcode
	}

	$txtIndex .= GetItemListHtml(\@files, \%params);

	# LISTING ITEMS ENDS HERE
	# LISTING ITEMS ENDS HERE
	# LISTING ITEMS ENDS HERE
	# LISTING ITEMS ENDS HERE
	# LISTING ITEMS ENDS HERE

	if ($pageType eq 'tag' && $pageParam eq 'image') { # GetReadPage()
		# a special case for the #image page
		# include upload dialog
		require_once('page/upload.pl');
		$txtIndex .= GetUploadDialog();
	}

	if ($queryDisplay) {
		my $queryWindowContents .= '<pre>' . HtmlEscape($queryDisplay) . '<br></pre>'; #todo templatify
		my $queryDisplayDialog = GetDialogX($queryWindowContents, 'Query');
		$queryDisplayDialog = '<span class=advanced>' . $queryDisplayDialog . '</span>';
		$txtIndex .= $queryDisplayDialog;
	}

	if (GetConfig('admin/js/enable') && GetConfig('setting/html/reply_cart')) {
		require_once('dialog/reply_cart.pl');
		$txtIndex .= GetReplyCartDialog();
	}

	# Close html
	$txtIndex .= GetPageFooter('read_' . $pageType);

	my @jsToInject = qw(settings timestamp voting utils profile);
	if ($pageType eq 'author') {
		push @jsToInject, 'itsyou';
	}
	if (GetConfig('setting/admin/js/fresh')) {
		push @jsToInject, 'fresh';
	}
	if (GetConfig('setting/html/reply_cart')) {
		push @jsToInject, 'reply_cart';
	}
	if ($needUploadJs) {
		push @jsToInject, 'upload';
	}
	$txtIndex = InjectJs($txtIndex, @jsToInject);

	$txtIndex .= '<!-- GetReadPage() -->';

	return $txtIndex;
} # GetReadPage()

1;
