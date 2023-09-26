#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

#puzzle

sub IndexPuzzle {
	my $textRef = shift;
	my %text = %{$textRef};

	my $message = $text{'message'};
	my $detokenedMessage = $text{'detokenedMessage'};
	my @indexMessageLog = @{$text{'messageLog'}};
	my $fileHash = $text{'fileHash'};
	my $authorKey = $text{'authorKey'};

	WriteLog('IndexPuzzle: $fileHash = ' . $fileHash);

	my $puzzleAuthorKey = '';
	my $mintedAt = '';
	my $checksum = '';
	if ($message =~ m/^([0-9A-F]{16}) ([0-9]{10}) (0\.[0-9]+)/mg) {
		$puzzleAuthorKey = $1;
		$mintedAt = $2;
		$checksum = $3;
	}
	my $titleCandidate = '';

	if ($puzzleAuthorKey && $mintedAt && $checksum) {
		WriteLog("IndexPuzzle: token: puzzle: $puzzleAuthorKey, $mintedAt, $checksum");
		push @indexMessageLog, 'puzzle: ' . $puzzleAuthorKey . ' ' . $mintedAt . ' ' . $checksum;

		if ($puzzleAuthorKey ne $authorKey) {
			WriteLog('IndexPuzzle: puzzle: warning: $puzzleAuthorKey ne $authorKey');
		} else {
			my $hash = sha512_hex($puzzleAuthorKey . ' ' . $mintedAt . ' ' . $checksum);
			my $configPuzzleAccept = GetConfig('puzzle/accept');
			if (!$configPuzzleAccept) {
				$configPuzzleAccept = '';
			}
			my @acceptPuzzlePrefix = split("\n", $configPuzzleAccept);
			push @acceptPuzzlePrefix, GetConfig('puzzle/prefix');

			my $puzzleAccepted = 0;

			foreach my $puzzlePrefix (@acceptPuzzlePrefix) {
				$puzzlePrefix = trim($puzzlePrefix);
				if (!$puzzlePrefix) {
					next;
				}

				my $puzzlePrefixLength = length($puzzlePrefix);
				if (
					(substr($hash, 0, $puzzlePrefixLength) eq $puzzlePrefix) && # hash matches
						($authorKey eq $puzzleAuthorKey) # key matches cookie or fingerprint
				) {
					$message = str_replace($puzzleAuthorKey . ' ' . $mintedAt . ' ' . $checksum, '[Puzzle Solved]', $message); #todo
					#$message = str_replace($puzzleAuthorKey . ' ' . $mintedAt . ' ' . $checksum, '[Puzzle Solved: ' . $puzzlePrefix . ']', $message);

					DBAddItemAttribute($fileHash, 'puzzle_timestamp', $mintedAt);
					DBAddItemAttribute($fileHash, 'puzzle_input', $puzzleAuthorKey . ' ' . $mintedAt . ' ' . $checksum);
					DBAddItemAttribute($fileHash, 'puzzle_result', $hash);
					DBAddItemAttribute($fileHash, 'puzzle_prefix', $puzzlePrefix);
					DBAddLabel($fileHash, $mintedAt, 'puzzle');

					$detokenedMessage = str_replace($puzzleAuthorKey . ' ' . $mintedAt . ' ' . $checksum, '', $detokenedMessage);
					$puzzleAccepted = 1;

					$titleCandidate = '[Puzzle Solved]';

					last;
				}
			} # foreach my $puzzlePrefix (@acceptPuzzlePrefix) {
		}
	} # puzzle

	$text{'message'} = $message;
	$text{'detokenedMessage'} = $detokenedMessage;
	$text{'messageLog'} = \@indexMessageLog;
	$text{'fileHash'} = $fileHash;
	$text{'titleCandidate'} = $titleCandidate;

	return \%text;
} # IndexPuzzle()

1;
