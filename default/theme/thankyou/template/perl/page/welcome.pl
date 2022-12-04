#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	my $html =
		GetPageHeader('welcome') .
		GetWindowTemplate(GetTemplate('html/page/welcome.template'), 'Welcome') .
		GetPageFooter('welcome')
	;

	return $html;
} # GetWelcomePage()

1;
