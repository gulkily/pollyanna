<?php

class Cache { // SQLite-based caching system with retry mechanism
	private static $db = null;
	private static $maxRetries = 3;  // Maximum retry attempts
	private static $retryDelay = 100000;  // Retry delay in microseconds (100ms)

	public static function initializeDb() { // Initialize SQLite database connection and schema
		// alternative: initDb()
		if (self::$db === null) {
			$cacheDir = GetDir('cache');
			$dbFile = $cacheDir . '/cache.db';

			try {
				self::$db = new SQLite3($dbFile);
				self::$db->busyTimeout(5000); // 5 second busy timeout

				$attempts = 0;
				$success = false;

				while (!$success && $attempts < self::$maxRetries) {
					try {
						self::$db->exec("
							CREATE TABLE IF NOT EXISTS cache (
								key TEXT PRIMARY KEY,
								value TEXT,
								version TEXT,
								created_at DATETIME DEFAULT CURRENT_TIMESTAMP
							)
						");
						$success = true;
					} catch (Exception $e) {
						$attempts++;
						if ($attempts >= self::$maxRetries) {
							throw $e;
						}
						WriteLog("initializeDb: retry attempt $attempts: " . $e->getMessage());
						usleep(self::$retryDelay);
					}
				}
			} catch (Exception $e) {
				WriteLog("initializeDb: error: " . $e->getMessage());
				die('Cache initialization failed');
			}
		}
		return self::$db;
	} // initializeDb()

	public static function getDb() { // Get database connection, initializing if needed
		return self::initializeDb();
	} // getDb()

	public static function closeDb() { // Close database connection if open
		if (self::$db !== null) {
			self::$db->close();
			self::$db = null;
		}
	} // closeDb()

	public static function retryOperation($callback) { // Execute operation with retry logic
		$attempts = 0;
		$lastError = null;

		while ($attempts < self::$maxRetries) {
			try {
				return $callback();
			} catch (Exception $e) {
				$lastError = $e;
				$attempts++;
				if (stripos($e->getMessage(), 'database is locked') !== false) {
					WriteLog("retryOperation: database locked, attempt $attempts");
					usleep(self::$retryDelay);
					continue;
				}
				throw $e;
			}
		}

		throw $lastError;
	} // retryOperation()
}

function GetCache($cacheName) { // Retrieve value from cache by key
	return Cache::retryOperation(function() use ($cacheName) {
		$db = Cache::getDb();
		$myVersion = GetMyCacheVersion();

		try {
			$stmt = $db->prepare('SELECT value FROM cache WHERE key = :key AND version = :version');
			if (!$stmt) {
				throw new Exception($db->lastErrorMsg());
			}

			$stmt->bindValue(':key', $cacheName, SQLITE3_TEXT);
			$stmt->bindValue(':version', $myVersion, SQLITE3_TEXT);

			$result = $stmt->execute();
			if ($row = $result->fetchArray(SQLITE3_ASSOC)) {
				WriteLog("GetCache: found value for $cacheName");
				return $row['value'];
			}
		} catch (Exception $e) {
			WriteLog("GetCache: error: " . $e->getMessage());
			throw $e;
		}

		WriteLog("GetCache: no value found for $cacheName");
		return '';
	});
} // GetCache()

function PutCache($cacheName, $content) { // Store value in cache with key
	return Cache::retryOperation(function() use ($cacheName, $content) {
		WriteLog("PutCache: storing $cacheName");

		$db = Cache::getDb();
		$myVersion = GetMyCacheVersion();

		try {
			$stmt = $db->prepare('
				INSERT OR REPLACE INTO cache (key, value, version)
				VALUES (:key, :value, :version)
			');

			if (!$stmt) {
				throw new Exception($db->lastErrorMsg());
			}

			$stmt->bindValue(':key', $cacheName, SQLITE3_TEXT);
			$stmt->bindValue(':value', $content, SQLITE3_TEXT);
			$stmt->bindValue(':version', $myVersion, SQLITE3_TEXT);

			return $stmt->execute() !== false;
		} catch (Exception $e) {
			WriteLog("PutCache: error: " . $e->getMessage());
			throw $e;
		}
	});
} // PutCache()

function UnlinkCache($cacheName) { // Remove cache entries matching key pattern
	// alternative: DeleteCache(), RemoveCache()
	return Cache::retryOperation(function() use ($cacheName) {
		WriteLog("UnlinkCache: removing $cacheName");

		$db = Cache::getDb();
		$myVersion = GetMyCacheVersion();

		try {
			$cacheName = str_replace('*', '%', $cacheName);

			$stmt = $db->prepare('DELETE FROM cache WHERE key LIKE :key AND version = :version');
			if (!$stmt) {
				throw new Exception($db->lastErrorMsg());
			}

			$stmt->bindValue(':key', $cacheName, SQLITE3_TEXT);
			$stmt->bindValue(':version', $myVersion, SQLITE3_TEXT);

			return $stmt->execute() !== false;
		} catch (Exception $e) {
			WriteLog("UnlinkCache: error: " . $e->getMessage());
			throw $e;
		}
	});
} // UnlinkCache()

function CacheExists($cacheName) { // Check if cache entry exists
	return Cache::retryOperation(function() use ($cacheName) {
		$db = Cache::getDb();
		$myVersion = GetMyCacheVersion();

		try {
			$stmt = $db->prepare('SELECT 1 FROM cache WHERE key = :key AND version = :version');
			if (!$stmt) {
				throw new Exception($db->lastErrorMsg());
			}

			$stmt->bindValue(':key', $cacheName, SQLITE3_TEXT);
			$stmt->bindValue(':version', $myVersion, SQLITE3_TEXT);

			$result = $stmt->execute();
			return $result->fetchArray() ? 1 : 0;
		} catch (Exception $e) {
			WriteLog("CacheExists: error: " . $e->getMessage());
			throw $e;
		}
	});
} // CacheExists()

function MigrateCache($cacheKey) { // Migrate cache from filesystem to SQLite
	if (!$cacheKey) {
		WriteLog('MigrateCache: warning: missing cache key');
		return false;
	}

	$CACHEPATH = GetDir('cache');
	$cacheVersion = GetMyCacheVersion();
	
	$filePath = "$CACHEPATH/$cacheVersion/$cacheKey";
	
	if (!file_exists($filePath)) {
		WriteLog('MigrateCache: cache file does not exist: ' . $filePath);
		return false;
	}

	// Read content and migrate to SQLite
	$content = GetFile($filePath);
	if ($content) {
		if (PutCache($cacheKey, $content)) {
			unlink($filePath);
			WriteLog('MigrateCache: migrated ' . $cacheKey . ' from filesystem to SQLite');
			return true;
		} else {
			WriteLog('MigrateCache: failed to write to SQLite cache: ' . $cacheKey);
			return false;
		}
	} else {
		WriteLog('MigrateCache: failed to read cache file: ' . $filePath);
		return false;
	}
} // MigrateCache()

register_shutdown_function(function() {
	Cache::closeDb();
});