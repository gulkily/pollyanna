#!/usr/bin/perl

use strict;
use warnings;

sub RunCommand {
	my $command = shift;
	chomp $command;
	print GetTime() . " " . $command . "\n";

	#if ($command =~ m/^([a-zA-Z[0-9]._\"\s:\\-])$/) {
	if ($command =~ m/^(.+)$/) {
		$command = $1;
		my $return = `$command`;
		return `$command`;
	} else {
		print "warning: command failed sanity check! $command\n";
		return '';
	}
}

sub GetTime { # NOT THE MAIN ONE, LOOK IN utils.pl INSTEAD
	return time();
}

sub OpenBrowser { # opens url in system browser

	#todo optimize

	my $url = shift;

	if (index($url, '"') != -1) {
		#todo escape double-quotes here instead of returning
		return '';
	}

	my $whichXdg = RunCommand('which xdg-open');
	my $whichOpen = RunCommand('which open');
	my $whichW3m = RunCommand('which w3m');
	my $whichPython = RunCommand('which python');
	my $whichGnomeOpen = RunCommand('which gnome-open');
	my $whichXWwwBrowser = RunCommand('which x-www-browser');

	if ($whichXdg) {
		#RunCommand("xdg-open \"$url\"");
	} elsif ($whichOpen) {
		RunCommand("open \"$url\"");
	} elsif ($whichW3m) {
		RunCommand("w3m \"$url\"");
	} elsif ($whichPython) {
		RunCommand("python -m webbrowser \"$url\"");
	} elsif ($whichGnomeOpen) {
		RunCommand("gnome-open \"$url\"");
	} elsif ($whichXWwwBrowser) {
		RunCommand("x-www-browser \"$url\"");
	}
	#
	# if ($whichXdg) {
	# 	RunCommand("xdg-open \"$url\"");
	# } elsif ($whichOpen) {
	# 	RunCommand("open \"$url\"");
	# } elsif ($whichW3m) {
	# 	RunCommand("w3m \"$url\"");
	# } elsif ($whichPython) {
	# 	RunCommand("python -m webbrowser \"$url\"");
	# } elsif ($whichGnomeOpen) {
	# 	RunCommand("gnome-open \"$url\"");
	# } elsif ($whichXWwwBrowser) {
	# 	RunCommand("x-www-browser \"$url\"");
	# }
}

OpenBrowser('http://localhost:2784/');

1;
