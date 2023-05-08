#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub AddToMenu { # $menuItem
	my $menuItem = shift;
	chomp $menuItem;

	my $existingMenu = GetTemplate('list/menu');
	if ($existingMenu =~ m/^$menuItem/im) {
		# already exists
	} else {
		my $newMenu = $existingMenu . "\n" . $menuItem;
		PutFile(GetDir('config') . '/theme/hypercode/template/list/menu', $newMenu);
		`bash hike.sh page write`;
	}
}

sub LogChangesToGit {
	if (GetConfig('setting/admin/git/operator_please_commit_and_push')) {
		my $action = shift;
		my $taskId = substr(sha1_hex($action), 0, 8);

		my $gitLog = '';

		my $pwd = cwd();
		if ($pwd =~ m/^(.+)$/) { #todo more sanity
			$pwd = $1;
		} else {
			#todo bad
		}

		$gitLog .= `cd config 2>&1 ; git add -v . 2>&1 ; git commit -m '$action $taskId' . 2>&1 ; git push 2>&1 ; cd "$pwd"`;
		$gitLog .= `cd html 2>&1 ; git add -v . 2>&1 ; git commit -m '$action $taskId' . 2>&1 ; git push 2>&1 ; cd "$pwd"`;
	}
} # LogChangesToGit()

