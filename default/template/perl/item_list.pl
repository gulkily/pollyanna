#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetItemListHtml { # @files(array of hashes) ; takes @files, returns html list
# sub GetItemListing {
# sub GetItemList {
# example: GetItemListHtml(\@files)
# uses GetItemTemplate()
	my $filesArrayReference = shift; # array of hash refs which contains items
	my $flagsHashReference = shift;

	if (!$filesArrayReference) {
		WriteLog('GetItemListHtml: warning: sanity check failed, missing $filesArrayReference');
		return 'problem getting item list, my apologies. (1)';
	}
	my @files = @{$filesArrayReference}; # de-reference
	if (!scalar(@files)) {
		WriteLog('GetItemListHtml: warning: sanity check failed, missing @files');
		return GetDialogX('No items found.');
		#return 'problem getting item list, my apologies. (2)';
	}

	WriteLog('GetItemListHtml: scalar(@files) = ' . scalar(@files));

	my %flags;
	if ($flagsHashReference) {
		%flags = %{$flagsHashReference};
	}

	my $itemList = '';
	my $itemComma = '';

	my $itemListTemplate = '<span class=itemList></span>'; #todo templatize

	#shift @files;

	foreach my $rowHashRef (@files) { # loop through each file
		my %row = %{$rowHashRef};

		$row{'vote_buttons'} = 1;
		$row{'show_vote_summary'} = 1;
		$row{'display_full_hash'} = 0;
		$row{'trim_long_text'} = 0;

		if ($flags{'vote_return_to'}) {
			$row{'vote_return_to'} = $flags{'vote_return_to'};
		}

		my $itemTemplate;
		$itemTemplate = GetItemTemplate(\%row); # GetIndexPage()

		if (!$itemTemplate) {
			WriteLog('GetItemListHtml: warning: $itemTemplate is FALSE');
		}

		$itemList = $itemList . $itemComma . $itemTemplate;

		if ($itemComma eq '') {
			$itemComma = '';
			#$itemComma = '<hr><br>';
			##$itemComma = '<p>';
		}
	}

	$itemListTemplate = str_replace('<span class=itemList></span>', '<span class=itemList>' . $itemList . '</span>', $itemListTemplate);

	WriteLog('GetItemListHtml: length($itemListTemplate) = ' . length($itemListTemplate));

	return $itemListTemplate;
} # GetItemListHtml()

1;
