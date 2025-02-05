#!/usr/bin/perl -T

# cache.pl
# This is an alternative to the default file-based cache in default/template/perl/cache.pl
# This module provides SQLite-based caching functionality for the application
# It handles cache initialization, storage, retrieval, and management
# The cache is used to store various types of data including avatars and page content
# Functions:
#   InitializeCache() - Sets up SQLite database connection and creates cache table
#   GetCache() - Retrieves cached content by key
#   PutCache() - Stores content in cache with given key
#   UnlinkCache() - Removes cached item
#   ExpireAvatarCache() - Specifically handles expiring avatar caches
#   MigrateCache() - Migrates cache entries from filesystem to SQLite

# TODO: Consider adding:
# - Cache expiration/TTL support
# - Cache size limits and pruning
# - Better error handling and recovery
# - Connection pooling for better concurrency
# - Prepared statement caching
# - Transaction support for batch operations
# - Compression for large values
# - Metrics/monitoring

use strict;
use 5.010;
use warnings;
use utf8;
use DBI;
use DBD::SQLite;

# POTENTIAL BUG: Global $dbh can lead to connection issues in multi-threaded env
# TODO: Consider making this a package variable or OO implementation
my $dbh;

sub InitializeCache { # connects to SQLite db and creates cache table
# sub InitDb {
	state $cacheDir = GetDir('cache');
	my $dbFile = "$cacheDir/cache.db";

	# POTENTIAL BUG: Race condition possible during directory creation
	if (!-d $cacheDir) {
		require File::Path;
		File::Path::make_path($cacheDir) or die "Failed to create cache directory: $!";
	}

	# TODO: Make these configurable
	my $maxRetries = 3;
	my $retryDelay = 0.1; # 100ms
	my $attempts = 0;
	my $connected = 0;

	# POTENTIAL BUG: No timeout on overall connection attempts
	while (!$connected && $attempts < $maxRetries) {
		eval {
			# TODO: Consider adding WAL mode and other performance optimizations
			$dbh = DBI->connect(
				"dbi:SQLite:dbname=$dbFile",
				"",
				"",
				{
					RaiseError => 1,
					AutoCommit => 1,
					sqlite_busy_timeout => 5000
				}
			);
			$connected = 1;
		};
		if ($@) {
			$attempts++;
			if ($attempts >= $maxRetries) {
				WriteLog('InitializeCache: error: failed after $maxRetries = ' . $maxRetries . '; $@ = ' . $@);
				die "Failed to connect after $maxRetries attempts: $@";
			}
			WriteLog('InitializeCache: retry $attempts = ' . $attempts . '; $@ = ' . $@);
			select(undef, undef, undef, $retryDelay);
		}
	}

	# TODO: Consider adding indexes on version and created_at
	$dbh->do("CREATE TABLE IF NOT EXISTS cache (
		key TEXT PRIMARY KEY,
		value TEXT,
		version TEXT,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	)") or die $dbh->errstr;
} # InitializeCache()

sub GetMyCacheVersion { # returns cache version string
# sub GetCacheVer {
	# POTENTIAL BUG: Hard-coded version prevents proper cache invalidation
	my $cacheVersion = 'b'; #todo make this return something else

	state $initialized;
	if (!$initialized) {
		$initialized = 1;
		InitializeCache();
	}

	WriteLog('GetMyCacheVersion: returning $cacheVersion = ' . $cacheVersion);
	return $cacheVersion;
} # GetMyCacheVersion()

