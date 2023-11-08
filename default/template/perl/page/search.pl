#!/usr/bin/perl -T

use strict;
use warnings;

sub GetSearchPage {# returns html for search page
	my $html = '';
	my $title = 'Search';

	$html .= GetPageHeader('search');
	$html .= GetTemplate('html/maincontent.template');
	$html .= GetSearchDialog();
	$html .= GetPageFooter('search');

	if (GetConfig('setting/admin/js/enable')) {
		$html = InjectJs($html, qw(utils settings avatar profile puzzle));
	}
	return $html;
} # GetSearchPage()

1;
