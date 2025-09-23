#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub IndexFile { # $file, \%flags ; calls IndexTextFile() or IndexImageFile() based on extension ;
# \%flags should be either FALSE or a reference to a hash of flags
# flags:
# skip_organize - skips OrganizeFile() call
# skip_pages - skips ReplaceMenuInAllPages() call and all other html output

# returns TRUE when success, FALSE when failure
# sub IndexItem {

# $file can be 'flush' as a special directive to flush all query queues

	my $file = shift;

	my $flagsReference = shift;
	my %flags;
	if ($flagsReference) {
		%flags = %{$flagsReference};
	}

	if (!$file) {
		WriteLog('IndexFile: warning: $file was FALSE; caller = ' . join(',', caller));
		return '';
	}

	if ($file eq 'flush') {
		WriteLog('IndexFile: flush was requested');
		IndexImageFile('flush');
		IndexTextFile('flush');
		return '';
	}

	if (!$file) {
		WriteLog('IndexFile: warning: $file is FALSE');
		return '';
	}

	chomp $file;

	WriteLog('IndexFile: $file = ' . $file);
	if (!-e $file) {
		WriteLog('IndexFile: warning: -e $file is false (file does not exist)');
		return '';
	}
	if (-d $file) {
		WriteLog('IndexFile: warning: -d $file was true (file is a directory)');
		return '';
	}

	#this causes bug
	#	if ($file =~ m/([0-9a-f]{40})/) {
	#		#attempted optimization of next block
	#		my $fileHash = $1;
	#		if (-e "./cache/b/indexed/$fileHash" || GetCache("indexed/$fileHash")) {
	#			WriteLog('IndexFile: aleady indexed, returning. $fileHash = ' . $fileHash);
	#			return $fileHash;
	#		}
	#	}

	my $fileHashFromFilename = '';
	if ($file =~ m/([0-9a-f]{40})/) {
		my $simpleHash = $1;
		my $cachedFilename = GetCache('indexed/' . $1); #todo maybe replace with IsFileAlreadyIndexed() ?

		if ($cachedFilename) {
			WriteLog('IndexFile: found hash in filename; $simpleHash = ' . $simpleHash);
			WriteLog('IndexFile: found hash in filename; $cachedFilename = ' . $cachedFilename);
			WriteLog('IndexFile: found hash in filename; $file = ' . $file);

			if ( index( $cachedFilename , $file ) != -1 ) {
				WriteLog('IndexFile: found hash in filename: already indexed, returning. $simpleHash = ' . $simpleHash);
				return $simpleHash;
			} else {
				WriteLog('IndexFile: found hash in filename: NOT indexed, continuing. $simpleHash = ' . $simpleHash);
			}
		}
	}

	my $fileHash = GetFileHash($file);
	WriteLog('IndexFile: $fileHash = ' . $fileHash);

	if (0) {
		# this never seems to get called, so disabling it for now
		if (GetCache('indexed/' . $fileHash)) { # disabled code
			if (trim(GetCache('indexed/' . $fileHash)) eq $file) { # disabled code
				WriteLog('IndexFile: already indexed, returning. $fileHash = ' . $fileHash);
				return $fileHash;
			} else {
				#return $fileHash; #who does that?#todo
				WriteLog('IndexFile: already indexed, but from different path. continuing. $fileHash = ' . $fileHash);
				if (GetConfig('admin/organize_files') && !$flags{'skip_organize'}) {
					WriteLog('IndexFile: calling OrganizeFile() with $fileHash = ' . $fileHash);
					$file = OrganizeFile($file); # IndexFile()

					if ($file) {
						WriteLog('IndexFile: Calling IndexFile recusrively with $file = ' . $file);
						my $recurseResult = IndexFile($file);
						WriteLog('IndexFile: $recurseResult = ' . $recurseResult);
						return $recurseResult;
					} else {
						WriteLog('IndexFile: OrganizeFile returned FALSE');
					}
				}
			}
		}
	}

	my $indexSuccess = 0;

	my $mimeType = '';
	my $handledByMime = 0;

	my $ext = lc(GetFileExtension($file));

	# THREADS MODE IS NOT FINISHED
	# DO NOT CHANGE THIS UNLESS YKWYD
	my $useThreads = 0;
	# IF TURNING ON, UNCOMMENT 'use' STATEMENT
	# AT THE TOP OF THIS FILE AS WELL

	if (!$handledByMime) {
		if ($ext eq 'txt') {
			if (GetConfig('setting/admin/index/text_binary_guard') && IsLikelyBinaryFile($file)) {
				WriteMessage('IndexFile: skipping text indexing (binary content) ' . $file);
				WriteLog('IndexFile: skipping text indexing; binary content detected; $file = ' . $file);
				return '';
			}

			$mimeType = GetFileMimeType($file);
			if ($mimeType && $mimeType =~ m/^image\//) {
				WriteLog('IndexFile: MIME indicates image content; delegating to IndexImageFile()');
				$indexSuccess = IndexImageFile($file);
				$handledByMime = 1;
				if (!$indexSuccess) {
					WriteLog('IndexFile: warning: IndexImageFile() via MIME returned FALSE; $mimeType = ' . $mimeType);
				}
			}

			if (!$handledByMime) {
				WriteLog('IndexFile: calling IndexTextFile()');

				if ($useThreads) {
					my $thr = threads->create('IndexTextFile', $file);
					$indexSuccess = $thr->join();
					$indexSuccess = 1;
					#todo this should return file hash
				} else {
					$indexSuccess = IndexTextFile($file, \%flags); #IndexFile()
					if (!$indexSuccess) {
						WriteLog('IndexFile: warning: IndexTextFile() returned FALSE');
						$indexSuccess = 0;
					}
				}
			}

			if (GetConfig('setting/admin/index/add_dir_as_hashtag')) {
				# add each subdirectory as an extra hashtag to item
				# for example txt/foo/bar/abc.txt will add #foo and #bar tags
				my $fileLocalPath = $file;
				$fileLocalPath = str_replace(GetDir('txt'), '', $file);
				$fileLocalPath = substr($fileLocalPath, 0, rindex($fileLocalPath, '/')); #just the path
				my @dirTags = split('/', $fileLocalPath);

				WriteLog('IndexFile: add_dir_as_hashtag: $fileLocalPath = ' . $fileLocalPath . '; @dirTags: ' . join(',', @dirTags));

				if (@dirTags) {
					foreach my $dirTag (@dirTags) {
						$dirTag = trim($dirTag);
						if ($dirTag =~ m/([0-9a-zA-Z_-]+)/ && length($dirTag) > 2) {
							$dirTag = $1;
							DBAddLabel($fileHash, 0, $dirTag);
						} else {
							WriteLog('IndexFile: warning: $dirTag failed sanity check; $dirTag = ' . $dirTag);
						}
					}
				}
			} # add_dir_as_hashtag
		} # ($ext eq 'txt')

		if ($ext eq 'html' && GetConfig('admin/html/enable')) { #todo enable once IndexHtmlFile() is better
			WriteLog('IndexFile: calling IndexHtmlFile()');
			$indexSuccess = IndexHtmlFile($file);

			if (!$indexSuccess) {
				WriteLog('IndexFile: warning: IndexHtmlFile $indexSuccess was FALSE');
				$indexSuccess = 0;
			}
		} # if ($ext eq 'html')

		if ($ext eq 'zip' && GetConfig('admin/zip/enable')) {
			WriteLog('IndexFile: calling IndexZipFile()');
			$indexSuccess = IndexZipFile($file);

			if (!$indexSuccess) {
				WriteLog('IndexFile: warning: IndexZipFile() returned FALSE; $indexSuccess was FALSE');
				$indexSuccess = 0;
			}
		} # if ($ext eq 'zip')

		if ($ext eq 'cpp' && GetConfig('admin/cpp/enable')) {
			WriteLog('IndexFile: calling IndexCppFile()');
			$indexSuccess = IndexCppFile($file);

			if (!$indexSuccess) {
				WriteLog('IndexFile: warning: IndexCppFile() returned FALSE; $indexSuccess was FALSE');
				$indexSuccess = 0;
			}
		} # if ($ext eq 'cpp')
		if ($ext eq 'py' && GetConfig('admin/python3/enable')) {
			WriteLog('IndexFile: calling IndexPyFile()');
			$indexSuccess = IndexPyFile($file);

			if (!$indexSuccess) {
				WriteLog('IndexFile: warning: IndexPyFile() returned FALSE; $indexSuccess was FALSE');
				$indexSuccess = 0;
			}
		} # if ($ext eq 'py')
		if ($ext eq 'pl' && GetConfig('admin/pl/enable')) {
			WriteLog('IndexFile: calling IndexPerlFile()');
			$indexSuccess = IndexPerlFile($file);

			if (!$indexSuccess) {
				WriteLog('IndexFile: warning: IndexPerlFile() returned FALSE; $indexSuccess was FALSE');
				$indexSuccess = 0;
			}
		} # if ($ext eq 'pl')

		if (GetConfig('admin/image/enable')) {
			#imagetypes
			my @allowedImages = GetConfigValueAsArray('setting/admin/image/allow_files');
			#my @allowedImages = qw(png gif jpg jpeg bmp svg webp jfif tiff tff);
			for my $allowedImage (@allowedImages) {
				if ($ext eq $allowedImage) {
					WriteLog('IndexFile: calling IndexImageFile()');
					$indexSuccess = IndexImageFile($file);
					last;
				}
			}
		}

		if (GetConfig('admin/video/enable')) {
			#videotypes
			my @allowedVideos = qw(mp4);

			for my $allowedVideo (@allowedVideos) {
				if ($ext eq $allowedVideo) {
					WriteLog('IndexFile: calling IndexVideoFile()');
					$indexSuccess = IndexVideoFile($file);
					last;
				}
			}
		}
	} # (!$handledByMime)

	if ($indexSuccess) {
		WriteLog('IndexFile: $indexSuccess = ' . $indexSuccess);
	} else {
		WriteLog('IndexFile: warning: $indexSuccess FALSE; $file = ' . $file . '; caller = ' . join(',', caller));
	}

	if ($indexSuccess) {
		if (-e $file) {
			if (GetConfig('admin/index/stat_file')) { #todo put all the other pieces of this here
				my @fileStat = stat($file);
				my $fileSize =    $fileStat[7]; #file size
				my $fileModTime = $fileStat[9];
				WriteLog('IndexFile: $fileModTime = ' . $fileModTime . '; $fileSize = ' . $fileSize);
				if ($fileModTime) {
					if (IsItem($indexSuccess)) {
						DBAddItemAttribute($indexSuccess, 'file_m_timestamp', $fileModTime);
						DBAddItemAttribute($indexSuccess, 'file_size', $fileSize);
					} else {
						WriteLog('IndexFile: warning: IsItem($indexSuccess) was FALSE');
					}
				}
			}

			if (GetConfig('admin/index/index_local_path_as_attribute')) {
				use Cwd 'abs_path';
				my $absPath = abs_path($file);

				if ($file) {
					DBAddItemAttribute($indexSuccess, 'local_path', $absPath);
				} else {
					WriteLog('IndexFile: warning: tried to get $absPath, got FALSE; $file = ' . $file . '; caller = ' . join(',', caller));
				}
			}

			if (GetConfig('admin/index/add_git_hash_file')) {
				#todo sanity check before running shell command #security
				if ($file =~ m/^([0-9a-z.\/_]+)/) {
					$file = $1;

					my $gitHash = `git hash-object $file`;
					if ($gitHash) {
						DBAddItemAttribute($indexSuccess, 'git_hash_object', $gitHash);
					} else {
						WriteLog('IndexFile: warning: $gitHash returned false');
					}
				} else {
					WriteLog('IndexFile: warning: add_git_hash_file, $file failed sanity check');
				}
			}
		}
	}

	if ($indexSuccess) {
		PutCache('indexed/' . $indexSuccess, $file);

		if (GetConfig('setting/admin/index/rewrite_menu_after_index') && !$flags{'skip_pages'}) {
			# rewrites all the menubars in all the existing pages
			require_once('pages.pl');
			ReplaceMenuInAllPages();
		}

		if (GetConfig('setting/admin/index/expire_html_after_index')) {
			ExpireHtmlFile('new.html');
			ExpireHtmlFile('chain.html');
			ExpireHtmlFile('authors.html');
			ExpireHtmlFile('tags.html');
			ExpireHtmlFile('compost.html');
			ExpireHtmlFile('threads.html');
			ExpireHtmlFile('dialog/new.html');
			ExpireHtmlFile('dialog/chain.html');
			ExpireHtmlFile('dialog/authors.html');
			ExpireHtmlFile('dialog/tags.html');
			ExpireHtmlFile('dialog/compost.html');
			ExpireHtmlFile('dialog/threads.html');

			#get all items in thread and expire them
			
			#get previous item in chain and expire it

			#get all hashtags and expire them

			#
			# what needs to be uncached when a new item is indexed?
			# 	new
			# 	chain
			# 	authors
			# 	tags
			# 	entire parent tree
			# 	author of item
			# 	affected authors if in parent tree
			# 	top/ pages for all affected hash tags
			# 	all dialog versions of above
			# 	previous item in chain
			# 	lower priority
			# 		compost
			# 		threads
		}

		WriteLog('IndexFile: returning $fileHash = ' . $fileHash);
		return $fileHash;
	} else {
		WriteLog('IndexFile: warning: $indexSuccess is FALSE; $file = ' . $file);
		return '';
	}

	return 0;
} # IndexFile()

