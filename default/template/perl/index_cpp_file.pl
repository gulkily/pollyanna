#!usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub RunItem {
# sub RunFile {
# sub RunCppFile {
	my $item = shift;

	WriteLog("RunItem($item)");

	my $runLog = 'run_log/' . $item;

	my $filePath = DBGetItemFilePath($item);
	my $fileBinaryPath = $filePath . '.out';

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
			WriteLog('RunItem: warning: $fileBinaryPath failed sanity check');
			return '';
		}
	} else {
		PutCache($runLog, 'error: run failed, file not found: ' . $fileBinaryPath);
		return 1;
	}
} # RunItem()


sub IndexCppFile { # $file | 'flush' ; indexes one text file into database
# sub IndexCpp {
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
		WriteLog('IndexCppFile: flush');
		return 1;
	}

	if ($file =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
		$file = $1;
	} else {
		WriteLog('IndexCppFile: warning: $file failed sanity check; $file = ' . $file);
		return '';
	}

	WriteLog('IndexCppFile: $file = ' . $file);

	my $itemName = TrimPath($file);
	my $fileHash = GetFileHash($file);

	DBAddItem($file, $itemName, '', $fileHash, 'cpp', 0);
	DBAddVoteRecord($fileHash, 0, 'cpp');

	# my $compileLog = `gcc -v $file -o $file.out 2>&1`;
	my $compileCommand = "g++ -v $file -o $file.out 2>&1";
	WriteLog('IndexCppFile: $compileCommand = ' . $compileCommand);

	my $compileStart = time();
	my $compileLog = `$compileCommand`;
	my $compileFinish = time();

	DBAddItemAttribute($fileHash, 'compile_start', $compileStart);
	DBAddItemAttribute($fileHash, 'compile_finish', $compileFinish);

	# my $compileLog = `g++ -v $file -o $file.out 2>&1`;
	if ($compileLog) {
		PutCache('compile_log/' . $fileHash, $compileLog); # parse_log parse.log ParseLog
	}

	my $addedTime = DBGetAddedTime($fileHash);

	# debug output
	WriteLog('IndexCppFile: $file = ' . ($file?$file:'false'));
	WriteLog('IndexCppFile: $fileHash = ' . ($fileHash?$fileHash:'false'));
	WriteLog('IndexCppFile: $addedTime = ' . ($addedTime?$addedTime:'false'));

	if (IsFileDeleted($file, $fileHash)) {
		# write to log
		WriteLog('IndexCppFile: IsFileDeleted() returned true, returning');
		return 0;
	}

	if (!$addedTime) {
		WriteLog('IndexCppFile: file missing $addedTime');
		if (GetConfig('admin/logging/write_chain_log')) {
			$addedTime = AddToChainLog($fileHash);
		} else {
			$addedTime = GetTime();
		}
		if (!$addedTime) {
			# sanity check
			WriteLog('IndexCppFile: warning: sanity check failed for $addedTime');
			$addedTime = GetTime();
		}
	}

	return 1;
} # IndexCppFile()


1;
