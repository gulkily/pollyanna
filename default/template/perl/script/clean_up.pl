#!/usr/bin/perl -T

# clean up things that tend to pile up
# removes things from here which are from more than 24 hours ago:
#	cache/b/response/*
#	log/*.sqlerr

# trim log file if it's there
# 	raise warning if there is a log file being written,
#	debug mode should normally not be on
# remove old entries in cache/b/response
#
# remove old files in log/*.sqlerr
# 	raise warning if there are a lot of them

use strict;
use warnings;
use 5.010;

require('./utils.pl');

sub CleanUp {
	WriteLog('CleanUp()');

	my $cacheDir = GetDir('cache');
	my $responseDir = "$cacheDir/b/response";
	if (-d $responseDir) {
		my @files = glob("$responseDir/*");
		WriteLog("CleanUp: Found " . scalar(@files) . " response files");
		foreach my $file (@files) {
			my $age = -M $file;
			if ($age > 1) {
				WriteLog("CleanUp: Removing old response file: $file");
				if ($file = IsSaneFilename($file)) {
					unlink($file);
				} else {
					WriteLog('CleanUp: Warning: sanity check failed on $file');
				}
			}
		}
	}

	my $logDir = GetDir('log');
	my @files = glob("$logDir/*.sqlerr");
	WriteLog("CleanUp: Found " . scalar(@files) . " sqlerr files");
	if (scalar(@files) > 100) {
		WriteLog('CleanUp: Removing old sqlerr files');
		foreach my $file (@files) {
			my $age = -M $file;
			if ($age > 1) {
				WriteLog("CleanUp: Removing old sqlerr file: $file");
				if ($file = IsSaneFilename($file)) {
					unlink($file);
				} else {
					WriteLog('CleanUp: Warning: sanity check failed on $file');
				}
			}
		}
	}
} # CleanUp()

CleanUp();

1;