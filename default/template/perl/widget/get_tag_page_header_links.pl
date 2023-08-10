#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetTagPageHeaderLinks { # $tagSelected ; returns html-formatted links to existing tags in system
# used for the header at the top of tag listings pages
# 'tag_wrapper.template', 'tag.template'
# sub GetTagsDialog {
# sub GetDialogTags {
# sub GetTags {
# GetDialog(..., 'Tags');

	my $tagSelected = shift;

	if (!$tagSelected) {
		$tagSelected = '';
	} else {
		chomp $tagSelected;
	}

	my $minimumTagCount = 1; # don't display if fewer than this, unless it is selected

	WriteLog("GetTagPageHeaderLinks($tagSelected)");

	my @voteCountsArray = DBGetVoteCounts();

	my $voteItemsWrapper = GetTemplate('html/tag_wrapper.template');

	my $voteItems = '';

	my $voteItemTemplateTemplate = GetTemplate('html/tag.template');

	shift @voteCountsArray;

	while (@voteCountsArray) {
		my $voteItemTemplate = $voteItemTemplateTemplate;

		my $tagHashRef = shift @voteCountsArray;
		my %tagHash = %{$tagHashRef};

		my $tagName = $tagHash{'vote_value'};
		my $tagCount = $tagHash{'vote_count'};

		if ($tagCount >= $minimumTagCount || $tagName eq $tagSelected) {
			my $voteItemLink = "/tag/" . $tagName . ".html";

			if ($tagName eq $tagSelected) {
				#todo template this
				$voteItems .= "<b>#$tagName</b>\n";
			}
			else {
				if (lc($tagName) eq $tagName) {
					# skip
					# next;
				}
				else {
					$voteItemTemplate =~ s/\$link/$voteItemLink/g;
					$voteItemTemplate =~ s/\$tagName/$tagName/g;
					$voteItemTemplate =~ s/\$tagCount/$tagCount/g;

					if (0 && GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
						#todo improve this (e.g. don't hard-code the url)
						$voteItemTemplate = AddAttributeToTag(
							$voteItemTemplate,
							'a ',
							'onclick',
							"if ((window.GetPrefs) && GetPrefs('draggable_spawn') && window.FetchDialogFromUrl) { return FetchDialogFromUrl('/dialog" . $voteItemLink . "'); }"
						);
					}

					$voteItems .= $voteItemTemplate;
				}
			}
		}
	}

	if (!$voteItems) {
		# $voteItems = GetTemplate('html/tag_listing_empty.template');
	}

	$voteItemsWrapper =~ s/\$tagLinks/$voteItems/g;

	return $voteItemsWrapper;
} # GetTagPageHeaderLinks()

1;