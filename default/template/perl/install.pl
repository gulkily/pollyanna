#!/usr/bin/perl -T

use strict;
use 5.010;
use utf8;
#die 'Script is not yet finished. Please comment this line to test it';

#############
# UTILITIES

sub WriteLog { # install.pl
	my $text = shift;
	print $text;
	print "\n";
}

sub GetTime { # NOT THE MAIN ONE, LOOK IN utils.pl INSTEAD
	return time();
}

sub GetYes { # $message, $defaultYes ; print $message, and get Y response from the user
	# $message is printed to output
	# $defaultYes true:  allows pressing enter
	# $defaultYes false: user must type Y or y

	my $message = shift;
	chomp $message;

	my $defaultYes = shift;
	chomp $defaultYes;

	print $message;
	if ($defaultYes) {
		print ' [Y] ';
	} else {
		print " Enter 'Y' to proceed: ";
	}

	my $input = <STDIN>;
	chomp $input;

	if ($input eq 'Y' || $input eq 'y' || ($defaultYes && $input eq '')) {
		print "====================================================\n";
		print "====== Thank you for your vote of confidence! ======\n";
		print "====================================================\n";

		return 1;
	}

	return 0;
}

sub WriteConfigureMessage { # $message ; print a line to user
	my $message = shift;
	chomp $message;

	my $timestamp = GetTime();

	print "$timestamp $message\n";

	# AppendFile('html/status.txt', $message);
}

sub RunCommand {
	my $command = shift;
	print GetTime() . " " . $command;
	my $return = `$command`;
	return `$command`;
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
	my $whichW3m = `which w3m`;
	my $whichPython = `which python`;
	my $whichGnomeOpen = `which gnome-open`;
	my $whichXWwwBrowser = `which x-www-browser`;

	if ($whichXdg) {
		RunCommand("xdg-open \"$url\"");
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
}


##################
# USER CAN READ?

WriteConfigureMessage('======');
WriteConfigureMessage('Hello!');

my $canRead = GetYes('Can you read this text?');

if ($canRead) {
	print "Great! Let's proceed...\n";
} else {
	print "Must enter Y to proceed. Exiting.\n";
	exit;
}

###############
# OS PACKAGES

# figure out which distro and ask to install packages

my $yumPath = `which yum 2>/dev/null`;
my $dnfPath = `which dnf 2>/dev/null`;
my $aptPath = `which apt 2>/dev/null`;

my $bedMade = 0;

if ($yumPath) {
	my $installYum = GetYes("yum is available. Install pre-requisite packages? ", 1);

	if ($installYum) {
		my $yumCommand = 'sudo yum install perl-Digest-MD5 perl-Digest-SHA perl-HTML-Parser perl-DBD-SQLite perl-URI-Encode perl-Digest-SHA1 sqlite gnupg gnupg2 perl-Devel-StackTrace perl-Digest-SHA perl-HTML-Parser perl-DBD-SQLite lighttpd-fastcgi ImageMagick screen';
		my $yumResult = `$yumCommand`;

		WriteConfigureMessage($yumResult);

		$bedMade = 1;
	}
}

if ($dnfPath) {
	my $installYum = GetYes("dnf is available. Install pre-requisite packages? ", 1);

	if ($installYum) {
		my $dnfCommand = 'sudo dnf install perl-Digest-MD5 perl-Digest-SHA perl-HTML-Parser perl-DBD-SQLite perl-URI-Encode perl-Digest-SHA1 sqlite gnupg gnupg2 perl-Devel-StackTrace perl-Digest-SHA perl-HTML-Parser perl-DBD-SQLite lighttpd-fastcgi ImageMagick screen';
		my $dnfResult = `$dnfCommand`;

		WriteConfigureMessage($dnfResult);

		$bedMade = 1;
	}
}

if ($aptPath) {
	my $aptCommand = 'sudo apt-get install liburi-encode-perl libhtml-parser-perl libdbd-sqlite3-perl libdigest-sha-perl sqlite3 gnupg gnupg2 imagemagick screen';
	WriteConfigureMessage("apt is available. Install pre-requisite packages?");
	WriteConfigureMessage("Actual Command: $aptCommand");
	my $installApt = GetYes("Run command to install packages?", 1);

	if ($installApt) {
		my $aptResult = system($aptCommand);
		#my $aptResult = `$aptCommand`;

		#WriteConfigureMessage($aptResult);

		$bedMade = 1;
	}
}

#####

# ask if need to symlink web root
# rename original?

#####


# launch browser?

# ask about php too

# ask about gpg1/2


