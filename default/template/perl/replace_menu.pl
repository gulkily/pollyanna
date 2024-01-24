#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub ReplaceMenuInAllPages {
# sub ReplaceMenu {
# sub PutMenu {
# sub WriteMenu {
# sub UpdateMenu {
	# the idea here is to in-place replace the menu in all the pages when the menu changes
	# the main challenge is that GetMenuTemplate() takes a parameter...
	my $HTMLDIR = GetDir('html');
	if (!$HTMLDIR) {
		WriteLog('ReplaceMenuInAllPages: warning: $HTMLDIR was FALSE');
		return '';
	}

	state $beenRun = 0;
	$beenRun++;
	if ($beenRun > 1) {
		WriteLog('ReplaceMenuInAllPages: warning: $beenRun > 1');
		return '';
	}

	require_once('widget/menu.pl');

	my @pages = `grep "menu_top.template" "$HTMLDIR" -rl`;
	WriteLog('ReplaceMenuInAllPages: scalar(@pages) = ' . scalar(@pages));

	my $pageCount = 0;

	for my $page (@pages) {
		$pageCount++;
		if ($pageCount > 1000) {
			WriteLog('ReplaceMenuInAllPages: warning: $pageCount > 1000');
			last;
		}
		chomp $page;
		if ($page =~ m/\.html$/) {
			my $html = GetFile($page);
			if (!$html) {
				WriteLog('ReplaceMenuInAllPages: warning: $html was FALSE');
				next;
			}
			my $lengthBefore = length($html);
			#$html =~ s/<\!-- template\/menu_top.template -->.+<\!-- \/ template\/menu_top.template -->//gs;
			#$html =~ s/<\!\-\- template\/menu_top\.template//gs;
			my $pageType = TrimPath($page);
			my $menu = GetMenuTemplate($pageType);
			$menu = FillThemeColors($menu);
			$html =~ s/<!-- template\/menu_top.template -->.+<!-- \/ menu_top.template -->/$menu/gs;
			my $lengthAfter = length($html);
			WriteLog('ReplaceMenuInAllPages: $page = ' . $page . '; $lengthBefore = ' . ($lengthBefore ? $lengthBefore : 'FALSE') . '; $lengthAfter = ' . ($lengthAfter ? $lengthAfter : 'FALSE'));
			PutFile($page, $html);
		}
	}
} # ReplaceMenuInAllPages()

1
