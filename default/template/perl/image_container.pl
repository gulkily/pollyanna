#!usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetImageContainer { # $fileHash, $imageAlt, $boolLinkToItemPage = 1
	my $fileHash = shift;
	my $imageAlt = shift;
	my $boolLinkToItemPage = shift;

	if (!defined($boolLinkToItemPage)) {
		$boolLinkToItemPage = 1;
	}

	#todo sanity

	#$fileHash = SqliteGetValue("SELECT file_hash FROM item_flat WHERE file_hash LIKE '$fileHash%'");
	#todo this is a hack

	WriteLog('GetImageContainer: $fileHash = ' . $fileHash);

	my $permalinkHtml = '';
	if (!$permalinkHtml) {
		$permalinkHtml = '/' . GetHtmlFilename($fileHash);
	}

	my $imageContainer = '';
	if ($boolLinkToItemPage) {
		$imageContainer = GetTemplate('html/item/container/image_with_link.template');
	} else {
		$imageContainer = GetTemplate('html/item/container/image_with_link.template');
		#$imageContainer = GetTemplate('html/item/container/image.template');
	}

	my $imageUrl = "/thumb/thumb_800_$fileHash.gif"; #todo hardcoding no
	# my $imageUrl = "/thumb/thumb_420_$fileHash.gif"; #todo hardcoding no
	my $imageSmallUrl = "/thumb/thumb_42_$fileHash.gif"; #todo hardcoding no
	#my $imageAlt = $itemTitle;

	if (file_exists($imageUrl) && file_exists($imageSmallUrl)) {
		WriteLog('GetImageContainer: $fileHash = ' . $fileHash . '; $imageAlt = ' . $imageAlt . '; $permalinkHtml = ' . $permalinkHtml);

		$imageContainer =~ s/\$imageUrl/$imageUrl/g;
		$imageContainer =~ s/\$imageSmallUrl/$imageSmallUrl/g;
		$imageContainer =~ s/\$imageAlt/$imageAlt/g;
		if ($boolLinkToItemPage) {
			$imageContainer =~ s/\$permalinkHtml/$permalinkHtml/g;
		}

		WriteLog('GetImageContainer: returning, length($imageContainer) = ' . length($imageContainer));

		return $imageContainer;
	} else {
		WriteLog('GetImageContainer: warning: thumbnails do not exist');
		#todo at some point thumbnails may be lazy-generated, and this will fail
		return '';
	}

	return '';
} # GetImageContainer()

1;
