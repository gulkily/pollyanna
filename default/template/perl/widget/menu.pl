#!/usr/bin/perl -T

use strict;
use warnings;

sub GetMenuFromList { # $listName, $templateName = 'html/menuitem.template'; returns html menu based on referenced list
# $listName is reference to a list in config/list, e.g. config/list/menu
# $separator is what is inserted between menu items
# sub GetMenuList {
# sub GetPageMenu {
# sub GetMenu {
	my $listName = shift;
	chomp $listName;
	if (!$listName) {
		WriteLog('GetMenuFromList: warning: $listName failed sanity check');
		return;
	}

	my $templateName = shift;
	if (!$templateName) {
		$templateName = 'html/menuitem.template';
	}
	chomp $templateName;

	WriteLog('GetMenuFromList: $listName = ' . $listName . ', $templateName = ' . $templateName);

	my $listText = GetTemplate('list/' . $listName);


	#	$listText = str_replace(' ', "\n", $listText);
	$listText = str_replace("\n\n", "\n", $listText);

	#WriteLog('GetMenuFromList: $listText = ' . $listText);

	my @menuList = split("\n", $listText);

	if (GetConfig('admin/expo_site_mode') && GetConfig('admin/expo_site_edit')) { #todo
		push @menuList, GetSystemMenuList();
	}

	my $menuItems = ''; # output html which will be returned
	my $menuComma = '';

	my @menuSkip;

	if ($listName eq 'menu') {
		# for main menu, hide menu items for features which are not available #hack
		if (!GetConfig('admin/js/enable') || !GetConfig('admin/php/enable')) { #todo profile/enable
			push @menuSkip, 'profile';
		}
		if (!GetConfig('admin/upload/enable')) {
			push @menuSkip, 'upload';
		}
	} else {
		WriteLog('GetMenuFromList: ' . $listName . ' ne ' . 'menu');
	}

	WriteLog('GetMenuFromList: scalar(@menuSkip) = ' . scalar(@menuSkip));

	foreach my $menuItem (@menuList) {
		my $menuItemName = $menuItem;

		if (in_array($menuItemName, @menuSkip)) {
			WriteLog('GetMenuFromList: ' . $listName . ': ' . $menuItemName . ' was found in @menuSkip');
			next;
		} else {
			WriteLog('GetMenuFromList: ' . $listName . ': ' . $menuItemName . ' NOT in @menuSkip, continuing');
		}

		if ($menuItemName) {
			my $menuItemUrl = '/' . $menuItemName . '.html';
			# capitalize caption
			my $menuItemCaption = uc(substr($menuItemName, 0, 1)) . substr($menuItemName, 1);

			if ($listName eq 'menu_tag') {
				$menuItemUrl = '/top/' . $menuItemName . '.html';
				$menuItemCaption = '#' . $menuItemName;
			}

			my $boolExtUrl = 0;

			if (GetConfig('admin/expo_site_mode')) {

				#this avoids creating duplicate urls but currently breaks light mode
				if ($menuItemName eq 'home') {
					$menuItemUrl = '/';
				}

				# add menu item to output

				if (GetString("menu/$menuItem")) {
					$menuItemCaption = GetString("menu/$menuItem");
				}

				if ($menuItem eq 'register') {
					$boolExtUrl = 1;
					$menuItemUrl = 'https://tinyurl.com/4ezdhdk';
				}

				if ($menuItem eq 'hackathon') {
					$boolExtUrl = 1;
					$menuItemUrl = 'https://mit-bitcoin-expo-hackathon.devfolio.co/';
					#					$menuItemUrl = 'https://forms.gle/JUvaggfVCNS8P54G7';
				}

				if ($menuItem eq 'mailinglist') {
					$boolExtUrl = 1;
					$menuItemUrl = 'https://eepurl.com/gOVdKb';

				}

				if ($menuItem eq 'priorexpo') {
					$boolExtUrl = 1;
					$menuItemUrl = '/flashback_2020/';
				}
			} # if (GetConfig('admin/expo_site_mode'))

			if (GetString("menu/$menuItem")) {
				$menuItemCaption = GetString("menu/$menuItem");
			}

			$menuItemCaption = ucfirst($menuItemCaption);

			if ($menuComma) {
				$menuItems .= $menuComma;
			} else {
				$menuComma = GetTemplate('html/menu_separator.template');
			}

			$menuItems .= GetMenuItem($menuItemUrl, $menuItemCaption, $templateName);
			if (0 && $boolExtUrl) {
				#mark the url as external #todo
			}

			if (GetConfig('admin/expo_site_mode')) {
				$menuItems .= ' &nbsp; ';
			}
		} # if ($menuItemName)
	} # foreach my $menuItem (@menuList)

	# return template we've built
	return $menuItems;
} # GetMenuFromList()

