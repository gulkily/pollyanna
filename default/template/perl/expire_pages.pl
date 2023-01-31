#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub ExpirePages { # $fileHash ; expire html pages affected by a change in item
# sub DeletePages {
	my $fileHash = shift;

	if (!$fileHash) {
		WriteLog('ExpirePages: failed sanity check, $fileHash is FALSE; caller = ' . join(',', caller));
		return '';
	}

	if (!IsItem($fileHash)) {
		WriteLog('ExpirePages: failed sanity check, IsItem($fileHash) is FALSE' . join(',', caller));
		return '';
	}

	WriteLog("ExpirePages($fileHash)");

	my $previousInChain = DBGetItemAttribute($fileHash, 'chain_previous');
	if ($previousInChain && IsItem($previousInChain)) {
		my $prevPage = GetHtmlFilename($previousInChain);
		RemoveHtmlFile($prevPage);
	}
}

1;