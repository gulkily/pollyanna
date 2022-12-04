#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDocumentationPage {
	my $html =
		GetPageHeader('documentation') .
		GetWindowTemplate(GetTemplate('html/page/documentation.template'), 'Documentation') .
		GetPageFooter('documentation')
	;
	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils);
		$html = InjectJs($html, @js)
	}

	return $html;
} # GetDocumentationPage()

1;
