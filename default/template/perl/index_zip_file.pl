#!usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

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
	state $IMAGEDIR = GetDir('image');

	my $file = shift;
	chomp($file);

	#todo sanity

	if ($file eq 'flush') {
		DBAddItem('flush');
		DBGetAddedTime('flush');
		DBAddVoteRecord('flush');
		DBAddItemAttribute('flush');
		WriteLog('IndexZipFile: flush');
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

	my $unzipStart = time();
	my $unzipLog = '';

	if (GetConfig('setting/admin/image/enable')) {
		#image files
		my $unzipCommand = "unzip -o $file '*.jpg' '*.jpeg' '*.gif' '*.bmp' '*.jfif' '*.webp' '*.svg' -d $IMAGEDIR 2>&1";
		WriteLog('IndexZipFile: $unzipCommand = ' . $unzipCommand);
		$unzipLog .= `$unzipCommand` . "\n";
		#imagetypes
	}

	if (1) {
		#text files only
		my $unzipCommand = "unzip -o $file '*.txt' -d $TXTDIR 2>&1";
		WriteLog('IndexZipFile: $unzipCommand = ' . $unzipCommand);
		$unzipLog .= `$unzipCommand` . "\n";
	}

	my $unzipFinish = time();

	DBAddItemAttribute($fileHash, 'unzip_start', $unzipStart);
	DBAddItemAttribute($fileHash, 'unzip_finish', $unzipFinish);

	if ($unzipLog) {
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
		WriteLog('IndexZipFile: $unzipLog is TRUE, looking for files to index...');

		my $indexStart = time();

		my $filesIndexed = 0;

		my $filesList = $unzipLog;
		$filesList =~ s/[\s]+/ /g; # replace all consecutive whitespace characters with one space
		my @outputTokens = split(' ', $filesList); # get list of all things in the output

		for my $token (@outputTokens) {
			if ($token =~ m/\.txt$/ && file_exists($token)) {
				WriteLog('IndexZipFile: calling IndexFile(' . $token . ')');
				my $resultHash = IndexFile($token);
				if ($resultHash) {
					$filesIndexed++;
				}
			}
		}

		WriteLog('IndexZipFile: $filesIndexed = ' . $filesIndexed);

		my $indexFinish = time();

		DBAddItemAttribute($fileHash, 'index_start', $indexStart);
		DBAddItemAttribute($fileHash, 'index_finish', $indexFinish);

		DBAddItemAttribute($fileHash, 'files_indexed', $filesIndexed);

	}

	return 1;
} # IndexZipFile()

1;
