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
	if (!$fingerprint) {
		$fingerprint = '';
	}
	WriteLog('GetPersonLink: $alias = ' . $alias . '; $fingerprint = ' . $fingerprint . '; caller = ' . join(',', caller));

	if ($fingerprint) {
		my $authorIsApproved = AuthorHasLabel($fingerprint, 'approve');
		if ($authorIsApproved) {
			my $checkmark = GetString('widget/checkmark');
			return '<a href="/person/' . UriEscape($alias) . '/index.html">' . HtmlEscape($alias) . $checkmark . $checkmark . '</a>';
		} else {
			return '<a href="/person/' . UriEscape($alias) . '/index.html">' . HtmlEscape($alias) . '</a>';
		}
	}
	else {
		my $checkmark = GetString('widget/checkmark');
		return '<a href="/person/' . UriEscape($alias) . '/index.html">' . HtmlEscape($alias) . $checkmark . '</a>';
	}
} # GetPersonLink()

1;

