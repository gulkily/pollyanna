#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetStylesheet { # $styleSheet ; returns stylesheet template based on config
# sub GetCss {
	state $styleSheet;
	if ($styleSheet) {
		return $styleSheet;
	}

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

	if (GetConfig('html/css_shimmer')) {
		$style .= "\n" . GetTemplate('css/shimmer.css');
	}

	if (GetThemeAttribute('additional.css')) {
		$style .= "\n" . GetThemeAttribute('additional.css'); # may concatenate styles from all applied themes!
	}

	$styleSheet = $style;

	return $styleSheet;
} # GetStylesheet()

1;
