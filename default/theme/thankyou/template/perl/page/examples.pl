#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetExamplesPage {
	my $html =
		GetPageHeader('examples') .
		GetWindowTemplate(GetTemplate('html/page/examples.template'), 'Examples') .
		GetPageFooter('examples')
	;
	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils);
		$html = InjectJs($html, @js)
	}

	return $html;
} # GetExamplesPage()

1;
