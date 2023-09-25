#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub ImageMakeThumbnails { # $file
	my $file = shift;
	chomp $file; #todo sanity

	my $fileHash = GetFileHash($file);
	if (!$fileHash) {
		WriteLog('ImageMakeThumbnails: warning: $fileHash was FALSE');
		return '';
	}

	my $fileShellEscaped = EscapeShellChars($file); #todo this is still a hack, should rename file if it has shell chars?

	if ($fileShellEscaped =~ m/(.+)/) { #todo #security
		$fileShellEscaped = $1;
	} else {
		WriteLog('IndexImageFile: warning: sanity check failed on $fileShellEscaped!');
		return '';
	}

	# make 800x800 thumbnail
	state $HTMLDIR = GetDir('html');

	if ($HTMLDIR =~ m/(.+)/) { #todo #security
		$HTMLDIR = $1;
	} else {
		WriteLog('IndexImageFile: warning: sanity check failed on $HTMLDIR!');
		return '';
	}

	if ($fileHash =~ m/(.+)/) { #todo #security
		$fileHash = $1;
	} else {
		WriteLog('IndexImageFile: warning: sanity check failed on $fileHash');
		return '';
	}

	#imagemagick

	#my @res = qw(800 512 42);
	if (!-e "$HTMLDIR/thumb/thumb_800_$fileHash.gif") {
		my $convertCommand = "convert \"$fileShellEscaped\" -auto-orient -thumbnail 800x800 -strip $HTMLDIR/thumb/thumb_800_$fileHash.gif";
		WriteLog('IndexImageFile: ' . $convertCommand);

		my $convertCommandResult = `$convertCommand`;
		WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);

		#sub DBAddTask { # $taskType, $taskName, $taskParam, $touchTime # make new task

	}
	if (!-e "$HTMLDIR/thumb/thumb_512_g_$fileHash.gif") {
		my $convertCommand = "convert \"$fileShellEscaped\" -auto-orient -thumbnail 512x512 -colorspace Gray -blur 0x16 -strip $HTMLDIR/thumb/thumb_512_g_$fileHash.gif";
		#my $convertCommand = "convert \"$fileShellEscaped\" -scale 5% -blur 0x25 -resize 5000% -colorspace Gray -blur 0x8 -thumbnail 512x512 -strip $HTMLDIR/thumb/thumb_512_$fileHash.gif";
		WriteLog('IndexImageFile: ' . $convertCommand);

		my $convertCommandResult = `$convertCommand`;
		WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
	}
	if (!-e "$HTMLDIR/thumb/thumb_512_$fileHash.gif") {
		my $convertCommand = "convert \"$fileShellEscaped\" -auto-orient -thumbnail 512x512 -strip $HTMLDIR/thumb/thumb_512_$fileHash.gif";
		WriteLog('IndexImageFile: ' . $convertCommand);

		my $convertCommandResult = `$convertCommand`;
		WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
	}
	if (!-e "$HTMLDIR/thumb/thumb_42_$fileHash.gif") {
		my $convertCommand = "convert \"$fileShellEscaped\" -auto-orient -thumbnail 42x42 -strip $HTMLDIR/thumb/thumb_42_$fileHash.gif";
		WriteLog('IndexImageFile: ' . $convertCommand);

		my $convertCommandResult = `$convertCommand`;
		WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
	}
} # ImageMakeThumbnails()

1;