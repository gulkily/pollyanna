#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetThanksPage {
	my $html =
		GetPageHeader('thanks') .
		GetWindowTemplate(GetTemplate('html/page/thanks.template'), 'Thanks') .
		GetPageFooter('thanks')
	;

	return $html;
} # GetThanksPage()

1;

