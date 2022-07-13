#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAccessDialog {
	my $accessTemplate = GetTemplate('html/access.template');
	if (GetConfig('admin/js/enable')) {
		$accessTemplate = AddAttributeToTag($accessTemplate, 'input value="Beginner"', 'onclick', "if (window.SetInterfaceMode) { return SetInterfaceMode('beginner', this); }");
		$accessTemplate = AddAttributeToTag($accessTemplate, 'input value="Intermediate"', 'onclick', "if (window.SetInterfaceMode) { return SetInterfaceMode('intermediate', this); }");
		$accessTemplate = AddAttributeToTag($accessTemplate, 'input value="Advanced"', 'onclick', "if (window.SetInterfaceMode) { return SetInterfaceMode('expert', this); }");
	}

	$accessTemplate = GetWindowTemplate(
		$accessTemplate,
		'Interface'
	);

	$accessTemplate =~ s/access\.html/settings.html/;
	return $accessTemplate;
} # GetAccessDialog()

1;