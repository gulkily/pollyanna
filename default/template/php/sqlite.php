<?php
/* sqlite things */

function GetSqliteDbName () {
	# todo improve on this
	$cacheDir = GetDir('cache');
	$cacheVersion = GetMyCacheVersion();
	if ($cacheDir && file_exists($cacheDir)) {
		$sqliteDbName = $cacheDir . '/' . $cacheVersion . '/index.sqlite3';
		return $sqliteDbName;
	} else {
		WriteLog('GetSqliteDbName: sanity check FAILED: $cacheDir does not exist');
		return '';
	}
} # GetSqliteDbName()

function SqliteEscape ($text) { # Escapes supplied text for use in sqlite query
# Just changes ' to ''
	WriteLog("SqliteEscape($text)");

	if (isset($text)) {
		$text = str_replace("'", "''", $text);
	} else {
		$text = '';
	}

	WriteLog('SqliteEscape: return ' . $text);

	return $text;
} # SqliteEscape()

function SqliteGetValue ($query) { # Returns the first column from the first row returned by sqlite $query
	# #todo should allow returning columns other than 0
	# #todo this should use SqliteQuery()
	# #todo this should allow @queryParams like the other procedures (note: this is php version, not perl)

	WriteLog("SqliteGetValue($query)");

	$sqliteDir = GetSqliteDbName();

	#todo more sanity here

	$command = 'sqlite3 "' . $sqliteDir . '" "' . $query . '"';
	WriteLog('SqliteGetValue: $command = ' . $command);

	$result = `$command`;
	WriteLog('SqliteGetValue: $result = ' . $result);

	return $result;
} # SqliteGetValue()

function SqliteQueryBasic ($query) {
	if (!class_exists('SQLite3') || !extension_loaded('sqlite3')) {
		// The SQLite3 class or the SQLite extension is not available.
		// You can issue a warning or handle this situation as needed.
		// For example, you can log a message or throw an exception.
		WriteLog('SqliteQueryBasic: warning: SQLite3 class or SQLite extension is not available!');
		return '';
	}

	#todo more sanity

	$CACHEDIR = GetDir('cache');
	$DB = "$CACHEDIR/b/index.sqlite3";

	$db = new SQLite3($DB);
	$result = $db->query($query);
	$db->close();
} # SqliteQueryBasic()

function DBGetAuthorScore ($key) { # returns author's score
// 	if (!IsFingerprint($key)) {
// 		WriteLog('DBGetAuthorScore: warning: called with invalid parameter! returning');
// 		return;
// 	} #todo re-add this sanity check
	WriteLog("DBGetAuthorScore($key)");

	$key = SqliteEscape($key);

	if ($key) {
		$query = "SELECT author_score FROM author_score WHERE author_key = '$key'";
		$returnValue = SqliteGetValue($query);

		WriteLog('DBGetAuthorScore: $returnValue = ' . $returnValue);

		return $returnValue;
	} else {
		return "";
	}
} # DBGetAuthorScore()

function DBGetAuthorAlias ($key) { # returns author's alias
// 	if (!IsFingerprint($key)) {
// 		WriteLog('DBGetAuthorAlias: warning: called with invalid parameter! returning');
// 		return;
// 	} #todo re-add this sanity check
	WriteLog("DBGetAuthorAlias($key)");

	$key = SqliteEscape($key);

	if ($key) {
		$query = "SELECT alias FROM author_alias WHERE key = '$key'";
		$returnValue = SqliteGetValue($query);

		WriteLog('DBGetAuthorAlias: $returnValue = ' . $returnValue);

		return $returnValue;
	} else {
		return "";
	}
} # DBGetAuthorAlias()

