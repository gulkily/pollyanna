#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetPuzzleDialog { # returns write form (for composing text message)
	return 'GetPuzzleDialog() is not finished'; #draft
	my $puzzleForm = GetDialogX(GetTemplate('html/form/puzzle.template'), 'Puzzle?');
	#dirty hack
	#$writeForm =~ s/textarea/input type=hidden/g;
	WriteLog('GetPuzzleDialog()');

	if (GetConfig('admin/php/enable')) {
		if (GetConfig('admin/php/enable') && !GetConfig('admin/php/rewrite')) {
			# if php is enabled but rewrite is disabled
			# change submit target to post.php
			my $postHtml = 'post\\.html'; # post.html
			$puzzleForm =~ s/$postHtml/post.php/; #todo is this necessary?
		}
	}

	my $initText = '';
	$puzzleForm =~ s/\$initText/$initText/g;

	$puzzleForm = '<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' . $puzzleForm . '</form>';#todo

	return $puzzleForm;
} # GetPuzzleDialog()

1;
