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
	my $setting = `find config | grep $argumentKeySanitized`;
	#print "$argumentKeySanitized\n";
	my @settingArray = split("\n", $setting);
	#print "$setting\n";
	#print scalar(@settingArray) . "\n";
	if (scalar(@settingArray) == 1) {
		my $argumentValue = shift;
		if (defined($argumentValue) && ($argumentValue || ($argumentValue == 0))) {
			#print $argumentValue . "\n";
			chomp $argumentValue;
			chomp $setting;
			#print "cool\n";
			if ($argumentValue =~ m/^([0-1])$/) {
				my $argumentValueSanitized = $1;
				#print "$argumentValueSanitized\n";
				#print "$argumentKeySanitized=$argumentValueSanitized";
				print "$argumentKeySanitized=$setting=$argumentValueSanitized\n";
			}
		} else {
			#print "uncool\n";
		}
	}
} else {
	#print "ay\n";
}

1;
