#!/usr/bin/perl -T

use strict;
use warnings;
use POSIX qw(strftime);

sub FeedDateFormat {
	my $date = shift;
	my $formattedDate = strftime '%a, %d %b %Y %H:%M:%S %Z', localtime $date;
	return $formattedDate;
}

sub GetRssFile { # returns rss feed for current site
# sub MakeRss {
# sub GetRss {
# sub MakeFeed {

# Resultset needs to have the following fields:
# file_path
# item_title
# add_timestamp

#todo it should also display and authors and link to author pages

	my %queryParams;

	my $urlProtocol = 'http';

	$queryParams{'order_clause'} = 'ORDER BY add_timestamp DESC';
	my @files = DBGetItemList(\%queryParams);

	my $feedContainerTemplate = GetTemplate('rss/feed.xml.template');;
	if (GetConfig('setting/admin/html/ascii_only')) {
		my $unicodeHeader = GetTemplate('rss/feed_header_utf8.xml.template');
		my $asciiHeader = GetTemplate('rss/feed_header_ascii.xml.template');

		$feedContainerTemplate = $asciiHeader . substr($feedContainerTemplate, length($unicodeHeader));
	}

	my $myHost = GetConfig('setting/admin/rss_host');
	if ($myHost eq 'localhost:2784') {
		WriteLog('GetRssFile: warning: rss_host has not been changed from default');
	}
	if (!$myHost) {
		#todo WriteLog('GetRssFile: ')
		$myHost = GetConfig('setting/admin/my_domain');
		if ($myHost eq 'localhost:2784') {
			WriteLog('GetRssFile: warning: my_domain has not been changed from default');
		}
	}

	my $baseUrl = $urlProtocol . '://' . $myHost . '/';

	my $feedTitle = GetConfig('setting/html/home_title');
	my $feedLink = GetConfig('setting/admin/my_domain'); # default = http://localhost:2784/
	my $feedDescription = GetString('site_description');
	my $aboutUrl = $baseUrl;

	my $feedPubDate = GetTime();
	$feedPubDate = FeedDateFormat($feedPubDate);
	#%a, %d %b %Y %H:%M +:%S %Z

	if (!$feedLink) {
		$feedLink = $myHost;
	}
	$feedLink = $urlProtocol . '://' . $feedLink;

	$feedContainerTemplate =~ s/\$feedTitle/$feedTitle/;
	$feedContainerTemplate =~ s/\$feedLink/$feedLink/;
	$feedContainerTemplate =~ s/\$feedDescription/$feedDescription/;
	$feedContainerTemplate =~ s/\$feedPubDate/$feedPubDate/;
	$feedContainerTemplate =~ s/\$aboutUrl/$aboutUrl/;

	my $feedItems = '';
	my $feedItemsToc = '';

	foreach my $file(@files) {
		my $fileHash = $file->{'file_hash'};

		if (IsFileDeleted(0, $fileHash)) {
			WriteLog("generate.pl: IsFileDeleted() returned true, skipping");

			return;
		}

		#
		#"item_flat.file_path file_path,
		#item_flat.item_name item_name,
		#item_flat.file_hash file_hash,
		#item_flat.author_key author_key,
		#item_flat.child_count child_count,
		#item_flat.parent_count parent_count,
		#item_flat.add_timestamp add_timestamp,
		#item_flat.item_title item_title,
		#item_flat.item_score item_score,
		#item_flat.labels_list labels_list";


		my $feedItem = GetTemplate('rss/feed.item.xml.template');

		my $fileName = $file->{'file_path'};
		my $itemPubDate = FeedDateFormat($file->{'add_timestamp'});
		my $itemTitle = $file->{'item_title'};
		my $itemLink = $urlProtocol . '://' . $myHost . '/' . GetHtmlFilename($fileHash); # GetRssFile()
		my $itemAbout = $itemLink;
		my $itemGuid = $itemLink;
		my $itemDescription = GetItemDetokenedMessage($fileHash, $file->{'file_path'});

		if ($itemTitle eq '') {
			if ($itemDescription) {
				$itemTitle = $itemDescription;
			} else {
				$itemTitle = '(Untitled)';
			}
		}

		if (!$itemPubDate) {
			$itemPubDate = GetTime();
		}

		$itemTitle = FormatForRss($itemTitle);
		$itemDescription = FormatForRss($itemDescription);

		#todo sanitize

		$feedItem =~ s/\$itemAbout/$itemAbout/g;
		$feedItem =~ s/\$itemGuid/$itemGuid/g;
		$feedItem =~ s/\$itemPubDate/$itemPubDate/g;
		$feedItem =~ s/\$itemTitle/$itemTitle/g;
		$feedItem =~ s/\$itemLink/$itemLink/g;
		$feedItem =~ s/\$itemDescription/$itemDescription/g;

		my $feedTocItem = GetTemplate('rss/feed.toc.item.xml.template');

		$feedTocItem =~ s/\$itemUrl/$itemLink/;

		$feedItems .= $feedItem;
		$feedItemsToc .= $feedTocItem;
	}

	$feedContainerTemplate =~ s/\$feedItemsList/$feedItemsToc/;
	$feedContainerTemplate =~ s/\$feedItems/$feedItems/;

	return $feedContainerTemplate;
} # GetRssFile()

1;
