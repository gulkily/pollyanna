<?php

function GetCache ($cacheName) { // get cache contents by key/name
	// comes from cache/ directory
	WriteLog('GetCache(' . $cacheName . ')');

	static $cacheDir;
	if (!$cacheDir) {
		$cacheDir = GetDir('cache');
		WriteLog('GetCache: $cacheDir = ' . $cacheDir);
	}
	$myVersion = GetMyCacheVersion();
	WriteLog('GetCache: $myVersion = ' . $myVersion);

	// cache name prefixed by current version
	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;
	WriteLog('GetCache: final $cacheName = ' . $cacheName);

	if (file_exists($cacheName)) {
		// return contents of file at that path
		$content = GetFile($cacheName);
		WriteLog('GetCache: returning content, length = ' . strlen($content));
		return $content;
	} else {
		WriteLog('GetCache: file not found, returning empty string');
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
		WriteLog('UnlinkCache: $cacheDir = ' . $cacheDir);
	}

	$myVersion = GetMyCacheVersion();
	WriteLog('UnlinkCache: $myVersion = ' . $myVersion);

	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;
	WriteLog('UnlinkCache: final $cacheName = ' . $cacheName);

	if (file_exists($cacheName)) {
		WriteLog('UnlinkCache: unlinking file');
		unlink($cacheName);
	} else {
		WriteLog('UnlinkCache: file does not exist');
	}
} # UnlinkCache()

function CacheExists ($cacheName) { // Check whether specified cache entry exists, return 1 (exists) or 0 (not)
	WriteLog('CacheExists(' . $cacheName . ')');

	static $cacheDir;
	if (!$cacheDir) {
		$cacheDir = GetDir('cache');
		WriteLog('CacheExists: $cacheDir = ' . $cacheDir);
	}

	$myVersion = GetMyCacheVersion();
	WriteLog('CacheExists: $myVersion = ' . $myVersion);

	$cacheName = $cacheDir . '/' . $myVersion . '/' . $cacheName;
	WriteLog('CacheExists: final $cacheName = ' . $cacheName);

	if (file_exists($cacheName)) {
		WriteLog('CacheExists: file exists, returning 1');
		return 1;
	} else {
		WriteLog('CacheExists: file not found, returning 0');
		return 0;
	}
} # CacheExists()

function MigrateCache ($cacheName) {
	WriteLog('MigrateCache(' . $cacheName . '): returning true');
	return true;
} # MigrateCache()