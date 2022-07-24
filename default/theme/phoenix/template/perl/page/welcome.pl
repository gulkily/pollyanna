#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	my $html = '';

	$html =
		GetPageHeader('welcome') .
		GetWindowTemplate(GetTemplate('html/dialog/welcome.template')) .
		GetPageFooter('welcome')
	;

	$html = InjectJs($html, qw(utils settings));

	return $html;
}

1;