sub GetCache { # $cacheName ; retrieves value from cache by key
# sub CacheGet {
	my $cacheName = shift;
	chomp $cacheName;

	WriteLog('GetCache: called with $cacheName = ' . $cacheName);

	# POTENTIAL BUG: Regex allows potentially dangerous path characters
	if ($cacheName =~ m/^([\/[a-z0-9A-Z_.\/]+)$/i) {
		$cacheName = $1;
		WriteLog('GetCache: sanity check passed, $cacheName = ' . $cacheName);
	} else {
		WriteLog('GetCache: warning: sanity check failed, $cacheName = ' . $cacheName);
		WriteLog('GetCache: returning empty string');
		return '';
	}

	state $myVersion = GetMyCacheVersion();
	WriteLog('GetCache: using cache version = ' . $myVersion);

	# POTENTIAL BUG: No check if $dbh is defined/connected
	return '' unless $dbh;

	# TODO: Consider caching prepared statements
	my $sth = $dbh->prepare("SELECT value FROM cache WHERE key = ? AND version = ?");
	$sth->execute($cacheName, $myVersion);
	my $row = $sth->fetchrow_arrayref();

	# POTENTIAL BUG: No distinction between "not found" and "empty value"
	if ($row) {
		WriteLog('GetCache: found value for key ' . $cacheName . ', length = ' . length($row->[0]));
		return $row->[0];
	} else {
		WriteLog('GetCache: no value found for key ' . $cacheName);
		return undef;
	}
} # GetCache()

sub PutCache { # $cacheName, $content ; stores value in cache
# sub CacheSet {
	my $cacheName = shift;
	chomp($cacheName);

	# POTENTIAL BUG: Regex pattern differs from GetCache()
	if ($cacheName =~ m/^([0-9a-zA-Z\/_.]+)$/) {
		$cacheName = $1;
		WriteLog('PutCache: sanity check passed, $cacheName = ' . $cacheName);
	} else {
		WriteLog('PutCache: warning: sanity check failed, $cacheName = ' . $cacheName);
		return '';
	}

	my $content = shift;

	# POTENTIAL BUG: Empty content is allowed but may cause issues
	if (!defined($content)) {
		WriteLog('PutCache: warning: no $content; caller = ' . join(',', caller));
		return 0;
	}

	WriteLog('PutCache: $cacheName = ' . $cacheName . '; content length = ' . length($content));

	state $myVersion = GetMyCacheVersion();

	# POTENTIAL BUG: No check if $dbh is defined/connected
	return 0 unless $dbh;

	# TODO: Consider using transactions for atomicity
	$dbh->do(
		"INSERT OR REPLACE INTO cache (key, value, version) VALUES (?, ?, ?)",
		undef,
		$cacheName,
		$content,
		$myVersion
	) or return 0;

	return 1;
} # PutCache()

sub UnlinkCache { # $cacheName ; removes cache entries matching pattern
# sub DeleteCache {
# sub RemoveCache {
	my $cacheName = shift;
	chomp($cacheName);

	WriteLog('UnlinkCache: $cacheName = ' . $cacheName);

	state $myVersion = GetMyCacheVersion();

	# POTENTIAL BUG: SQL injection possible with unescaped wildcards
	$cacheName =~ s/\*/%/g;

	# POTENTIAL BUG: No check if $dbh is defined/connected
	return unless $dbh;

	$dbh->do(
		"DELETE FROM cache WHERE key LIKE ? AND version = ?",
		undef,
		$cacheName,
		$myVersion
	);
} # UnlinkCache()

sub CacheExists { # $cacheName ; checks if cache key exists
# sub HasCache {
	my $cacheName = shift;
	chomp($cacheName);

	state $myVersion = GetMyCacheVersion();

	# POTENTIAL BUG: No check if $dbh is defined/connected
	return 0 unless $dbh;

	# TODO: Consider using COUNT(*) instead of SELECT 1
	my $sth = $dbh->prepare("SELECT 1 FROM cache WHERE key = ? AND version = ?");
	$sth->execute($cacheName, $myVersion);
	return $sth->fetchrow_array() ? 1 : 0;
} # CacheExists()

sub GetMessageCacheName { # $itemHash ; returns cache key for message
# sub MessageCacheKey {
	my $itemHash = shift;
	chomp($itemHash);

	# POTENTIAL BUG: IsItem() function not defined in this file
	if (!IsItem($itemHash)) {
		WriteLog('GetMessageCacheName: warning: sanity check failed, $itemHash = ' . $itemHash);
		return '';
	}

	return "message/$itemHash";
} # GetMessageCacheName()

sub ExpireAvatarCache { # $key ; removes avatar caches for key
# sub DeleteAvatarCache {
	my $key = shift;

	if (!defined($key) || $key eq '' || !$key) {
		WriteLog('ExpireAvatarCache: warning: invalid $key; caller = ' . join(',', caller));
		return 0;
	}

	# POTENTIAL BUG: IsFingerprint() function not defined in this file
	if (!IsFingerprint($key) && $key ne '*') {
		WriteLog('ExpireAvatarCache: warning: sanity check failed, $key = ' . $key);
		return 0;
	}

	my $themesValue = GetConfig('theme');
	$themesValue =~ s/[\s]+/ /g;
	my @activeThemes = split(' ', $themesValue);
	my $themeName = $activeThemes[0];

	WriteLog('ExpireAvatarCache: $themeName = ' . $themeName . '; $key = ' . $key);

	return UnlinkCache('avatar%/%/' . $key);
} # ExpireAvatarCache()

sub MigrateCache { # $cacheKey ; migrates cache from filesystem to SQLite
	my $cacheKey = shift;
	chomp($cacheKey);

	if (!$cacheKey) {
		WriteLog('MigrateCache: warning: missing cache key');
		return 0;
	}

	state $CACHEPATH = GetDir('cache');
	state $cacheVersion = GetMyCacheVersion();

	my $filePath = "$CACHEPATH/$cacheVersion/$cacheKey";

	# POTENTIAL BUG: Race condition between check and read
	if (!-e $filePath) {
		WriteLog('MigrateCache: cache file does not exist: ' . $filePath);
		return 0;
	}
	# Read content and migrate to SQLite
	my $content = GetFile($filePath);
	if (!defined($content)) {
		WriteLog('MigrateCache: failed to read cache file: ' . $filePath);
		return 0;
	}

	# POTENTIAL BUG: Race condition between write and unlink
	if (PutCache($cacheKey, $content)) {
		unlink($filePath);
		WriteLog('MigrateCache: migrated ' . $cacheKey . ' from filesystem to SQLite');
		return 1;
	} else {
		WriteLog('MigrateCache: failed to write to SQLite cache: ' . $cacheKey);
		return 0;
	}
} # MigrateCache()

END {
	$dbh->disconnect if $dbh;
}

1;
