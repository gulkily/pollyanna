#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetFaqPage {
	my $html =
		GetPageHeader('faq') .
		GetDialogX(GetTemplate('html/page/faq/faq_requirements.template'), 'Requirements') .
		GetDialogX(GetTemplate('html/page/faq/faq_any_browser.template'), 'Any Browser') .
		GetPageFooter('faq')
	;
	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils);
		$html = InjectJs($html, @js)
	}

	return $html;
} # GetFaqPage()

1;
