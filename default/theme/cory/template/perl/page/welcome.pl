#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	WriteLog('GetWelcomePage: cory theme');

	my $HTMLDIR = GetDir('html');

	{
		# these are included in the page, so we need to put them in the html directory
		# technically, GetWelcomePage() should not be responsible for this, but it's a simple way to do it
		my $css = GetTemplate('css/styles.css');
		PutFile("$HTMLDIR/styles.css", $css);

		my $js = GetTemplate('js/scripts.js');
		PutFile("$HTMLDIR/scripts.js", $js);
	}

	my $html = GetTemplate('html/page/home.template'); # template for home page

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE labels_list LIKE '%ideas%'";
	$queryParams{'order_clause'} = 'ORDER BY add_timestamp DESC';

	my @items = DBGetItemList(\%queryParams);

	my $itemsHtml = '';
	for my $item (@items) {
		# <div class="idea-card">
		# 	<div class="idea-content"></div>
		# 	<div class="idea-time"></div>
		# </div>

		my $itemHtml = GetTemplate('html/item_flat.template');
		my $itemText = GetFileMessage($item->{'file_hash'});
		$itemText = str_replace("\n-- ", '', $itemText); # remove signature
		$itemText = FormatForWeb($itemText);
		$itemHtml = str_replace('<div class="idea-content"></div>', '<div class="idea-content">' . $itemText . '</div>', $itemHtml);

		my $itemTimestampWidget = GetTimestampWidget($item->{'add_timestamp'});

		my %linkFlags;
		$linkFlags{'do_not_escape_html_characters'} = 1;
		my $itemLink = GetItemHtmlLink($item->{'file_hash'}, $itemTimestampWidget, '', \%linkFlags);

		$itemHtml = str_replace('<div class="idea-time"></div>', '<div class="idea-time">' . $itemLink . '</div>', $itemHtml);
		$itemsHtml .= $itemHtml;
	}

	$html = str_replace('<div id="ideasList"></div>', $itemsHtml, $html);

	return $html;




	my $siteName = GetConfig('setting/site_name');
	$html = str_replace('<title>Welcome</title>', '<title>' . $siteName . '</title>', $html);

	if (1) {
		my $fileFields = DBGetItemFields();
		my @ref = SqliteQueryHashRef('welcome');

		shift @ref; # remove first element, which contains the list of columns

		my $html2 = ''; # inner html containing the items
		foreach my $ref (@ref) {
			if ($ref->{'item_type'} eq 'txt') {
				my $replyText = GetFileMessage($ref->{'file_hash'});
				if (!$replyText) {
					next;
					#todo figure out why this happens
				}

				# trim everything after signature placeholder "-- \n"
				$replyText = substr($replyText, 0, index($replyText, "\n-- \n"));

				# remove item references like >>[sha1] and replace them with empty string
				$replyText =~ s/>>[0-9a-f]{40}//g;

				# remove extra line breaks
				$replyText =~ s/^\n+//g;
				$replyText =~ s/\n+$//g;
				$replyText =~ s/\n\n/\n/g;

				# FormatForWeb() adds <br> tags and escapes html entities
				$replyText = FormatForWeb($replyText);

				# convert urls to links
				#$replyText =~ s{ (https?://[a-zA-Z&./\-=0-9\?#;]+) }{<a href="$1">$1</a>}gx;

				my $item = GetTemplate('html/item_flat.template');
				$item = str_replace('<span class=text></span>', '<span class=text>' . $replyText . '</span>', $item);
				my $itemUrl = GetItemUrl($ref->{'file_hash'});
				$item = AddAttributeToTag($item, 'a', 'href', $itemUrl);
				$html2 .= $item;
			}
			if ($ref->{'item_type'} eq 'image') {
				#my $imageTemplate = GetImageContainer2($ref->{'file_hash'}, $ref->{'file_name'}, '/image.html', 512);
				#$html2 .= $imageTemplate;
				my $imageTemplate = GetImageContainer2($ref->{'file_hash'}, $ref->{'file_name'}, 'item', 512);
				my $item = GetTemplate('html/item_flat.template');
				$item = str_replace('<span class=text></span>', '<span class=text>' . $imageTemplate . '</span>', $item);
				$html2 .= $item;
			}
		}
		$html = str_replace('<div id="item_flat_placeholder"></div>', '<div id="item_flat_placeholder">' . $html2 . '</div>', $html);
	}

	#my $imageTemplate = GetImageContainer2('768bc106e30ef173498776242b353540fa2b9083', 'ilya', '/image.html', 512);
	#$html = str_replace('<img id=ilya>', $imageTemplate, $html);

	#my $css = GetTemplate('css/chatgpt.css');
	#my $css = GetTemplate('css/claude.css');
	#my $css = GetTemplate('css/bard.css');
	my $css = GetStylesheet();
	$html = str_replace('$styleSheet', $css, $html);

	$html = InjectJs($html, qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write));

	return $html;
}

1;
