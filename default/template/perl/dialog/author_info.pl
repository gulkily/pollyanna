#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAuthorInfoBox { # $authorKey ; returns author info box
# sub GetAuthorDialog {
	my $authorKey = shift;
	chomp $authorKey;

	if (!$authorKey) {
		return '';
	}

	if (!IsFingerprint($authorKey) && IsItem($authorKey)) {
		#todo refactor this nonsense
		my @queryParams;
		push @queryParams, $authorKey;
		my $newAuthorKey = SqliteGetValue('SELECT author_key FROM author_flat WHERE file_hash = ?', @queryParams);
		if ($newAuthorKey) {
			$authorKey = $newAuthorKey;
		}
	} # if (!IsFingerprint($authorKey) && IsItem($authorKey))

	my $authorInfoTemplate = GetTemplate('html/author_info.template');
	$authorInfoTemplate = FillThemeColors($authorInfoTemplate);

	my $authorAliasHtml = GetAlias($authorKey);
	my $authorAvatarHtml = GetAvatar($authorKey);
	my $authorImportance = 1;
	my $itemCount = DBGetAuthorItemCount($authorKey);
	my $authorDescription = '';
	my $authorLastSeen = DBGetAuthorLastSeen($authorKey) || 0;

	my $publicKeyHash = DBGetAuthorPublicKeyHash($authorKey);
	my $publicKeyHashHtml = '';
	if (defined($publicKeyHash) && IsSha1($publicKeyHash)) {
		$publicKeyHashHtml = GetItemHtmlLink($publicKeyHash);
	} else {
		$publicKeyHashHtml = '*';
	}
	my $authorScore = DBGetAuthorScore($authorKey);
	if (!$authorScore) {
		$authorScore = 0;
	}

	my $authorMessageLink = GetItemHtmlLink($publicKeyHash, 'Message', '#reply');

	if (IsAdmin($authorKey)) {
		if ($authorDescription) {
			$authorDescription .= '<br>';
		}

		my $descText = '<b>Admin.</b>';
		my $adminContainer = GetTemplate('html/item/container/admin.template');
		my $colorAdmin = GetThemeColor('admin_text') || '#c00000';
		$adminContainer =~ s/\$colorAdmin/$colorAdmin/g;
		$adminContainer =~ s/\$message/$descText/g;

		$authorDescription = $adminContainer;
	}

	if ($authorDescription) {
		$authorDescription .= '<br>';
	}
	$authorDescription .= GetItemTagsSummary($publicKeyHash);

	my $profileVoteButtons = GetItemTagButtons($publicKeyHash, 'pubkey');
	if (!$profileVoteButtons) {
		$profileVoteButtons = '*';
	}

	$authorLastSeen = GetTimestampWidget($authorLastSeen) || '*';

	if (!$authorDescription) {
		$authorDescription = '*';
	}

	if (!$publicKeyHash) {
		$publicKeyHash = '*';
	}

	if (IsAdmin($authorKey)) {
		#todo make this more proper like
		$authorInfoTemplate =~ s/<p>This page about author listed below.<\/p>/<p>Note: This user is a system operator.<\/p>/;
	}
	$authorInfoTemplate =~ s/\$avatar/$authorAvatarHtml/;
	$authorInfoTemplate =~ s/\$authorName/$authorAliasHtml/;
	$authorInfoTemplate =~ s/\$fingerprint/$authorKey/g;
	$authorInfoTemplate =~ s/\$importance/$authorImportance/;
	$authorInfoTemplate =~ s/\$authorScore/$authorScore/;
	$authorInfoTemplate =~ s/\$itemCount/$itemCount/;
	$authorInfoTemplate =~ s/\$authorDescription/$authorDescription/;
	$authorInfoTemplate =~ s/\$authorLastSeen/$authorLastSeen/g;
	$authorInfoTemplate =~ s/\$profileVoteButtons/$profileVoteButtons/g;
	if ($publicKeyHashHtml) {
		$authorInfoTemplate =~ s/\$publicKeyHash/$publicKeyHashHtml/g;
	} else {
		$authorInfoTemplate =~ s/\$publicKeyHash/*/g;
	}
	if ($authorMessageLink) {
		$authorInfoTemplate =~ s/\$authorMessageLink/$authorMessageLink/g;
	} else {
		$authorInfoTemplate =~ s/\$authorMessageLink/*/g;
	}

	$authorInfoTemplate = GetDialogX($authorInfoTemplate, 'Author Information', 2);

	return $authorInfoTemplate;
} # GetAuthorInfoBox()

1;