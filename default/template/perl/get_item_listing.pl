#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetItemListing { # $fileHash ; returns listing of items based on topic
# sub GetResultsPage {
# sub GetItemListingHtml {
#
# ATTENTION: not to be confused with GetItemListingPage()
	my $htmlOutput = '';

	my @topItems; #todo rename this

	my $fileHash = shift;
	my $title = 'Welcome, Guest!';

	if (!$fileHash) {
		$fileHash = 'top'; #what
	}

	my $listingType = '';

	#todo refactor
	if ($fileHash eq 'top') {
		@topItems = DBGetTopItems(); # get top items from db
		$listingType = 'top';
	} else {
		@topItems = DBGetItemReplies($fileHash);
		$title = 'Replies';
		$listingType = 'replies';
	}

	WriteLog('GetItemListing(' . $fileHash . '); caller = ' . join(',', caller));

	if (!@topItems) {
		WriteLog('GetItemListing: warning @topItems missing, sanity check failed');
		return '';
	}

	my $itemCount = scalar(@topItems);

	if ($itemCount) {
	# at least one item returned

		my $itemListingWrapper = GetTemplate('html/item_listing_wrapper2.template');

		my $itemListings = '';

		my $rowBgColor = ''; # stores current value of alternating row color
		my $colorRow0Bg = GetThemeColor('row_0'); # color 0
		my $colorRow1Bg = GetThemeColor('row_1'); # color 1

		while (@topItems) {
			my $itemTemplate = GetTemplate('html/item_listing.template');
			# it's ok to do this every time because GetTemplate() already stores it in a static
			# alternative is to store it in another variable above

			#alternate row color
			if ($rowBgColor eq $colorRow0Bg) {
				$rowBgColor = $colorRow1Bg;
			} else {
				$rowBgColor = $colorRow0Bg;
			}

			my $itemRef = shift @topItems; # reference to hash containing item
			my %item = %{$itemRef}; # hash containing item data

			my $itemKey = $item{'file_hash'};
			my $itemScore = $item{'item_score'};
			my $authorKey = $item{'author_key'};

			my $itemLastTouch = DBGetItemLatestAction($itemKey); #todo add to itemfields

			my $itemTitle = $item{'item_title'};
			if (trim($itemTitle) eq '') {
				# if title is empty, use the item's hash
				# $itemTitle = '(' . $itemKey . ')';
				$itemTitle = 'Untitled';
			}
			$itemTitle = HtmlEscape($itemTitle);

			# my $itemLink = '/' . GetHtmlFilename($itemKey); # GetItemListing() #todo this is a bandaid
			my $itemLink = '/' . GetItemUrl($itemKey); # GetItemListing() #todo this is a bandaid

			my $authorAvatar;
			if ($authorKey) {
#				$authorAvatar = GetPlainAvatar($authorKey);
				my $authorLink = GetAuthorLink($authorKey, 1);
				if ($authorLink) {
					$authorAvatar = GetAuthorLink($authorKey, 1);
#					$authorAvatar = 'by ' . GetAuthorLink($authorKey, 1);
				} else {
					$authorAvatar = 'Unsigned';
				}
			} else {
				$authorAvatar = 'Unsigned';
			}

			$itemLastTouch = GetTimestampWidget($itemLastTouch);

			# populate item template
			$itemTemplate =~ s/\$link/$itemLink/g;
			$itemTemplate =~ s/\$itemTitle/$itemTitle/g;
			$itemTemplate =~ s/\$itemScore/$itemScore/g;
			$itemTemplate =~ s/\$authorAvatar/$authorAvatar/g;
			$itemTemplate =~ s/\$itemLastTouch/$itemLastTouch/g;
			$itemTemplate =~ s/\$rowBgColor/$rowBgColor/g;

			# if ($listingType eq 'replies') {
			# 	if (index($item{'tags_list'}, 'notext') != -1) {
			# 		$itemTemplate .= '<span class=advanced>' . $itemTemplate . '</span>';
			# 	}
			# 	$itemTemplate .= $item{'tags_list'};
			# }

			# add to main html
			$itemListings .= $itemTemplate;
		}

		$itemListingWrapper =~ s/\$itemListings/$itemListings/;

		my $statusText = '';
		if ($itemCount == 0) {
			$statusText = 'No threads found.';
		} elsif ($itemCount == 1) {
			$statusText = '1 thread';
		} elsif ($itemCount > 1) {
			$statusText = $itemCount . ' threads';
		}

		my $columnHeadings = 'title,author,activity';

		$itemListingWrapper = GetDialogX(
			$itemListings,
			$title,
			$columnHeadings,
			$statusText
		);

		$htmlOutput .= $itemListingWrapper;

		#$htmlOutput .= GetDialogX('<tt>... and that is ' . $itemCount . ' item(s) total! beep boop</tt>', 'robot voice');

	} else {
	# no items returned, use 'no items' template
		$htmlOutput .= GetDialogX(GetTemplate('html/item/no_items.template'), 'Welcome, Guest!');
		#todo add menu?
	}

	return $htmlOutput;
} # GetItemListing()

1;