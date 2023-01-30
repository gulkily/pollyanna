#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAvatar { # $key, $noCache ; returns HTML avatar based on author key, using avatar.template
# sub GetAvatarCache {
	# affected by config/html/avatar_icons
	WriteLog("GetAvatar(...)");
	my $aliasHtmlEscaped = '';

	state $avatarCachePrefix;
	state $avatarTemplate;

	if (!$avatarCachePrefix || !$avatarTemplate) {
		if (GetConfig('html/avatar_icons')) {
			$avatarCachePrefix = 'avatar_color';
			$avatarTemplate = 'html/avatar.template';
		} else {
			$avatarCachePrefix = 'avatar_plain';
			$avatarTemplate = 'html/avatar-username.template';
		}
		{
			my $themesValue = GetConfig('theme');

			# this is not entirely correct ... should be based on entire theme value, not just the first line
			# {
				# it's a hack to map theme value onto path
				#$themesValue =~ s/[\s]+/ /g;
				#my @activeThemes = split(' ', $themesValue);
				#my $themeName = $activeThemes[0];
			# }

			$avatarCachePrefix .= '/' . substr(md5_hex($themesValue), 0, 8);
			# this is still less than ideal because it does not include theme names,
			# but including theme names could run into many issues, like long directory names, sanity, etc.
		}
	}

	WriteLog('GetAvatar: $avatarCachePrefix = ' . $avatarCachePrefix . '; $avatarTemplate = ' . $avatarTemplate);

	state %avatarCache;

	my $authorKey = shift;
	if (!$authorKey) {
		WriteLog('GetAvatar: warning: $authorKey is false, returning empty string');
		return '';
	}
	chomp $authorKey;

	WriteLog("GetAvatar($authorKey) ; caller = " . join(',', caller));

	my $noCache = shift;
	$noCache = ($noCache ? 1 : 0);

	if (! $noCache) {
		# $noCache is FALSE, so use cache!
		if ($avatarCache{$authorKey}) {
			WriteLog('GetAvatar: found in %avatarCache');
			return $avatarCache{$authorKey};
		}
		my $avCacheFile = GetCache("$avatarCachePrefix/$authorKey");
		if ($avCacheFile) {
			$avatarCache{$authorKey} = $avCacheFile;
			WriteLog('GetAvatar: found cache, returning: $avatarCache{$authorKey} = ' . $avatarCache{$authorKey});
			return $avatarCache{$authorKey};
		}
	} else {
		WriteLog('GetAvatar: $noCache is true, ignoring cache');
	}

	my $avatar = GetTemplate($avatarTemplate);
	#WriteLog('GetAvatar: $avatar = ' . $avatar . '; $avatarTemplate = ' . $avatarTemplate);

	{ # trim whitespace from avatar template
		#this trims extra whitespace from avatar template
		#otherwise there may be extra spaces in layout
		#WriteLog('avdesp before:'.$avatar);
		$avatar =~ s/\>\s+/>/g;
		$avatar =~ s/\s+\</</g;
		#WriteLog('avdesp after:'.$avatar);
	}

	my $isVerified = 0;
	my $redditUsername = '';
	if ($authorKey) {
		WriteLog('GetAvatar: $authorKey = ' . $authorKey);

		my $authorPubKeyHash = DBGetAuthorPublicKeyHash($authorKey) || '';
		WriteLog('GetAvatar: $authorPubKeyHash = ' . $authorPubKeyHash);
		my $authorItemAttributes = $authorPubKeyHash ? DBGetItemAttributes($authorPubKeyHash) : '' || '';
		WriteLog('GetAvatar: $authorItemAttributes = ' . $authorItemAttributes);

		my $alias = '';

		if (!$alias) {
			$alias = GetAlias($authorKey, $noCache);
			if (!$alias) {
				#user has no alias for some reason.
				#not sure how this would happen, except if they generated a key with a blank alias
				WriteLog('GetAlias: warning: $alias was FALSE; $authorKey = ' . $authorKey . '; caller = ' . join(',', caller));
				$alias = 'Guest'; #guest...
			}
			$alias = trim($alias);
		}
		if (0 && $authorItemAttributes) {
			#todo code below no longer works, and should be fixed in order to correctly display author's status
			#todo this doesn't work because it is expecting a big string, while it's getting a hash reference
			foreach my $authorAttributeLine (split("\n", $authorItemAttributes)) {
				WriteLog('GetAvatar: $authorAttributeLine = ' . $authorAttributeLine);
				my ($authorAttribute, $authorAttributeValue) = split('\|', $authorAttributeLine);
				WriteLog('GetAvatar: $authorAttribute = ' . $authorAttribute);

				if ($authorAttribute eq 'gpg_id') { #todo add or admin
#				if ($authorAttribute eq 'reddit_username') { #todo add or admin
					WriteLog('GetAvatar: found gpg_id!');

					$isVerified = 1;

					if (!GetConfig('admin/html/ascii_only')) {
						#$alias .= '✔';
						#$alias .= '&check;';
						#$alias .= 'V';
						$alias .= '+';
					} else {
						$alias .= '+';
					}

					#$redditUsername = $authorAttributeValue . 'xx';
#
#					if ($redditUsername eq $alias) {
#						# if alias is the same as reddit username,
#						# don't print it twice
#						if (!GetConfig('admin/html/ascii_only')) {
#							$alias .= '✔';
#						} else {
#							$alias .= '(verified)';
#						}
#					} else {
#						$alias .= '(' . $redditUsername . ')';
#					}
				} # gpg_id
			} # $authorAttributeLine
		} # $authorItemAttributes

		if (GetConfig('html/avatar_icons')) {
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

			$alias = encode_entities2($alias);
			#$alias = encode_entities($alias, '<>&"');

			if ($alias) {
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

				# $char1 =~ tr/0123456789ABCDEF/abcdefghijklmnop/;
				# $char2 =~ tr/0123456789ABCDEF/abcdefghijklmnop/;
				# $char3 =~ tr/0123456789ABCDEF/abcdefghijklmnop/;

				# $char1 = '*';
				# $char2 = '*';
				# $char3 = '*';

				$avatar =~ s/\$color1/$color1/g;
				$avatar =~ s/\$color2/$color2/g;
				$avatar =~ s/\$color3/$color3/g;
				$avatar =~ s/\$color4/$color4/g;
				$avatar =~ s/\$color5/$color5/g;
				$avatar =~ s/\$color6/$color6/g;
				$avatar =~ s/\$color7/$color7/g;
				$avatar =~ s/\$color8/$color8/g;
				$avatar =~ s/\$color9/$color9/g;
				$avatar =~ s/\$colorA/$colorA/g;
				$avatar =~ s/\$colorB/$colorB/g;

				$avatar =~ s/\$alias/$alias/g;
				$avatar =~ s/\$char1/$char1/g;
				$avatar =~ s/\$char2/$char2/g;
				$avatar =~ s/\$char3/$char3/g;
			}
			else {
				$avatar = '';
			}
		}
		else {
			# no icons
			$aliasHtmlEscaped = encode_entities2($alias);
			if ($isVerified) {
				$aliasHtmlEscaped = '<b><i>'.$aliasHtmlEscaped.'</i></b>';
			} else {
				$aliasHtmlEscaped = '<b><i>'.$aliasHtmlEscaped.'</i></b>';
			}
		}
		#$avatar =~ s/\$alias/$aliasHtmlEscaped/g;
	} else {
		WriteLog('GetAvatar: warning: sanity check failed, $authorKey is false');
		$avatar = "";
	}

	$avatar =~ s/\$alias/$aliasHtmlEscaped/g;

	#my $colorUsername = GetThemeColor('username_text');
	my $colorUsername = GetThemeColor('author_text');
	WriteLog('GetAvatar: $colorUsername reason is basic');
	if ($isVerified) {
		$colorUsername = GetThemeColor('verified_text');
		WriteLog('GetAvatar: $colorUsername reason is verified');
	}
	if (IsAdmin($authorKey)) {
		$colorUsername = GetThemeColor('admin_text');
		WriteLog('GetAvatar: $colorUsername reason is admin');
	}
	WriteLog('GetAvatar: $colorUsername = ' . $colorUsername);
	$avatar =~ s/\$colorUsername/$colorUsername/g;

	$avatarCache{$authorKey} = $avatar;

	if ($avatar) {
		PutCache("$avatarCachePrefix/$authorKey", $avatar);
	}

	return $avatar;
} # GetAvatar()

1;
