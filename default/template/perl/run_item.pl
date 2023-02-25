#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub RunItem {
	# sub RunFile {
	# sub RunCppFile {
	# sub RunPyFile {
	# sub RunPerlFile {
	my $item = shift;
	WriteLog("RunItem($item)");

	my $runLog = 'run_log/' . $item;

	my $filePath = DBGetItemFilePath($item);
	my $itemType = DBGetItemType($item);
	#todo optimize this to reduce database queries

	WriteLog('RunItem: $filePath = ' . $filePath . '; $itemType = ' . $itemType);

	if ($itemType eq 'perl') {
		if (-e $filePath) {
			if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
				$filePath = $1;
				`chmod +x $filePath`;
				my $runStart = time();
				my $result = `perl $filePath`;
				my $runFinish = time();

				DBAddItemAttribute($item, 'perl_run_start', $runStart);
				DBAddItemAttribute($item, 'perl_run_finish', $runFinish);

				PutCache($runLog, $result);
				return 1;
			}
		}
	}

	if ($itemType eq 'py') {
		if (-e $filePath) {
			if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
				$filePath = $1;
				`chmod +x $filePath`;
				my $runStart = time();
				my $result = `python $filePath`;
				my $runFinish = time();

					DBAddItemAttribute($item, 'python_run_start', $runStart);
					DBAddItemAttribute($item, 'python_run_finish', $runFinish);

				PutCache($runLog, $result);
				return 1;
			}
		}
	}

	if ($itemType eq 'cpp') {
		my $fileBinaryPath = $filePath . '.out';

		if (-e $fileBinaryPath) {
			if ($fileBinaryPath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
				$fileBinaryPath = $1;
				`chmod +x $fileBinaryPath`;
				my $runStart = time();
				my $result = `$fileBinaryPath`;
				my $runFinish = time();

				DBAddItemAttribute($item, 'cpp_run_start', $runStart);
				DBAddItemAttribute($item, 'cpp_run_finish', $runFinish);

				PutCache($runLog, $result);
				return 1;
			} else {
				WriteLog('RunItem: cpp: warning: $fileBinaryPath failed sanity check');
				return '';
			}
		} # if (-e $fileBinaryPath)
		else {
			PutCache($runLog, 'error: run failed, file not found: ' . $fileBinaryPath);
			return 1;
		}
	} # if ($itemType eq 'cpp')
} # RunItem()

1;