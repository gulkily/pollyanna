#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetHistoryDialog {
	my $dialogContent = GetTemplate('html/widget/history.template');
	my $dialog = GetDialogX($dialogContent, 'History');

	return $dialog;
}

1;
