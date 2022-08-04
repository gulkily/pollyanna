#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetContentFilterDialog () { # ; returns thermostat / content filter dialog
	my @list = split("\n", trim(GetTemplate('list/content_filter_ui_tags')));

	my $list = '';
	for my $item (@list) {
		my $itemTemplate = GetTemplate('html/widget/vote_value_item.template');
		$itemTemplate = str_replace('$tagName', $item, $itemTemplate);

		my $currentValue = SqliteGetValue("select value from vote_value where vote='$item'");
		if (!$currentValue || $currentValue eq 1) {
			$itemTemplate = str_replace('title=Low', 'title=Low checked', $itemTemplate);
		}
		elsif ($currentValue eq 10) {
			$itemTemplate = str_replace('title=Medium', 'title=Medium checked', $itemTemplate);
		}
		 elsif ($currentValue eq 11) {
			$itemTemplate = str_replace('title=High', 'title=High checked', $itemTemplate);
		}
		#$itemTemplate .= $currentValue;

		$list .= $itemTemplate;
		$list .= "<br>\n";
	}

	my $information = '
		<span class=beginner><p>
			This changes the weight of the given tags.<br>
			The radio buttons for each are 1, 10, and 11.<br>
			This feature can be safely ignored.
		</p></span>
	'; #todo more explanation or documentation

	my $dialog = GetWindowTemplate($list . $information, 'Thermostat');

	#my $form = '<form class=advanced
	my $form = '<form name=frmContentFilter id=frmContentFilter class=advanced action="/post.html">' . $dialog . '</form>';

	return $form;
} # GetContentFilterDialog()

1;
