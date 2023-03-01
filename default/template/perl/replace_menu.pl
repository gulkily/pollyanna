#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;


sub ReplaceMenuInAllPages {
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

	require_once('widget/menu.pl');

	my @pages = `grep "topmenu2.template" html -rl`; #todo htmldir
	WriteLog('ReplaceMenuInAllPages: scalar(@pages) = ' . scalar(@pages));
	for my $page (@pages) {
		chomp $page;
		if ($page =~ m/\.html$/) {
			my $html = GetFile($page);
			my $lengthBefore = length($html);
			#$html =~ s/<\!-- template\/topmenu2.template -->.+<\!-- \/ template\/topmenu2.template -->//gs;
			#$html =~ s/<\!\-\- template\/topmenu2\.template//gs;
			my $pageType = TrimPath($page);
			my $menu = GetMenuTemplate($pageType);
			$menu = FillThemeColors($menu);
			$html =~ s/<!-- template\/topmenu2.template -->.+<!-- \/ topmenu2.template -->/$menu/gs;
			my $lengthAfter = length($html);
			WriteLog('ReplaceMenuInAllPages: $page = ' . $page . '; $lengthBefore = ' . $lengthBefore . '; $lengthAfter = ' . $lengthAfter);
			PutFile($page, $html);
		}
	}
} # ReplaceMenuInAllPages()


1
