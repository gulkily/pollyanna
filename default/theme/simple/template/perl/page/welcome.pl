#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	WriteLog('GetWelcomePage: simple theme');

	my $html = GetTemplate('html/page/home.template'); # template for home page

	if (1) {
		my $fileFields = DBGetItemFields();
		my @ref = SqliteQueryHashRef("
			SELECT
				$fileFields
			FROM
				item_flat
			WHERE
				item_type = 'txt'
				AND item_score >= 0
				AND labels_list NOT LIKE '%changelog%'
				AND labels_list NOT LIKE '%notext%'
			ORDER BY
				add_timestamp DESC
			LIMIT 50
		");
		#todo move query teo template

		shift @ref; # remove first element, which contains the list of columns

		my $html2 = ''; # inner html containing the items
		foreach my $ref (@ref) {
			my $replyText = GetFileMessage($ref->{'file_hash'});
			if (!$replyText) {
				next;
				#todo figure out why this happens
			}
			# trim everything after signature placeholder "-- \n"
			$replyText = substr($replyText, 0, index($replyText, "\n-- \n"));
			$replyText = FormatForWeb($replyText);
			my $item = GetTemplate('html/item_flat.template');
			$item = str_replace('<span class=text></span>', '<span class=text>' . $replyText . '</span>', $item);
			$html2 .= $item;
		}
		$html = str_replace('<div id="item_flat_placeholder"></div>', '<div id="item_flat_placeholder">' . $html2 . '</div>', $html);
	}

	#my $imageTemplate = GetImageContainer2('768bc106e30ef173498776242b353540fa2b9083', 'ilya', '/image.html', 512);
	#$html = str_replace('<img id=ilya>', $imageTemplate, $html);

	#my $css = GetTemplate('css/chatgpt.css');
	#my $css = GetTemplate('css/claude.css');
	my $css = GetTemplate('css/bard.css');
	$html = str_replace('$styleSheet', $css, $html);

	my $intro = GetTemplate('txt/intro.txt');
	#$intro = FormatForWeb($intro);
	$html = str_replace('<span id=intro></span>', '<span class=text>' . $intro . '</span>', $html);

	$html = InjectJs($html, qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write));

	return $html;
}

1;
