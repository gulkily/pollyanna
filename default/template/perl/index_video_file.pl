#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;


sub IndexVideoFile { # $file ; indexes one video file into database and makes thumbnails
# sub IndexVidyaFile {
	# Reads a given $file, gets its attributes, puts it into the index database
	# If ($file eq 'flush), flushes any queued queries
	# Also sets appropriate task entries

	if (!GetConfig('setting/admin/ffmpeg/enable')) {
		WriteLog('IndexVideoFile: warning: called when ffmpeg/enable is false');
		return '';
		#todo deal with it better
	}

	my $file = shift;
	chomp($file);

	if ($file =~ m/\s/) {
		WriteLog('IndexVideoFile: warning: sanity check failed, $file contains space character, which is not allowed');
		return 0;
	}

	if ($file =~ m/^([0-9a-zA-Z.\/_\-:]+)$/) { #todo bug here?
		if ($1 eq $file) {
			$file = $1;
		} else {
			WriteLog('IndexVideoFile: warning: sanity check 2 failed on $file: ' . $file);
			return 0;
		}
	} else {
		WriteLog('IndexVideoFile: warning: sanity check 1 failed on $file: ' . $file);
		return 0;
	}

	WriteLog("IndexVideoFile($file)");

	if ($file eq 'flush') {
		WriteLog("IndexVideoFile(flush)");
		DBAddItemAttribute('flush');
		DBAddItem('flush');
		DBAddLabel('flush');
		DBAddPageTouch('flush');

		return 1;
	}

	#my @tagFromFile;
	#my @tagsFromFile;
	my @tagFromPath;

	my $addedTime;          # time added, epoch format
	my $fileHash;            # git's hash of file blob, used as identifier

	if (IsVideoFile($file)) {
		my $fileHash = GetFileHash($file);

		if (GetCache('indexed/'.$fileHash)) {
			WriteLog('IndexVideoFile: skipping because of flag: indexed/'.$fileHash);
			return $fileHash;
		}

		WriteLog('IndexVideoFile: $fileHash = ' . ($fileHash ? $fileHash : '--'));

		$addedTime = DBGetAddedTime($fileHash);
		# get the file's added time.

		# debug output
		WriteLog('IndexVideoFile: $file = ' . ($file?$file:'false'));
		WriteLog('IndexVideoFile: $fileHash = ' . ($fileHash?$fileHash:'false'));
		WriteLog('IndexVideoFile: $addedTime = ' . ($addedTime?$addedTime:'false'));

		# if the file is present in deleted.log, get rid of it and its page, return
		if (IsFileDeleted($file, $fileHash)) {
			# write to log
			#todo
			WriteLog('IndexVideoFile: IsFileDeleted() returned true, returning');
			return 0;
		}

		if (!$addedTime) {
			WriteLog('IndexVideoFile: file missing $addedTime; if write_chain_log is TRUE, add it to chain:');
			if (GetConfig('admin/logging/write_chain_log')) {
				$addedTime = AddToChainLog($fileHash);
			} else {
				$addedTime = GetTime();
			}
			if (!$addedTime) {
				# sanity check
				WriteLog('IndexVideoFile: warning: sanity check failed for $addedTime');
				$addedTime = GetTime();
			}
		}

		my $itemName = TrimPath($file);

		require_once('video_thumbnail.pl');
		VideoMakeThumbnails($file);

		DBAddItem($file, $itemName, '', $fileHash, 'video', 0);
		DBAddItem('flush');
		#DBAddItemAttribute($fileHash, 'title', $itemName, $addedTime);

		my $videoTitle = $itemName;
		while (length($videoTitle) > 0 && $videoTitle =~ m/[0-9\.]+$/) {
			$videoTitle = substr($videoTitle, 0, length($videoTitle) - 1);
		}
		DBAddItemAttribute($fileHash, 'title', $videoTitle, time()); #todo time should come from actual file time #todo re-add this

		DBAddLabel($fileHash, $addedTime, 'video'); # add video label

		if (@tagFromPath) {
			foreach my $tag (@tagFromPath) {
				DBAddLabel($fileHash, $addedTime, $tag);
			}
		}

		DBAddPageTouch('read');
		DBAddPageTouch('tag', 'video');
		DBAddPageTouch('item', $fileHash);
		DBAddPageTouch('stats');
		DBAddPageTouch('rss');
		DBAddPageTouch('index');
		DBAddPageTouch('flush');
		DBAddPageTouch('compost');
		DBAddPageTouch('chain');

		return $fileHash;
	}
} # IndexVideoFile()

1;
