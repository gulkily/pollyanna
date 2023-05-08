#!usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetItemHtmlLink { # $hash, [link caption], [#anchor] ; returns <a href=...
# sub GetItemLink {
# sub GetLink {
	my $hash = shift;

	if ($hash = IsItem($hash)) {
		#ok
	} else {
		WriteLog('GetItemHtmlLink: warning: sanity check failed on $hash');
		return '';
	}

	if ($hash) {
		#todo templatize this
		my $linkCaption = shift;
		if (!$linkCaption) {
			$linkCaption = substr($hash, 0, 8) . '..';
		}

		my $shortHash = substr($hash, 0, 8);

		my $hashAnchor = shift;
		if ($hashAnchor) {
			if (substr($hashAnchor, 0, 1) ne '#') {
				$hashAnchor = '#' . $hashAnchor;
			}
		} else {
			$hashAnchor = '';
		}

		my $flagsReference = shift;
		my %flags;
		if ($flagsReference) {
			%flags = %{$flagsReference};
		}

		if ($flags{'do_not_escape_html_characters'}) {
			# do not escape
		} else {
			$linkCaption = HtmlEscape($linkCaption);
		}

		#my $htmlFilename = GetHtmlFilename($hash); # GetItemHtmlLink()
		my $htmlFilename = GetItemUrl($hash); # GetItemHtmlLink()

		my $linkPath = $htmlFilename;
		if (GetConfig('admin/php/enable') && GetConfig('admin/php/url_alias_friendly')) {
			$linkPath = substr($hash, 0, 8);
		}

		my $itemLink = '';

		if (
			GetConfig('html/overline_links_with_missing_html_files') && # #todo this could potentially be a css class?
 			! -e GetDir('html') . '/' . $htmlFilename
		) {
			# html file does't exist, annotate link to indicate this
			# the html file may be generated as needed
			$itemLink = '<a href="/' . $linkPath . $hashAnchor . '" style="text-decoration: overline">' . $linkCaption . '</a>';
		} else {
			# html file exists, nice
			$itemLink = '<a href="/' . $linkPath . $hashAnchor . '">' . $linkCaption . '</a>';
		}

		if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
			#$itemLink = AddAttributeToTag($itemLink, 'a ', 'onclick', '');
			$itemLink = AddAttributeToTag(
				$itemLink,
				'a ',
				'onclick',
				"
					if (
						(!window.GetPrefs || GetPrefs('draggable_spawn')) &&
						(window.FetchDialogFromUrl) &&
						document.getElementById
					) {
						if (document.getElementById('$shortHash')) {
							SetActiveDialog(document.getElementById('$shortHash'));
							return false;
						} else {
							return FetchDialogFromUrl('/dialog/$htmlFilename');
						}
					}
				"
			);
		}

		return $itemLink;
	} else {
		WriteLog('GetItemHtmlLink: warning: no $hash after first sanity check!');
		return '';
	}
} # GetItemHtmlLink()

1;
