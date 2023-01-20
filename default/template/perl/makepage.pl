#!/usr/bin/perl -T

use strict;
use warnings;
use utf8;
use 5.010;

#use threads ('yield',
#             'stack_size' => 64*4096,
#             'exit' => 'threads_only',
#             'stringify');

my @argsFound;
while (my $argFound = shift) {
	push @argsFound, $argFound;
}

require_once('item_list_as_gallery.pl');
require_once('get_window_template.pl');

sub MakePage { # $pageType, $pageParam, $htmlRoot ; make a page and write it into $HTMLDIR directory; $pageType, $pageParam
# sub makepage {
# sub getpage {
# sub GetTagsPage {
# sub GetPage {
			# supported page types so far:
# tag, #hashtag
# author, ABCDEF01234567890
# item, 0123456789abcdef0123456789abcdef01234567
# date, YYYY-MM-DD
# authors
# read
# prefix
# summary (deprecated)
# tags
# stats
# index
# compost
# bookmark

	state $HTMLDIR = GetDir('html');

	# $pageType = author, item, tags, etc.
	# $pageParam = author_id, item_hash, etc.
	my $pageType = shift;
	my $pageParam = shift;
	my $htmlRoot = shift;

	if ($htmlRoot) {
		$HTMLDIR = $htmlRoot;
	}

	#todo sanity checks
	#todo sanity checks
	#todo sanity checks

	if (!defined($pageParam)) {
		$pageParam = 0;
	}

	WriteMessage('MakePage(' . $pageType . ', ' . $pageParam . ')');
	WriteLog('MakePage(' . $pageType . ', ' . $pageParam . '); caller = ' . join(',', caller));

	my @listingPages = qw(child chain url deleted compost new raw picture image read authors scores tags threads boxes tasks);
	#chain.html #new.html #boxes.html #tasks.html
	my @simplePages = qw(spy data cloud bookmark help example access welcome calendar profile upload links post cookie chat thanks examples about faq documentation);

	if (0) { } # this is to make all the elsifs below have consistent formatting
	elsif (in_array($pageType, @simplePages)) {
		WriteLog('MakePage: found "' . $pageType . '" in @simplePages');
		MakeSimplePage($pageType);
		if ($pageType eq 'settings') {
			MakeStatsPages();
		}
	}
	elsif (in_array($pageType, @listingPages)) {
		WriteLog('MakePage: found "' . $pageType . '" in @listingPages');
		require_once('item_listing_page.pl');
		my %params;

		# uses WriteItemListingPages() and GetItemListingPage()

		if ($pageType eq 'chain') { # chain.html
			$params{'dialog_columns'} = 'special_title_tags_list,chain_order,chain_timestamp,file_hash';
		}
		if ($pageType eq 'tags') {
			#todo does this need to happen every time a listing page is generated?
			my $tagsHorizontal = GetTagPageHeaderLinks();
			PutHtmlFile('tags-horizontal.html', $tagsHorizontal);
		}
		if ($pageType eq 'image') {
			#todo unhardcode
			WriteItemListingPages($pageType, 'full_items', \%params);
		} else {
			WriteItemListingPages($pageType, 'dialog_list', \%params);
		}
	}

	elsif ($pageType eq 'write') {
		WriteLog('MakePage: write');
		MakeWritePage();
	}

	elsif ($pageType eq 'random') {
		WriteLog('MakePage: random');

		my @itemsRandom = SqliteQueryHashRef('random');
		shift @itemsRandom;

		if (@itemsRandom) {
			my $targetPath = "random.html";
			my $randomPage =
				GetPageHeader('random') .
				GetQueryAsDialog('select file_hash, item_title from item_flat order by random() limit 25') .
				#GetItemListAsGallery(\@itemsRandom) . # this doesn't work for some reason #todo
				GetPageFooter('random');
			;

			my @jsToInject = qw(settings timestamp voting utils profile);
			if (GetConfig('setting/admin/js/fresh')) {
				push @jsToInject, 'fresh';
			}
			if (GetConfig('setting/html/reply_cart')) {
				push @jsToInject, 'reply_cart';
			}
			$randomPage = InjectJs($randomPage, @jsToInject);

			#my $randomPage = GetReadPage('random');
			PutHtmlFile($targetPath, $randomPage);
		} else {
			my $targetPath = "random.html";
			PutHtmlFile($targetPath, GetPageHeader('random') . GetWindowTemplate('Nothing to display on the random page yet.') . GetPageFooter('random'));
		}
	} #random

	# tag page, get the tag name from $pageParam
	elsif ($pageType eq 'tag') {
		my $tagName = $pageParam;
		my $targetPath = "tag/$tagName.html";
		WriteLog('MakePage: tag: $tagName = ' . $tagName);

		if (0) {
			require_once('item_listing_page.pl');

			my %params;
			my %queryParams;
			#$queryParams{'limit_clause'} = "LIMIT 1000"; #todo fix hardcoded limit #todo pagination
			$queryParams{'order_clause'} = "ORDER BY item_score DESC, item_flat.add_timestamp DESC";
			my $scoreThreshold = 0;
			$queryParams{'where_clause'} = "WHERE ','||tags_list||',' LIKE '%,$tagName,%' AND item_score >= $scoreThreshold";

			$params{'query'} = DBGetItemListQuery(\%queryParams);
			$params{'query_params'} = \%queryParams;
			$params{'target_path'} = 'tag/' . $tagName;

			WriteItemListingPages($pageType, 'dialog_list', \%params);
		}

		my $tagPage = GetReadPage('tag', $tagName);
		PutHtmlFile($targetPath, $tagPage);
	}
	
	elsif ($pageType eq 'date') {
		my $pageDate = $pageParam;
		my $targetPath = "date/$pageDate.html";
		
		WriteLog('MakePage: date: $pageDate = ' . $pageDate);
		my $datePage = GetReadPage('date', $pageDate);
		PutHtmlFile($targetPath, $datePage);
	}

	elsif ($pageType eq 'speakers') {
		WriteLog('MakePage: speakers');
		my $speakersPage = '';
		$speakersPage = GetPageHeader('speakers');

		my %queryParams;
		$queryParams{'where_clause'} = "WHERE ','||tags_list||',' LIKE '%,speaker,%'";
		$queryParams{'order_clause'} = "ORDER BY file_name";
#		$queryParams{'where_clause'} = "WHERE ','||tags_list||',' LIKE '%,speaker,%'";

		my @itemSpeakers = DBGetItemList(\%queryParams);
		foreach my $itemSpeaker (@itemSpeakers) {
			#$itemSpeaker->{'item_title'} = $itemSpeaker->{'item_name'};
			if (length($itemSpeaker->{'item_title'}) > 48) {
				$itemSpeaker->{'item_title'} = substr($itemSpeaker->{'item_title'}, 0, 45) . '[...]';

			}
			$itemSpeaker->{'item_statusbar'} = GetItemHtmlLink($itemSpeaker->{'file_hash'}, $itemSpeaker->{'item_title'});
			my $itemSpeakerTemplate = GetItemTemplate($itemSpeaker);
			$speakersPage .= $itemSpeakerTemplate;
		}

		$speakersPage .= GetPageFooter('speakers');
		$speakersPage = InjectJs($speakersPage, qw(settings utils));
		PutHtmlFile('speakers.html', $speakersPage);
	}


	elsif ($pageType eq 'committee') {
		WriteLog('MakePage: committee');
		my $committeePage = '';
		$committeePage = GetPageHeader('committee');

		my %queryParams;
		$queryParams{'where_clause'} = "WHERE ','||tags_list||',' LIKE '%,committee,%'";
		$queryParams{'order_clause'} = "ORDER BY item_order";

		my @itemCommittee = DBGetItemList(\%queryParams);
		foreach my $itemCommittee (@itemCommittee) {
			if (GetConfig('admin/mit_expo_mode')) {
				if ($itemCommittee->{'item_name'} eq 'Manish Kumar') {
					#expo mode #todo #bandaid
					$itemCommittee->{'item_title'} = 'Hackathon Co-Chair';
				}
			}
			if (length($itemCommittee->{'item_title'}) > 48) {
				$itemCommittee->{'item_title'} = substr($itemCommittee->{'item_title'}, 0, 43) . '[...]';
			}
			if (!GetConfig('admin/expo_site_edit')) {
				$itemCommittee->{'no_permalink'} = 1;
			}
			my $itemCommitteeTemplate = GetItemTemplate($itemCommittee);
			$committeePage .= $itemCommitteeTemplate;
		}

		$committeePage .= GetPageFooter('committee');
		$committeePage = InjectJs($committeePage, qw(settings utils));
		PutHtmlFile('committee.html', $committeePage);
	}
	elsif ($pageType eq 'sponsors') {
		WriteLog('MakePage: sponsors');
		my $sponsorsPage = '';
		$sponsorsPage = GetPageHeader('sponsors');

		foreach my $sponsorLevel (qw(gold silver)) {
			my %queryParams;
			$queryParams{'where_clause'} = "WHERE ','||tags_list||',' LIKE '%,sponsor,%' AND ','||tags_list||',' LIKE '%,$sponsorLevel,%'";
			$queryParams{'order_clause'} = "ORDER BY file_name";

			my $sponsorsImages = '';

			my @itemSponsors = DBGetItemList(\%queryParams);
			foreach my $itemSponsor (@itemSponsors) {
				if (length($itemSponsor->{'item_title'}) > 48) {
					$itemSponsor->{'item_title'} = substr($itemSponsor->{'item_title'}, 0, 43) . '[...]';
				}
				my $sponsorImage = GetImageContainer($itemSponsor->{'file_hash'}, $itemSponsor->{'item_name'});
				$sponsorImage = AddAttributeToTag($sponsorImage, 'img', 'height', '100');
				$sponsorImage = GetWindowTemplate($sponsorImage, '');
				$sponsorsImages .= $sponsorImage;
				$sponsorsImages .= "<br><br><br>";
				#my $itemSponsorTemplate = GetItemTemplate($itemSponsor);
				#$sponsorsPage .= $itemSponsorTemplate;
			}

			$sponsorsImages = '<center style="padding: 5pt">' . $sponsorsImages . '</center>';
			$sponsorsPage .= GetWindowTemplate('<tr><td>' . $sponsorsImages . '</td></tr>', ucfirst($sponsorLevel) . ' Sponsors');

			$sponsorsPage .= "<br><br>";
		}

		$sponsorsPage .= GetPageFooter('sponsors');
		$sponsorsPage = InjectJs($sponsorsPage, qw(settings utils));

		PutHtmlFile('sponsors.html', $sponsorsPage);
	} #sponsors
	#
	# author page, get author's id from $pageParam
	elsif ($pageType eq 'author') {
		if ($pageParam =~ m/^([0-9A-F]{16})$/) {
			$pageParam = $1;
		} else {
			WriteLog('MakePage: author: warning: $pageParam sanity check failed. returning');
			return '';
		}

		my $authorKey = $pageParam;
		my $targetPath = "author/$authorKey/index.html";

		WriteLog('MakePage: author: ' . $authorKey);

		my $authorPage = GetReadPage('author', $authorKey);
		if (!-e "$HTMLDIR/author/$authorKey") {
			mkdir ("$HTMLDIR/author/$authorKey");
		}
		PutHtmlFile($targetPath, $authorPage);

		if (IsAdmin($authorKey) == 2) {
			MakeSummaryPages();
		}
	}
	#
	# if $pageType eq item, generate that item's page
	elsif ($pageType eq 'item') {
		# get the item's hash from the param field
		my $fileHash = $pageParam;

		# get item page's path #todo refactor this into a function
		#my $targetPath = $HTMLDIR . '/' . substr($fileHash, 0, 2) . '/' . substr($fileHash, 2) . '.html';
		my $targetPath = GetHtmlFilename($fileHash); # MakePage()

		# get item list using DBGetItemList()
		# #todo clean this up a little, perhaps crete DBGetItem()
		my @files = DBGetItemList({'where_clause' => "WHERE file_hash LIKE '$fileHash%'"});

		if (scalar(@files)) {
			my $file = $files[0];

			if ($file) {
				if ($HTMLDIR =~ m/^(^\s+)$/) { #security #taint #todo
					$HTMLDIR = $1; # untaint
					# create a subdir for the first 2 characters of its hash if it doesn't exist already
					if (!-e ($HTMLDIR . '/' . substr($fileHash, 0, 2))) {
						mkdir(($HTMLDIR . '/' . substr($fileHash, 0, 2)));
					}
					if (!-e ($HTMLDIR . '/' . substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2))) {
						mkdir(($HTMLDIR . '/' . substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2)));
					}
				}

				# get the page for this item and write it
				WriteLog('MakePage: my $filePage = GetItemPage($file = "' . $file . '")');
				my $filePage = GetItemPage($file);
				WriteLog('PutHtmlFile($targetPath = ' . $targetPath . ', $filePage = ' . length($filePage) . ' bytes)');
				PutHtmlFile($targetPath, $filePage);
			} # if ($file)
			else { # no $file
				#PutHtmlFile($targetPath, 'I looked for that, but could not find it (1)');
				WriteMessage('MakePage: item: warning: $file missing, sanity check failed!');
				WriteLog('MakePage: item: warning: sanity check failed: $file ($files[0]) is missing!');
			} # no $file
		} # if (scalar(@files))
		else { # no @files
			#PutHtmlFile($targetPath, 'I looked for that, but could not find it (2)');
			WriteLog('MakePage: warning: Item not in database; $fileHash = ' . $fileHash . '; caller = ' . join(',', caller));
			# my $query = GetTemplate('query/new') . " LIMIT 12";
			# my $queryDialog = GetQueryAsDialog($query, 'Newest');
			# my $page =
			# 	GetPageHeader('help') .
			# 	GetWindowTemplate('Could not find item. It may have been renamed?', 'Error') .
			# 	$queryDialog .
			# 	GetPageFooter('help')
			# ;
			# PutHtmlFile($targetPath, $page);
			return '';
		} # nothing in scalar(@files)
	} # $pageType eq 'item' # item page
	#
	# topitems page
	elsif ($pageType eq 'image') {
		WriteLog('MakePage: image');
		require_once('item_listing_page.pl');
		WriteItemListingPages('image', 'image_gallery');
	}
	elsif ($pageType eq 'picture') {
		WriteLog('MakePage: picture');
		require_once('item_listing_page.pl');
		WriteItemListingPages('picture', 'image_gallery');
	}
	# stats page
	elsif ($pageType eq 'stats') {
		WriteLog('MakePage: stats');
		PutStatsPages();
	}
	#
	# item prefix page
	elsif ($pageType eq 'prefix') {
		my $itemPrefix = $pageParam;
		my $itemsPage = GetItemPrefixPage($itemPrefix);
		PutHtmlFile(substr($itemPrefix, 0, 2) . '/' . substr($itemPrefix, 2, 2) . '/index.html', $itemsPage);
	}
	#
	#
	# rss feed
	elsif ($pageType eq 'rss') {
		require_once('page/rss.pl');
		#todo break out into own module and/or auto-generate rss for all relevant pages

		my %queryParams;

		$queryParams{'order_clause'} = 'ORDER BY add_timestamp DESC';
		$queryParams{'limit_clause'} = 'LIMIT 200';
		my @rssFiles = DBGetItemList(\%queryParams);

		PutFile("$HTMLDIR/rss.xml", GetRssFile(@rssFiles));
	}
	#
	# summary pages
	elsif ($pageType eq 'summary') {
		MakeSummaryPages();
	}
	#
	# summary pages
	#
	# fallthrough
	else {
		WriteMessage('Warning: did not recognize that page type: ' . $pageType);
		WriteMessage('=========================================');
	}

	WriteLog("MakePage: finished, calling DBDeletePageTouch($pageType, $pageParam)");
	DBDeletePageTouch($pageType, $pageParam);
} # MakePage()

1;
