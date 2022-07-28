#!/usr/bin/perl -T

use strict;
use warnings;

sub GetWelcomePage {
	my $html = GetTemplate('html/page/welcome.template');

	#$html = InjectJs($html, qw(utils clock));
}

1;
