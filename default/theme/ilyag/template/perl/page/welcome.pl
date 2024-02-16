#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	WriteLog('GetWelcomePage: ilyag theme');
## this welcome page displays all items which have a tag of 'approve' and a score of greater than 0
#	my %params;
#	$params{'where_clause'} = "WHERE labels_list LIKE '%approve%' AND item_score > 0";
#	my @files = DBGetItemList(\%params);
#
#	my $welcomePage =
#		GetPageHeader('welcome') .
#		GetItemListHtml(\@files) .
#		GetPageFooter('welcome')
#	;
#
#	if (GetConfig('admin/js/enable')) {
#		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
#		if (GetConfig('admin/php/enable')) {
#			push @js, 'write_php'; # write.html
#		}
#		$welcomePage = InjectJs($welcomePage, @js)
#	}
#	return $welcomePage

	my $html = GetTemplate('html/page/home.template');

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
