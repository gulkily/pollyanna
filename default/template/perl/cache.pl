#!/usr/bin/perl -T
use strict;
use 5.010;
use warnings;
use utf8;

sub GetMyCacheVersion { # returns "version" of cache
# this is used to prevent cache conflicts between different software versions
# used to return git commit identifier, looking for a better alternative now
# todo make this return something other than hard-coded string
	my $cacheVersion = 'b';

	state $dirChecked;
	if (!$dirChecked) {
		$dirChecked = 1;
		state $cacheDir = GetDir('cache');
		if (!-e "$cacheDir/$cacheVersion") {
			WriteLog('GetMyCacheVersion: warning: directory no exist. try to make once...');
			mkdir("$cacheDir/$cacheVersion");
		}
	}
	WriteLog('GetMyCacheVersion: returning $cacheVersion = ' . $cacheVersion);

	return $cacheVersion;
}

sub GetCache { # get cache by cache key
	my $cacheName = shift;
	chomp $cacheName;

	if ($cacheName =~ m/^([\/[a-z0-9A-Z_.\/]+)$/i) {
		# sanity check passed
		$cacheName = $1;
		WriteLog('GetCache: sanity check passed, $cacheName = ' . $cacheName);
	} else {
		WriteLog('GetCache: warning: sanity check failed on $cacheName = "' . $cacheName . '"');
		return '';
	}

	state $myVersion = GetMyCacheVersion();

	state $cacheDir = GetDir('cache');
	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;

	if (-e $cacheName) {
		# return contents of file at that path
		return GetFile($cacheName);
	}
	else {
		return;
	}
} # GetCache()

sub PutCache { # $cacheName, $content; stores value in cache
	my $cacheName = shift;
	chomp($cacheName);

	if ($cacheName =~ m/^([0-9a-zA-Z\/_.]+)$/) {
		$cacheName = $1;
	} else {
		WriteLog('PutCache: warning: $cacheName failed sanity check: ' . $cacheName);
		return '';
	}

	if ($cacheName) {
		# sanity check ok
	} else {
		WriteLog('PutCache: warning: $cacheName is FALSE; caller = ' . join(',', caller));
		return '';
	}

	my $content = shift;

	if (!defined($content)) {
		WriteLog('PutCache: warning: sanity check failed, no $content');
		return 0;
	}

	WriteLog('PutCache: $cacheName = ' . $cacheName . '; $content = (' . length($content) . 'b); caller = ' . join(',', caller));

	chomp($content);

	state $myVersion = GetMyCacheVersion();

	state $cacheDir = GetDir('cache');
	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName; #todo

	return PutFile($cacheName, $content);
} # PutCache()

sub UnlinkCache { # removes cache by unlinking file it's stored in
# sub DeleteCache {
# sub RemoveCache {
# sub ClearCache {
# sub DeleteItemCache {
# sub RemoveItem {
# sub RemoveItemCache {

	my $cacheName = shift;
	chomp($cacheName);

	WriteLog("UnlinkCache($cacheName)");

	state $myVersion = GetMyCacheVersion();

	state $cacheDir = GetDir('cache');
	my $cacheFile = $cacheDir . '/' . $myVersion . '/' . $cacheName; #todo

	WriteLog('UnlinkCache: $cacheFile = ' . $cacheFile);

	my @cacheFiles = glob($cacheFile);

	if (scalar(@cacheFiles)) {
		WriteLog('UnlinkCache: scalar(@cacheFiles) = ' . scalar(@cacheFiles));

		for my $cacheFile (@cacheFiles) {
			if ($cacheFile =~ m/^([0-9a-zA-Z_.\/]+)$/) {
				unlink($1);
			}
		}
	} else {
		WriteLog('UnlinkCache: scalar(@cacheFiles) is false for $cacheFile = ' . $cacheFile);
	}
} # UnlinkCache()

sub CacheExists { # Check whether specified cache entry exists, return 1 (exists) or 0 (not)
	my $cacheName = shift;
	chomp($cacheName);

	state $myVersion = GetMyCacheVersion();

	state $cacheDir = GetDir('cache');
	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName; #todo

	if (-e $cacheName) {
		return 1;
	} else {
		return 0;
	}
}

sub GetMessageCacheName { # $itemHash ;
	my $itemHash = shift;
	chomp($itemHash);

	if (!IsItem($itemHash)) {
		WriteLog('GetMessageCacheName: sanity check failed on $itemHash = ' . $itemHash);
		return '';
	}

	state $myVersion = GetMyCacheVersion();
	state $cacheDir = GetDir('cache');
	my $messageCacheName = $cacheDir . '/' . $myVersion . '/message/' . $itemHash;

	if (!-e $messageCacheName) {
		WriteLog('GetMessageCacheName: warning: NO FILE: $messageCacheName = ' . $messageCacheName . '; caller = ' . join(',', caller));
	}

	return $messageCacheName;
}


sub ExpireAvatarCache { # $fingerprint ; removes all caches for alias
# sub DeleteAvatarCache
# sub ExpireAliasCache {

	my $key = shift;
	WriteLog("ExpireAvatarCache($key)");
	if (!IsFingerprint($key) && $key ne '*') {
		WriteLog('ExpireAvatarCache: warning: sanity check failed');
		my ($package, $filename, $line) = caller;
		WriteLog('ExpireAvatarCache: caller information: ' . $package . ',' . $filename . ', ' . $line);
		return 0;
	}

	my $themesValue = GetConfig('theme');
	$themesValue =~ s/[\s]+/ /g;
	my @activeThemes = split(' ', $themesValue);

	my $themeName = $activeThemes[0];

	WriteLog('ExpireAvatarCache: $themeName = ' . $themeName);

	my $unlinkCacheResult = UnlinkCache('avatar*/*/' . $key); #todo reduce danger

	if ($unlinkCacheResult) {
		WriteLog('ExpireAvatarCache: $unlinkCacheResult = ' . $unlinkCacheResult);
	} else {
		WriteLog('ExpireAvatarCache: $unlinkCacheResult =  FALSE');
	}

#	UnlinkCache('avatar/' . $themeName . '/' . $key);
#	UnlinkCache('avatar_color/' . $themeName . '/' . $key);
#	UnlinkCache('avatar_plain/' . $themeName . '/' . $key);
} # ExpireAvatarCache()


1;
