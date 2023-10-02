#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetAuthorLink { # $fingerprint, $showPlain ; returns avatar'ed link for an author id
	my $fingerprint = shift; # author's fingerprint
	my $showPlain = shift; # 1 to display avatar without colors

	require_once('widget/avatar.pl');

	# sanitize $showPlain
	if (!$showPlain) {
		$showPlain = 0;
	} else {
		$showPlain = 1;
	}

	if (!$fingerprint) {
		WriteLog('GetAuthorLink: warning: $fingerprint is missing; caller = ' . join(',', caller));
		return '';
	}

	# verify $fingerprint is valid
	if (!IsFingerprint($fingerprint)) {
		WriteLog('GetAuthorLink: warning: sanity check failed on $fingerprint = ' . ($fingerprint ? $fingerprint : 'FALSE') . '; caller: ' . join(',', caller));
		return 'Guest'; #guest...
	}

	WriteLog("GetAuthorLink($fingerprint, $showPlain)");

	my $authorUrl;
	$authorUrl = "/author/$fingerprint/index.html";
	if (GetConfig('setting/html/avatar_link_to_person_when_approved')) {
		my $authorPubKeyHash = DBGetAuthorPublicKeyHash($fingerprint) || '';

		if (SqliteGetValue("SELECT COUNT(label) FROM item_label WHERE label = 'approve' AND file_hash = '$authorPubKeyHash'")) {
			my $alias = GetAlias($fingerprint);
			my $aliasEscaped = UriEscape($alias);

			$authorUrl = "/person/$aliasEscaped/index.html";
		}
	}

	my $authorAvatar = '';
	if ($showPlain) {
		$authorAvatar = GetAvatar($fingerprint);
	} else {
		$authorAvatar = GetAvatar($fingerprint);
	}

	my $authorLink = GetTemplate('html/authorlink.template');

	{ # trim whitespace from avatar template
		#this trims extra whitespace from avatar template
		#otherwise there may be extra spaces in layout
		#WriteLog('avdesp before:'.$avatar);
		$authorLink =~ s/\>\s+/>/g;
		$authorLink =~ s/\s+\</</g;
		#WriteLog('avdesp after:'.$avatar);
	}

	$authorAvatar = trim($authorAvatar);

	$authorLink =~ s/\$authorUrl/$authorUrl/g;
	$authorLink =~ s/\$authorAvatar/$authorAvatar/g;

	return $authorLink;
} # GetAuthorLink()

1;

