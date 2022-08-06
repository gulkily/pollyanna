#!/usr/bin/perl -T
#

exit;

# should reset config where defaults have changed
# for dev use

use strict;
use warnings;
use 5.010;

require('./utils.pl');
require_once('file.pl');

sub RefreshConfigTree {
	my $tree = shift;

	my $filesList = `find config/$tree`;
	my @files = split("\n", $filesList);

	for my $file (@files) {
		my $configStat = filemtime($file);

		my $defaultFile = $file;
		$defaultFile =~ s/^config/default/;

		my $defaultStat = filemtime($defaultFile);

		if ($defaultStat && ($defaultStat > $configStat)) {
			if (-f $file) {
				print "$file\n";

				if ($file =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
					$file = $1;
					#unlink($file);
					print `rm -v $file`
				}
			}
		}
	}
} # RefreshConfigTree()

RefreshConfigTree('template');
RefreshConfigTree('theme');

1;