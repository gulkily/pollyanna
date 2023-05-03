#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetChainLogAsDialog {
# sub GetVerificationTable {
	#my $chainLog = `nl html/chain.log | tail -n 11`;
	my $chainLog = `tail -n 5 html/chain.log`;
	my @chainArray = split("\n", $chainLog);

	my $chainRows = '';

	while (@chainArray) {
		my $line = pop @chainArray;
		my @lineItems = split('\|', $line);

		$chainRows .= '<tr>';
		#$chainRows .= '<td>' . $lineNumber . '</td>';
		$chainRows .= '<td>' . GetItemHtmlLink($lineItems[0], substr(DBGetItemTitle($lineItems[0]), 0, 16)) . '</td>'; #item
		$chainRows .= '<td>' . substr($lineItems[0], 0, 8) . '</td>'; #item
		#$chainRows .= '<td>' . substr($lineItems[1], 0, 10) . '</td>'; #timestamp
		$chainRows .= '<td>' . GetTimestampWidget($lineItems[1]) . '</td>'; #timestamp
		$chainRows .= '<td>' . substr($lineItems[2], 0, 8) . '</td>'; #checksum
		$chainRows .= '</tr>';
	}

	$chainRows .= '<tr><td></td><td></td><td></td></tr>';

	my %dialogParams;
	$dialogParams{'body'} = $chainRows;
	$dialogParams{'title'} = 'Notarized';
	$dialogParams{'headings'} = 'title,item,timestamp,checksum';
	$dialogParams{'table_sort'} = 0;
	my $chainDialog = GetDialogX2(\%dialogParams);

	if (!$chainDialog) {
		WriteLog('GetChainLogAsDialog: warning: $chainDialog is FALSE');
	}

	return $chainDialog;
} # GetChainLogAsDialog()

1;