sub IsFileAlreadyIndexed { # $file, $fileHash ; returns 1 if file has already been indexed, 0 if not
# both hash and path should match what is in GetCache("indexed/$fileHash");

	my $file = shift;
	my $fileHash = shift;

	if ($file && $fileHash) {
		# ok
	} else {
		if (!$file) {
			WriteLog('IsFileAlreadyIndexed: warning: $file is FALSE; caller = ' . join(',', caller));
			return 0;
		}
		if (!$fileHash) {
			WriteLog('IsFileAlreadyIndexed: warning: $fileHash is FALSE; caller = ' . join(',', caller));
			return 0;
		}
	}

	#todo sanity checks
	#todo perhaps use GetAbsolutePath() ?

	my $cacheValue = GetCache("indexed/$fileHash");

	if (!$cacheValue) {
		WriteLog('IsFileAlreadyIndexed: $file = ' . $file . '; $fileHash = ' . $fileHash . '; return = FALSE; caller = ' . join(',', caller));
		return 0;
	}
	elsif (GetCache("indexed/$fileHash") eq $file) {
		WriteLog('IsFileAlreadyIndexed: $file = ' . $file . '; $fileHash = ' . $fileHash . '; return = TRUE; caller = ' . join(',', caller));
		return 1;
	}
	else {
		WriteLog('IsFileAlreadyIndexed: $file = ' . $file . '; $fileHash = ' . $fileHash . '; return = FALSE; caller = ' . join(',', caller));
		return 0;
	}
} # IsFileAlreadyIndexed()

1;
