#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetFloatDialog { # returns settings dialog
	# sub GetFloatWindow {
	WriteLog('GetFloatDialog() BEGIN');
	return '<form>' . GetDialogX(GetTemplate('html/form/float.template'), 'Float') . '</form>';
} # GetFloatDialog()

1;