sub GetOperatorResponse {
	my $query = shift;
	chomp $query;

	#todo need to set client-side flags

#	my $onceLog = GetOnce($query);
#	if (!$onceLog) {
#		WriteLog('GetOperatorResponse: warning: encountered previously done task');
#		return 'I may have done that already';
#	}

	if (GetConfig('setting/admin/git/operator_please_commit_and_push')) {
		LogChangesToGit("before $query");
	}

	if ($query eq 'add calendar page') {
		AddToMenu('calendar');
		`bash hike.sh page calendar`;
		return 'ok, I added calendar page and a link in the menu.';
	}
	if ($query eq 'add threads page') {
		AddToMenu('threads');
		`bash hike.sh page threads`;
		return 'ok, I added threads page and a link in the menu.';
	}
	if ($query eq 'add search page') {
		AddToMenu('search');
		`bash hike.sh page search`;
		return 'ok, I added search page and a link in the menu.';
	}
	if ($query eq 'add profile page') {
		AddToMenu('profile');
		`bash hike.sh page profile`;
		return 'ok, I added profile page with basic cookie authentication.';
	}
	if ($query =~ m/bitcoin/i) {
		AddToMenu('tag/BitcoinExpo2023');
		return 'ok, I added a page about the 2023 MIT Bitcoin Expo. it may take a minute.';
	}
	if ($query =~ m/add.+OpenPGP.+profile/) {
		PutConfig('setting/admin/js/openpgp', 1);
		PutConfig('setting/admin/js/openpgp_checked', 1);
		`./pages.pl --js`;
		`bash hike.sh page profile`;
		return 'ok, I added basic OpenPGP.js integration to the profiles.';
	}
	if ($query =~ m/add.+keychain/) {
		PutConfig('setting/admin/js/openpgp_keychain', 1);
		`bash hike.sh page profile`;
		return 'ok, I added a keychain for private keys to the profile page.';
	}
	if ($query eq 'add upload feature with paste option' || $query eq 'add upload page' || $query eq 'add upload') {
		AddToMenu('upload');
		PutConfig('setting/admin/upload/enable', 1);
		PutConfig('setting/admin/image/enable', 1);
		`bash hike.sh page upload`;
		return 'ok, I added upload page.';
	}
	if ($query =~ m/monochrome/i) {
		PutConfig('setting/html/monochrome', 1);
		#`bash hike.sh refresh`;
		return 'ok, I made the site less colorful';
	}
	if ($query =~ m/inbox+.top/) {
		PutConfig('setting/html/css_inbox_top', 1);
		#`bash hike.sh refresh`;
		return 'ok, I put the inbox dialog at the top of the page';
	}
	if ($query eq 'add inline-block to dialogs') {
		PutConfig('setting/html/css_inline_block', 1);
		#`bash hike.sh refresh`;
		return 'ok, I added display: inline-block to the dialog class';
	}
	if ($query eq 'add notarization chain') {
		AddToMenu('chain');
		`bash hike.sh page chain`;
		return 'ok, I added a notarization chain page.';
	}
	if ($query =~ m/sha1.+md5/i) {
		AddToMenu('help');
		`bash hike.sh page help`;
		#`bash hike.sh refresh`;
		return 'I used SHA1 and MD5 in the notarization chain to make it easier for other computers to audit the data while still retaining reasonable tampering protection';
	}
	if ($query eq 'add a basic image board' || $query eq 'add image board') {
		AddToMenu('image');
		PutConfig('setting/admin/image/enable', 1);
		`bash hike.sh page image`;
		return 'ok, I added a basic image board';
	}
	if ($query eq 'add basic javascript' || $query eq 'add javascript support' || $query eq 'enable javascript') {
		#AddToMenu('settings');
		PutConfig('setting/admin/js/enable', 1);
		`bash hike.sh frontend`;
		return 'ok, I added a basic javascript, including live timestamps, in-place voting buttons. a settings page is available on request.';
	}
	if ($query eq 'add page loading indicator' || $query eq 'add loading indicator' || $query =~ m/progress.+indicator/) {
		PutConfig('setting/admin/js/loading', 1);
		`bash hike.sh frontend`;
		if (GetConfig('setting/admin/js/enable')) {
			return 'ok, I added a loading indicator which advises the user to meditate while waiting.';
		} else {
			return 'would you like to allow javascript in the html templates?';
		}
	}
	if ($query eq 'change appearance to dark theme') {
		PutConfig('setting/theme', 'hypercode dark');
		#`bash hike.sh refresh`;
		return 'ok, I changed the theme to hypercode dark';
	}
	if ($query eq 'reset appearance to default theme') {
		PutConfig('setting/theme', 'hypercode chicago');
		#`bash hike.sh refresh`;
		return 'ok, I reset the theme to hypercode chicago';
	}
	if ($query eq 'remove javascript' || $query eq 'turn off javascript') {
		PutConfig('setting/admin/js/enable', 0);
		#`bash hike.sh refresh`;
		if (GetConfig('setting/html/menu_layer_controls')) {
			PutConfig('setting/html/menu_layer_controls', 0);
		}
		if (GetConfig('setting/html/back_to_top_button')) {
			PutConfig('setting/html/back_to_top_button', 0);
		}
		if (GetConfig('setting/admin/js/openpgp')) {
			return 'ok, I removed all the javascript. please note, OpenPGP.js integration does not work without javascript.';
		} else {
			return 'ok, I removed all the javascript. please note, some features may not work without it.';
		}
	}
	if ($query eq 'add a tags page' || $query eq 'add tags page') {
		AddToMenu('tags');
		#`bash hike.sh refresh`;
		return 'ok, I added a basic tags page, including item-descriptive tags and hashtags';
	}
	if ($query =~ m/inbox/ && !GetConfig('setting/admin/php/cookie_inbox')) {
		AddToMenu('active');
		PutConfig('setting/admin/php/cookie_inbox', 1);
		#`bash hike.sh refresh`;
		return 'ok, you should see any replies in your inbox, and I added an active users page.';
	}
	if ($query eq 'let me download our conversation' || $query =~ m/conversation.+download/i || $query =~ m/download.+conversation/i) {
		AddToMenu('data');
		`bash hike.sh page data`;
		return 'ok, I added a data page where you can download our conversation';
	}
	if ($query eq 'accept my gratitude') {
		AddToMenu('tag/gratitude');
		#`bash hike.sh refresh`;
		return "you're welcome! I added a gratitude page";
	}
	if ($query eq 'enable javascript debugging') {
		PutConfig('setting/admin/js/debug', 'console.log');
		#`bash hike.sh refresh`;
		return "ok, I enabled javascript debug output to the console";
	}
	if ($query eq 'turn off javascript debugging') {
		PutConfig('setting/admin/js/debug', 0);
		#`bash hike.sh refresh`;
		return "ok, I turned off javascript debugging";
	}
	if ($query =~ /hacker news/) {
		my $bookmarkFile = GetTemplate('js/bookmark/scrape_hn_comments.js');
		return "/* please use this bookmarklet to input the comments */\n\n" . $bookmarkFile . "\n\n/* #example */";
	}
	if ($query =~ /interface.+draggable/) {
		PutConfig('setting/admin/js/dragging', 1);
		PutConfig('setting/html/menu_layer_controls', 1);
		#`bash hike.sh refresh`;
		return "ok, I added some javascript for draggable dialogs.";
	}
	if ($query =~ /cryptographic.+attributes/) {
		PutConfig('setting/admin/js/dragging', 1);
		PutConfig('setting/html/menu_layer_controls', 1);
		#`bash hike.sh refresh`;
		return "to see more detailed information about items on the current page, please use the Expand menu item in the. use the Minimal menu item to hide the technical details.";
	}
	if ($query eq 'add authors page') {
		AddToMenu('authors');
		`bash hike.sh page authors`;
		return "ok, I added an authors page. there may not be much on it at first.";
	}
	if ($query eq 'add people page') {
		AddToMenu('people');
		`bash hike.sh page people`;
		return "ok, I added a people page. there may not be much on it at first.";
	}
	if ($query eq 'add random page' || $query eq 'add a random items page' || $query =~ m/add.+random.+page/) {
		AddToMenu('random');
		`bash hike.sh page random`;
		return "ok, I added a page with random items";
	}
	if ($query eq 'make a python file') {
		AddToMenu('tag/python3');
		PutConfig('setting/admin/python3/enable');
		PutConfig('setting/admin/token/run');
		PutFile("html/py/hi.py", "print('hi')");
		IndexPyFile("html/py/hi.py");
		return "ok, I made a python3 file and put it in the menu";
	}
	if ($query =~ m/dvorak/i) {
		#todo js needs to be enabled
		PutConfig('setting/html/write_options', 1);
		PutConfig('setting/admin/js/translit', 1);
		`./pages.pl --write`;
		return 'ok, I added a Dvorak layout transliteration in javascript. to access it, press ctrl+d. i added an on-screen keyboard to the write page to help you.';
	}
	if ($query =~ m/raw.+items/i) {
		AddToMenu('raw');
		`bash hike.sh page raw`;
		return 'ok, I added a Dvorak layout transliteration in javascript. to access it, press ctrl+d. i added an on-screen keyboard to the write page to help you.';
	}
	if ($query =~ m/reset.+site/i) {
		`bash default/theme/hypercode/template/sh/reset_config.sh`;
		#`bash hike.sh refresh`;
		return 'ok, I reset the website settings';
	}
	if ($query =~ m/make me admin/) {
		return 'In order to become admin, you have to solve a puzzle.';
		#PutConfig('setting')
	}
	if ($query =~ m/make.+accessible.+text/) {
		PutConfig('setting/admin/php/light_mode_always_on', 1);
		return 'I switched on light mode. Does that help?';
	}
	if ($query =~ /compatibility/i) {
		return "this website should be compatible with every mainstream and historically mainstream (1% or higher peak adoption rate) browser which supports HTTP/1.1.\n\n" .
		" the browsers I am aware of are Google Chrome and Chromium, Thorium, Vivaldi, and Brave; Mozilla Firefox and Waterfox, Waterfox Classic, PaleMoon, LibreWolf, and Abrowser; Internet Explorer, Apple Safari for Mac OS and for iOS and iPadOS, Microsoft Edge, Lynx, Links, w3m, Dillo, Mozilla SeaMonkey, Netscape Navigator, OffByOne Browser, Opera Browser (post-Chromium transition, Presto era, and pre-Presto), WebTV Browser, Samsung TV browser, America Online 3.0 and higher, Midori, Luakit, qutebrowser, Camino, OmniWeb, NetSurf, Nyxt, Falkon, Beacon, GNU IceCat, Emacs Web Wowser, and curl.";
	}
	else {
		return 'I did not understand that query';
	}
} # GetOperatorResponse()

1;
