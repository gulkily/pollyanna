#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub RunLlm { # $item ; sends item text as prompt to language model and logs a new item with response
# sub RunGpt {
	my $item = shift;
	WriteLog("RunLlm($item)");

	#my $runLog = 'run_log/' . $item;

	my $promptText = '';
	$promptText .= ">>$item";
	$promptText .= "\n\n";
	$promptText .= GetTemplate('prompt/item_categorize.txt');
	$promptText .= "\n\n";
	$promptText .= GetFileMessage($item);
	$promptText .= "\n\n";

	my $promptHash = sha1_hex($promptText);
	my $promptFile = substr($promptHash, 0, 2) . '/' . substr($promptHash, 2, 2) . '/' . $promptHash . '.txt';
	my $TXTDIR = GetDir('txt');
	PutFile("$TXTDIR/$promptFile", $promptText);
	$promptHash = IndexFile("$TXTDIR/$promptFile");
	my $filePath = GetFilePath($item);

	my $itemType = DBGetItemType($promptHash);
	my $scriptPath = 'default/template/python/run_prompt.py';
	#my $scriptPath = 'default/template/python/llm.py';
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

					#WriteLog('RunLlm: $pythonCommand was run with $filePath = ' . $filePath . '; about to save output to $runLog = ' . $runLog);

					#PutCache($runLog, $result); # store the result in cache

					#sub AttachLogToItem { # $itemHash, $result, $runStart, $runFinish ; attaches log to item
					AddLogToItem($item, $result, $runStart, $runFinish);

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