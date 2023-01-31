#!/usr/bin/perl -T

# file.pl # contains file operations
# ==================================
#
# OrganizeFile($file)
# renames file based on hash of its contents
#
# GetFileMessage($file)
#   get file message from cache
#   if not in cache, determine it and add to cache
#
# PutFileMessage($file, $message)
#   store message of file in cache
#   message typically contains original text, minus pgp envelope

use strict;
use warnings;
use 5.010;
use utf8;

sub filemtime { # $file ; returns mod time of file, mimics php's filemtime()
# sub mtime {
# sub filetime {
# sub file_time {
	my $file = shift;
	#todo sanity

	my @fileStat = stat($file);
	#my $fileSize =    $fileStat[7]; #file size
	my $fileModTime = $fileStat[9];

	return $fileModTime;
}

sub GetFileMessageCachePath { # $fileHash/$filePath ;  returns path to file's message hash
	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('GetFileMessageCachePath: warning: parameter $fileHash/$filePath missing');
		return ''; #todo
	}
	if (
		!IsItem($fileHash) && # not an item
		-e $fileHash # file exists
	) {
		# parameter appears to be a file path, not a file hash
		# change it to file hash
		$fileHash = GetFileHash($fileHash);
	}

	state $CACHEPATH = GetDir('cache');
	state $cacheVersion = GetMyCacheVersion();

	my $cachePathMessage = "$CACHEPATH/$cacheVersion/message";

	if ($cachePathMessage =~ m/^([a-zA-Z0-9_\/.]+)$/) {
		$cachePathMessage = $1;
		WriteLog('GpgParse: $cachePathMessage sanity check passed: ' . $cachePathMessage);
	} else {
		WriteLog('GpgParse: warning: sanity check failed, $cachePathMessage = ' . $cachePathMessage);
		return '';
	}

	my $fileMessageCachePath = "$cachePathMessage/$fileHash";

	if ($fileMessageCachePath =~ m/^([a-zA-Z0-9_\/.]+)$/) {
		$fileMessageCachePath = $1;
		WriteLog('GpgParse: $fileMessageCachePath sanity check passed: ' . $fileMessageCachePath);
	} else {
		WriteLog('GpgParse: warning: sanity check failed, $fileMessageCachePath = ' . $fileMessageCachePath);
		return '';
	}

	return $fileMessageCachePath;
} # GetFileMessageCachePath()

sub GetAbsolutePath { # $file
# sub GetFilePath {
# sub GetFullPath {
	use File::Spec;

	my $filePath = shift;

	if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
		$filePath = $1;

		if (-e $filePath) {
			$filePath = File::Spec->rel2abs( $filePath ) ;
		} else {
			return 0;
		}
	} else {
		WriteLog('GetAbsolutePath: warning: failed sanity check on $filePath = ' . $filePath);
		return '';
	}
} # GetAbsolutePath()

sub MergeFiles { # $file1, $file2, ... ; merge files which have same body but different footer
	my @files = @_;

	#todo need to alias the two previous file hashes to the new file's hash

	WriteLog('MergeFiles: scalar(@files) = ' . scalar(@files));

	my $fileBody = '';
	my $fileHash = '';
	my $fileFooter = '';

	foreach my $file (@files) {
		WriteLog('MergeFiles: $file = ' . $file);

		my $thisContent = GetFile($file);
		my $thisBody = '';
		my $thisFooter = '';

		my $divPos = index($thisContent, "\n-- \n");
		if ($divPos != -1) {
			$thisBody = substr($thisContent, 0, $divPos);
			if (length($thisContent) > ($divPos + 5)) {
				#$thisFooter = substr($thisContent, $divPos + 5, length($thisContent) - $divPos + 5);
				$thisFooter = substr($thisContent, $divPos + 5);
			}
			WriteLog('MergeFiles: if: $divPos = ' . $divPos . '; $thisFooter = ' . $thisFooter);
		} else {
			$thisBody = $thisContent;
			$divPos = length($thisContent);
			WriteLog('MergeFiles: else: $divPos = ' . $divPos . '; $thisFooter = ' . $thisFooter);
		}	
		$thisBody = trim($thisBody);
		if (!$fileBody) {
			$fileBody = $thisBody;
		}
		if ($thisBody ne $fileBody) {
			WriteLog('MergeFiles: warning: bodies not equal: ' . $thisBody . ' vs ' . $fileBody);
			return '';
		}
		$fileFooter .= trim($thisFooter) . "\n";
	}

	my @footerLines = split("\n", $fileFooter);
	@footerLines = array_unique(@footerLines);

	for my $line (@footerLines) {
		WriteLog('MergeFiles: loop: $line = ' . $line);
	}

	$fileFooter = join("\n", @footerLines);	

	my $fileOutContent = $fileBody . "\n-- \n" . $fileFooter;
	state $fileOutPath = GetDir('txt') . '/merged_' . sha1_hex($fileOutContent) . '.txt';

	WriteLog('MergeFiles: pass!');
	WriteLog('MergeFiles: PutFile(' . $fileOutPath . ', ' . $fileOutContent . ')');
	
	PutFile($fileOutPath, $fileOutContent);

	UnlinkCache('indexed/' . $fileHash);
	UnlinkCache('message/' . $fileHash);

	my %indexFlags;
	$indexFlags{'skip_organize'} = 1;
	IndexTextFile($fileOutPath, \%indexFlags);

	my $confirm = GetFile($fileOutPath);
	if ($confirm eq $fileOutContent) {
		for my $file (@files) {
			if ($file ne $fileOutPath) {
				unlink($file);
			}
		}

		#todo sweep

		return $fileOutPath;
	}
} # MergeFiles()

