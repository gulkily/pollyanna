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
	# sub GetAvatarCache {
	# affected by config/html/avatar_icons
	# affected by setting/html/avatar_link_to_person_when_approved

	WriteLog("GetAvatar(...)");
	my $aliasHtmlEscaped = '';

	state $avatarCachePrefix;
	state $avatarTemplate;

	if (!$avatarCachePrefix || !$avatarTemplate) {
		WriteLog('GetAvatar: setting up state $avatarTemplate');

		if (GetConfig('html/avatar_icons')) {
			$avatarCachePrefix = 'avatar_color';
			$avatarTemplate = 'html/avatar.template';
		} else {
			$avatarCachePrefix = 'avatar_plain';
			$avatarTemplate = 'html/avatar-username.template';
		}
		{
			my $themesValue = GetConfig('theme');
			$avatarCachePrefix .= '/' . substr(md5_hex($themesValue), 0, 8);
			# generate cache prefix using hash of all the enabled themes together
			# this is still less than ideal because it does not include theme names,
			# but including theme names could run into many issues, like long directory names, sanity, etc.
		}
	}

	WriteLog('GetAvatar: $avatarCachePrefix = ' . $avatarCachePrefix . '; $avatarTemplate = ' . $avatarTemplate);

	state %avatarMemo;

	my $authorKey = shift;
	if (!$authorKey) {
		WriteLog('GetAvatar: warning: $authorKey is FALSE, returning empty string');
		return '';
	}
	chomp $authorKey;

	WriteLog("GetAvatar($authorKey) ; caller = " . join(',', caller));

	if ($avatarMemo{$authorKey}) {
		WriteLog('GetAvatar: returning, found in %avatarMemo');
		return $avatarMemo{$authorKey};
	}
	my $avCacheFile = GetCache("$avatarCachePrefix/$authorKey");
	if ($avCacheFile) {
		$avatarMemo{$authorKey} = $avCacheFile;
		WriteLog('GetAvatar: found cache, returning: $avatarMemo{$authorKey} = ' . $avatarMemo{$authorKey});
		return $avatarMemo{$authorKey};
	}
	WriteLog('GetAvatar: not found in memo, continuing');

	my $avatar = GetTemplate($avatarTemplate);

	{
		# trim whitespace from avatar template
		# this trims extra whitespace from avatar template
		# otherwise there may be extra spaces in layout

		$avatar =~ s/\>\s+/>/g;
		$avatar =~ s/\s+\</</g;
	}

	my $isVerified = 0;
	my $isApproved = 0;

	if ($authorKey) {
		WriteLog('GetAvatar: $authorKey = ' . $authorKey);

		my $authorPubKeyHash = DBGetAuthorPublicKeyHash($authorKey) || '';
		WriteLog('GetAvatar: $authorPubKeyHash = ' . $authorPubKeyHash);
		my $authorItemAttributesRef = $authorPubKeyHash ? DBGetItemAttributes($authorPubKeyHash) : '' || '';
		WriteLog('GetAvatar: $authorItemAttributesRef = ' . $authorItemAttributesRef);
		my %authorItemAttributes;
		if ($authorItemAttributesRef) {
			%authorItemAttributes = %{$authorItemAttributesRef};
		}

		if (GetConfig('setting/html/avatar_link_to_person_when_approved')) {
			if (SqliteGetValue("SELECT COUNT(label) FROM item_label WHERE label = 'approve' AND file_hash = ?", $authorPubKeyHash)) {
				$isApproved = 1;
			}
		}

		my $alias = '';

		if (!$alias) {
			#$alias = GetAlias($authorKey, $noCache);
			$alias = GetAlias($authorKey);
			if (!$alias) {
				#user has no alias for some reason.
				#not sure how this would happen, except if they generated a key with a blank alias
				WriteLog('GetAvatar: warning: $alias was FALSE; $authorKey = ' . $authorKey . '; caller = ' . join(',', caller));
				$alias = 'Guest'; #guest...
			}
			$alias = trim($alias);
		}
		if (%authorItemAttributes) {
			if ($authorItemAttributes{'gpg_id'}) {
				WriteLog('GetAvatar: found gpg_id!');

				$isVerified = 1;

				if (!GetConfig('admin/html/ascii_only')) {
					#$alias .= '✔';
					#$alias .= '&check;';
					$alias .= '+';
				} else {
					#$alias .= 'V';
					$alias .= '+';
				}
			} # if ($authorItemAttributes{'gpg_id'})
		} # if (%authorItemAttributes)

		if (GetConfig('html/avatar_icons')) {
			my $avatarIcon = GetAvatarIcon($authorKey);
			WriteLog('GetAvatar: $avatarIcon = ' . length($avatarIcon));
			$avatar = str_replace('<span class=icon></span>', $avatarIcon, $avatar);
		} # GetConfig('html/avatar_icons')
		else {
			WriteLog('GetAvatar: $avatarIcon not necessary, removing placeholder');
			$avatar = str_replace('<span class=icon></span>', '', $avatar);
		}
	} # if ($authorKey)
	else {
		WriteLog('GetAvatar: warning: sanity check failed, $authorKey is false');
		$avatar = 'Guest';
		#option:
		#$avatar = '(Guest)';
	}

	$avatar = str_replace('$alias', $aliasHtmlEscaped, $avatar);

	#todo below, approved status should not necessarily override coloring of username based on status
	my $colorUsername = '';

	if (GetConfig('setting/html/avatar_display_approved_status')) {
		if ($isApproved) {
			my $checkmark = GetString('widget/checkmark');
			$avatar = '<b>' . GetAlias($authorKey) . $checkmark . '</b>';
		}
		else {
			my $hourglass = GetString('widget/hourglass');
			$avatar = '<b>' . GetAlias($authorKey) . $hourglass . '</b>';
		}
	}
	else {
		$avatar = '<b>' . GetAlias($authorKey) . '</b>';
	}

	{
		if (IsAdmin($authorKey)) {
			$colorUsername = GetThemeColor('admin_text');
			WriteLog('GetAvatar: $colorUsername reason is admin');
		}
		elsif ($isVerified) {
			$colorUsername = GetThemeColor('verified_text');
			WriteLog('GetAvatar: $colorUsername reason is verified');
		}
		else {
			$colorUsername = GetThemeColor('author_text');
			WriteLog('GetAvatar: $colorUsername reason is basic');
		}
		WriteLog('GetAvatar: $colorUsername = ' . $colorUsername);
		$avatar =~ s/\$colorUsername/$colorUsername/g;
	}

	# save to memo
	$avatarMemo{$authorKey} = $avatar;

	if ($avatar) {
		PutCache("$avatarCachePrefix/$authorKey", $avatar);
	}

	if (!$avatar) {
		WriteLog('GetAvatar: warning: $avatar is FALSE before return; caller = ' . join(',', caller));
		if (IsFingerprint($authorKey)) {
			$avatar = '(' . $authorKey . ')';
		}
	}

	WriteLog('GetAvatar: returning $avatar = ' . $avatar);

	return $avatar;
} # GetAvatar()

1;
