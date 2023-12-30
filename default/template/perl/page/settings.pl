#!/usr/bin/perl -T

use strict;
use warnings;

sub GetSettingsPage { # returns html for settings page (/settings.html)
	my $txtIndex = "";

	$txtIndex = GetPageHeader('settings');
	$txtIndex .= GetTemplate('html/maincontent.template');

	require_once('dialog/content_filter.pl');

	$txtIndex .= GetAccessDialog();

	#if (GetConfig('setting/admin/logging/write_chain_log')) {
	#	$txtIndex .= GetChainLogAsDialog();
	#}

	#$txtIndex .= GetQueryAsDialog('authors', 'Authors');
	#$txtIndex .= GetQueryAsDialog('threads', 'Threads');

	#$txtIndex .= GetQueryAsDialog('admin_list', 'Operators');

	if (GetConfig('setting/admin/js/enable')) {
		$txtIndex .= GetSettingsDialog();
	}

	# $txtIndex .= GetStatsTable();  # GetSettingsPage()

	#frontend:
	my @settingsVisible1 = qw(
		theme
		html/clock
		html/clock_format
		html/css/inline_block
		html/css/shimmer
		admin/js/enable
		admin/js/debug
		admin/js/dragging
		admin/js/translit
		admin/js/fresh
		admin/js/table_sort
	);

	#backend:
	my @settingsVisible2 = qw(
		current_version
		admin/http_auth/enable
		admin/gpg/enable
		admin/gpg/use_gpg2
		admin/php/enable
		admin/php/debug
		admin/php/route_notify_printed_time
		admin/php/post/index_file_on_post
		admin/php/post/use_return_to
		admin/php/footer_stats
	);

	#zip module:
	my @settingsVisible3 = qw(
		admin/zip/enable
		zip/tag
		zip/label
		zip/author
		zip/person
		zip/image
	);

	#debuggers:
	my @settingsDebugger = qw(
		config/debug
		config/setting/admin/js/debug
		config/setting/admin/php/debug
		config/setting/admin/html/debug
		config/setting/admin/perl/debug
	);

	require_once('dialog/server_config.pl');

	$txtIndex .= GetServerConfigDialog('Frontend', @settingsVisible1); # >frontend< #for searches
	$txtIndex .= GetServerConfigDialog('Backend', @settingsVisible2); # >backend< #for searches
	$txtIndex .= GetServerConfigDialog('ZipFiles', @settingsVisible3); # >zip< >archiving< #for searches
	$txtIndex .= GetServerConfigDialog('Debug', @settingsDebugger); # debug 'debug' >debug<
	$txtIndex .= GetContentFilterDialog();

	#todo add dialog for voting options
	#add option to use a "cart" for voting, submitting all the labels at once
	#this would require some server-side additions too, unless we use the old-style pipe-separated syntax

	if (GetConfig('setting/admin/js/enable')) {
		$txtIndex .= GetDialogX(GetTemplate('html/form/writing.template'), 'Writing'); # write_settings
	}

	$txtIndex .= GetOperatorDialog();

	$txtIndex .= '<span class=admin>' . GetDialogX('<form action=/post.html><input type=hidden name=comment value=1><span class=advanced><input type=checkbox name=chkUpgrade></span><input type=submit name=btnUpgrade value=Upgrade></form>', 'Developer') . '</span>';

	if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
		# $txtIndex .= '<span class=advanced>' . GetDialogX(GetTemplate('html/form/annoyances.template'), 'Annoyances') . '</span>';
		$txtIndex .= GetDialogX(GetTemplate('html/form/annoyances.template'), 'Annoyances');
	}
	#$txtIndex .= GetMenuTemplate();

	$txtIndex .= GetPageFooter('settings');

	if (GetConfig('setting/admin/js/enable')) {
		$txtIndex = InjectJs($txtIndex, qw(settings avatar profile timestamp pingback utils clock));
	}

	return $txtIndex;
} # GetSettingsPage()

1;
