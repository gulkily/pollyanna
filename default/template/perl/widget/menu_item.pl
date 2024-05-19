#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

# menu_item.pl
# purpose: generate menu items
# sub GetMenuItem { # $address, $caption, $templateName; returns html snippet for a menu item (used for both top and footer menus)
# $address example: '/foo.html'
# $caption example: 'Foo'
# $templateName example: 'html/menuitem.template'

sub GetMenuItem { # $address, $caption, $templateName; returns html snippet for a menu item (used for both top and footer menus)
# $address example: '/foo.html'
# $caption example: 'Foo'
# $templateName example: 'html/menuitem.template'

# sub GetMenuButton {
	my $address = shift;
	my $caption = shift;

	chomp $address;
	chomp $caption;

	if (!$address) {
		return '';
	}
	if (!$caption) {
		return '';
	}

	if (index($address, "\r") != -1 || index($caption, "\r") != -1) {
		WriteLog('GetMenuItem: warning: $address or $caption failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	#todo more sanity

	my $menuName = lc($caption);
	my $dialogName = substr($address, 1, length($address) - 6); # '/foo.html' ==> 'foo'

	# if (!-e "$HTMLDIR/$address") {
	#	#don't make a menu item if file doesn't exist
	# 	return '';
	# }

	my $templateName = shift;
	if (!$templateName) {
		$templateName = 'html/menuitem.template';
	}
	chomp $templateName;

	WriteLog('GetMenuItem: $address = ' . $address . '; $caption = ' . $caption . '; $templateName = ' . $templateName . '; caller = ' . join(',', caller));

	#state $menuItemTemplate = GetTemplate($templateName);
	my $menuItem = '';
	$menuItem = GetTemplate($templateName);

	my $color = '';
	if (GetConfig('setting/html/menu_color_code')) { #todo should be under css/
		my $colorSourceHash = md5_hex($caption);
		for (my $colorSelectorI = 0; $colorSelectorI < 6; $colorSelectorI++) {
			#this is a hack to make sure the color is not too dark
		 	my $char = substr($colorSourceHash, $colorSelectorI, 1);
			if ($char eq 'd' || $char eq 'e' || $char eq 'f') {
				$char = 'c';
			}
	 		if ($char eq '0' || $char eq '1' || $char eq '2') {
	 			$char = '3';
	 		}
		 	$color .= $char;
		}

		$color = substr(md5_hex($caption), 0, 6);
	} else {
		$color = GetThemeColor('link');
	}

	if (GetConfig('html/accesskey')) {
		my $accessKey = GetAccessKey($caption);
		if ($accessKey) {
			$menuItem = AddAttributeToTag($menuItem, 'a', 'accesskey', $accessKey);
			if (GetConfig('html/emoji_menu')) {
				my $menuItemEmoji = GetString(lc($caption), 'emoji', 1); #lc() is a hack, name should be passed instead of caption
				$menuItem = AddAttributeToTag($menuItem, 'a', 'title', $caption);
			} else {
				$caption =~ s/($accessKey)/<u>$1<\/u>/i;
			}
		}
	} else {
		if (GetConfig('html/emoji_menu')) {
			my $menuItemEmoji = GetString(lc($caption), 'emoji', 1); #lc() is a hack, name should be passed instead of caption
		}
	}

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
		#todo use RenderLink() here
		#if ($menuName ne 'help' && $menuName ne 'people') { # DO NOT DO THIS PLEASE, it is jarring and unexpected
		if (1) {
			# todo also need some kind of special handling
			# if it is an item page, otherwise we run into an
			# issue with relativize_urls
			$dialogName = trim($dialogName);
			$menuItem = AddAttributeToTag(
				$menuItem,
				'a ',
				'onclick',
				"if (!(window.GetPrefs) || GetPrefs('draggable_spawn')) { return FetchDialog('$dialogName'); }"
			);
		}
		#todo this also needs relativize support
	}

	if (in_array($menuName, qw(chain threads tags authors active people new image topics labels))) {
		#todo allow/include label/tag/hashtag items
		WriteLog('GetMenuItem: counter: $menuName = ' . $menuName . '; caller = ' . join(',', caller));
		# counter counters #counter
		# sum counters like this:
		# menu counters
		#Threads(5) Tags(3) People(7) Labels(5)
		# topics counter
		#todo this should be a list instead of hard-coded (or automatically look for template/query/foo)
		my $itemCount = SqliteGetCount($menuName);
		# my $threadCount = SqliteGetValue('thread_count');
		if ($itemCount) {
			$caption .= '(' . $itemCount . ')';
		}
	} else {
		WriteLog('GetMenuItem: no counter: $menuName = ' . $menuName . '; caller = ' . join(',', caller));
	}

	$menuItem =~ s/\$address/$address/g;
	$menuItem =~ s/\$caption/$caption/g;

	if ($address eq '/frame.html') {
		# frame.html displays the keyboard frame
		# doing this prevents frame re-nesting
		$menuItem = AddAttributeToTag($menuItem, 'a ', 'target', '_top');
	}

	if (GetConfig('setting/html/menu_color_code')) { #todo should be under css/
		$menuItem = AddAttributeToTag($menuItem, 'a ', 'style', 'border-bottom: #$color 3px solid;');
		$menuItem =~ s/\$color/$color/g;
	}

	# $menuItem =~ s/\$firstLetter/$firstLetter/g;

	return $menuItem;
} # GetMenuItem()

1;