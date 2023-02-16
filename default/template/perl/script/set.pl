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

	my $setting = `find config/setting -type f | grep \/$argumentKeySanitized\$`; # look for one which matches at both beginning and end
	if (!$setting) {
		$setting = `find config/setting -type f | grep $argumentKeySanitized\$`; # look for one which matches at the end
	}
	if (!$setting) {
		$setting = `find config/setting -type f | grep $argumentKeySanitized`; # if not, do general search
	}
	#print "$argumentKeySanitized\n";
	my @settingArray = split("\n", $setting);
	#print "$setting\n";
	#print scalar(@settingArray) . "\n";
	if (scalar(@settingArray) == 1) {
		my $settingKey = $settingArray[0];
		#ONLY ONE FOUND
		#ONLY ONE FOUND
		#ONLY ONE FOUND

		my $argumentValue = shift;
		if (defined($argumentValue) && ($argumentValue || ($argumentValue == 0))) {
			# VALUE SPECIFIED
			# VALUE SPECIFIED
			# VALUE SPECIFIED

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
			# VALUE NOT SPECIFIED
			# VALUE NOT SPECIFIED
			# VALUE NOT SPECIFIED

			chomp $settingKey;
			#print "$argumentKeySanitized=$settingKey";

			if ($settingKey =~ m/^([0-9a-zA-Z.\/_\-:]+)$/) { #todo bug here?
				$settingKey = $1;
				my $settingValue = `cat $settingKey`;

				chomp $settingValue;

				print "$settingKey=$settingValue";
				print "\n";

				if (-e "$settingKey.list") {
					my $settingList = `cat $settingKey.list`;
					print $settingList;
					print "\n";
				}

				print "New value: ";

				my $input = <STDIN>;
				if (defined($input)) {
					chomp $input;

					if ($input =~ m/(.+)/) { #todo
						$input = $1;
						`echo $input > $settingKey`;

						$settingValue = `cat $settingKey`;
						print "$settingKey=$settingValue";

						if ($settingKey eq 'config/setting/theme') {
							print "Theme changed, about to rebuild frontend...\n";
							sleep 2;
							print `sh hike.sh frontend`;
						}
					} else {
						print 'Warning: Value not changed';
					}
				} else {
					print 'warning';
				}
			} else {
				print 'warning';
			}

			# if ($settingKey =~ m/^([.+])$/) {
			# 	$settingKey = $1;
			# 	print `cat $settingKey`;
			# }
			print "\n";
		}
	} else {
		# SEARCH RESULTS
		# SEARCH RESULTS
		# SEARCH RESULTS
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
