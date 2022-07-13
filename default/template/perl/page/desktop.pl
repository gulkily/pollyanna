#!/usr/bin/perl -T

use strict;
use warnings;

require_once('page/upload.pl'); #todo move upload dialog to separate file

sub GetDesktopPage { # returns html for desktop page (/desktop.html)
	my $html = "";
	my $title = "Desktop";

	$html = GetPageHeader('desktop');
	$html .= GetTemplate('html/maincontent.template');

	$html .= GetQueryAsDialog('tags', 'Tags');

	$html .= GetStatsTable(); # GetDesktopPage()

	if (GetConfig('admin/php/enable')) {
		if (GetConfig('admin/upload/enable')) {
			require_once('page/upload.pl');
			$html .= GetUploadDialog('html/form/upload.template');
		}
	}

	$html .= GetPageFooter('tags');

	if (GetConfig('admin/js/enable')) {
		my @scripts = qw(settings avatar profile timestamp pingback utils);
		if (GetConfig('admin/js/dragging')) {
			push @scripts, 'dragging'; # GetDesktopPage()
		}
		if (GetConfig('admin/php/enable')) {
			if (GetConfig('admin/upload/enable')) {
				push @scripts, 'upload';
			}
		}
		push @scripts, 'write';
		$html = InjectJs($html, @scripts);
	}

	return $html;
} # GetDesktopPage()

1;
