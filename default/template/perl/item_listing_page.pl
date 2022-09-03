#!/usr/bin/perl -T

use strict;
use warnings;
use utf8;
use 5.010;
use POSIX;

require './utils.pl';

my @argsFound;
while (my $argFound = shift) {
	push @argsFound, $argFound;
}

sub GetPageFileName {
	my $pageQuery = shift;
	my $pageNumber = shift;

	my $targetPathPrefix = $pageQuery;

	if ($pageNumber == 0) {
		return $pageQuery . '.html';
	} else {
		return $pageQuery . ($pageNumber + 1) . '.html';
	}
} # GetPageFileName()

sub GetPaginationLink { # returns one pagination link as html, used by GetPageLinks
	my $pageQuery = shift;
	my $pageNumber = shift;
#    my $itemCount = shift;
#    my $perPage = shift;
#
#	if (!$perPage) {
#		WriteLog('GetPaginationLink: warning: $perPage was FALSE, setting to sane 25');
#		$perPage = 25;
#	}
#
#	my $pageStart = $pageNumber * $perPage;
#	my $pageEnd = $pageNumber * $perPage + $perPage;
#	if ($pageEnd > $itemCount) {
#		$pageEnd = $itemCount - 1;
#	}
#	my $pageCaption = $pageStart . '-' . $pageEnd;
#
	state $pageLinkTemplate;
	if (!defined($pageLinkTemplate)) {
		$pageLinkTemplate = GetTemplate('html/widget/pagination_link.template');
	}

	my $pageLink = $pageLinkTemplate;
	my $pageUrl = GetPageFileName($pageQuery, $pageNumber);
	my $pageCaption = ($pageNumber + 1);

	$pageLink = str_replace('<a href="#">', '<a href="' . $pageUrl . '">', $pageLink);
	$pageLink = str_replace('<big></big>', '<big>' . $pageCaption . '</big>', $pageLink);

	return $pageLink;
} # GetPaginationLink()

sub GetPaginationLinks { # $pageQuery, $currentPageNumber, $itemCount, $perPage
	my $pageQuery = shift;
	my $currentPageNumber = shift; #
	my $itemCount = shift;
	my $perPage = shift;

	if (int($currentPageNumber) != $currentPageNumber) {
		WriteLog('GetPaginationLinks: warning: sanity check failed, $currentPageNumber = ' . $currentPageNumber);
		return '';
	}
	if (int($itemCount) != $itemCount) {
		WriteLog('GetPaginationLinks: warning: sanity check failed, $itemCount = ' . $itemCount);
		return '';
	}
	if (int($perPage) != $perPage) {
		WriteLog('GetPaginationLinks: warning: sanity check failed, $perPage = ' . $perPage);
		return '';
	}
	if (!$pageQuery) {
		WriteLog('GetPaginationLinks: warning: sanity check failed, $pageQuery is FALSE');
		return '';
	}

	my $pageLinks = '';
	my $lastPageNum = ceil($itemCount / $perPage);

	if ($itemCount > $perPage) {
		#for (my $i = $lastPageNum - 1; $i >= 0; $i--) {
		for (my $i = 0; $i < $lastPageNum; $i++) {
			if ($i == $currentPageNumber) {
				my $pageLink = GetTemplate('html/widget/pagination_link_current.template');
				$pageLink = str_replace('<big></big>', '<big>' . ($i + 1) . '</big>', $pageLink);
				#my $pageLink = '<big>' . ($i + 1) . '</big>';
				$pageLinks .= $pageLink;
			} else {
				my $pageLink = GetPaginationLink($pageQuery, $i);
				$pageLinks .= $pageLink;
			}
		}
	}

	return $pageLinks;
} # GetPaginationLinks()



