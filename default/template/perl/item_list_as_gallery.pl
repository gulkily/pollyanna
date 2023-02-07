#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

require_once('dialog.pl');

sub GetItemListAsGallery { # \@items ; returns gallery as series of dialogs without <body>
#
	my $itemsRef = shift;
	my @items = @{$itemsRef};

	if (@items && scalar(@items)) {
		WriteLog('GetItemListAsGallery: scalar(@items) = ' . scalar(@items));
	} else {
		WriteLog('GetItemListAsGallery: warning: @items missing');
		my $html = GetDialogX('An image gallery is coming soon at this address.', 'Gallery');
		return $html;
	}

	my $boolLinkImage = 1;
	my $html = '';

	foreach my $itemRef (@items) {
		my %item = %{$itemRef};
		if (length($item{'item_title'}) > 48) {
			$item{'item_title'} = substr($item{'item_title'}, 0, 43) . '[...]';
		}
		my $itemImage = '';
		if ($item{'item_score'} && $item{'item_score'} > 0) {
			$itemImage = GetImageContainer($item{'file_hash'}, $item{'item_name'}, $boolLinkImage, '');
		} else {
			#todo check if file exists first
			# the 'g' prefix is for greyscale , the greyed out/blurred thumbnail
			# this is displayed in listings until item gets positive score
			$itemImage = GetImageContainer($item{'file_hash'}, $item{'item_name'}, $boolLinkImage, 'g');
		}
		$itemImage = AddAttributeToTag($itemImage, 'img', 'height', '100');
		$itemImage = GetDialogX($itemImage, '');

		$html .= $itemImage;
	}

	return $html;
} # GetItemListAsGallery()


1;
