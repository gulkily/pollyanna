#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPaintPage {
	WriteLog('GetPaintPage: simple theme');

	my $js = GetTemplate('js/main.js');
	PutHtmlFile('main.js', $js);

	my $css = GetTemplate('css/style.css');
	PutHtmlFile('style.css', $css);

	my $html = GetTemplate('html/wall.template');
	return $html;
}

1;
