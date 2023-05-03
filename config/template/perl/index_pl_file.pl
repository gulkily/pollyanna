#!usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub RunPerlItem {
# sub RunFile {
# sub RunPerlFile {
	my $item = shift;

	WriteLog("RunPerlItem($item)");

	my $runLog = 'run_log/' . $item;

	my $filePath = DBGetItemFilePath($item);
	my $fileBinaryPath = $filePath;
	#my $fileBinaryPath = $filePath . '.out';

	if (-e $fileBinaryPath) {
		if ($fileBinaryPath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
			$fileBinaryPath = $1;
			`chmod +x $fileBinaryPath`;
			my $runStart = time();
			my $result = `$fileBinaryPath`;
			my $runFinish = time();

			DBAddItemAttribute($item, 'run_start', $runStart);
			DBAddItemAttribute($item, 'run_finish', $runFinish);

			PutCache($runLog, $result);
			return 1;
		} else {
			WriteLog('RunPerlItem: warning: $fileBinaryPath failed sanity check');
			return '';
		}
	} else {
		PutCache($runLog, 'error: run failed, file not found: ' . $fileBinaryPath);
		return 1;
	}
} # RunPerlItem()


sub IndexPerlFile { # $file | 'flush' ; indexes one text file into database
# sub IndexPerl {
# sub IndexPlFile {
# DRAFT
# DRAFT
# DRAFT
# DRAFT
# DRAFT
	state $SCRIPTDIR = GetDir('script');
	state $HTMLDIR = GetDir('html');
	state $TXTDIR = GetDir('txt');

	my $file = shift;
	chomp($file);

	#todo sanity

	if ($file eq 'flush') {
		DBAddItem('flush');
		DBGetAddedTime('flush');
		DBAddVoteRecord('flush');
		DBAddItemAttribute('flush');
		WriteLog('IndexPerlFile: flush');
		return 1;
	}

	if ($file =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
		$file = $1;
	} else {
		WriteLog('IndexPerlFile: warning: $file failed sanity check; $file = ' . $file);
		return '';
	}

	WriteLog('IndexPerlFile: $file = ' . $file);

	my $itemName = TrimPath($file);
	my $fileHash = GetFileHash($file);

	DBAddItem($file, $itemName, '', $fileHash, 'perl', 0);
	DBAddVoteRecord($fileHash, 0, 'perl');

	if (0) {
		my $compileCommand = "perl -c $file";
		# this is actually dangerous because of begin blocks
		# which is why thise code block is disabled

		WriteLog('IndexPerlFile: $compileCommand = ' . $compileCommand);

		my $compileStart = time();
		my $compileLog = `$compileCommand`;
		my $compileFinish = time();

		DBAddItemAttribute($fileHash, 'compile_start', $compileStart);
		DBAddItemAttribute($fileHash, 'compile_finish', $compileFinish);

		if ($compileLog) {
			PutCache('compile_log/' . $fileHash, $compileLog); # parse_log parse.log ParseLog
		}
	}

	my $addedTime = DBGetAddedTime($fileHash);

	# debug output
	WriteLog('IndexPerlFile: $file = ' . ($file?$file:'false'));
	WriteLog('IndexPerlFile: $fileHash = ' . ($fileHash?$fileHash:'false'));
	WriteLog('IndexPerlFile: $addedTime = ' . ($addedTime?$addedTime:'false'));

	if (IsFileDeleted($file, $fileHash)) {
		# write to log
		WriteLog('IndexPerlFile: IsFileDeleted() returned true, returning');
		return 0;
	}

	if (!$addedTime) {
		WriteLog('IndexPerlFile: file missing $addedTime');
		if (GetConfig('admin/logging/write_chain_log')) {
			$addedTime = AddToChainLog($fileHash);
		} else {
			$addedTime = GetTime();
		}
		if (!$addedTime) {
			# sanity check
			WriteLog('IndexPerlFile: warning: sanity check failed for $addedTime');
			$addedTime = GetTime();
		}
	}

	return 1;
} # IndexPerlFile()

1;