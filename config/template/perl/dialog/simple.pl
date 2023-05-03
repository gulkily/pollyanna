#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetSimpleDialog { # dialogType ; gets simple dialog based on template/html/page/$dialogType.template
	# sub GetSimpleWindow {
	my $dialogType = shift;

	WriteLog('GetSimpleDialog: $dialogType = ' . $dialogType);

	#todo sanity
	my $html = '';
	my $pageContent = GetTemplate("html/page/$dialogType.template");
	if (!$pageContent) {
		WriteLog('GetSimpleDialog: warning: empty template, sanity check failed; $pageContent was FALSE');
		return '';
	}
	my $contentWindow = GetDialogX(
		$pageContent,
		ucfirst($dialogType)
	);

	if ($dialogType =~ m/^[0-9a-z]+$/) {
		$contentWindow = AddAttributeToTag($contentWindow, 'table', 'id', $dialogType);
	}

	return $contentWindow;
} # GetSimpleDialog()

1;