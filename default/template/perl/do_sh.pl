#!/usr/bin/perl -T
exit;

use strict;
require './utils.pl';
# get files which start with #!/bin/sh

#my $filesFound = `find html/txt | grep txt$`;
my @files = glob('html/txt/*');
push @files, glob('html/txt/*/*');
push @files, glob('html/txt/*/*/*');

# calculate hash

for my $file (@files) {
	print "checking $file...";

	if ($file =~ m/^(.+)$/) {
	#if ($file =~ m/^([\/.a-zA-Z0-9])$/) {
		$file = $1;
	} else {
		print 'SANITY CHECK FAILED $file = '.$file."\n";
	}

	if (-e $file && (index(GetFile($file), '#!/bin/sh') != -1)) {
		print 'SHELL SCRIPT!';
# if hash does not exist in once/hash
		my $fileHash = GetFileHash($file);
		if (-e ('once/' . $fileHash . '.log')) {
			print '... already run' . "\n";
		} else {
			print 'running...';
			system('bash ' . $file . ' > ' . 'once/'.$fileHash.'.log');
		}
	} # contains #!/bin/sh
# run with bash

# pipe results into once/hash
}
