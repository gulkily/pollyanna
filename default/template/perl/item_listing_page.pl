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

sub GetItemListingPage { # $pageQuery, $pageMode (dialog_list, full_items, image_gallery), $pageNumber, $refParams ;
# sub GetListingPage {
# sub MakeListingPage {
# sub GetAuthorsPage {
# sub GetViewPage {
# sub GetItemListing {
# sub GetItemHtmlListing {
# sub MakeAuthorsPage {
# sub GetImagePage {
# sub ImagePage {
# sub GetTagsPage { ItemListingPage()
# sub GetLabelsPage {
# sub GetListing {
# sub GetListByTag {
# sub GetItemTagListing {

	my $pageQuery = shift;
	my $pageMode = shift; # example: dialog_list, 'full_items', 'image_gallery'
	my $pageNumber = shift;
	my $refParams = shift;

	my $pageTitle = ucfirst($pageQuery);

	my %params;
	if ($refParams) {
		%params = %{$refParams};
	}

	if (!$pageNumber && $pageNumber != 0) {
		WriteLog('GetItemListingPage: warning: $pageNumber was FALSE; caller = ' . join(',', caller));
		return '';
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

	WriteLog('GetItemListingPage: override test: setting/theme = ' . GetConfig('setting/theme'));
	WriteLog('GetItemListingPage: override test: GetActiveThemes() = ' . join(',', GetActiveThemes()));
	WriteLog('GetItemListingPage: override test: GetTemplate(memo_count) = ' . GetTemplate('memo_count'));


	require_once('get_page_header.pl');
	$html .= GetPageHeader($pageQuery);

	if (GetConfig('setting/html/page_intro') && $pageQuery =~ m/[^\s]+/) {
		# $pageQuery does not have any spaces, so it's a page name, like 'top' or 'read' or 'tags' or 'labels'
		# page_info/
		# sub GetPageIntro {
		my $pageDescription = GetStringNoFallback('page_intro/' . $pageQuery);
		if ($pageDescription) {
			$pageDescription = str_replace("\n", "<br>\n", $pageDescription);
			my $dialogContents = '<fieldset>' . $pageDescription . '</fieldset>';
			my %dialogParam;
			$dialogParam{'id'} = 'page_intro';
			#$html .= '<span class=beginner>' . GetDialogX3($dialogContents, 'Introduction', \%dialogParam) . '</span>'; #PageIntro
		} # if ($pageDescription)
	} # if (GetConfig('setting/html/page_intro') && $pageQuery =~ m/[^\s]+/)

	my $paginationLinks = GetPaginationLinks($pageQuery, $pageNumber, $totalItemCount, $perPage);

	#top of page
	#if ($needPagination) {
	#	$html .= GetDialogX($paginationLinks, 'Pages');
	#}

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

	#bottom of page
	if ($needPagination) {
		$html .= '<br>';
		$html .= GetDialogX($paginationLinks, 'Pages');
	}

	if ($pageQuery eq 'chain') {
		# sub GetChainPage {
		#special case hack for chain page
		if (1) {
			# simple link
			$html .= GetDialogX('<a href="/chain.log">chain.log</a><br><a href="/chain_log_verify.txt">chain_log_verify.py</a>', 'Log');
		} else {
			# iframe display, has problems
			$html .= GetDialogX('<a href="/chain.log">chain.log</a><br><iframe height=300 width=700 src="/chain.log"></iframe>', 'Log');
		}
		# $html .= '<span class=advanced>' . GetDialogX('<a href="/chain.log">chain.log</a>', 'Log') . '</span>'; #should be called GetDialog? #todo
	}

	if (GetConfig('setting/html/reply_cart')) {
		require_once('dialog/reply_cart.pl');
		$html .= GetReplyCartDialog();
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

	if (!$html) {
		WriteLog('GetItemListingPage: warning: $html is FALSE before InjectJs(); caller = ' . join(',', caller));
	}

	$html = InjectJs($html, @js);

	if (!$html) {
		WriteLog('GetItemListingPage: warning: $html is FALSE after InjectJs(); caller = ' . join(',', caller));
	}

	if (GetConfig('setting/html/debug')) {
		$html = $html . "\n" . "<!-- GetItemListingPage($pageQuery, $pageMode, $pageNumber, $refParams) -->" . "\n";
	}

	return $html;
} # GetItemListingPage()

require_once('makefeed.pl');

sub WriteItemListingPages { # $pageQuery, $pageMode, \%params
# sub MakeListingPages {
	my $pageQuery = shift; # example: 'chain', 'select ...'
	# if it has no spaces, a template lookup is attmpted in e.g. template/query/chain
	my $pageMode = shift; # example: 'dialog_list', 'full_items', 'image_gallery',
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

	WriteLog('WriteItemListingPages: override test: setting/theme = ' . GetConfig('setting/theme'));
	WriteLog('WriteItemListingPages: override test: GetActiveThemes() = ' . join(',', GetActiveThemes()));
	WriteLog('WriteItemListingPages: override test: GetTemplate(memo_count) = ' . GetTemplate('memo_count'));


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

		for (my $pageNumber = 0; $pageNumber < $pageCount; $pageNumber++) {
			my $pageFilename = '';
			if ($params{'target_path'}) {
				$pageFilename = $params{'target_path'} . $pageNumber . '.html';
				#todo unhack this hack
			} else {
				$pageFilename = GetPageFileName($pageQuery, $pageNumber);
			}
			my $pageContent = GetItemListingPage($pageQuery, $pageMode, $pageNumber, \%params);

			if ($pageContent) {
				WriteLog('WriteItemListingPages: override test: setting/theme = ' . GetConfig('setting/theme'));
				WriteLog('WriteItemListingPages: override test: GetActiveThemes() = ' . join(',', GetActiveThemes()));
				WriteLog('WriteItemListingPages: override test: GetTemplate(memo_count) = ' . GetTemplate('memo_count'));

				PutHtmlFile($pageFilename, $pageContent);
			} else {
				WriteLog('WriteItemListingPages: warning: $pageContent was FALSE; caller = ' . join(',', caller));
				PutHtmlFile($pageFilename, '<html><body>There was a problem creating this listing. <a href=/>Home</a></body></html>');
			}
		}

		if (GetConfig('html/write_listing_txt')) {
			MakeFeed($pageQuery);
		}
	} else {
		# no items returned by database
		my $pageNoContent = '';
		require_once('get_page_header.pl');
		$pageNoContent .= GetPageHeader($pageQuery);
		$pageNoContent .= GetDialogX('<fieldset><p>This page reserved for future content (2)</p></fieldset>', 'No Results');

		$pageNoContent .= GetQuerySqlDialog($pageQuery);

		if ($pageQuery eq 'boxes') { #banana theme
			$pageNoContent .= GetDialogX(GetTemplate('html/dialog/new_box_count.template'), 'Add');
		}

		$pageNoContent .= GetPageFooter($pageQuery);
		$pageNoContent = InjectJs($pageNoContent, qw(utils settings avatar voting table_sort profile timestamp));
		my $pageFilename = GetPageFileName($pageQuery, 0);

		WriteLog('WriteItemListingPages: no items returned, putting empty file: $pageFilename = ' . $pageFilename . '; caller = ' . join(',', caller));

		PutHtmlFile($pageFilename, $pageNoContent);
	}
} # WriteItemListingPages()

1;
