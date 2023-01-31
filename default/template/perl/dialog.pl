#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

require_once('dialog/chain_log.pl');
require_once('dialog/access.pl');
require_once('get_dialog.pl');
require_once('dialog/tos.pl');
require_once('dialog/write.pl');
require_once('dialog/puzzle.pl');

sub GetSearchDialog { # search dialog for search page
	my $searchForm = GetTemplate('html/form/search.template');
	my $searchWindow = GetDialogX($searchForm, 'Public Search');
	return $searchWindow;
} # GetSearchDialog()

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

sub GetOperatorDialog {
	my $operatorTemplate = GetTemplate('html/form/operator.template');
	my $operatorWindow = GetDialogX($operatorTemplate, 'Operator');
	$operatorWindow = '<form id=frmOperator name=frmOperator class=admin>' . $operatorWindow . '</form>';
	return $operatorWindow;
} # GetOperatorDialog()

sub GetAnnoyancesDialog { # returns settings dialog
# sub GetAnnoyancesWindow {
	WriteLog('GetAnnoyancesDialog() BEGIN');
	return '<form>' . GetDialogX(GetTemplate('html/form/annoyances.template'), 'Annoyances') . '</form>';
} # GetAnnoyancesDialog()

require_once('dialog/settings.pl');

1;
