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

sub GetComputerResponse {
	my $query = shift;
	chomp $query;

	#todo need to set client-side flags

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
	if ($query =~ m/OpenPGP/) {
		PutConfig('setting/admin/js/openpgp', 1);
		`./pages.pl --js`;
		`bash hike.sh page profile`;
		return 'ok, I added basic OpenPGP.js integration to the profiles.';
	}
	if ($query eq 'add upload feature with paste option' || $query eq 'add upload page') {
		AddToMenu('upload');
		PutConfig('setting/admin/upload/enable', 1);
		PutConfig('setting/admin/image/enable', 1);
		`bash hike.sh page upload`;
		return 'ok, I added upload page.';
	}
	if ($query =~ m/monochrome/i) {
		PutConfig('setting/html/monochrome', 1);
		`bash hike.sh refresh`;
		return 'ok, I made the site less colorful';
	}
	if ($query eq 'add inline-block to dialogs') {
		PutConfig('setting/html/css_inline_block', 1);
		`bash hike.sh refresh`;
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
		`bash hike.sh refresh`;
		return 'I used SHA1 and MD5 in the notarization chain to make it easier for other computers to audit the data while still retaining reasonable tampering protection';
	}
	if ($query eq 'add a basic image board' || $query eq 'add image board') {
		AddToMenu('image');
		PutConfig('setting/admin/image/enable', 1);
		`bash hike.sh page image`;
		return 'ok, I added a basic image board';
	}
	if ($query eq 'add basic javascript' || $query eq 'add javascript support' || $query eq 'enable javascript') {
		AddToMenu('settings');
		PutConfig('setting/admin/js/enable', 1);
		`bash hike.sh frontend`;
		return 'ok, I added a basic javascript, including live timestamps, in-place voting buttons, and a settings page';
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
		`bash hike.sh refresh`;
		return 'ok, I changed the theme to hypercode dark';
	}
	if ($query eq 'reset appearance to default theme') {
		PutConfig('setting/theme', 'hypercode chicago');
		`bash hike.sh refresh`;
		return 'ok, I reset the theme to hypercode chicago';
	}
	if ($query eq 'remove javascript' || $query eq 'turn off javascript') {
		PutConfig('setting/admin/js/enable', 0);
		`bash hike.sh refresh`;
		if (GetConfig('setting/admin/js/openpgp')) {
			return 'ok, I removed all the javascript. please note, OpenPGP.js integration does not work without javascript.';
		} else {
			return 'ok, I removed all the javascript. please note, some features may not work without it.';
		}
	}
	if ($query eq 'add a tags page' || $query eq 'add tags page') {
		AddToMenu('tags');
		`bash hike.sh refresh`;
		return 'ok, I added a basic tags page, including item-descriptive tags and hashtags';
	}
	if ($query eq 'let me download our conversation' || $query =~ m/conversation.+download/i) {
		AddToMenu('data');
		`bash hike.sh page data`;
		return 'ok, I added a data page where you can download our conversation';
	}
	if ($query eq 'accept my gratitude') {
		AddToMenu('tag/gratitude');
		`bash hike.sh refresh`;
		return "you're welcome! I added a gratitude page";
	}
	if ($query eq 'enable javascript debugging') {
		PutConfig('setting/admin/js/debug', 'console.log');
		`bash hike.sh refresh`;
		return "ok, I enabled javascript debug output to the console";
	}
	if ($query eq 'turn off javascript debugging') {
		PutConfig('setting/admin/js/debug', 0);
		`bash hike.sh refresh`;
		return "ok, I turned off javascript debugging";
	}
	if ($query =~ /hacker news/) {
		my $bookmarkFile = GetTemplate('js/bookmark/scrape_hn_comments.js');
		return $bookmarkFile . "\n\n#textart";
	}
	if ($query eq 'add authors page') {
		AddToMenu('authors');
		`bash hike.sh page authors`;
		return "ok, I added an authors page. there may not be much on it at the moment.";
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
	if ($query eq 'make me admin') {
		PutConfig('setting')
	}
	if ($query =~ /compatibility/i) {
		return "this website should be compatible with every mainstream (1% or higher adoption rate) browser which supports HTTP/1.1.";
	}
	else {
		return 'I did not understand that query';
	}
}

1;
