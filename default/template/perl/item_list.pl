#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetItemListHtml { # @files(array of hashes) ; takes @files, returns html list
# sub GetItemListing {
# sub GetItemList {
# sub GetItemListingHtml {
# sub GetItemListing {
# sub ItemListAsHtml {
# example: GetItemListHtml(\@files)
# uses GetItemTemplate()
# this is called when 'full_items' is used
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
	my $itemLimit = 0; # implemented by counting items rather than using LIMIT in SQL

	if ($flags{'item_limit'}) {
		WriteLog('GetItemListHtml: $flags{item_limit} = ' . $flags{'item_limit'});
		$itemLimit = $flags{'item_limit'};
		if ($itemLimit !~ m/^\d+$/) {
			$itemLimit = int($itemLimit);
		} else {
			WriteLog('GetItemListHtml: warning: $itemLimit failed sanity check');
			$itemLimit = 0;
		}
		#todo more sanity checks
	}

	my $itemListTemplate = GetTemplate('html/widget/item_list.template');

	#shift @files;

	my $itemCount = 0;

	foreach my $rowHashRef (@files) { # loop through each file
		if ($itemLimit) {
			if ($itemCount >= $itemLimit) {
				WriteLog('GetItemListHtml: $itemCount >= $itemLimit; breaking');
				last;
			}
		}

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
