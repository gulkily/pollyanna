#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetAuthorLink { # $authorKey ; returns avatar'ed link for an author id
	my $authorKey = shift; # author's fingerprint

	require_once('widget/avatar.pl');

	if (!$authorKey) {
		WriteLog('GetAuthorLink: warning: $authorKey is missing; caller = ' . join(',', caller));
		return '';
	}

	# verify $authorKey is valid
	if (!IsFingerprint($authorKey)) {
		WriteLog('GetAuthorLink: warning: sanity check failed on $authorKey = ' . ($authorKey ? $authorKey : 'FALSE') . '; caller: ' . join(',', caller));
		return 'Guest'; #guest...
	}

	WriteLog("GetAuthorLink($authorKey)");

	my $authorUrl;
	$authorUrl = "/author/$authorKey/index.html";

	my $authorAvatar = '';

	if (GetConfig('setting/html/avatar_link_to_person_when_approved')) {
		WriteLog('GetAuthorLink: avatar_link_to_person_when_approved is TRUE');

		my $authorPubKeyHash = DBGetAuthorPublicKeyHash($authorKey) || '';

		if (SqliteGetValue("SELECT COUNT(label) FROM item_label WHERE label = 'approve' AND file_hash = '$authorPubKeyHash'")) {
			my $alias = GetAlias($authorKey);
			my $aliasEscaped = UriEscape($alias);
			#$authorAvatar = $alias;
			$authorAvatar = GetAvatar($authorKey);

			$authorUrl = "/person/$aliasEscaped/index.html";
		}
	}

	if (!$authorAvatar) {
		$authorAvatar = GetAvatar($authorKey);
	}

	if (!$authorAvatar || trim($authorAvatar) eq '') {
		WriteLog('GetAuthorLink: warning: $avatar is FALSE; $authorKey = ' . $authorKey . '; caller = ' . join(',', caller));
		$authorAvatar = '(' . $authorKey . ')';
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

