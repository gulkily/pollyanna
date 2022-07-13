#!/usr/bin/perl -T

use strict;
use warnings;

sub IndexScunthorpe {
	my $cussWords = GetTemplate('list/scunthorpe');
	# #scunthorpe is a very basic word filter
	# it can be used to apply a negative score to
	# common inflammatory or offensive terms
	# stored \n-separated in config/list/scunthorpe

	my $textRef = shift;
	my %text = %{$textRef};

	my $message = $text{'message'};
	my @indexMessageLog = @{$text{'messageLog'}};
	my $fileHash = $text{'fileHash'};

	WriteLog('IndexScunthorpe: $fileHash = ' . $fileHash);

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
					WriteLog('IndexScunthorpe: scunthorpe: $word = ' . $word);
					$cussWordCount++;
				}
			}

			if ($cussWordCount) {
                WriteLog('IndexScunthorpe: $cussWordCount = ' . $cussWordCount);

                push @indexMessageLog, '#scunthorpe matches found: ' . $cussWordCount;
				DBAddVoteRecord($fileHash, 0, 'scunthorpe');
			}
		} # @cussWord
	} # $cussWords

	$text{'message'} = $message;
	$text{'messageLog'} = \@indexMessageLog;
	$text{'fileHash'} = $fileHash;

	return \%text;
} # IndexScunthorpe()

1;