sub GetItemListingPage { # $pageQuery, $pageMode (dialog_list, full_items, dialog_list), $pageNumber ;
# sub GetListingPage {
# sub MakeListingPage {
	my $pageQuery = shift;
	my $pageMode = shift;
	my $pageNumber = shift;
	my $refParams = shift;

	my $pageTitle = ucfirst($pageQuery);

	my %params;
	if ($refParams) {
		%params = %{$refParams};
	}

	chomp $pageQuery;
	chomp $pageMode;
	chomp $pageNumber;

	WriteLog('GetItemListingPage: $pageQuery = ' . $pageQuery . '; $pageMode = ' . $pageMode . '; $pageNumber = ' . $pageNumber);

	my $queryDisplayName = $pageQuery . '.sql';

	my $perPage = GetConfig('html/page_limit');
	my %queryParams;

	#my $queryItemList = DBGetItemListQuery(\%queryParams);
	my $queryItemList = SqliteGetNormalizedQueryString($pageQuery);
	my $queryItemCount = "SELECT COUNT(*) AS item_count FROM ($queryItemList)";
	my $totalItemCount = SqliteGetValue($queryItemCount);

	my $needPagination = 0;
	if ($totalItemCount > $perPage) {
		#todo add sanity checks here
		$needPagination = 1;
	}

	my $queryWithLimit = $queryItemList;
	if ($pageNumber) {
		my $offset = $perPage * $pageNumber;
		#$queryParams{'limit_clause'} = "LIMIT $perPage OFFSET $offset";
		$queryWithLimit .= " LIMIT $perPage OFFSET $offset";
	} else {
		#$queryParams{'limit_clause'} = "LIMIT $perPage";
		$queryWithLimit .= " LIMIT $perPage";
	}
	#$queryParams{'include_headers'} = 1;

	#my @items = DBGetItemList(\%queryParams);
	my @items = SqliteQueryHashRef($queryWithLimit);
	my $html = '';

	WriteLog('GetItemListingPage: $pageQuery = ' . $pageQuery . '; $pageMode = ' . $pageMode . '; $pageNumber = ' . $pageNumber . '; scalar(@items) = ' . scalar(@items));

	$html .= GetPageHeader($pageQuery);

	my $paginationLinks = GetPaginationLinks($pageQuery, $pageNumber, $totalItemCount, $perPage);

	if ($needPagination) {
		$html .= GetWindowTemplate($paginationLinks, 'Pages');
	}

	#$html .= $totalItemCount;

	my $itemListing = '';

	if ($pageMode eq 'dialog_list') {
		my $dialogColumns = '';
		if ($params{'dialog_columns'}) {
			$dialogColumns = $params{'dialog_columns'};
		}
		$itemListing .= GetResultSetAsDialog(\@items, $pageTitle, $dialogColumns);
	}
	elsif ($pageMode eq 'full_items') {
		shift @items; # remove first array element (headers)
		$itemListing .= GetItemListHtml(\@items);
	}
	elsif ($pageMode eq 'image_gallery') {
		shift @items; # remove first array element (headers)
		$itemListing .= GetItemListAsGallery(\@items);
	}

	if ($itemListing) {
		$html .= $itemListing;
	} else {
		$html .= GetWindowTemplate('Sorry, there was a problem generating an item listing.');
		WriteLog('GetItemListingPage: warning: $itemListing is FALSE');
	}

	if ($needPagination) {
		$html .= GetWindowTemplate($paginationLinks, 'Pages');
	}
	#my $displayQuery = TextartForWeb(SqliteGetQueryTemplate($pageQuery));
	my $displayQuery = '<pre>'.HtmlEscape(SqliteGetQueryTemplate($pageQuery)).'<br></pre>'; #todo templatify

	$html .= '<span class=advanced>' . GetWindowTemplate($displayQuery, $queryDisplayName) . '</span>';

	if ($pageQuery eq 'chain') {
		#special case hack for chain page
		$html .= '<span class=advanced>' . GetWindowTemplate('<a href="/chain.log">chain.log</a>', 'PSV') . '</span>'; #should be called GetDialog? #todo
	}

	if ($pageQuery eq 'boxes') { #banana theme
		$html .= GetWindowTemplate(GetTemplate('html/dialog/new_box_count.template'), 'Add');
	}

	$html .= GetPageFooter($pageQuery);
	my @js = qw(utils settings avatar voting table_sort profile timestamp);
	if (GetConfig('setting/html/reply_cart')) {
		push @js, 'reply_cart';
	}
	$html = InjectJs($html, @js);

	return $html;
} # GetItemListingPage()

