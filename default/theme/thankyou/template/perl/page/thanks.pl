#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetThanksPage {
	my $html =
		GetPageHeader('thanks') .
		GetDialogX(GetTemplate('html/page/thanks/god.template'), 'Creator') .
		GetDialogX(GetTemplate('html/page/thanks/supporters.template'), 'Supporters') .
		GetDialogX(GetTemplate('html/page/thanks/enablers.template'), 'Enablers') .
		GetPageFooter('thanks')
	;
	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils);
		$html = InjectJs($html, @js)
	}

	return $html;
} # GetThanksPage()

1;

