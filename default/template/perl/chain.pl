#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub MakeChainIndex { # $import = 1; reads from log/chain.log and puts it into item_attribute table
	# note: this is kind of a hack, and non-importing validation should just be separate own sub
	# note: this hack seems to work ok

	my $import = shift;
	if (!defined($import)) {
		$import = 1;
	} else {
		chomp $import;
		$import = ($import ? 1 : 0);
	}
	WriteMessage("MakeChainIndex($import)");

	my $newLog = '';

	if (GetConfig('setting/admin/index/read_chain_log')) {
		WriteLog('MakeChainIndex: setting/admin/index/read_chain_log was TRUE');
		my $chainLog = GetFile('html/chain.log');

		if (defined($chainLog) && $chainLog) {
			WriteLog('MakeChainIndex: $chainLog was defined');
			my @addedRecord = split("\n", $chainLog);

			my $previousLine = '';
			my $sequenceNumber = 0;

			my %return;

			foreach my $currentLine (@addedRecord) {
				WriteLog("MakeChainIndex: $currentLine");
				WriteMessage("Verifying Chain: $sequenceNumber");

				my ($fileHash, $addedTime, $proofHash) = split('\|', $currentLine);
				my $expectedHash = md5_hex($previousLine . '|' . $fileHash . '|' . $addedTime);

				my $isChecksumGood = 0;

				if ($expectedHash ne $proofHash) {
					WriteLog('MakeChainIndex: warning: checksum mismatch.');

					$newLog .= "$fileHash|$addedTime|$expectedHash\n";
				} else {
					$newLog .= "$fileHash|$addedTime|$proofHash\n";
					$isChecksumGood = 1;
				}

				DBAddItemAttribute($fileHash, 'chain_timestamp', $addedTime);#todo may not need
				DBAddItemAttribute($fileHash, 'chain_sequence', $sequenceNumber, $addedTime);
				DBAddItemAttribute($fileHash, 'chain_previous', $previousLine);
				DBAddItemAttribute($fileHash, 'chain_checksum_good', $isChecksumGood);
				DBAddItemAttribute($fileHash, 'chain_hash', $fileHash);
				WriteLog('MakeChainIndex: $sequenceNumber = ' . $sequenceNumber);
				WriteLog('MakeChainIndex: (next item stub/aka checksum) $previousLine = ' . $previousLine);

				$return{'chain_sequence'} = $sequenceNumber;
				$return{'chain_previous'} = $previousLine;
				$return{'chain_timestamp'} = $addedTime;

				$sequenceNumber = $sequenceNumber + 1;

				if ($isChecksumGood) {
					$previousLine = $currentLine;
				} else {
					$previousLine = "$fileHash|$addedTime|$expectedHash";
				}
			} # foreach $currentLine (@addedRecord)

			WriteMessage("==========================");
			WriteMessage("Verifying Chain: Complete!");
			WriteMessage("==========================");

			PutFile('html/chain2.log', $newLog);

			DBAddItemAttribute('flush');

			return %return;
		} # $chainLog
		else {
			WriteLog('MakeChainIndex: warning: $chainLog was NOT defined');
			return 0;
		}
	} # GetConfig('setting/admin/index/read_chain_log')
	else {
		WriteLog('MakeChainIndex: setting/admin/index/read_chain_log was FALSE');
		return 0;
	}

	WriteLog('MakeChainIndex: warning: unreachable was reached');
	return 0;
} # MakeChainIndex()

sub RemakeChain {
	#
	# # save the current chain.log and create new one
	# # new chain.log should go up to the point of the break
	# my $curTime = GetTime();
	# my $moveChain = `mv html/chain.log html/chain.log.$curTime ; head -n $sequenceNumber html/chain.log.$curTime > html/chain_new.log; mv html/chain_new.log html/chain.log`;
	#
	# # make a record of what just happened
	# my $moveChainMessage = 'Chain break detected. Timestamps for items may reset. #meta #warning ' . $curTime;
	# PutFile('html/txt/chain_break_' . $curTime . '.txt');
	#
	# if ($import) {
	# 	MakeChainIndex($import); # recurse
	# }
	#
	# WriteLog('MakeChainIndex: return 0');
	# return 0;
}

