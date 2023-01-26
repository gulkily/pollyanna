#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetMessagesPage {
	# interests aka fields
	# should probably standardize on the term for this?
	my $html =
		GetPageHeader('messages') .
		#GetDialogX($interestsTemplate, 'Interests') .
		'<span id=messages></span>' .
		GetPageFooter('messages')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils profile write puzzle clock easyreg settings);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php';
		}
		if (GetConfig('setting/html/reply_cart')) {
			push @js, 'reply_cart';
		}
		$html = InjectJs($html, @js);
	}

	return $html;
} # GetMessagesPage()

1;