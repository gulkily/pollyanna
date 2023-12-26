#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetConceptDialog { ## not used
	my $pageType = shift; # type of page

	my $conceptDialog = '';

	my $conceptInformation = GetString('concept/' . $pageType . '.txt', '', 1);
	# if that doesn't work, try singular form
	if (!$conceptInformation) {
		if (substr($pageType, -1) eq 's') {
			$conceptInformation = GetString('concept/' . substr($pageType, 0, -1) . '.txt', '', 1);
		}
	}

	if ($conceptInformation) {
		$conceptDialog = '<span class=advanced>' . GetDialogX(ConceptForWeb($conceptInformation), 'Concept') . '</span>';
	}

	return $conceptDialog;
} GetConceptDialog()

1;