sub AddToChainLog { # $fileHash ; add line to log/chain.log
	# line format is:
	# file_hash|timestamp|checksum
	# file_hash = hash of file, a-f0-9 40
	# timestamp = epoch time in seconds, no decimal
	# checksum  = hash of new line with previous line
	#
	# if success, returns timestamp of item (epoch seconds)

	my $fileHash = shift;

	if (!$fileHash) {
		WriteLog('AddToChainLog: warning: sanity check failed');
		return '';
	}

	chomp $fileHash;

	if (!IsItem($fileHash)) {
		WriteLog('AddToChainLog: warning: sanity check failed');
		return '';
	}

	state $HTMLDIR = GetDir('html');
	my $logFilePath = "$HTMLDIR/chain.log"; #public

	$fileHash = IsItem($fileHash);

	if ($fileHash && $logFilePath) {
		#look for existin entry, exit if found
		my $findExistingCommand = "grep ^$fileHash $logFilePath";
		my $findExistingResult = `$findExistingCommand`;

		WriteLog("AddToChainLog: $findExistingCommand returned $findExistingResult");
		if ($findExistingResult) { #todo remove fork
			# hash already exists in chain, return
			#todo return timestamp
			my ($exHash, $exTime, $exChecksum) = split('\|', $findExistingResult);

			if ($exTime) {
				return $exTime;
			} else {
				return 0;
			}
		}
	} else {
		WriteLog('AddToChainLog: warning: sanity check failed');
	}

	# get components of new line: hash, timestamp, and previous line
	my $newAddedTime = GetPaddedEpochTimestamp();

	my $logLine = $fileHash . '|' . $newAddedTime;
	my $lastLineAddedLog = `tail -n 1 $logFilePath`; #note the backticks
	if (!$lastLineAddedLog) {
		$lastLineAddedLog = '';
	}
	chomp $lastLineAddedLog;
	my $lastAndNewTogether = $lastLineAddedLog . '|' . $logLine;
	my $checksum = md5_hex($lastAndNewTogether);
	my $newLineAddedLog = $logLine . '|' . $checksum;

	WriteLog('AddToChainLog: $lastLineAddedLog = ' . $lastLineAddedLog);
	WriteLog('AddToChainLog: $lastAndNewTogether = ' . $lastAndNewTogether);
	WriteLog('AddToChainLog: md5(' . $lastAndNewTogether . ') = $checksum  = ' . $checksum);
	WriteLog('AddToChainLog: $newLineAddedLog = ' . $newLineAddedLog);

	if (!$lastLineAddedLog || ($newLineAddedLog ne $lastLineAddedLog)) {
		# write new line to file
		AppendFile($logFilePath, $newLineAddedLog);

		# figure out how many existing entries for chain sequence value
		my $chainLogLineCount = `wc -l html/chain.log | cut -d " " -f 1`;
		$chainLogLineCount = trim($chainLogLineCount);
		if (!$chainLogLineCount) {
			$chainLogLineCount = 0;
		}
		my $chainSequenceNumber = $chainLogLineCount - 1;
		if ($chainSequenceNumber < 0) {
			WriteLog('AddToChainLog: warning: $chainSequenceNumber < 0');
			$chainSequenceNumber = 0;
		}

		# add to index database
		DBAddItemAttribute($fileHash, 'chain_timestamp', $newAddedTime);
		DBAddItemAttribute($fileHash, 'chain_sequence', $chainSequenceNumber, $newAddedTime); #
		DBAddItemAttribute('flush');
	}

	return $newAddedTime;
} # AddToChainLog()

sub SquashChain { # compresses chain by removing references to removed items
# sub CollapseChain {
	#todo check for if squash is not needed?

	WriteLog('SquashChain: warning: this sub is not yet finished');
	exit;

	my $TXTDIR = GetDir('txt');
	my $curTime = GetTime();

	my $oldChainFile = "$TXTDIR/oldchain.txt";
	my $mainChainFile = 'html/chain.log';
	my $newChainFile = "$TXTDIR/newchain.txt";

	WriteLog('SquashChain: $oldChainFile = ' . $oldChainFile . '; $mainChainFile = ' . $mainChainFile);

	if (-e $mainChainFile) {
		PutFile($oldChainFile, GetFile($mainChainFile));
		unlink($mainChainFile);
	}

	my @goodItems = SqliteGetColumnArray('new', 0);

	foreach my $goodItem (@goodItems) {
		#todo refactor
		PutFile('make_new_chain.sh', '#!/bin/sh');
		AppendFile('make_new_chain.sh', "\n");
		AppendFile('make_new_chain.sh', "grep $goodItem $oldChainFile >> $newChainFile &");
	}
	system('bash make_new_chain.sh');
	rename($newChainFile, $mainChainFile);

} # SquashChain()

1;