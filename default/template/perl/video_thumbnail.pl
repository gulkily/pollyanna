#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub VideoMakeThumbnails { # $file
	my $file = shift;
	chomp $file; #todo sanity

	my $fileHash = GetFileHash($file);
	if (!$fileHash) {
		WriteLog('VideoMakeThumbnails: warning: $fileHash was FALSE');
		return '';
	}

	my $fileShellEscaped = EscapeShellChars($file); #todo this is still a hack, should rename file if it has shell chars?

	if ($fileShellEscaped =~ m/(.+)/) { #todo #security
		$fileShellEscaped = $1;
	} else {
		WriteLog('VideoMakeThumbnails: warning: sanity check failed on $fileShellEscaped!');
		return '';
	}

	my $thumbnailExtension = GetConfig('setting/admin/image/thumbnail_extension'); # .gif

	# make 800x800 thumbnail
	state $HTMLDIR = GetDir('html');

	if ($HTMLDIR =~ m/(.+)/) { #todo #security
		$HTMLDIR = $1;
	} else {
		WriteLog('VideoMakeThumbnails: warning: sanity check failed on $HTMLDIR!');
		return '';
	}

	if ($fileHash =~ m/(.+)/) { #todo #security
		$fileHash = $1;
	} else {
		WriteLog('VideoMakeThumbnails: warning: sanity check failed on $fileHash');
		return '';
	}

	#ffmpeg

	if (!-e "$HTMLDIR/thumb/thumb_video_$fileHash" . $thumbnailExtension) {
		my $ffmpegCommand = "ffmpeg -i \"$fileShellEscaped\" -ss 00:00:01.000 -vframes 1 $HTMLDIR/thumb/thumb_800_$fileHash" . $thumbnailExtension;

		WriteLog('VideoMakeThumbnails: ' . $ffmpegCommand);

		my $ffmpegCommandResult = `$ffmpegCommand`;
		WriteLog('VideoMakeThumbnails: ffmpeg result: ' . $ffmpegCommandResult);
	}

	#imagemagick

	if (!-e "$HTMLDIR/thumb/thumb_video_$fileHash" . $thumbnailExtension) {
		#my @res = qw(800 512 42);
		if (!-e "$HTMLDIR/thumb/thumb_800_$fileHash" . $thumbnailExtension) {
			my $convertCommand = "convert \"$HTMLDIR/thumb/thumb_video_$fileHash" . $thumbnailExtension . ""\" -auto-orient -thumbnail 800x800 -strip $HTMLDIR/thumb/thumb_800_$fileHash" . $thumbnailExtension . "";
			WriteLog('VideoMakeThumbnails: ' . $convertCommand);

			my $convertCommandResult = `$convertCommand`;
			WriteLog('VideoMakeThumbnails: convert result: ' . $convertCommandResult);

			#sub DBAddTask { # $taskType, $taskName, $taskParam, $touchTime # make new task

		}
		if (!-e "$HTMLDIR/thumb/thumb_512_g_$fileHash" . $thumbnailExtension) {
			my $convertCommand = "convert \"$HTMLDIR/thumb/thumb_video_$fileHash" . $thumbnailExtension . "\" -auto-orient -thumbnail 512x512 -colorspace Gray -blur 0x16 -strip $HTMLDIR/thumb/thumb_512_g_$fileHash" . $thumbnailExtension;
			#my $convertCommand = "convert \"$fileShellEscaped\" -scale 5% -blur 0x25 -resize 5000% -colorspace Gray -blur 0x8 -thumbnail 512x512 -strip $HTMLDIR/thumb/thumb_512_$fileHash" . $thumbnailExtension;
			WriteLog('VideoMakeThumbnails: ' . $convertCommand);

			my $convertCommandResult = `$convertCommand`;
			WriteLog('VideoMakeThumbnails: convert result: ' . $convertCommandResult);
		}
		if (!-e "$HTMLDIR/thumb/thumb_512_$fileHash" . $thumbnailExtension) {
			my $convertCommand = "convert \"$HTMLDIR/thumb/thumb_video_$fileHash" . $thumbnailExtension . "\" -auto-orient -thumbnail 512x512 -strip $HTMLDIR/thumb/thumb_512_$fileHash" . $thumbnailExtension;
			WriteLog('VideoMakeThumbnails: ' . $convertCommand);

			my $convertCommandResult = `$convertCommand`;
			WriteLog('VideoMakeThumbnails: convert result: ' . $convertCommandResult);
		}
		if (!-e "$HTMLDIR/thumb/thumb_42_$fileHash" . $thumbnailExtension) {
			my $convertCommand = "convert \"$HTMLDIR/thumb/thumb_video_$fileHash" . $thumbnailExtension . "\" -auto-orient -thumbnail 42x42 -strip $HTMLDIR/thumb/thumb_42_$fileHash" . $thumbnailExtension;
			WriteLog('VideoMakeThumbnails: ' . $convertCommand);

			my $convertCommandResult = `$convertCommand`;
			WriteLog('VideoMakeThumbnails: convert result: ' . $convertCommandResult);
		}
	}
} # VideoMakeThumbnails()

1;