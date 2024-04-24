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
} # GetWelcomePage()

1;
