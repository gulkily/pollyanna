#!/usr/bin/perl -T
#

use strict;
use warnings;

sub GetTagLink { # $tag ; returns html for a tag link
# sub GetHashTagLink {

	my $tag = shift;
	my $voteCount = shift;

	if ($tag =~ m/^([0-9a-zA-Z_-]+)$/) { #tagName
		#sanity check
		$tag = $1;

		WriteLog('GetTagLink: $tag = ' . $tag);

		my $tagColor = '';
		if (GetConfig('html/hash_color_hashtags') && !GetConfig('html/mourn')) { # GetTagLink()
			$tagColor = GetStringHtmlColor($tag);
		} else {
			$tagColor = GetThemeColor('tag_text');
		}
		my $voteItemLink = "/top/" . $tag . ".html";
		my $dialogName = '/top/' . $tag;

		my $tagCaption = $tag;
		if ($voteCount) {
			$tagCaption .= '(' . $voteCount . ')';
		}

		#todo template this
		my $tagLink =
			'<a href="' . $voteItemLink . '">' .
			'<font color="' . $tagColor . '">#</font>' .
			$tagCaption .
			'</a>';

		$tagLink = AddAttributeToTag(
			$tagLink,
			'a ',
			'onclick',
<<<<<<< HEAD
			"if (window.GetPrefs && GetPrefs('draggable_spawn') && window.FetchDialog) { return FetchDialog('$dialogName'); }"
=======
			"if (window.GetPrefs && GetPrefs('draggable_spawn') && window.FetchDialog) { return FetchDialog('top/" . $dialogName . "'); }"
>>>>>>> 08ff823f66c14ff4f17157ba383793fa65f7f278
		);
	} else {
		WriteLog('GetItemTemplate: warning: $tag sanity check failed, @tagsList $tag = ' . $tag);
		return '';
	}
} # GetTaglink()


1;
