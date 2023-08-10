#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetTagLink { # $tag ; returns html for a tag link
# sub GetHashTagLink {

# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure

	my $tag = shift;
	my $voteCount = shift;

	if ($tag =~ m/^([0-9a-zA-Z_-]+)$/) { #tagName
		#sanity check
		$tag = $1;

		WriteLog('GetTagLink: $tag = ' . $tag);

		my $tagColor = '';
		if (GetConfig('html/hash_color_hashtags') && !GetConfig('html/mourn') && !GetConfig('html/monochrome')) { # GetTagLink()
			# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
			# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
			# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
			# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure
			# NOTE: THIS IS A VOTING BUTTON, NOT A TAG LINK #todo rename this subprocedure

			$tagColor = GetStringHtmlColor($tag);
		} else {
			$tagColor = GetThemeColor('tag_text'); # #TextColor
		}
		my $voteItemLink = "/tag/" . $tag . ".html";
		my $dialogName = '/tag/' . $tag;

		my $tagCaption = $tag;
		if ($voteCount) {
			$tagCaption .= '(' . $voteCount . ')';
		}
		#
		# #todo template this
		my $tagLinkTemplate = GetTemplate('html/widget/tag_link.template');
		$tagLinkTemplate = trim(str_replace("\n", '', $tagLinkTemplate)); # remove extra whitespace
		#$tagLinkTemplate =~ s/<!--[^<]+-->//g;
		my $tagLink = $tagLinkTemplate; #todo

		$tagLink = str_replace('$voteItemLink', $voteItemLink, $tagLink);
		$tagLink = str_replace('$tagCaption', $tagCaption, $tagLink);
		$tagLink = str_replace('$tagColor', $tagColor, $tagLink);

		# my $tagLink =
		# 	'<a href="' . $voteItemLink . '">' .
		# 	'<font color="' . $tagColor . '">#</font>' .
		# 	$tagCaption .
		# 	'</a>';

		if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
			$tagLink = AddAttributeToTag(
				$tagLink,
				'a ',
				'onclick',
				"if ((window.GetPrefs) && GetPrefs('draggable_spawn') && window.FetchDialog) { return FetchDialog('$dialogName'); }"
			);
		}

		return $tagLink;
	} else {
		WriteLog('GetTagLink: warning: $tag sanity check failed, @tagsList $tag = ' . $tag);
		return '';
	}
} # GetTaglink()

1;
