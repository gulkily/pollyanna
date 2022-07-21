#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;


sub GetStatsTable { # returns Stats dialog (without dialog frame)
#note this can take a while to warm up first time, because lots of sql count() and group by such
	my $templateName = shift;
	if (!$templateName) {
		$templateName = 'html/stats.template'; # GetStatsTable()
	}

	my $timeBegin = time();
	WriteLog('GetStatsTable() BEGIN');

	state $itemsIndexed;
	if (!$itemsIndexed && (!defined($itemsIndexed) || $itemsIndexed != 0)) {
		# a bit of a mess, should be refactored #todo
		$itemsIndexed = DBGetItemCount();
		if ($itemsIndexed == -1) {
			$itemsIndexed = 0;
		}
	}

	state $threadsCount;
	if (!$threadsCount && (!defined($threadsCount) || $threadsCount != 0)) {
		#$threadsCount = SqliteGetValue('threads');
		$threadsCount = SqliteGetValue('SELECT COUNT(file_hash) FROM item_flat WHERE parent_count = 0 AND child_count > 0 AND item_score >= 0');
	}

	my $imagesCount = SqliteGetValue("select count(*) from item_flat where tags_list like '%image%'");

	my $authorCount = DBGetAuthorCount();

	state $itemsDeleted;
	if (!$itemsDeleted) {
		my @result = SqliteQueryHashRef('deleted');
		$itemsDeleted = (scalar(@result) - 1); #minus 1 because first row is headers
		#todo optimize
	}

#	my $adminId = GetRootAdminKey();
#	my $adminUsername = GetAlias($adminId);
#	my $adminLink = GetAuthorLink($adminId);

	#my $adminId = '';#GetRootAdminKey();
	my $adminId = DBGetAdminKey(); # returns highest scoring

	my $adminUsername = GetAlias($adminId);
	my $adminLink = GetAuthorLink($adminId);

	my $serverId = '';#GetServerKey();
	my $serverLink = GetAuthorLink($serverId);

	my $versionFull = GetMyVersion();
	my $versionSuccinct = substr($versionFull, 0, 8);

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
	#
	# finished counting files

	if (GetConfig('admin/image/enable')) {
		state $IMAGEDIR = GetDir('image');
		if ($IMAGEDIR =~ m/^([^\s]+)$/) { #security #taint
			$IMAGEDIR = $1;
			my $imagesFindResults = `find $IMAGEDIR -name \\\*.png -o -name \\\*.jpg -o -name \\\*.jpeg -o -name \\\*.gif -o -name \\\*.bmp -o -name \\\*.jfif -o -name \\\*.webp -o -name \\\*.svg | wc -l`;
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

	my $chainLogLength = 0;
	if (GetConfig('admin/logging/write_chain_log')) {
		#$chainLogLength = `wc -l html/chain.log`;
		$chainLogLength = SqliteGetValue('chain_length');
		#todo make sqlite optional
		#todo templatize query
		#todo move to sqlite.pl
	}

	if (!GetConfig('html/mourn') && abs($itemsIndexed - $filesTotal) > 3) { # GetStatsTable() -- Check Engine indicator
		$statsTable = str_replace(
			'<p id=diagnostics></p>',
			'<p id=diagnostics><a href="/engine.html"><b><font color=orange style="padding: 2pt; border-radius: 3pt; border: inset 1pt #606060; background-color: #404040;">Check engine!</font></b></a></p>',
			$statsTable
		);
	}

	my $tagsTotal = DBGetTagCount();
	if (!$tagsTotal) {
		WriteLog('GetStatsTable: warning: $tagsTotal was false');
		$tagsTotal = 0;
	}

	#todo optimize
	#todo config/setting/admin/upload/allow_files

	$lastBuildTime = GetTimestampWidget($lastBuildTime);
	$statsTable =~ s/\$lastBuildTime/$lastBuildTime/;

	$statsTable =~ s/\$tagsTotal/$tagsTotal/;
	$statsTable =~ s/\$versionFull/$versionFull/;
	$statsTable =~ s/\$versionSuccinct/$versionSuccinct/;
	$statsTable =~ s/\$versionSequence/$versionSequence/;
	$statsTable =~ s/\$itemsIndexed/$itemsIndexed/;
	$statsTable =~ s/\$threadsCount/$threadsCount/;
	$statsTable =~ s/\$imagesCount/$imagesCount/;
	$statsTable =~ s/\$itemsDeleted/$itemsDeleted/;
	$statsTable =~ s/\$authorCount/$authorCount/;
	$statsTable =~ s/\$filesTotal/$filesTotal/;
	$statsTable =~ s/\$chainLogLength/$chainLogLength/;

	if ($templateName eq 'html/stats.template') { # GetStatsTable() conditional
		$statsTable = GetWindowTemplate($statsTable, 'Status');
		#todo remove this once other template is fixed #???
	}

	WriteLog('GetStatsTable() FINISHED in ' . (time()-$timeBegin) . '. length($statsTable) = ' . length($statsTable));
	return $statsTable;
} # GetStatsTable()

1;
