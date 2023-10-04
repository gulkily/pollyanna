#!/usr/bin/perl -T

die "File needs fixing and debugging";

use strict;
use warnings;
use 5.010;
use utf8;

my $versionBefore = GetMyVersion();

my $time = time();
my $upgradeLogFilename = "html/txt/upgrade_$time.txt";

my $titleUpgradeLogCommand = "echo 'upgrade initiated at $time' >> $upgradeLogFilename";
print(`$titleUpgradeLogCommand`);

my $pullCommand = "time git pull --all >> $upgradeLogFilename";
print(`$pullCommand`);

my $versionAfter = GetMyVersion(1);

if ($versionBefore ne $versionAfter) {
	my $cleanCommand = "time ./default/template/sh/clean.sh >> $upgradeLogFilename";
	print(`$cleanCommand`);

	my $buildCommand = "time ./build.sh >> $upgradeLogFilename";
	print(`$buildCommand`);
} else {
	my $noUpgradeNeededCommand = "echo 'version no change' >> $upgradeLogFilename";
	print(`$noUpgradeNeededCommand`);
}

$time = time();
my $finishedUpgradeLogCommand = "echo 'upgrade finished at $time' >> $upgradeLogFilename";
print(`$finishedUpgradeLogCommand`);

my $indexUpgradeLogCommand = 'time ./index.pl html/txt/upgrade_$time.txt';
print(`$indexUpgradeLogCommand`);

my $pagesSummaryCommand = 'time ./pages.pl --summary';
print(`$pagesSummaryCommand`);