sub MakeFeed { # writes a bare-bones txt file with items list
	my $feed = 'new'; # 'new.txt' "new.txt"

	# outputs plaintext list version of query if it has certain tags
	#hack #todo
	#if ($pageQuery =~ m/file_hash/ && $pageQuery =~ m/item_title/ && $pageQuery =~ m/add_timestamp/) {
	#my $plaintextList = SqliteQuery("SELECT file_hash, item_title, add_timestamp FROM ($pageQuery) LIMIT 25");
	my $plaintextList = SqliteQuery("SELECT file_hash, CAST (add_timestamp AS INT) AS add_timestamp FROM item_flat ORDER BY add_timestamp DESC LIMIT 20");
	$plaintextList =~ s/^[^\n]+\n//s;

	#if ($plaintextList) {
	PutFile(GetDir('html').'/'.$feed.'.txt', $plaintextList);
	#PutFile(GetDir('html').'/'.$pageQuery.'.txt', $plaintextList);
	#}
	#}
}

sub WriteItemListingPages { # $pageQuery, $pageMode, \%params
	my $pageQuery = shift;
	my $pageMode = shift;
	my $refParams = shift;

	if ($pageQuery eq 'new') {
		MakeFeed('new');
	}

	my %params;
	if ($refParams) {
		%params = %{$refParams};
	}

	WriteLog('WriteItemListingPages: $pageQuery = ' . $pageQuery . '; caller = ' . join(',', caller));

	chomp $pageQuery;
	chomp $pageMode;

	if (!$pageMode) {
		$pageMode = 'dialog_list';
	}

	my $perPage = GetConfig('html/page_limit');
	my %queryParams;

	#my $queryItemList = DBGetItemListQuery(\%queryParams);
	my $queryItemList = '';
	if ($params{'query'}) {
		$queryItemList = SqliteGetNormalizedQueryString($params{'query'}, %{$params{'query_params'}});
		#todo unhack this hack
	} else {
		$queryItemList = SqliteGetNormalizedQueryString($pageQuery);
	}

	WriteLog('WriteItemListingPages: $queryItemList = ' . $queryItemList);

	my $queryItemCount = "SELECT COUNT(*) AS item_count FROM ($queryItemList) LIMIT 1";
	my $totalItemCount = SqliteGetValue($queryItemCount);

	if ($totalItemCount) {
		# there is more than one item
		my $pageCount = ceil($totalItemCount / $perPage);

		for (my $page = 0; $page < $pageCount; $page++) {
			my $pageFilename = '';
			if ($params{'target_path'}) {
				$pageFilename = $params{'target_path'} . $page . '.html';
				#todo unhack this hack
			} else {
				$pageFilename = GetPageFileName($pageQuery, $page);
			}
			my $pageContent = GetItemListingPage($pageQuery, $pageMode, $page, \%params);
			PutHtmlFile($pageFilename, $pageContent);
		}
	} else {
		# no items returned by database
		my $pageNoContent = '';
		my $queryDisplayName = $pageQuery . '.sql';
		$pageNoContent .= GetPageHeader($pageQuery);
		$pageNoContent .= GetWindowTemplate('This page reserved for future content.');

		my $displayQuery = '<pre>'.HtmlEscape(SqliteGetQueryTemplate($pageQuery)).'<br></pre>'; #todo templatify
		$pageNoContent .= '<span class=advanced>' . GetWindowTemplate($displayQuery, $queryDisplayName) . '</span>'; #todo should have <pre> like in GetItemListingPage()

		if ($pageQuery eq 'boxes') { #banana theme
			$pageNoContent .= GetWindowTemplate(GetTemplate('html/dialog/new_box_count.template'), 'Add');
		}

		$pageNoContent .= GetPageFooter($pageQuery);
		$pageNoContent = InjectJs($pageNoContent, qw(utils settings avatar voting table_sort profile timestamp));
		my $pageFilename = GetPageFileName($pageQuery, 0);
		PutHtmlFile($pageFilename, $pageNoContent);
	}
} # WriteItemListingPages()

1;