sub OrganizeFile { # $file ; renames file based on hash of its contents
	# returns new filename
	# filename is obtained using GetFileHashPath()

	my $file = shift;
	chomp $file;

	if (!$file) {
		WriteLog('OrganizeFile: warning: $file is FALSE');
		return '';
	}

	my $TXTDIR = './html/txt'; #todo

	if (!-e $file) {
		#file does not exist.
		WriteLog('OrganizeFile: warning: called on non-existing file: ' . $file);
		return '';
	}

	if (!GetConfig('admin/organize_files')) {
		WriteLog('OrganizeFile: warning: admin/organize_files was false! returning');
		return $file;
	}

	if ($file eq "$TXTDIR/server.key.txt" || $file eq $TXTDIR || -d $file) {
		# $file should not be server.key, the txt directory, or a directory
		WriteLog('OrganizeFile: file is on ignore list, ignoring.');
		return $file;
	}

	if (GetConfig('admin/dev/block_organize')) {
		WriteLog('OrganizeFile: warning: dev/block_organize is true, returning');
		return $file;
	}

	# organize files aka rename to hash-based path
	my $fileHashPath = GetFileHashPath($file);

	# turns out this is actually the opposite of what needs to happen
	# but this code snippet may come in handy
	# if (index($fileHashPath, $SCRIPTDIR) == 0) {
	# 	WriteLog('IndexTextFile: hash path begins with $SCRIPTDIR, removing it');
	# 	$fileHashPath = str_replace($SCRIPTDIR . '/', '', $fileHashPath);
	# } # index($fileHashPath, $SCRIPTDIR) == 0
	# else {
	# 	WriteLog('IndexTextFile: hash path does NOT begin with $SCRIPTDIR, leaving it alone');
	# }

	if ($fileHashPath) {
		use File::Spec;
		$fileHashPath = File::Spec->rel2abs( $fileHashPath ) ;
		#get absolute path

		if ($file eq $fileHashPath) {
			# Does it match? No action needed
			WriteLog('OrganizeFile: hash path matches, no action needed');
		}
		elsif ($file ne $fileHashPath) {
			# It doesn't match, fix it
			WriteLog('OrganizeFile: hash path does not match, organize');
			WriteLog('OrganizeFile: Before: ' . $file);
			WriteLog('OrganizeFile: After: ' . $fileHashPath);

			if (-e $fileHashPath) {

				# new file already exists, rename only if not larger
				WriteLog("OrganizeFile: warning: $fileHashPath already exists!");

				#todo this should be sanity-checked way before here
				if ($fileHashPath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
					$fileHashPath = $1;
				} else {
					WriteLog('OrganizeFile: warning: $fileHashPath failed sanity check');
					return '';
				}

				if ($file =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
					$file = $1;
				} else {
					WriteLog('OrganizeFile: warning: $file failed sanity check');
					return '';
				}

				my $mergedName = MergeFiles($file, $fileHashPath);
				
				if ($mergedName =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
					$mergedName = $1;
				} else {
					WriteLog('OrganizeFile: warning: $mergedName failed sanity check');
					return '';
				}
				
				RenameFile($mergedName, $fileHashPath);
			} # -e $fileHashPath
			else {
				# new file does not exist, safe to rename
				#
				if ($file && $file =~ m/^([0-9a-zA-Z.\-_\/]+)$/) {
					$file = $1;

					if ($fileHashPath && $fileHashPath =~ m/^([0-9a-zA-Z.\-_\/]+)$/) {
						$fileHashPath = $1;

						RenameFile($file, $fileHashPath);
					} else {
						WriteLog('OrganizeFile: warning: $fileHashPath sanity check failed on rename: ' . $fileHashPath);
					}
				} else {
					WriteLog('OrganizeFile: warning: $file sanity check failed on rename: ' . $file);
				}
			}

			if (-e $fileHashPath) {
				# if new file exists
				$file = $fileHashPath; #don't see why not... is it a problem for the calling function?
			} else {
				WriteLog("OrganizeFile: warning: Very strange... \$fileHashPath doesn't exist? $fileHashPath");
			}
		} # $file ne $fileHashPath
		else {
			WriteLog('OrganizeFile: it already matches, next!');
			WriteLog('$file: ' . $file);
			WriteLog('$fileHashPath: ' . $fileHashPath);
		}
	} # $fileHashPath

	WriteLog("OrganizeFile: returning $file");
	return $file;
} # OrganizeFile()


