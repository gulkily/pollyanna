#!/usr/bin/perl -T
#
print "Please use this script with caution.\n";
exit;

use strict;
use warnings;
use 5.010;

require './utils.pl';

my @files = `ls -1 archive/*.tar.gz`;

my $filesNeededCount = 0;

print "Counting files...\n";

for my $file (@files) {
	chomp $file;
	if ($file =~ m/([\S]+)/) { #todo more sanity
		$file = $1;
		my @filesListed = `tar --list -f $file`;
		my $filesNeeded = '';
		for my $fileListed (@filesListed) {
			chomp $fileListed;
			if ($fileListed =~ m/([\S]+)/) { #todo more sanity
				$fileListed = $1;
				#say $fileListed;
				if ($fileListed =~ m/.txt$/) {
					if (!-e $fileListed) {
						$filesNeeded = $filesNeeded . ' ' . $fileListed;
						if (length($filesNeeded) > 10000) {
							#say `tar -vzxf $file $filesNeeded`;
							#say `cat $filesNeeded`;
							$filesNeededCount++;
							#$filesNeeded = '';
						}
					}
				}
			}
		}
		#say `tar -vzxf $file $filesNeeded`;
	} else {
		#todo warning
	}
}

print 'Files found: ' . $filesNeededCount . "\n";

sleep 1;

#todo cd `html/txt`;

if (!$filesNeededCount) {
	exit;
}

my $filesDone = 0;

for my $file (@files) {
	chomp $file;
	if ($file =~ m/([\S]+)/) { #todo more sanity
		$file = $1;
		my @filesListed = `tar --list -f $file`;
		my $filesNeeded = '';
		for my $fileListed (@filesListed) {
			chomp $fileListed;
			if ($fileListed =~ m/([\S]+)/) { #todo more sanity
				$fileListed = $1;
				#say $fileListed;
				if ($fileListed =~ m/.txt$/) {
					if (!-e $fileListed) {
						$filesDone++;
						$filesNeeded = $filesNeeded . ' ' . $fileListed;
						if (length($filesNeeded) > 10000) {
							`tar -vzxf $file $filesNeeded`;
							$filesNeeded = '';
							print ".";
							sleep 1;
						}
					}
					#say $fileListed;
#					my $fileTarSaid = `tar -vzxf $file $fileListed`;
#					chomp $fileTarSaid;
#					if ($fileTarSaid) {
#						if ($fileTarSaid eq $fileListed) {
#							say 'done';
#						} else {
#							say 'hey';
#						}
#					}
				}
			}
		}
							say `tar -vzxf $file $filesNeeded`;
							$filesNeeded = '';
	} else {
		#todo warning
	}
}

# inflate all .tar.gz files
#
# move all text files into html/txt

1;
