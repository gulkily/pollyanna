#!/usr/bin/perl -T

print "this script is not yet finished\n";
exit;

use strict;
use warnings;
use 5.010;

require('./utils.pl');

sub GetNeighborsList {
	my @neighbors = GetConfigListAsArray('neighbor');
	return @neighbors;
}

sub GetNeighborFeeds {
	#todo sanity
	my @neighbors = GetConfigListAsArray('neighbor');
	print(`mkdir -v html/feed`);

	for my $neighbor (@neighbors) {
		chomp($neighbor);
		$neighbor = trim($neighbor);
		if ($neighbor =~ m/^([0-9a-z:\.]+)$/) {
			$neighbor = $1;
		} else {
			#todo
			next;
		}
		print(`mkdir -v html/feed/$neighbor`);

		#if ($neighbor =~ m/([a-zA-Z0-9:\/\.]+)) {
        if ($neighbor =~ m/([a-zA-Z0-9:\/\.]+)/) {  # Corrected the regular expression
			$neighbor = $1;
		} else {
			print('bye');
			$neighbor = '';
		}

		my $neighborFeedUrl = 'http://' . $neighbor . '/new.txt';
		print($neighborFeedUrl);
		print("\n");

		my $command = 'curl "' . $neighborFeedUrl . '" > "html/feed/' . $neighbor. '/new.txt"';
		print($command);
		print("\n");

		my $commandResult = `$command`;
		print($commandResult);
		print("\n");
	}
}

GetNeighborFeeds();

1;
