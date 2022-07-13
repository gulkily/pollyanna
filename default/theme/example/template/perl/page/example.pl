#!/usr/bin/perl -T

use strict;
use warnings;

sub GetExamplePage {
	WriteLog('GetExamplePage()');

	my $html = 
		GetPageHeader('example') .
		GetQueryAsDialog('SELECT file_hash, item_title FROM item_flat ORDER BY item_score DESC LIMIT 10') .
		GetWindowTemplate(GetTemplate('html/page/example.template')) .
		GetPageFooter('example');

	$html = InjectJs($html, qw(dragging utils settings));

	return $html;
}

1;