#!usr/bin/perl -T

use strict;
use warnings;
use utf8;

sub GetNocookiePage {
	my $html =
		GetPageHeader('nocookie') .
		GetTemplate('html/maincontent.template') .
		GetDialogX( "<p>Please forgive me, friend, <br>but you must <a href=/profile.html>register</a> first, <br>before you do that</p>", 'No Cookie Haiku' ) .
		GetDialogX( "<p>Return to this page <br>via bookmarks, history, <br>or the Back button.</p>" , 'Tips' ) .
		GetPageFooter('nocookie')
	;

	if (GetConfig('admin/js/enable')) {
		$html = InjectJs($html, qw(utils settings avatar profile upload paste));
	}

	return $html;
} # sub GetNocookiePage()

1;