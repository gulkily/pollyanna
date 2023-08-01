#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDonatePage {
	my $html =
		GetPageHeader('donate') .
		GetDialogX(GetTemplate('html/page/donate.template'), 'Information') .
		GetPageFooter('donate')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('admin/php/enable')) {
				push @js, 'write_php';
		}
		$html = InjectJs($html, @js);
	}

	return $html;
}

1;
