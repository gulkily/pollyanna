#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub RunLlm { # $item ; calls 'run' action on specified item
# sub RunGpt {
	my $item = shift;
	WriteLog("RunLlm($item)");

	my $runLog = 'run_log/' . $item;

	my $filePath = DBGetItemFilePath($item);
	my $itemType = DBGetItemType($item);
	my $scriptPath = 'default/template/python/llm.py';
	#todo optimize this to reduce database queries

	if (1) {
		if (-e $filePath) {
			if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
				$filePath = $1;

				my $pythonCommand = '';
				$pythonCommand = `which python`;
				if (!$pythonCommand) {
					$pythonCommand = `which python3`;
				}
				# if (!$pythonCommand) {
				# 	$pythonCommand = `which python2`;
				# }
				if (!$pythonCommand) {
					WriteLog('RunLlm: warning: $pythonCommand was FALSE');
					return '';
				}
				chomp $pythonCommand;
				if ($pythonCommand =~ m/^([\/a-z3]+)$/) {
					$pythonCommand = $1;

					`chmod +x $scriptPath`; # make file executable
					my $runStart = time();
					my $fullCommand = "$pythonCommand $scriptPath $filePath";
					WriteLog('RunLlm: $fullCommand = ' . $fullCommand);
					my $result = `$pythonCommand $scriptPath $filePath`; # run and collect the result #todo quotes and escape
					my $runFinish = time();

					DBAddItemAttribute($item, 'llm_run_start', $runStart);
					DBAddItemAttribute($item, 'llm_run_finish', $runFinish);

					WriteLog('RunLlm: $pythonCommand was run with $filePath = ' . $filePath . '; about to save output to $runLog = ' . $runLog);

					PutCache($runLog, $result); # store the result in cache

					{
						my $newItemFooter = "
							--
							>>$item
							start: $runStart
							finish: $runFinish
						";
``						$newItemFooter = trim($newItem);
						$newItemFooter = str_replace("\t", "", $newItem);

						my $newItem = $result . "\n" . $newItemFooter;

						my $TXTDIR = GetDir('txt');
						my $newHash = sha1_hex($newItem);
						my $newPath = substr($newHash, 0, 2) . '/' . substr($newHash, 2, 2) . '/' . $newHash . '.txt';
						PutFile("$TXTDIR/$newPath", $newItem);
						IndexFile("$TXTDIR/$newPath");
					}

					return 1;
				} # if ($pythonCommand =~ m/^([\/a-z3]+)$/)
				else {
					WriteLog('RunLlm: $pythonCommand failed sanity check; $pythonCommand = "' . $pythonCommand . '"');
				}
			} # if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/)
		} # if (-e $filePath)
	} # if ($itemType eq 'py')

	{
		WriteLog('RunLlm: warning: fallthrough, no handler found for $item = ' . $item . '; caller = ' . join(',', caller));
	}
} # RunLlm()

1;