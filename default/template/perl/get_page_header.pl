#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetPageHeader { # $pageType, $title ; returns html for page header
# sub GetHeader {
# sub GetHtmlStart {
	my $pageType = shift; # type of page
	# my $pageHeaderHtml = '';

	my $title = shift; # page title
	if (!$title) {
		# if title is not provided, come up with one
		$title = GetString("menu/$pageType"); # look up in strings first
		if (!$title) {
			# if still no title, use the page type with capitalization
			$title = ucfirst($pageType);
		} # if (!$title)
	} # if (!$title)

	if (
		!$pageType ||
			(index($pageType, ' ') != -1)
	) {
		WriteLog('GetPageHeader: warning: $pageType failed sanity check; caller = ' . join(',', caller));
	}

	if (!$pageType) {
		WriteLog('GetPageHeader: warning: $pageType missing, setting to default');
		$pageType = 'default';
	}

	WriteLog("GetPageHeader($pageType) ; caller = " . join(',', caller));

	if (defined($title)) {
		chomp $title;
	} else {
		$title = '';
	}

	my $pageHeaderHtml = '';
	require_once('widget/stylesheet.pl');
	my $styleSheet = GetHeaderStylesheet($pageType); #todo also pass parameter

    #PageIntro
	#my $introText = trim(GetString('page_intro/' . $pageType));
	#if (!$introText) {
	#	# sub GetPageIntro {
	#	# sub GetPageDescription {
	#	$introText = trim(GetDialogX(GetString('page_intro/default'), 'Introduction'));
	#}
	#todo this should actually be used

	# Get the HTML page template
	my $htmlStart = GetTemplate('html/htmlstart.template');
	# and substitute $title with the title

	my $titleHtml = $title;

	$htmlStart = str_replace('$titleHtml', $titleHtml, $htmlStart);
	$htmlStart = str_replace('$title', $title, $htmlStart);

	if (GetConfig('admin/offline/enable')) {
		$htmlStart = AddAttributeToTag(
			$htmlStart,
			'html',
			'manifest',
			'/cache.manifest'
		);
	}

	if (GetConfig('html/prefetch_enable')) {
		#todo add more things to this template and make it not hard-coded
		my $prefetchTags = GetTemplate('html/prefetch_head.template');
		$htmlStart = str_replace('</head>', $prefetchTags . "\n" . '</head>', $htmlStart);
	}



	#top menu
	my $topMenuTemplate = '';
	if (GetConfig('html/menu_top')) {
		if ($pageType eq 'welcome' && GetConfig('admin/php/route_welcome_desktop_logged_in') && GetConfig('admin/php/force_profile')) {
			# when force_profile setting is on, there should be
			# no menu on welcome page if not logged in
		} else {
			require_once('widget/menu.pl');
			$topMenuTemplate = GetMenuTemplate($pageType); #GetPageHeader()

			# if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging') && GetConfig('admin/js/controls_header')) {
			# 	my $dialogControls = GetTemplate('html/widget/dialog_controls.template'); # GetPageHeader()
			# 	$dialogControls = GetDialogX($dialogControls, 'Controls'); # GetPageHeader()
			# 	#$dialogControls = '<span class=advanced>' . $dialogControls . '</span>';
			# 	$topMenuTemplate .= $dialogControls;
			# }

			if (GetConfig('html/dialog_history')) {
				require_once('dialog/history.pl');
				$topMenuTemplate .= GetHistoryDialog();
			}

			if (GetConfig('html/global_message')) {
				#todo it may be nice to have a #GlobalMessage hashtag option here
				my $globalMessage = GetString('server/global_message');
				if ($globalMessage) {
					$topMenuTemplate .= GetDialogX('<fieldset><p>' . $globalMessage . '</p></fieldset>');
				}
			}
		}
	}

	if (GetConfig('setting/html/page_map_top') || GetConfig('setting/html/page_map')) {
		require_once('dialog/page_map.pl');
		$topMenuTemplate .= GetPageMapDialog();
		#$topMenuTemplate .= '<span class=advanced>' . GetPageMapDialog() . '</span>';
		#todo this can be changed once pagemap is accessible from the main menu
	}

	if (GetConfig('setting/html/neighbor_list')) {
		if ($pageType eq 'item') {
			#exception, this doesn't work here yet
		} else {
			#todo this needs a lot of improvement, does not work on all pages
			require_once('dialog/neighbor.pl');
			my $neighboringInstances = GetNeighborDialog($pageType, $title);
			$topMenuTemplate .= $neighboringInstances;
		}
	}

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging') && GetConfig('admin/js/dialog_properties')) {
		my $dialogStyle = GetTemplate('html/widget/dialog_style.template'); # GetPageHeader()
		$dialogStyle = GetDialogX($dialogStyle, 'Dialog');
		$topMenuTemplate .= $dialogStyle;
	}

	#	my $noJsIndicator = '<noscript><a href="/profile.html">Profile</a></noscript>';
	#todo profile link should be color-underlined like other menus
	{
		if (GetConfig('html/logo_enabled')) {
			state $logoText;
			if (!defined($logoText)) {
				$logoText = GetConfig('html/logo_text');
				if (!$logoText) {
					$logoText = '';
				}
			}
			my $logoTemplate = GetDialogX('<a href="/" class=logo>Home</a>', $logoText);
			$htmlStart .= $logoTemplate;
		}
	}

	if ($pageType ne 'item') {
		$htmlStart =~ s/\$topMenu/$topMenuTemplate/g;
	} else {
		if (GetConfig('html/item_page_menu_bottom')) {
			$htmlStart =~ s/\$topMenu//g;
		} else {
			$htmlStart =~ s/\$topMenu/$topMenuTemplate/g;
		}
	}

	$htmlStart =~ s/\$styleSheet/$styleSheet/g;
	# $htmlStart =~ s/\$titleHtml/$titleHtml/g;
	# $htmlStart =~ s/\$title/$title/g;

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/loading')) { #begin loading
		require_once('inject_js.pl');
		$htmlStart = InjectJs2($htmlStart, 'after', '<body>', qw(loading_begin));

		# # #todo #templatize #hide #loading
		#$htmlStart .= '<style><!-- .dialog {display: none !important; } --></style>';
	}

	$htmlStart = FillThemeColors($htmlStart);
	$pageHeaderHtml .= $htmlStart;

	return $pageHeaderHtml ;
} # GetPageHeader()

sub GetPageHeaderWithoutMenu { # $pageType, $title ; returns html for page header
	my $pageType = shift;
	my $title = shift;
	#todo sanity checks

	if (!$title) {
		# if title is not provided, come up with one
		$title = GetString("menu/$pageType"); # look up in strings first
		if (!$title) {
			# if still no title, use the page type with capitalization
			$title = ucfirst($pageType);
		} # if (!$title)
	} # if (!$title)

	if (defined($title)) {
		chomp $title;
	} else {
		$title = '';
	}

	my $titleHtml = $title;

	my $styleSheet = GetHeaderStylesheet($pageType); #todo also pass parameter

	my $htmlStart = GetTemplate('html/htmlstart.template');

	$htmlStart =~ s/\$topMenu//g;
	$htmlStart = str_replace('$titleHtml', $titleHtml, $htmlStart);
	$htmlStart = str_replace('$title', $title, $htmlStart);
	$htmlStart = str_replace('$styleSheet', $styleSheet, $htmlStart);

	return $htmlStart;
}

1;
