#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetNeighborDialog { # $pageName, $pageArgument ; displays links to same resource on other instances
# sub GetNeighborsDialog {

	my $pageName = shift;
	my $pageArgument = shift;

	#todo sanity checks

	WriteLog('GetNeighborDialog: $pageName = ' . $pageName . '; $pageArgument = ' . $pageArgument . '; caller = ' . join(',', caller));

	my @neighbors = GetConfigListAsArray('neighbor');
	my $linkTemplate = '<a href="http://$host/$pageName.html">$host</a>';
	$linkTemplate =~ s/\$pageName/$pageName/g;

	#if ($pageName eq 'item') {
	#	my $itemHash = $pageArgument;
	#	my $itemPath = substr($itemHash, 0, 2) . '/' . substr($itemHash, 2, 2) . '/' . substr($itemHash, 0, 8);
	#	$linkTemplate = '<a href="http://$host/$pageName/$itemPath/$itemHash.html">$host</a>';
	#	$linkTemplate =~ s/\$pageName/$pageName/g;
	#	$linkTemplate =~ s/\$itemHash/$itemHash/g;
	#	$linkTemplate =~ s/\$itemPath/$itemPath/g;
	#}

	my $dialog = '';
	for my $neighbor (@neighbors) {
		chomp($neighbor);
		$neighbor = trim($neighbor);
		if ($neighbor =~ m/^([0-9a-z:\.]+)$/) {
			$neighbor = $1;
		} else {
			#todo
			next;
		}

		my $link = $linkTemplate;
		$link =~ s/\$host/$neighbor/g;
		$dialog .= $link . '<br/>';
	}

	$dialog = GetDialogX($dialog, 'Neighbors');
	$dialog = '<span class=advanced>' . $dialog . '</span>';
	return $dialog;

} # GetNeighborDialog()

1;