sub GetFileMessage { # $fileHash ; get file message based on hash
	my $fileHash = shift;
	if (!$fileHash) {
		return ''; #todo
	}

	if (!IsItem($fileHash) && -e $fileHash) {
		$fileHash = GetFileHash($fileHash);
	}

	WriteLog('GetFileMessage(' . $fileHash . ')');

	my $messagePath;

	if (GetConfig('admin/gpg/enable')) {
		$messagePath = GetFileMessageCachePath($fileHash) . '_gpg';
		WriteLog('GetFileMessage: $messagePath1: ' . $messagePath);

		if (-e $messagePath) {
			WriteLog('GetFileMessage: (message_gpg) return GetFile(' . $messagePath . ')');
			return GetFile($messagePath);
		} else {
			WriteLog('GetFileMessage: not returning, no file at $messagePath = '. $messagePath . '; caller = ' . join(',', caller));
		}
	}

	$messagePath = GetFileMessageCachePath($fileHash);
	WriteLog('GetFileMessage: $messagePath2: ' . $messagePath);

	if (-e $messagePath) {
		WriteLog('GetFileMessage: (message) return GetFile(' . $fileHash . ')');
		return GetFile($messagePath);
	} else {
		WriteLog('GetFileMessage: return GetPathFromHash(' . $fileHash . ')');
		my $filePath = GetPathFromHash($fileHash);

		if (!(-e $filePath)) { # file_exists()
			WriteLog('GetFileMessage: warning: !-e $filePath = ' . $filePath);

			$filePath = SqliteGetValue("SELECT file_name FROM item WHERE file_hash = '$fileHash'");

			if (!(-e $filePath)) { # file_exists()
				WriteLog('GetFileMessage: warning: #2 !-e $filePath = ' . $filePath);
				return '';
			} else {
				WriteLog('GetFileMessage: return GetFile(' . $filePath . ')');
				return GetFile($filePath);
			}

			return '';
		} else {
			WriteLog('GetFileMessage: return GetFile(' . $filePath . ')');
			return GetFile($filePath);
		}
	}
} # GetFileMessage()


#   R        W           R
# txt --> gpgpg --> cache/message_gpg
#                      | GetFileMessage()
#       R              v   W       R
# cache/message <-- index.pl <-- txt
#      | GetItemDetokenedMessage()
#      v W
#    pages.pl

sub PutFileMessage {
	my $fileHash = shift;
	if (!$fileHash) {
		return ''; #todo
	}
	if (!IsItem($fileHash) && -e $fileHash) {
		$fileHash = GetFileHash($fileHash);
	}

	my $message = shift;
	if (!$message) {
		return ''; #todo
	}

	return PutFile(GetFileMessageCachePath($fileHash), $message);
} # PutFileMessage()

1;
