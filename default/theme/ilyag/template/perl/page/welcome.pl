#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	WriteLog('GetWelcomePage: ilyag theme');

	my $html = GetTemplate('html/page/home.template');

	my $IMAGEDIR = GetDir('image');
	if (file_exists("$IMAGEDIR/gaining_advantage_orig.pdf")) {
		$html = str_replace('<a>Gaining Advantage in Information Society</a>', '<a href="/image/gaining_advantage_orig.pdf">Gaining Advantage in Information Society</a>', $html);
	}
	if (file_exists("$IMAGEDIR/three_peppers.pdf")) {
		$html = str_replace('<a>Three Peppers</a>', '<a href="/image/three_peppers.pdf">Three Peppers</a>', $html);
	}

	if (GetConfig('admin/image/enable')) {
		my $image = SqliteGetValue("SELECT file_hash FROM item_flat WHERE item_type = 'image' AND labels_list LIKE '%,welcome,%' AND item_score > 0 ORDER BY RANDOM() LIMIT 1");
		# select a random image with a score of greater than 0
		if ($image) {
			# add the image to the container
			# 512 is the maximum width of the image
			# ilya is the alt text
			# /image.html is the url it links to
			my $imageTemplate = GetImageContainer2($image, 'ilya', '/image.html', 512);
			if ($imageTemplate) {
				$html = str_replace('<span id=home_image></span>', '<span class=image>' . $imageTemplate . '</span>', $html);
			}
			else {
				$html = str_replace('<span id=home_image></span>', 'x', $html);
			}
		}
		else {
			# remove the image container
			$html = str_replace('<span id=home_image></span>', '', $html);
		}
	} # if GetConfig('admin/image/enable'))
	else {
		# remove the image container
		$html = str_replace('<span id=home_image></span>', '', $html);
	}

	return $html;
}

1;
