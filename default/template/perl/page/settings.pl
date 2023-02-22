#!/usr/bin/perl -T

use strict;
use warnings;

sub GetSettingsPage { # returns html for settings page (/settings.html)
	my $txtIndex = "";

	$txtIndex = GetPageHeader('settings');
	$txtIndex .= GetTemplate('html/maincontent.template');

	require_once('dialog/content_filter.pl');

	$txtIndex .= GetAccessDialog();

	#if (GetConfig('admin/logging/write_chain_log')) {
	#	$txtIndex .= GetChainLogAsDialog();
	#}

	#$txtIndex .= GetQueryAsDialog('authors', 'Authors');
	#$txtIndex .= GetQueryAsDialog('threads', 'Threads');

	#$txtIndex .= GetQueryAsDialog('admin_list', 'Operators');

	if (GetConfig('admin/js/enable')) {
		$txtIndex .= GetSettingsDialog();
	}

	$txtIndex .= GetStatsTable();  # GetSettingsPage()

	my @settingsVisible1 = qw(
		theme
		html/clock
		html/clock_format
		html/css_inline_block
		html/css_shimmer
		admin/js/enable
		admin/js/debug
		admin/js/dragging
		admin/js/translit
		admin/js/fresh
		admin/js/table_sort
	);

	my @settingsVisible2 = qw(
		current_version
		admin/http_auth/enable
		admin/gpg/enable
		admin/gpg/use_gpg2
		admin/php/enable
		admin/php/debug
		admin/php/route_notify_printed_time
		admin/php/post/use_return_to
		admin/php/footer_stats
	);

	require_once('dialog/server_config.pl');

	$txtIndex .= GetServerConfigDialog('Frontend', @settingsVisible1); # >frontend< #for searches
	$txtIndex .= GetServerConfigDialog('Backend', @settingsVisible2); # >backend< #for searches
	$txtIndex .= GetContentFilterDialog();

	if (GetConfig('admin/js/enable')) {
		$txtIndex .= GetDialogX(GetTemplate('html/form/writing.template'), 'Writing');
	}

	$txtIndex .= GetOperatorDialog();

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
		# $txtIndex .= '<span class=advanced>' . GetDialogX(GetTemplate('html/form/annoyances.template'), 'Annoyances') . '</span>';
		$txtIndex .= GetDialogX(GetTemplate('html/form/annoyances.template'), 'Annoyances');
	}
	#$txtIndex .= GetMenuTemplate();

	$txtIndex .= GetPageFooter('settings');

	if (GetConfig('admin/js/enable')) {
		$txtIndex = InjectJs($txtIndex, qw(settings avatar profile timestamp pingback utils clock));
	}

	return $txtIndex;
} # GetSettingsPage()

1;
