#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub IndexScunthorpe { # $textRef ; adds to vote table, returns same hash plus index log
# $textRef is a reference to a hash of {'message', 'messageLog', 'fileHash'}
	my $cussWords = GetTemplate('list/scunthorpe');
	# #scunthorpe is a very basic word filter
	# it can be used to apply a negative score to
	# common inflammatory or offensive terms
	# stored \n-separated in config/list/scunthorpe
	#
	# if any words are found, a vote of "scunthorpe" will be added to the item
	# returns hash reference to hash, message, and parse log

	my $textRef = shift;
	my %text = %{$textRef};

	my $message = $text{'message'};
	my @indexMessageLog = @{$text{'messageLog'}};
	my $fileHash = $text{'fileHash'};

	WriteLog('IndexScunthorpe($fileHash = ' . $fileHash . '); caller = ' . join(',', caller));

	if ($cussWords) {
		WriteLog('IndexScunthorpe: $cussWords is TRUE');
		my $cussWordCount = 0;

		$message = trim($message);

		my @cussWord = split("\n", $cussWords);
		if (@cussWord) {
			for my $word (@cussWord) {
				$word = trim($word);
				#WriteLog('IndexScunthorpe: $word = ' . $word);
				# if ($word && (index($message, $word) != -1)) {
				if (
					$word &&
					(
						$message =~ m/\W$word\W/i
						||
						$message =~ m/^$word/i
						||
						$message =~ m/$word$/i
					)
				) {
					# match word on beginning of line, end of line, or between two whitespaces
					# this helps reduce the scunthorpe problem

					WriteLog('IndexScunthorpe: scunthorpe: $word = ' . $word);
					$cussWordCount++;
				}
			}

			if ($cussWordCount) {
				WriteLog('IndexScunthorpe: $cussWordCount = ' . $cussWordCount);

				push @indexMessageLog, '#scunthorpe matches found: ' . $cussWordCount;
				DBAddLabel($fileHash, 0, 'scunthorpe');
			}
		} # @cussWord
	} # if ($cussWords)
	else {
		WriteLog('IndexScunthorpe: warning: $cussWords was false, skipping');
	}

	$text{'message'} = $message;
	$text{'messageLog'} = \@indexMessageLog;
	$text{'fileHash'} = $fileHash;

	return \%text;
} # IndexScunthorpe()

1;
