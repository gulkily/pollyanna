#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetStatsTable { # $templateName = 'html/stats.template' ; returns Stats dialog (without dialog frame if template is not default value)
# sub GetStatsDialog {
#note this can take a while to warm up first time, because lots of sql count() and group by such
	my $templateName = shift;
	if (!$templateName) {
		$templateName = 'html/stats.template'; # GetStatsTable()
	}

	my $timeBegin = time();
	WriteLog('GetStatsTable() BEGIN');

	state $itemsIndexed;
	if (!$itemsIndexed && (!defined($itemsIndexed))) {
		$itemsIndexed = DBGetItemCount(); # SqliteGetCount('compost')
	}

	state $threadsCount;
	if (!$threadsCount && (!defined($threadsCount))) {
		$threadsCount = DBGetCount('threads');
	}

	state $imagesCount;
	if (!$imagesCount && (!defined($imagesCount))) {
		$imagesCount = DBGetCount('image');
	}

	state $authorCount;
	if (!$authorCount && (!defined($authorCount))) {
		$authorCount = DBGetCount('authors');
	}

	state $peopleCount;
	if (!$peopleCount && (!defined($peopleCount))) {
		$peopleCount = DBGetCount('people');
	}

	state $itemsDeleted;
	if (!$itemsDeleted && (!defined($itemsDeleted))) {
		$itemsDeleted = DBGetCount('deleted');
	}

	# my $adminId = GetRootAdminKey();
	# my $adminUsername = GetAlias($adminId);
	# my $adminLink = GetAuthorLink($adminId);

	# my $adminId = '';#GetRootAdminKey();
	my $adminId = DBGetAdminKey(); # returns highest scoring

	my $adminUsername = '';
	my $adminLink = '';
	if ($adminId) {
		$adminUsername = GetAlias($adminId);
		$adminLink = GetAuthorLink($adminId);
	}

	my $serverId = ''; #GetServerKey();
	my $serverLink = '';
	if ($serverId) {
		$serverLink = GetAuthorLink($serverId);
	}

	my $versionFull = GetMyVersion();
	my $versionSuccinct = substr($versionFull, 0, 7);
	my $versionSequence = `git log --oneline | wc -l`; #todo don't shell

	UpdateUpdateTime();
	my $lastUpdateTime = GetCache('system/last_update_time');
	$lastUpdateTime = GetTimestampWidget($lastUpdateTime);

	my $lastBuildTime = GetConfig('admin/build_end');
	if (!defined($lastBuildTime) || !$lastBuildTime) {
		$lastBuildTime = 0;
	}

	###

	my $statsTable = GetTemplate($templateName);

	if ($adminId) {
		if ($adminUsername eq 'Operator' && $templateName eq 'html/stats-horizontal.template') {
			# harmless hack
			$statsTable =~ s/\<span class=beginner>Operator: <\/span>\$admin/$adminLink/;
		} else {
			$statsTable =~ s/\$admin/$adminLink/;
		}
	} else {
		$statsTable =~ s/\$admin/*/;
	}

	if (!defined($lastUpdateTime) || !$lastUpdateTime) {
		$lastUpdateTime = 0;
	}

	$statsTable =~ s/\$lastUpdateTime/$lastUpdateTime/;

	# count total number of files
	#
	my $filesTotal = 0;
	WriteLog('GetStatsTable: $filesTotal = 0');
	state $TXTDIR = GetDir('txt');
	if ($TXTDIR =~ m/^([^\s]+)$/) { #security #taint
		$TXTDIR = $1;
		my $findResult = `find $TXTDIR -name \\\*.txt | wc -l`; #todo get rid of this, #performance
		if ($findResult =~ m/(.+)/) { #todo add actual check of some kind
			$findResult = $1;
			my $filesTxt = trim($findResult); #todo cache GetCache('count_txt')
			PutCache('count_txt', $filesTxt);
			WriteLog('GetStatsTable: $filesTotal (' . $filesTotal . ') += $filesTxt (' . $filesTxt . ');');
			$filesTotal += $filesTxt;
		}
	} else {
		WriteLog('GetStatsTable: warning: sanity check failed: $TXTDIR contains space');
	}
	if (GetConfig('admin/image/enable')) {
		state $IMAGEDIR = GetDir('image');
		if ($IMAGEDIR =~ m/^([^\s]+)$/) { #security #taint
			$IMAGEDIR = $1;

			#imagetypes
			my @imageTypes = GetConfigValueAsArray('setting/admin/image/allow_files');
			#my @imageTypes = qw(png jpg jpeg gif bmp jfif webp svg);
			my $findParam = '';
			for my $imageType (@imageTypes) {
				if ($imageType =~ m/([a-z]+)/) {
					$imageType = $1;
					$findParam .= ($findParam ? ' -o' : '') . " -name \\\*.$imageType";
				}
				else {
					WriteLog('GetStatsTable: warning: $imageType sanity check failed while building $findParam');
				}
			}

			my $imagesFindResultsCommand = "find $IMAGEDIR $findParam | wc -l";

			my $imagesFindResults = `$imagesFindResultsCommand`;
			chomp $imagesFindResults;
			if ($imagesFindResults =~ m/^[0-9]+$/) {
				my $filesImage =  GetCache('count_image') || trim($imagesFindResults);
				PutCache('count_image', $filesImage);
				WriteLog('GetStatsTable: $filesTotal (' . $filesTotal . ') += $filesImage (' . $filesImage . ');');
				$filesTotal += $filesImage;
			} else {
				WriteLog('GetStatsTable: warning: sanity check failed getting image count');
			}
		} else {
			WriteLog('GetStatsTable: warning: sanity check failed: $IMAGEDIR contains space');
		}
	}
	#
	# finished counting files

	my $chainLogLength = 0;
	if (GetConfig('admin/logging/write_chain_log')) {
		#$chainLogLength = `wc -l html/chain.log`;
		$chainLogLength = SqliteGetValue('chain_length');
		#todo make sqlite optional
		#todo templatize query
		#todo move to sqlite.pl
	}

	my $checkEngineStatus = GetConfig('setting/admin/check_engine_status');

	#if (abs($itemsIndexed - $filesTotal) > 3) { # GetStatsTable() -- Check Engine indicator
	if ($checkEngineStatus) {
		if (!-e GetDir('html') .'/'. 'engine.html') {
			WriteLog('GetStatsTable: warning: engine.html does not exist');
			PutHtmlFile('engine.html', '<h1>Check Engine indicator is on.</h1><p>Please check the logs.</p>');
		}
		if (GetConfig('html/mourn') || GetConfig('html/monochrome')) {
			$statsTable = str_replace(
				'<p id=diagnostics></p>',
				'<p id=diagnostics><a href="/engine.html"><b>Check engine!</b></a></p>',
				$statsTable
			);
		} else {
			$statsTable = str_replace(
				'<p id=diagnostics></p>',
				'<p id=diagnostics><a href="/engine.html"><b><font color=orange style="padding: 2pt; border-radius: 3pt; border: inset 1pt #606060; background-color: #404040;">Check engine!</font></b></a></p>',
				$statsTable
			);
		}
	}

	#my $tagsTotal = DBGetTagCount();
	my $tagsTotal = DBGetCount('tags');
	if (!$tagsTotal) {
		WriteLog('GetStatsTable: warning: $tagsTotal was FALSE');
		$tagsTotal = 0;
	}

	my $labelsTotal = DBGetCount('labels');
	if (!$labelsTotal) {
		WriteLog('GetStatsTable: warning: $labelsTotal was FALSE');
		$labelsTotal = 0;
	}

	#my $newLength = SqliteGetValue('SELECT COUNT(file_hash) FROM item_flat WHERE item_score >= 0');
	my $newLength = DBGetCount('new');
	if (!$newLength) {
		$newLength = 0;
	}

	my $urlLength = DBGetCount('url');

	#todo optimize
	#todo config/setting/admin/upload/allow_files

	$lastBuildTime = GetTimestampWidget($lastBuildTime);
	$statsTable =~ s/\$lastBuildTime/$lastBuildTime/;

	$statsTable =~ s/\$tagsTotal/$tagsTotal/;
	$statsTable =~ s/\$labelsTotal/$labelsTotal/;
	$statsTable =~ s/\$versionFull/$versionFull/;
	$statsTable =~ s/\$versionSuccinct/$versionSuccinct/;
	$statsTable =~ s/\$versionSequence/$versionSequence/;
	$statsTable =~ s/\$newLength/$newLength/;
	$statsTable =~ s/\$urlLength/$urlLength/;
	$statsTable =~ s/\$itemsIndexed/$itemsIndexed/;
	$statsTable =~ s/\$threadsCount/$threadsCount/;
	$statsTable =~ s/\$imagesCount/$imagesCount/;
	$statsTable =~ s/\$itemsDeleted/$itemsDeleted/;
	$statsTable =~ s/\$authorCount/$authorCount/;
	$statsTable =~ s/\$peopleCount/$peopleCount/;
	$statsTable =~ s/\$filesTotal/$filesTotal/;
	$statsTable =~ s/\$chainLogLength/$chainLogLength/;

	if ($templateName eq 'html/stats.template') { # GetStatsTable() conditional
		$statsTable = GetDialogX($statsTable, 'Status');
		#todo remove this once other template is fixed #???
	}

	WriteLog('GetStatsTable() FINISHED in ' . (time()-$timeBegin) . '. length($statsTable) = ' . length($statsTable));
	return $statsTable;
} # GetStatsTable()

1;
