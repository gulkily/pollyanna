#!/usr/bin/perl -T

use strict;
use warnings;
use utf8;
use 5.010;

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
# sub GetPageButtons {
# sub GetPaginationButtons {

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

1;