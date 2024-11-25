<?php

function GetCache ($cacheName) { // get cache contents by key/name
	// comes from cache/ directory

	static $cacheDir;
	if (!$cacheDir) {
		$cacheDir = GetDir('cache');
	}
	$myVersion = GetMyCacheVersion();

	// cache name prefixed by current version
	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;

	if (file_exists($cacheName)) {
		// return contents of file at that path
		return GetFile($cacheName);
	} else {
		return '';
	}
} # GetCache()

function PutCache ($cacheName, $content) { // stores value in cache
//#todo sanity checks and error handling
	WriteLog("PutCache($cacheName, $content)");

	static $cacheDir;
	if (!$cacheDir) {
		$cacheDir = GetDir('cache');
	}
	$myVersion = GetMyCacheVersion();

	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;

	WriteLog('PutCache: $cacheName = ' . $cacheName);

	return PutFile($cacheName, $content);
} # PutCache()

function UnlinkCache ($cacheName) { // removes cache by unlinking file it's stored in
	WriteLog('UnlinkCache(' . $cacheName . ')');

	static $cacheDir;
	if (!$cacheDir) {
		$cacheDir = GetDir('cache');
	}

	$myVersion = GetMyCacheVersion();

	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;

	if (file_exists($cacheName)) {
		unlink($cacheName);
	}
} # UnlinkCache()

function CacheExists ($cacheName) { // Check whether specified cache entry exists, return 1 (exists) or 0 (not)
	static $cacheDir;
	if (!$cacheDir) {
		$cacheDir = GetDir('cache');
	}

	$myVersion = GetMyCacheVersion();

	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;

	if (file_exists($cacheName)) {
		return 1;
	} else {
		return 0;
	}
} # CacheExists()

function MigrateCache ($cacheName) {
	return true;
} # MigrateCache()