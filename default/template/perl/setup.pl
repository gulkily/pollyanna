#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use utf8;

#############
# UTILITIES

sub WriteMessage {
	my $text = shift;
	print $text;
	print "\n";
} # WriteMessage()

sub GetChoice { # $message ; gets input from user
	my $message = shift;
	chomp $message;
	print $message;

	my $input = <STDIN>;
	chomp $input;
	
	return $input;
} # GetChoice()

sub GetYes { # $message ; gets an approval from user
	my $message = shift;
	chomp $message;

	my $response = GetChoice($message . ' [Y] ');

	if (lc($response) eq 'y' || lc($response) eq 'yes' || $response eq '') {
		return 1;
	} else {
		return 0;
	}
} # GetYes()

sub RunCommand {
	my $command = shift;
	print GetTime() . " " . $command;
	my $return = `$command`;
	return `$command`;
} # RunCommand()

my %dep;
$dep{'php'} = `which php`;
$dep{'php-cgi'} = `which php-cgi`;
$dep{'gpg'} = `which gpg`;
$dep{'lighttpd'} = `which lighttpd`;
$dep{'convert'} = `which convert`;
$dep{'sqlite3'} = `which sqlite3`;

$dep{'pacman'} = `which pacman 2>/dev/null`;
$dep{'pkg'} = `which pkg 2>/dev/null`;
$dep{'apt'} = `which apt 2>/dev/null`;
$dep{'yum'} = `which yum 2>/dev/null`;
$dep{'dnf'} = `which dnf 2>/dev/null`;
$dep{'brew'} = `which brew 2>/dev/null`;

for my $depName (keys(%dep)) {
	if ($dep{$depName}) {
		print($depName . ': ' . $dep{$depName});
	} else {
		print($depName . ': no' . "\n");
	}
}

require('./utils.pl');
require_once('config.pl');

my $needPackages = 0;
# some packages are named differently across different platforms.
# rather than trying to keep track of them, it's just a 0/1 flag.
# trying to install an already installed package will be ignored.

PutConfig('admin/js/enable', 1);
if ($dep{'php'} && $dep{'php-cgi'}) {
	PutConfig('admin/php/enable', 1);
	PutConfig('admin/upload/enable', 1);
} else {
	$needPackages = 1;
	PutConfig('admin/php/enable', 0);
	PutConfig('admin/upload/enable', 0);
}
if ($dep{'convert'}) {
	PutConfig('admin/image/enable', 1);
} else {
	$needPackages = 1;
	PutConfig('admin/image/enable', 0);
}
if ($dep{'gpg'}) {
	PutConfig('admin/gpg/enable', 1);
} else {
	$needPackages = 1;
	PutConfig('admin/gpg/enable', 0);
}
if ($dep{'lighttpd'}) {
	PutConfig('admin/lighttpd/enable', 1);
} else {
	$needPackages = 1;
	PutConfig('admin/lighttpd/enable', 0);
}

if ($needPackages) {
	if ($dep{'pacman'} || $dep{'apt'} || $dep{'yum'} || $dep{'dnf'} || $dep{'brew'}) {
		print "\n\n";
		if (GetYes('lighttpd is not installed, try to sudo install it? ')) {
			if ($dep{'pacman'}) {
				print `sudo pacman --noconfirm -S lighttpd php-cgi gnupg imagemagick`;
			}
			elsif ($dep{'pkg'}) {
				print `sudo pkg install -y lighttpd`;
			}
			elsif ($dep{'apt'}) {
				print `sudo apt install -y lighttpd`;
			}
			elsif ($dep{'yum'}) {
				print `sudo yum -y install lighttpd`;
			}
			elsif ($dep{'dnf'}) {
				print `sudo dnf install lighttpd`;
			}
			elsif ($dep{'brew'}) {
				print `sudo brew install lighttpd`;
			}
		}
	}
}

PutConfig('admin/http_auth/enable', 0);
PutConfig('reply/enable', 1);
PutConfig('admin/allow_admin_permissions_tag_lookup', 1);
PutConfig('admin/allow_self_admin_whenever', 1);
PutConfig('admin/allow_self_admin_when_adminless', 1);
PutConfig('admin/token/remove', 1);

#print `perl -T ./server_local_lighttpd.pl &`;

#print "Making pages and indexing existing files...\n";

#print `perl -T ./pages.pl --system &`;

#print `perl -T ./index.pl --chain &`;

#print `perl -T ./index.pl --all &`;
#
#print `xdg-open http://localhost:2784/ &`;