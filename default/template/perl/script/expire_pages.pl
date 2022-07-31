#!/usr/bin/perl -T

use strict;
use warnings;

sub ExpirePages { # $fileHash ; expire html pages affected by a change in item
	#todo sanity
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
}

1;