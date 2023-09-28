#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetTagPageHeaderLinks { # $labelSelected ; returns html-formatted links to existing labels in system
# used for the header at the top of tag listings pages
# 'tag_wrapper.template', 'tag.template'# sub GetTagsDialog {
# sub GetDialogTags {
# sub GetTags {
# GetDialog(..., 'Tags');

	my $labelSelected = shift;

	if (!$labelSelected) {
		$labelSelected = '';
	} else {
		chomp $labelSelected;
	}

	my $minimumTagCount = 1; # don't display if fewer than this, unless it is selected

	WriteLog("GetTagPageHeaderLinks($labelSelected)");

	my @voteCountsArray = DBGetLabelCounts();

	my $labelItemsWrapper = GetTemplate('html/tag_wrapper.template');

	my $labelItems = '';

	my $labelItemTemplateTemplate = GetTemplate('html/tag.template');

	shift @voteCountsArray;

	while (@voteCountsArray) {
		my $labelItemTemplate = $labelItemTemplateTemplate;

		my $labelHashRef = shift @voteCountsArray;
		my %labelHash = %{$labelHashRef};

		my $labelName = $labelHash{'label'};
		my $labelCount = $labelHash{'label_count'};

		if ($labelCount >= $minimumTagCount || $labelName eq $labelSelected) {
			my $labelItemLink = "/tag/" . $labelName . ".html";

			if ($labelName eq $labelSelected) {
				#todo template this
				$labelItems .= "<b>#$labelName</b>\n";
			}
			else {
				if (lc($labelName) eq $labelName) {
					# skip
					# next;
				}
				else {
					$labelItemTemplate =~ s/\$link/$labelItemLink/g;
					$labelItemTemplate =~ s/\$labelName/$labelName/g;
					$labelItemTemplate =~ s/\$labelCount/$labelCount/g;

					if (0 && GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
						#todo improve this (e.g. don't hard-code the url)
						$labelItemTemplate = AddAttributeToTag(
							$labelItemTemplate,
							'a ',
							'onclick',
							"if ((window.GetPrefs) && GetPrefs('draggable_spawn') && window.FetchDialogFromUrl) { return FetchDialogFromUrl('/dialog" . $labelItemLink . "'); }"
						);
					}

					$labelItems .= $labelItemTemplate;
				}
			}
		}
	}

	if (!$labelItems) {
		# $labelItems = GetTemplate('html/tag_listing_empty.template');
	}

	$labelItemsWrapper =~ s/\$labelLinks/$labelItems/g;

	return $labelItemsWrapper;
} # GetTagPageHeaderLinks()

1;