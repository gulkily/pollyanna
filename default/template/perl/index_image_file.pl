#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub IndexExif { # $file, $fileHash ; indexes image's exif and stores it as an attached log
	my $file = shift;
	my $fileHash = shift;

	#todo sanity checks

	if (index($file, ' ') != -1) {
		WriteLog('IndexExif: warning: sanity check failed, $file contains space character, which is not allowed; caller = ' . join(', ', caller));
		return 0;
	}

	my $startTime = GetTime();
	my $command = "identify -format '%[EXIF:*]'";
	my $exifResult = `$command "$file"`;
	my $doneTime = GetTime();

	WriteLog('IndexExif: $file = ' . $file . '; $exifResult = ' . ($exifResult ? 'YES' : 'NO') . '; caller = ' . join(', ', caller));

	if ($exifResult) {
		AttachLogToItem($fileHash, $exifResult, $startTime, $doneTime);
	}

	#my $exifTool = new Image::ExifTool;
	#$exifTool->Options(Unknown => 1);
	#$exifTool->ExtractInfo($file);
	#my $exif = $exifTool->GetInfo('Group0');
} # IndexExif()

sub IndexImageFile { # $file ; indexes one image file into database and makes thumbnails
	# Reads a given $file, gets its attributes, puts it into the index database
	# If ($file eq 'flush), flushes any queued queries
	# Also sets appropriate task entries

	if (!GetConfig('setting/admin/convert/enable')) {
		WriteLog('IndexImageFile: warning: called when convert/enable is false');
		#todo deal with it better
	}

	my $file = shift;
	chomp($file);

	if ($file =~ m/\s/) {
		WriteLog('IndexImageFile: warning: sanity check failed, $file contains space character, which is not allowed');
		return 0;
	}

	if ($file =~ m/^([0-9a-zA-Z.\/_\-:]+)$/) { #todo bug here?
		if ($1 eq $file) {
			$file = $1;
		} else {
			WriteLog('IndexImageFile: warning: sanity check 2 failed on $file: ' . $file);
			return 0;
		}
	} else {
		WriteLog('IndexImageFile: warning: sanity check 1 failed on $file: ' . $file);
		return 0;
	}

	WriteLog("IndexImageFile($file)");

	if ($file eq 'flush') {
		WriteLog("IndexImageFile(flush)");
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

	if (IsImageFile($file)) {
		my $fileHash = GetFileHash($file);

		#if (GetCache('indexed/'.$fileHash)) {
		if (IsFileAlreadyIndexed($file, $fileHash)) {
			WriteLog('IndexImageFile: skipping because of flag: indexed/'.$fileHash);
			return $fileHash;
		}

		WriteLog('IndexImageFile: $fileHash = ' . ($fileHash ? $fileHash : '--'));

		$addedTime = DBGetAddedTime($fileHash);
		# get the file's added time.

		# debug output
		WriteLog('IndexImageFile: $file = ' . ($file?$file:'false'));
		WriteLog('IndexImageFile: $fileHash = ' . ($fileHash?$fileHash:'false'));
		WriteLog('IndexImageFile: $addedTime = ' . ($addedTime?$addedTime:'false'));

		# if the file is present in deleted.log, get rid of it and its page, return
		if (IsFileDeleted($file, $fileHash)) {
			# write to log
			#todo
			WriteLog('IndexImageFile: IsFileDeleted() returned true, returning');
			return 0;
		}

		if (!$addedTime) {
			WriteLog('IndexImageFile: file missing $addedTime; if write_chain_log is TRUE, add it to chain:');
			if (GetConfig('admin/logging/write_chain_log')) {
				$addedTime = AddToChainLog($fileHash);
			} else {
				$addedTime = GetTime();
			}
			if (!$addedTime) {
				# sanity check
				WriteLog('IndexImageFile: warning: sanity check failed for $addedTime');
				$addedTime = GetTime();
			}
		}

		my $itemName = TrimPath($file);

		require_once('image_thumbnail.pl');
		ImageMakeThumbnails($file);

		DBAddItem($file, $itemName, '', $fileHash, 'image', 0);
		DBAddItem('flush');
		#DBAddItemAttribute($fileHash, 'title', $itemName, $addedTime);

		my $imageTitle = $itemName;
		while (length($imageTitle) > 0 && $imageTitle =~ m/[0-9\.]+$/) {
			$imageTitle = substr($imageTitle, 0, length($imageTitle) - 1);
		}
		DBAddItemAttribute($fileHash, 'title', $imageTitle, time()); #todo time should come from actual file time #todo re-add this

		DBAddLabel($fileHash, $addedTime, 'image'); # add image label

		if (@tagFromPath) {
			foreach my $tag (@tagFromPath) {
				DBAddLabel($fileHash, $addedTime, $tag);
			}
		}

		if (GetConfig('setting/admin/index/image_index_exif')) { #exif
			IndexExif($file, $fileHash);
		}

		DBAddPageTouch('read');
		DBAddPageTouch('tag', 'image');
		DBAddPageTouch('item', $fileHash);
		DBAddPageTouch('stats');
		DBAddPageTouch('rss');
		DBAddPageTouch('index');
		DBAddPageTouch('flush');
		DBAddPageTouch('compost');
		DBAddPageTouch('chain');

		return $fileHash;
	}
} # IndexImageFile()

1;
