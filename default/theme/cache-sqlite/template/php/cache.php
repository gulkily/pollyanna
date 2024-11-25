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
						error_log("initializeDb: retry attempt $attempts: " . $e->getMessage());
						usleep(self::$retryDelay);
					}
				}
			} catch (Exception $e) {
				error_log("initializeDb: error: " . $e->getMessage());
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
					error_log("retryOperation: database locked, attempt $attempts");
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
				error_log("GetCache: found value for $cacheName");
				return $row['value'];
			}
		} catch (Exception $e) {
			error_log("GetCache: error: " . $e->getMessage());
			throw $e;
		}

		error_log("GetCache: no value found for $cacheName");
		return '';
	});
} // GetCache()

function PutCache($cacheName, $content) { // Store value in cache with key
	return Cache::retryOperation(function() use ($cacheName, $content) {
		error_log("PutCache: storing $cacheName");

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
			error_log("PutCache: error: " . $e->getMessage());
			throw $e;
		}
	});
} // PutCache()

function UnlinkCache($cacheName) { // Remove cache entries matching key pattern
	// alternative: DeleteCache(), RemoveCache()
	return Cache::retryOperation(function() use ($cacheName) {
		error_log("UnlinkCache: removing $cacheName");

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
			error_log("UnlinkCache: error: " . $e->getMessage());
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
			error_log("CacheExists: error: " . $e->getMessage());
			throw $e;
		}
	});
} // CacheExists()

register_shutdown_function(function() {
	Cache::closeDb();
});