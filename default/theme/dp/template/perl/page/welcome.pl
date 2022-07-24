#!/usr/bin/perl -T

use strict;
use warnings;

sub GetWelcomePage {
	my $html =
		GetPageHeader('welcome') .
		GetPageFooter('welcome')
	;
	$html = InjectJs($html, qw(utils clock));
}

1;
