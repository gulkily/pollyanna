#!usr/bin/perl -T

use strict;
use warnings;
use utf8;

sub GetNocookiePage {
	my $html =
		GetPageHeaderWithoutMenu('nocookie') .
		GetDialogX( "<p>Please forgive me, friend, <br>but you must <a href=/profile.html>register</a> first, <br>before you do that</p>", 'No Cookie Haiku' ) .
		GetDialogX( "<p>Return to this page <br>via bookmarks, history, <br>or the Back button.</p>" , 'Tips' ) .
		GetPageFooterWithoutMenu('nocookie')
	;

	return $html;
}

1;