#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetItemLabelButtons { # $fileHash, [$tagSet], [$returnTo] ; get vote buttons for item in html form
	# sub GetItemTagButtons {
	# sub GetItemVoteButtons {
	# sub GetVoteButtons {
	# sub GetVotingButtons {
	# sub GetVoteLinks {
	# sub GetItemVoteLinks
	# sub GetVoteButton {
	# sub GetTagLinks {
	my $fileHash = shift; # item's file hash
	my $tagSet = shift;   # (optional) use a particular tagset instead of item's default
	my $returnTo = shift; # (optional) what page to return to instead of current (for use by post.php)
	WriteLog('GetItemLabelButtons(' . ($fileHash ? $fileHash : '-') . ', ' . ($tagSet ? $tagSet : '-') . '); caller = ' . join(',', caller));

	if (!IsItem($fileHash)) {
		WriteLog('GetItemLabelButtons: warning: sanity check failed: $fileHash = ' . $fileHash . '; caller = ' . join(',', caller));
		return '';
	}

	my @quickVotesList; # this will hold all the tag buttons we want to display
	my $voteTotalsRef = DBGetItemLabelTotals2($fileHash);
	my %voteTotals = %{$voteTotalsRef};
	WriteLog('GetItemLabelButtons: scalar(%voteTotals) = ' . scalar(%voteTotals));

	if ($tagSet) {
		# if $tagSet is specified, just use that list of tags
		my $quickVotesForTagSet = GetTemplate('tagset/' . $tagSet);
		if ($quickVotesForTagSet) {
			WriteLog('GetItemLabelButtons: tagset found: ' . $tagSet . '; caller = ' . join(',', caller));
			push @quickVotesList, split("\n", $quickVotesForTagSet);
		}
		else {
			# no tagset?
			WriteLog('GetItemLabelButtons: warning: tagset not found: ' . $tagSet . '; caller = ' . join(',', caller));
			return '';
		}
	} # $tagSet
	else {
		WriteLog('GetItemLabelButtons: tagset not specified; caller = ' . join(',', caller));

		# need to look up item's default tagset
		my $quickVotesForTags;
		foreach my $voteTag (keys %voteTotals) {
			$quickVotesForTags = GetTemplate('tagset/' . $voteTag);
			if ($quickVotesForTags) {
				push @quickVotesList, split("\n", $quickVotesForTags);
			}
		}

		# all items will have a 'flag' button
		push @quickVotesList, 'flag'; #todo this should probably still be a tagset

		# remove duplicates #todo make it a sub
		my %dedupe = map {$_, 1} @quickVotesList;
		@quickVotesList = keys %dedupe;
	}

	require_once('widget/stylesheet.pl');
	my $styleSheet = GetStylesheet(); # for looking up which vote buttons need a class=
	# if they're listed in the stylesheet, add a class= below
	# the class name is tag-foo, where foo is tag

	my $tagButtons = '';
	my $doVoteButtonStyles = GetConfig('html/style_vote_buttons');
	my $jsEnabled = GetConfig('admin/js/enable');

	WriteLog('GetItemLabelButtons: scalar(@quickVotesList) = ' . scalar(@quickVotesList));

	my $commaCount = scalar(@quickVotesList) - 1; # actually semicolons

	foreach my $quickTagValue (@quickVotesList) {
		my $ballotTime = GetTime();

		if ($fileHash && $ballotTime) {
			my $tagButton = GetTemplate('html/vote/vote_button.template');

			if ($jsEnabled) {
				$tagButton = AddAttributeToTag(
					$tagButton,
					'a', 'onclick',
					trim("
						if (window.SignVote) {
							var gt = unescape('%3E');
							return SignVote(this, gt+gt+'\$fileHash\\n#\$voteValue');
						}
					")
				);
			} #todo maybe this should only be added when openpgp.js is enabled? but still use PingUrl() to vote

			if ($doVoteButtonStyles) {
				# this is a hack, think about replace with config/tag_color
				if (index($styleSheet, "tag-$quickTagValue") > -1) {
					#$tagButton =~ s/\$class/tag-$quickTagValue/g;
					$tagButton = str_replace('$class', '/tag-$quickTagValue', $tagButton);
				}
				else {
					#$tagButton =~ s/class="\$class"//g;
					$tagButton = str_replace('$class', '', $tagButton);
				}
			}

			my $quickTagCaption = GetString($quickTagValue);
			WriteLog('GetItemLabelButtons: $quickTagCaption = ' . $quickTagCaption . '; $quickTagValue = ' . $quickTagValue);
			if ($voteTotals{$quickTagCaption}) {
				# $voteTotals{$quickTagCaption} is the number of tags of this type item has

				$quickTagCaption .= '(' . $voteTotals{$quickTagCaption} . ')';
				# $quickTagCaption = '<b><big>' . $quickTagCaption . '</big></b>';
			}

			if ($returnTo) {
				# set value for $returnTo placeholder
				#$tagButton =~ s/\$returnTo/$returnTo/g;
				$tagButton = str_replace('$returnTo', $returnTo, $tagButton);
			}
			else {
				# remove entire returnto= parameter
				#$tagButton =~ s/&returnto=\$returnTo//g;
				$tagButton = str_replace('&returnto=$returnTo', '', $tagButton);
			}

			#$tagButton =~ s/\$fileHash/$fileHash/g;
			#$tagButton =~ s/\$ballotTime/$ballotTime/g;
			#$tagButton =~ s/\$voteValue/$quickTagValue/g;
			#$tagButton =~ s/\$voteCaption/$quickTagCaption/g;
			$tagButton = str_replace('$fileHash', $fileHash, $tagButton);
			$tagButton = str_replace('$ballotTime', $ballotTime, $tagButton);
			$tagButton = str_replace('$voteValue', $quickTagValue, $tagButton);
			$tagButton = str_replace('$voteCaption', $quickTagCaption, $tagButton);

			if ($commaCount) {
				#$tagButton =~ s|</a>|</a>;|;
				$tagButton = str_replace('</a>', '</a>;', $tagButton);
				#it's this way instead of just appending it
				# because it needs to be right after the tag, and the template has
				# \n and a comment after it
				$commaCount--;
			}

			$tagButtons .= trim($tagButton);
		} # if ($fileHash && $ballotTime)
	} # foreach my $quickTagValue (@quickVotesList)

	WriteLog('GetItemLabelButtons: returning $tagButtons; length($tagButtons) = ' . length($tagButtons));

	return $tagButtons;
} # GetItemLabelButtons()

1;