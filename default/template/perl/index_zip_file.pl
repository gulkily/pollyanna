#!usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub IndexZipFile { # $file | 'flush' ; indexes one text file into database
# sub IndexZip {
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
		WriteLog('IndexZipFile: warning: $file failed sanity check; $file = ' . $file);
		return '';
	}

	WriteLog('IndexZipFile: $file = ' . $file);

	my $itemName = TrimPath($file);
	my $fileHash = GetFileHash($file);

	if (IsFileDeleted($file, $fileHash)) {
		# write to log
		WriteLog('IndexZipFile: IsFileDeleted() returned true, returning');
		return 0;
	}

	DBAddItem($file, $itemName, '', $fileHash, 'zip', 0);
	DBAddVoteRecord($fileHash, 0, 'zip');

	my $unzipCommand = "unzip -o $file '*.txt' -d $TXTDIR 2>&1";
	WriteLog('IndexCppFile: $unzipCommand = ' . $unzipCommand);
	#
	# my $compileStart = time();
	my $unzipLog = `$unzipCommand`;
	# my $compileFinish = time();
	#
	# DBAddItemAttribute($fileHash, 'compile_start', $compileStart);
	# DBAddItemAttribute($fileHash, 'compile_finish', $compileFinish);

	# my $compileLog = `g++ -v $file -o $file.out 2>&1`;
	if ($unzipCommand) {
		PutCache('compile_log/' . $fileHash, $unzipLog); # parse_log parse.log ParseLog
	}

	my $addedTime = DBGetAddedTime($fileHash);

	# debug output
	WriteLog('IndexZipFile: $file = ' . ($file?$file:'false'));
	WriteLog('IndexZipFile: $fileHash = ' . ($fileHash?$fileHash:'false'));
	WriteLog('IndexZipFile: $addedTime = ' . ($addedTime?$addedTime:'false'));

	if (!$addedTime) {
		WriteLog('IndexZipFile: file missing $addedTime');
		if (GetConfig('admin/logging/write_chain_log')) {
			$addedTime = AddToChainLog($fileHash);
		} else {
			$addedTime = GetTime();
		}
		if (!$addedTime) {
			# sanity check
			WriteLog('IndexZipFile: warning: sanity check failed for $addedTime');
			$addedTime = GetTime();
		}
	}

	if ($unzipLog) {
		my $filesList = $unzipLog;
		$filesList =~ s/[\s]+/ /g; # replace all consecutive whitespace characters with one space
		my @outputTokens = split(' ', $filesList); # get list of all things in the output
		for my $token (@outputTokens) {
			if ($token =~ m/\.txt$/ && file_exists($token)) {
				WriteLog('IndexZipFile: calling IndexFile(' . $token . ')');
				my $resultHash = IndexFile($token);
			}
		}
	}

	return 1;
} # IndexCppFile()


1;
