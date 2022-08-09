#!/usr/bin/perl -T

# set.pl basic
# lets you set config values to 0 or 1
# #todo:
#  read from defaults if missing in config
#  allow values other than 0 or 1
#  allow setting multiple values at once

use strict;
use warnings;
use 5.010;

$ENV{PATH}="/bin:/usr/bin"; #this is needed for -T to work

my $argumentKey = shift;

if ($argumentKey && $argumentKey =~ m/^([0-9a-zA-Z_\/-]+)$/) {
	my $argumentKeySanitized = $1;
	my $setting = `find config/setting | grep $argumentKeySanitized`;
	#print "$argumentKeySanitized\n";
	my @settingArray = split("\n", $setting);
	#print "$setting\n";
	#print scalar(@settingArray) . "\n";
	if (scalar(@settingArray) == 1) {
		my $settingKey = $settingArray[0];
		#only one found

		my $argumentValue = shift;
		if (defined($argumentValue) && ($argumentValue || ($argumentValue == 0))) {
			# value specified

			#print $argumentValue . "\n";
			chomp $argumentValue;
			#print "cool\n";
			if ($argumentValue =~ m/^([0-1])$/) {
				my $argumentValueSanitized = $1;
				#print "$argumentValueSanitized\n";
				#print "$argumentKeySanitized=$argumentValueSanitized";
				print "echo $argumentValueSanitized > $settingKey\n";
				if ($settingKey =~ m/^([0-9a-zA-Z_\/-]+)$/) {
					my $settingKeySanitized = $1;
					`echo $argumentValueSanitized > $settingKeySanitized`;
				}
			}
		} else {
			chomp $settingKey;
			print "$argumentKeySanitized=$settingKey\n";
		}
	} else {
		# search results
		foreach my $settingKey (@settingArray) {
			if ($settingKey =~ m/^([0-9a-zA-Z_\/-]+)$/) {
				my $settingKeySanitized = $1;
				if (-f $settingKeySanitized) {
					print "$settingKey = ";
					my $settingValue = `cat $settingKeySanitized`;
					chomp $settingValue;
					if (index($settingValue, "\n") != -1) {
						$settingValue =~ s/\n/, /g;
						#$settingValue = str_replace("\n", ' / ', $settingValue);
					}
					print $settingValue;
					print "\n";
				}
			}
		}
	}
} else {
	#print "ay\n";
}

1;
