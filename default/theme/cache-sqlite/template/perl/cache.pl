#!/usr/bin/perl -T

use strict;
use 5.010;
use warnings;
use utf8;
use DBI;
use DBD::SQLite;

my $dbh;

sub InitializeCache { # connects to SQLite db and creates cache table
# sub InitDb {
    state $cacheDir = GetDir('cache');
    my $dbFile = "$cacheDir/cache.db";
    
    if (!-d $cacheDir) {
        require File::Path;
        File::Path::make_path($cacheDir) or die "Failed to create cache directory: $!";
    }

    my $maxRetries = 3;
    my $retryDelay = 0.1; # 100ms
    my $attempts = 0;
    my $connected = 0;

    while (!$connected && $attempts < $maxRetries) {
        eval {
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

    $dbh->do("CREATE TABLE IF NOT EXISTS cache (
        key TEXT PRIMARY KEY,
        value TEXT,
        version TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )") or die $dbh->errstr;
} # InitializeCache()

sub GetMyCacheVersion { # returns cache version string
# sub GetCacheVer {
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

    if ($cacheName =~ m/^([\/[a-z0-9A-Z_.\/]+)$/i) {
        $cacheName = $1;
        WriteLog('GetCache: sanity check passed, $cacheName = ' . $cacheName);
    } else {
        WriteLog('GetCache: warning: sanity check failed, $cacheName = ' . $cacheName);
        return '';
    }

    state $myVersion = GetMyCacheVersion();

    my $sth = $dbh->prepare("SELECT value FROM cache WHERE key = ? AND version = ?");
    $sth->execute($cacheName, $myVersion);
    my $row = $sth->fetchrow_arrayref();
    
    return $row ? $row->[0] : undef;
} # GetCache()

sub PutCache { # $cacheName, $content ; stores value in cache
# sub CacheSet {
    my $cacheName = shift;
    chomp($cacheName);

    if ($cacheName =~ m/^([0-9a-zA-Z\/_.]+)$/) {
        $cacheName = $1;
        WriteLog('PutCache: sanity check passed, $cacheName = ' . $cacheName);
    } else {
        WriteLog('PutCache: warning: sanity check failed, $cacheName = ' . $cacheName);
        return '';
    }

    my $content = shift;

    if (!defined($content)) {
        WriteLog('PutCache: warning: no $content; caller = ' . join(',', caller));
        return 0;
    }

    WriteLog('PutCache: $cacheName = ' . $cacheName . '; content length = ' . length($content));

    state $myVersion = GetMyCacheVersion();

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

    $cacheName =~ s/\*/%/g;
    
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

    my $sth = $dbh->prepare("SELECT 1 FROM cache WHERE key = ? AND version = ?");
    $sth->execute($cacheName, $myVersion);
    return $sth->fetchrow_array() ? 1 : 0;
} # CacheExists()

sub GetMessageCacheName { # $itemHash ; returns cache key for message
# sub MessageCacheKey {
    my $itemHash = shift;
    chomp($itemHash);

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

END {
    $dbh->disconnect if $dbh;
}

1;
