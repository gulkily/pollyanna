#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetAvatarIcon { # $authorKey ; returns text-based icon for avatar
	my $authorKey = shift;
	#todo sanity checks on $authorKey
	#todo sanity check that setting/html/avatar_icons is enabled

	WriteLog('GetAvatarIcon: $authorKey = ' . $authorKey . '; caller = ' . join(',', caller));

	my $avatarIcon = GetTemplate('html/avatar-icon.template');

	if (!$avatarIcon) {
		WriteLog('GetAvatarIcon: warning: sanity check failed on $avatarIcon');
		return '';
	}

	my $color1 = '#' . substr($authorKey, 0, 6);
	my $color2 = '#' . substr($authorKey, 3, 6);
	my $color3 = '#' . substr($authorKey, 6, 6);
	my $color4 = '#' . substr($authorKey, 9, 6);
	my $color5 = '#' . substr($authorKey, 12, 4) . substr($authorKey, 0, 2);
	my $color6 = '#' . substr($authorKey, 1, 6);
	my $color7 = '#' . substr($authorKey, 2, 6);
	my $color8 = '#' . substr($authorKey, 4, 6);
	my $color9 = '#' . substr($authorKey, 5, 6);
	my $colorA = '#' . substr($authorKey, 7, 6);
	my $colorB = '#' . substr($authorKey, 8, 6);

	my $char1;
	my $char2;
	my $char3;

	$char1 = substr($authorKey, 12, 1);
	$char2 = substr($authorKey, 13, 1);
	$char3 = substr($authorKey, 14, 1);

	#
	$char1 =~ tr/0123456789ABCDEF/)!]#$%^&*(;,.:['/;
	$char2 =~ tr/0123456789ABCDEF/)!]#$%^&*(;,.:['/;
	$char3 =~ tr/0123456789ABCDEF/)!]#$%^&*(;,.:['/;

	$avatarIcon =~ s/\$color1/$color1/g;
	$avatarIcon =~ s/\$color2/$color2/g;
	$avatarIcon =~ s/\$color3/$color3/g;
	$avatarIcon =~ s/\$color4/$color4/g;
	$avatarIcon =~ s/\$color5/$color5/g;
	$avatarIcon =~ s/\$color6/$color6/g;
	$avatarIcon =~ s/\$color7/$color7/g;
	$avatarIcon =~ s/\$color8/$color8/g;
	$avatarIcon =~ s/\$color9/$color9/g;
	$avatarIcon =~ s/\$colorA/$colorA/g;
	$avatarIcon =~ s/\$colorB/$colorB/g;

	$avatarIcon =~ s/\$char1/$char1/g;
	$avatarIcon =~ s/\$char2/$char2/g;
	$avatarIcon =~ s/\$char3/$char3/g;

	if (!$avatarIcon) {
		WriteLog('GetAvatarIcon: warning: $avatarIcon is FALSE!');
	} else {
		WriteLog('GetAvatarIcon: $avatarIcon = ' . length($avatarIcon));
	}

	return $avatarIcon;
} # GetAvatarIcon()

sub GetAvatar { # $authorKey ; returns HTML avatar based on author key, using avatar.template
	# sub GetAvatarCache { ###
	# affected by config/html/avatar_icons
	# affected by setting/html/avatar_link_to_person_when_approved

	WriteLog("GetAvatar(...)");

	my $authorKey = shift;
	if (!$authorKey) {
		WriteLog('GetAvatar: warning: $authorKey is FALSE, returning empty string; caller = ' . join(',', caller));
		return '';
	}
	chomp $authorKey;

	if ($authorKey = IsFingerprint($authorKey)) {
		# sanity check passed
	} else {
		WriteLog('GetAvatar: warning: sanity check failed on $authorKey; caller = ' . join(',', caller));
		return '';
	}

	my $alias = GetAlias($authorKey);

	if (!$alias) {
		#user has no alias for some reason.
		#not sure how this would happen, except if they generated a key with a blank alias
		WriteLog('GetAvatar: warning: $alias was FALSE; $authorKey = ' . $authorKey . '; caller = ' . join(',', caller));
		$alias = 'Guest'; #guest...
	}

	#my $isApproved = 0;

	#if (GetConfig('setting/html/avatar_link_to_person_when_approved')) {
	#	if (SqliteGetValue("SELECT COUNT(label) FROM item_label WHERE label = 'approve' AND file_hash = ?", DBGetAuthorPublicKeyHash($authorKey))) {
	#		$isApproved = 1;
	#	}
	#}

	return $alias;

} # GetAvatar()

1;
