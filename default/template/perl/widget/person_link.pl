#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetPersonLink { # $alias, $fingerprint
# fingerprint is optional, but providing fingerprint will show checkmark (and cost a db query atm)
	my $alias = shift;
	chomp $alias;

	if ($alias =~ m/^([A-Za-z0-9]+)$/) {
		$alias = $1;
	}
	else {
		$alias = 'Guest';
	}
	#todo sanity

	my $fingerprint = shift;

	if ($fingerprint) {
		my $authorIsApproved = AuthorHasLabel($fingerprint, 'approve');
		if ($authorIsApproved) {
			return '<a href="/person/' . UriEscape($alias) . '/index.html">' . HtmlEscape($alias) . '&check;' . '</a>';
		} else {
			return '<a href="/person/' . UriEscape($alias) . '/index.html">' . HtmlEscape($alias) . '</a>';
		}
	}
	else {
		return '<a href="/person/' . UriEscape($alias) . '/index.html">' . HtmlEscape($alias) . '&check;' . '</a>';
	}

#	my $fingerprint = shift; # author's fingerprint
#	my $showPlain = shift; # 1 to display avatar without colors
#
#	require_once('widget/avatar.pl');
#
#	# sanitize $showPlain
#	if (!$showPlain) {
#		$showPlain = 0;
#	} else {
#		$showPlain = 1;
#	}
#
#	if (!$fingerprint) {
#		WriteLog('GetAuthorLink: warning: $fingerprint is missing; caller = ' . join(',', caller));
#		return '';
#	}
#
#	# verify $fingerprint is valid
#	if (!IsFingerprint($fingerprint)) {
#		WriteLog('GetAuthorLink: warning: sanity check failed on $fingerprint = ' . ($fingerprint ? $fingerprint : 'FALSE') . '; caller: ' . join(',', caller));
#		return 'Guest'; #guest...
#	}
#
#	my $authorUrl = "/author/$fingerprint/index.html";
#
#	my $authorAvatar = '';
#	if ($showPlain) {
#		$authorAvatar = GetAvatar($fingerprint);
#	} else {
#		$authorAvatar = GetAvatar($fingerprint);
#	}
#
#	my $authorLink = GetTemplate('html/authorlink.template');
#
#	{ # trim whitespace from avatar template
#		#this trims extra whitespace from avatar template
#		#otherwise there may be extra spaces in layout
#		#WriteLog('avdesp before:'.$avatar);
#		$authorLink =~ s/\>\s+/>/g;
#		$authorLink =~ s/\s+\</</g;
#		#WriteLog('avdesp after:'.$avatar);
#	}
#
#	$authorAvatar = trim($authorAvatar);
#
#	$authorLink =~ s/\$authorUrl/$authorUrl/g;
#	$authorLink =~ s/\$authorAvatar/$authorAvatar/g;
#
#	return $authorLink;
} # GetPersonLink()

1;

