#!/usr/bin/perl -T

#this is some kind of practice file, not sure what it does

use strict;
use 5.010;
use POSIX qw(strftime ceil);
use Data::Dumper;
require './utils.pl';

my $localtime = localtime();

print $localtime;
print "\n";

my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);


my $epoch = time();
my $done = 0;

my $curMon = strftime ('%b', localtime ($epoch));
my $curDay = '01';#strftime ('%d', localtime ($epoch));
my $curYear = strftime ('%Y', localtime ($epoch));

my $formattedDate = '';

my $secondsBegin = 0;
my $secondsEnd = 0;

my $daysGoneBack = 0;

while (! $done) {
	$epoch -= 100;
	$formattedDate = strftime ('%d %b %Y', localtime ($epoch));
	
	chomp $formattedDate;

	#print $formattedDate . '-' . "$curDay $curMon $curYear" . "\n";

	if ($formattedDate eq "$curDay $curMon $curYear") {
		if ($secondsEnd) {
			$done = 1;
		} else {
			if (!$secondsBegin) {
				$secondsBegin = $epoch;
			}
		}
	} else {
		if ($secondsBegin) {
			$secondsEnd = $epoch;
			$done = 1;
		}
	}
}

$epoch = $secondsBegin;
$done = 0;

my $prevDate = '';
my ($firstDay, $firstMonth, $firstYear) = split(' ', $formattedDate);

my $monthsDone = 0;

my @daysToPrint;
my %daysToPrint;

while (!$done) {
	$formattedDate = strftime ('%d %b %Y', localtime ($epoch));
	$epoch += 100;

	if (!$daysToPrint{$formattedDate}) {
		while ($formattedDate eq strftime ('%d %b %Y', localtime ($epoch))) {
			$epoch--;
		}
		$epoch++;
		
		#todo optimize
		$daysToPrint{$formattedDate} = $epoch;
		push @daysToPrint, $formattedDate;
	}

	if ($formattedDate ne $prevDate) {
		#print $formattedDate;
		#print "\n";
		$prevDate = $formattedDate;
	}

	my ($curDay, $curMonth, $curYear) = split(' ', $formattedDate);

	if ($curMonth ne $firstMonth) {
		$monthsDone ++;
		$firstMonth = $curMonth;
	}

	if ($monthsDone > 3) {
		$done = 1;
	}
}

print $epoch;
print " ";
print $formattedDate;
print "\n";
print $secondsBegin . '-' . $secondsEnd;
print "\n";

print Dumper(@daysToPrint);
print Dumper(%daysToPrint);
