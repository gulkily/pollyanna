#!/usr/bin/perl -T

use strict;
use warnings;

sub GetAddToReplyCartButton { # itemHash
	my $itemHash = shift;

	if (!IsItem($itemHash)) {
		WriteLog('GetAddToReplyCartButton: warning: IsItem($itemHash) is FALSE; caller = ' . join(',', caller));
		return '';
	}

	#todo sanity

	my $button = '
	    <a class=replyCartButton href=#>+cart</a>
	';
	$button = trim($button);

	$button = AddAttributeToTag(
		$button, 'a', 'item-id',
		$itemHash
	);

	$button = AddAttributeToTag(
		$button, 'a', 'onclick',
		"if (window.addToReplyCartButton) { return addToReplyCartButton('$itemHash', this); }"
	);
	return $button;
} # GetAddToReplyCartButton()

1;
