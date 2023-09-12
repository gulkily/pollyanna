#!usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetImageContainer { # $fileHash, $imageAlt, $boolLinkToItemPage = 1
#sub GetThumbnail {
#sub GetImageThumbnail {
#sub GetImageTemplate {
#sub GetImage {

#todo, needs to take an optional %file hash and read from it instead of the database
	my $fileHash = shift;
	my $imageAlt = shift;
	my $boolLinkToItemPage = shift;

	if (!defined($boolLinkToItemPage)) {
		$boolLinkToItemPage = 1;
	}

	#todo sanity

	#$fileHash = SqliteGetValue("SELECT file_hash FROM item_flat WHERE file_hash LIKE '$fileHash%'");
	#todo this is a hack

	WriteLog('GetImageContainer: $fileHash = ' . $fileHash . '; $imageAlt = ' . $imageAlt . '; $boolLinkToItemPage = ' . ($boolLinkToItemPage ? 'TRUE' : 'FALSE') . '; caller = ' . join(',', caller));

	my $permalinkHtml = '';
	if (!$permalinkHtml) {
		$permalinkHtml = '/' . GetHtmlFilename($fileHash); # GetImageContainer()
	}

	my $imageContainer = '';
	if ($boolLinkToItemPage) {
		$imageContainer = GetTemplate('html/item/container/image_with_link.template');
	} else {
		$imageContainer = GetTemplate('html/item/container/image_without_link.template');
		#$imageContainer = GetTemplate('html/item/container/image.template');
		#todo fix this
	}

	my $imageUrl = "/thumb/thumb_800_$fileHash.gif"; #todo hardcoding no
	# my $imageUrl = "/thumb/thumb_420_$fileHash.gif"; #todo hardcoding no
	my $imageSmallUrl = "/thumb/thumb_42_$fileHash.gif"; #todo hardcoding no
	#my $imageAlt = $itemTitle;

	if (!$imageAlt) {
		$imageAlt = 'image';
		WriteLog('GetImageContainer: warning: $imageAlt missing; caller = ' . join(',', caller));
	}

	#if (file_exists($imageUrl) || file_exists($imageSmallUrl)) { #this doesn't work because paths are wrong
	if (1) { #todo, see above comment
		WriteLog('GetImageContainer: $fileHash = ' . $fileHash . '; $imageAlt = ' . $imageAlt . '; $permalinkHtml = ' . $permalinkHtml);

		$imageContainer =~ s/\$imageUrl/$imageUrl/g;
		$imageContainer =~ s/\$imageSmallUrl/$imageSmallUrl/g;
		$imageContainer =~ s/\$imageAlt/$imageAlt/g;
		if ($boolLinkToItemPage) {
			$imageContainer =~ s/\$permalinkHtml/$permalinkHtml/g;
		} else {
			# nothing to do, there is no link
		}

		WriteLog('GetImageContainer: returning, length($imageContainer) = ' . length($imageContainer));

		return $imageContainer;
	} else {
		WriteLog('GetImageContainer: warning: thumbnails do not exist');
		#todo at some point thumbnails may need to be lazy-generated, and this will fail
		return '';
	}

	return '';
} # GetImageContainer()

1;
