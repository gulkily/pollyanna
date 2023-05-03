#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetOperatorDialog {
	my $operatorTemplate = GetTemplate('html/form/operator.template');
	my $operatorWindow = GetDialogX($operatorTemplate, 'Operator');
	$operatorWindow = '<form id=frmOperator name=frmOperator class=admin>' . $operatorWindow . '</form>';
	return $operatorWindow;
} # GetOperatorDialog()

1;