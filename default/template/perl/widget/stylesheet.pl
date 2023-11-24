#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetHeaderStylesheet { # $pageType ; returns base stylesheet, plus extra stylesheet for particular page type,
# can be called without parameter
# sub GetPageStylesheet {
# sub GetPageCss {
	if (GetConfig('setting/css/enable')) {
		# ok
	} else {
		# css feature is disabled
		WriteLog('GetHeaderStylesheet: warning: css/enable was FALSE; caller = ' . join(',', caller));
		return '';
	}
	state $baseStylesheet = GetStylesheet();

	my $pageType = shift;
	#todo sanity
	if (!$pageType) {
		$pageType = '';
	}
	chomp $pageType;

	WriteLog('GetHeaderStylesheet: $pageType = ' . $pageType);

	if ($pageType) {
		$baseStylesheet . "\n" . GetPageStylesheet($pageType);
	} else {
		return $baseStylesheet . "\n" . '/* GetHeaderStylesheet: $pageType not specified */';
	}
} # GetHeaderStylesheet()

sub GetPageStylesheet {
	my $pageType = shift;
	#todo sanity
	if (!$pageType) {
		$pageType = '';
	}
	chomp $pageType;

	WriteLog('GetPageStylesheet: $pageType = ' . $pageType);

	if ($pageType) {
		#todo multiple page types
		if (GetTemplate("css/page/$pageType.css")) {
			return GetTemplate("css/page/$pageType.css");
#            return '/* GetPageStylesheet: adding stylesheet below: */' . "\n" . GetTemplate("css/page/$pageType.css");
		} else {
			return '/* GetPageStylesheet: ' . "$pageType.css" . ' not found */';
		}
	} else {
		return '/* GetPageStylesheet: $pageType not specified */';
	}
} # GetPageStylesheet()

sub GetBaseStylesheet {
    #todo is this used anywhere?
	return GetStylesheet();
}

sub GetStylesheet { # ; returns common stylesheet template based on config
# uses $styleSheet as memo
# sub GetCss {
# sub GetCommonStylesheet {
	state $styleSheet;
	if ($styleSheet) {
		return $styleSheet;
	}

	WriteLog('GetStylesheet(); caller = ' . join(',', caller));

	my $style = GetTemplate('css/default.css');
	# baseline style

	if (GetConfig('html/avatar_icons')) {
		$style .= "\n" . GetTemplate('css/avatar.css');
		# add style for color avatars if that's the setting
	}

	if (GetConfig('admin/js/dragging') || GetConfig('html/css_inline_block')) {
		$style .= "\n" . GetTemplate('css/dragging.css');
		$style .= "\n" . GetTemplate('css/width.css');
	}

	if (GetConfig('html/css_inbox_top')) {
		$style .= "\n" . GetTemplate('css/inbox_top.css');
	}

	if (GetConfig('html/css_shimmer')) {
		$style .= "\n" . GetTemplate('css/shimmer.css');
	}

	if (GetThemeAttribute('additional.css')) {
		$style .= "\n" . GetThemeAttribute('additional.css'); # may concatenate styles from all applied themes!
	}

	if (1) {
		#todo unhardcode this
		$style .= "\n" . GetTemplate('css/pre_time_sans.css');
	}

	$styleSheet = $style;

	return $styleSheet;
} # GetStylesheet()

1;