sub GetMenuTemplate { # returns menubar
# sub GetMenubarTemplate {
# sub GetMenubar {
# sub GetMenuBar {
# sub GetTopMenu {
	my $topMenuTemplate = GetTemplate('html/topmenu2.template');

	my $dialogControls = GetTemplate('html/widget/layer_controls.template');
	if (GetConfig('setting/admin/js/dragging')) {
		$dialogControls .= GetTemplate('html/widget/dialog_controls.template');
	} else {
		# remove extra menu placeholder from template
		#$topMenuTemplate = str_replace('<span id=spanDialogControls></span>', '', $topMenuTemplate);
		#todo it should remove table cell as well
	}
	$topMenuTemplate = str_replace('<span id=spanDialogControls></span>', '<span id=spanDialogControls>' . $dialogControls . '</span>', $topMenuTemplate);

	my $pageType = shift;
	if (!$pageType) {
		$pageType = '';
	}
	if (
		!$pageType ||
		(index($pageType, ' ') != -1)
	) {
		WriteLog('GetMenuTemplate: warning: $pageType failed sanity check; caller = ' . join(',', caller));
	}

	WriteLog('GetMenuTemplate: $pageType = ' . $pageType . '; caller = ' . join(',', caller));

	#
	#	if (GetConfig('admin/js/enable')) {
	#		$topMenuTemplate = AddAttributeToTag(
	#			$topMenuTemplate,
	#			'a href="/etc.html"',
	#			'onclick',
	#			"if (window.ShowAll) { ShowAll(this); } return false;"
	#		); # &pi;
	#	}

	my $selfLink = '/access.html';
	my $menuItems = GetMenuFromList('menu'); # GetMenuTemplate()

	#WriteLog('GetMenuTemplate: $menuItems = ' . $menuItems);

	my $menuItemsTag = '';
	my $menuItemsAdvanced = '';
	my $menuItemsAdmin = '';

	if (GetConfig('admin/expo_site_mode')) {
		#do nothing
	} else {
		my $menuItemsTag = GetMenuFromList('menu_tag'); # GetMenuTemplate()
		my $menuItemsAdvanced = GetMenuFromList('menu_advanced'); # GetMenuTemplate()
		my $menuItemsAdmin = GetMenuFromList('menu_admin'); # GetMenuTemplate()
	}

	if (!$menuItems || trim($menuItems) eq '') {
		#fallback menu in case menu config is so jacked the output is empty
		#todo could use more sanity checks here, like are these basic links present?
		WriteLog('GetMenuTemplate: warning: using hard-coded fallback menu list');
		$menuItems = '
			<a href=/>Home</a>
			<a href=/read.html>Read</a>
			<a href=/write.html>Write</a>
			<a href=/help.html>Help</a>
			<a href=/settings.html><font color=gray>Settings</a>
			<span class=advanced title="Fallback menu is in use">!</span>
		';
	}

	my $siteName = GetConfig('site_name');
	if (GetConfig('config/debug')) {
		$siteName .= ' (debug mode)';
	}

	$topMenuTemplate =~ s/\$menuItemsAdvanced/$menuItemsAdvanced/g;
	$topMenuTemplate =~ s/\$menuItemsAdmin/$menuItemsAdmin/g;
	$topMenuTemplate =~ s/\$menuItemsTag/$menuItemsTag/g;
	$topMenuTemplate =~ s/\$menuItems/$menuItems/g;
	$topMenuTemplate =~ s/\$selfLink/$selfLink/g;
	$topMenuTemplate =~ s/\$siteName/$siteName/g;

	if (GetConfig('html/clock')) {
		my $clockTemplate = GetClockWidget();
		$topMenuTemplate = '<form action="/stats.html" name=frmTopMenu>' . $topMenuTemplate . '</form>';
		$topMenuTemplate =~ s/<span id=spnClock><\/span>/$clockTemplate/g;
	} else {
		# code below not approved for public consumoption #todo
		# removes colspan and fixes the hanging cell bug in some browsers
		#$topMenuTemplate =~ s/<td colspan=2>/<td>/g;
	}

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmousedown', 'this.style.zIndex = ++window.draggingZ;');
		$topMenuTemplate = AddAttributeToTag($topMenuTemplate, 'table', 'onmouseenter', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetMenuTemplate()
		$topMenuTemplate = AddAttributeToTag($topMenuTemplate, 'table', 'onmousedown', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetMenuTemplate()
	}

	if (GetConfig('admin/js/enable') || GetConfig('admin/php/enable')) { #todo there should be a config called profile_enabled
		if ($pageType ne 'profile' && $pageType ne 'identity') {
			#$topMenuTemplate .= GetWindowTemplate(GetTemplate('html/widget/identity.template'), 'Identity');
		}
	}

	if (GetConfig('admin/js/enable') || GetConfig('setting/html/reply_cart')) {
		if (
			$pageType eq 'write' ||
			$pageType eq 'read_author' ||
			$pageType eq 'item'
		) {
			#todo should open a write dialog automatically
			require_once('dialog/reply_cart.pl');
			$topMenuTemplate .= GetReplyCartDialog(); # GetMenuTemplate()
		} else {
			#$topMenuTemplate .= GetWindowTemplate('$pageType = ' . $pageType, 'no reply cart?');
			#nothing needed here
		}
	}

	return $topMenuTemplate;
} # GetMenuTemplate()

sub GetMenuItem { # $address, $caption, $templateName; returns html snippet for a menu item (used for both top and footer menus)
	my $address = shift;
	my $caption = shift;

	#todo more sanity

	WriteLog('GetMenuItem: $address = ' . $address . '; $caption = ' . $caption);

	my $menuName = lc($caption);

	# if (!-e "$HTMLDIR/$address") {
	#	#don't make a menu item if file doesn't exist
	# 	return '';
	# }

	my $templateName = shift;
	if (!$templateName) {
		$templateName = 'html/menuitem.template';
	}
	chomp $templateName;

	my $menuItem = '';
	$menuItem = GetTemplate($templateName);

	# my $color = GetThemeColor('link');
	# my $colorSourceHash = md5_hex($caption);
	# my $menuColorMode = GetThemeAttribute('menu_color_mode') ? 1 : 0;
	# for (my $colorSelectorI = 0; $colorSelectorI < 6; $colorSelectorI++) {
	# 	my $char = substr($colorSourceHash, $colorSelectorI, 1);
	# 	if (!$menuColorMode) {
	# 		if ($char eq 'd' || $char eq 'e' || $char eq 'f') {
	# 			$char = 'c';
	# 		}
	# 	}
	# 	if ($menuColorMode) {
	# 		if ($char eq '0' || $char eq '1' || $char eq '2') {
	# 			$char = '3';
	# 		}
	# 	}
	# 	$color .= $char;
	# }

	# my $firstLetter = substr($caption, 0, 1);
	# $caption = substr($caption, 1);

	#my $color = substr(md5_hex($caption), 0, 6);

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
		#todo ??
		$menuItem = AddAttributeToTag(
			$menuItem,
			'a ',
			'onclick',
			"if ((!window.GetPrefs || GetPrefs('draggable_spawn'))) { return FetchDialog('$menuName'); }"
		);
		#todo this also needs relativize support
	}

	if ($menuName eq 'threads') {
		my $threadCount = SqliteGetValue('thread_count');
		if ($threadCount) {
			$caption .= ' (' . $threadCount . ')';
		}
	}

	$menuItem =~ s/\$address/$address/g;
	$menuItem =~ s/\$caption/$caption/g;


	# $menuItem =~ s/\$color/$color/g;
	# $menuItem =~ s/\$firstLetter/$firstLetter/g;

	return $menuItem;
} # GetMenuItem()

1;
