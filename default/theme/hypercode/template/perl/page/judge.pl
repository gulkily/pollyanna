#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetJudgePage {
	my $html = 
		GetPageHeader('judge') .

		GetDialogX(GetTemplate('html/page/judge.template'), 'Judge') .
		GetQueryAsDialog('judge', 'Problems') .
		GetPageFooter('judge')
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
