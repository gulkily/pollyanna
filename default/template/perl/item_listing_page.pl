#!/usr/bin/perl -T

use strict;
use warnings;
use utf8;
use 5.010;

use POSIX;

#require('./utils.pl');
require_once('dialog.pl');

my @argsFound;
while (my $argFound = shift) {
	push @argsFound, $argFound;
}

require_once('pagination_links.pl');

sub GetItemListingPage { # $pageQuery, $pageMode (dialog_list, full_items, dialog_list), $pageNumber ;
# sub GetListingPage {
# sub MakeListingPage {
# sub GetAuthorsPage {
# sub GetViewPage {
# sub GetItemListing {
	my $pageQuery = shift;
	my $pageMode = shift; # example: dialog_list, 'full_items', 'image_gallery'
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

	WriteLog('GetItemListingPage($pageQuery = ' . $pageQuery . '; $pageMode = ' . $pageMode . '; $pageNumber = ' . $pageNumber . '); caller = ' . join(',', caller));

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

	if (GetConfig('setting/html/page_intro') && $pageQuery =~ m/[^\s]+/) {
		# $pageQuery does not have any spaces, so it's a page name
		# page_info/
		my $pageDescription = GetStringNoFallback('page_intro/' . $pageQuery);
		if ($pageDescription) {
			$pageDescription = str_replace("\n", "<br>\n", $pageDescription);
			my %dialogParam;
			$dialogParam{'id'} = 'page_intro';
			$html .= GetDialogX3($pageDescription, $pageQuery, \%dialogParam);
		}
	}

	my $paginationLinks = GetPaginationLinks($pageQuery, $pageNumber, $totalItemCount, $perPage);

	if ($needPagination) {
		$html .= GetDialogX($paginationLinks, 'Pages');
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
		$html .= GetDialogX('Sorry, there was a problem generating an item listing.');
		WriteLog('GetItemListingPage: warning: $itemListing is FALSE');
	}

	if ($needPagination) {
		$html .= '<br>';
		$html .= GetDialogX($paginationLinks, 'Pages');
	}

	if ($pageQuery eq 'chain') {
		#special case hack for chain page
		if (0) {
			$html .= GetDialogX('<a href="/chain.log">chain.log</a>', 'Log');
		} else {
			$html .= GetDialogX('<a href="/chain.log">chain.log</a><br><iframe height=300 width=700 src="/chain.log"></iframe>', 'Log');
		}
		# $html .= '<span class=advanced>' . GetDialogX('<a href="/chain.log">chain.log</a>', 'Log') . '</span>'; #should be called GetDialog? #todo
	}

	$html .= GetQuerySqlDialog($pageQuery);

	if ($pageQuery eq 'boxes') { #banana theme
		$html .= GetDialogX(GetTemplate('html/dialog/new_box_count.template'), 'Add');
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
	my $pageQuery = shift; # example: 'chain', 'select ...'
	# if it has no spaces, a template lookup is attmpted in e.g. template/query/chain
	my $pageMode = shift; # example: dialog_list, 'full_items', 'image_gallery'
	my $refParams = shift; # reference to %params hash
	# example: $params{'query'} (overrides $pageQuery, but not the page name)
	# example: $params{'query_params'} reference to query's params
	# example: $params{'target_path'} where to write files if not under web root
	#

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

	WriteLog('WriteItemListingPages: $totalItemCount = ' . $totalItemCount);

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
		$pageNoContent .= GetDialogX('This page reserved for future content.');

		my $displayQuery = '<pre>' . HtmlEscape(SqliteGetQueryTemplate($pageQuery)) . '<br></pre>'; #todo templatify
		$pageNoContent .= '<span class=advanced>' . GetDialogX($displayQuery, $queryDisplayName) . '</span>'; #todo should have <pre> like in GetItemListingPage()

		if ($pageQuery eq 'boxes') { #banana theme
			$pageNoContent .= GetDialogX(GetTemplate('html/dialog/new_box_count.template'), 'Add');
		}

		$pageNoContent .= GetPageFooter($pageQuery);
		$pageNoContent = InjectJs($pageNoContent, qw(utils settings avatar voting table_sort profile timestamp));
		my $pageFilename = GetPageFileName($pageQuery, 0);
		PutHtmlFile($pageFilename, $pageNoContent);
	}
} # WriteItemListingPages()

1;
