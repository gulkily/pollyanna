#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Carp;
use 5.010;

my @foundArgs;
while (my $argFound = shift) {
	push @foundArgs, $argFound;
}

sub GetSqliteDbName {
	state $cacheDir = GetDir('cache');
	state $cacheVersion = GetMyCacheVersion();
	my $SqliteDbName = "$cacheDir/$cacheVersion/index.sqlite3"; # path to sqlite db
	return $SqliteDbName;
} # GetSqliteDbName()

sub DBMaxQueryLength { # Returns max number of characters to allow in sqlite query
	return 1024;
} # DBMaxQueryLength()

sub DBMaxQueryParams { # Returns max number of parameters to allow in sqlite query
	return 128;
} # DBMaxQueryParams()

sub SqliteQuery2 {
	my $query = shift;
	my @params = @_;
	return SqliteQuery($query, @params);
} # SqliteQuery2()

sub SqliteIndexTagsets {
	my $suggestList = GetTemplate('tagset/suggest');
	my @suggest = split("\n", $suggestList);

	if (@suggest) {
		for my $tagSet (@suggest) {
			my $tagList = GetTemplate('tagset/' . $tagSet);
			my @tag = split("\n", $tagList);

			if (@tag) {
				for my $t (@tag) {
					my $query = "insert into tag_parent(tag, tag_parent) values(?, ?)";
					my @queryParams;
					push @queryParams, $t;
					push @queryParams, $tagSet;
					SqliteQuery($query, @queryParams);
				}
			}
		}
	}
} # SqliteIndexTagsets()

sub SqliteMakeTables { # creates sqlite schema
	# sub SqliteCreateTables {
	# sub SqliteMakeTables {
	# sub SqliteMakeSchema {
	# sub DBMakeTables {

	WriteLog('SqliteMakeTables()');

	my $existingTables = SqliteQueryCachedShell('.tables');
	if ($existingTables) {
		WriteLog('SqliteMakeTables: warning: tables already exist');
		return '';
	}

	my $schemaQueries = GetTemplate('sqlite3/schema.sql');
	$schemaQueries .= GetTemplate('sqlite3/vote_value.sql');

	$schemaQueries =~ s/^#.+$//mg; # remove sh-style comments (lines which begin with #)

	#confess $schemaQueries;

	SqliteQuery($schemaQueries);

	SqliteIndexTagsets();

	my $SqliteDbName = GetSqliteDbName();

	#todo cache the result so that this can be skipped if building often
} # SqliteMakeTables()

sub SqliteGetNormalizedQueryString { # $query ; returns normalized query string
	my $query = shift;
	chomp $query;

	my @queryParams = @_;

	if ($query =~ m/^(.+)$/s) { #todo real sanity check
		$query = $1;
	} else {
		WriteLog('SqliteGetNormalizedQueryString: warning: sanity check failed on $query');
		return '';
	}

	#WriteLog('SqliteGetNormalizedQueryString: $query = ' . $query);

	$query = SqliteGetQueryTemplate($query);

	# remove any non-space space characters and make it one line
	my $queryOneLine = $query;
	$queryOneLine =~ s/\s/ /g;
	while ($queryOneLine =~ m/\s\s/) {
		$queryOneLine =~ s/  / /g;
	}
	$queryOneLine = trim($queryOneLine);

	WriteLog('SqliteGetNormalizedQueryString: $queryOneLine = ' . $queryOneLine);
	WriteLog('SqliteGetNormalizedQueryString: caller: ' . join(', ', caller));

	my $queryWithParams = $queryOneLine;

	my @qmPositions;
	for (my $i = 0; $i < length($queryWithParams); $i++) {
		if (substr($queryWithParams, $i, 1) eq '?') {
			push @qmPositions, $i;
		}
	}

	if (scalar(@qmPositions) != scalar(@queryParams)) {
		WriteLog('SqliteGetNormalizedQueryString: warning: scalar(@qmPositions) != scalar(@queryParams); caller = ' . join(',', caller));
		return '';
	}

	my $addedCharacters = 0;
	if (@queryParams && scalar(@queryParams)) {
		# insert params into ? placeholders
		while (@queryParams) {
			my $paramValue = shift @queryParams;
			if ($paramValue) {
				$paramValue = str_replace("'", "''", $paramValue);
				$paramValue = str_replace('"', '""', $paramValue);

				$paramValue = str_replace('|', '-', $paramValue);
				# don't allow pipes because they are separator for sqlite3 output
			} else {
				$paramValue = '0';
			}
			$paramValue = "'" . $paramValue . "'";
			my $qmPosition = shift @qmPositions;
			$qmPosition += $addedCharacters;
			$addedCharacters += length($paramValue) - 1;
			$queryWithParams = substr($queryWithParams, 0, $qmPosition) . $paramValue . substr($queryWithParams, $qmPosition+1);
		}
	}

	WriteLog('SqliteGetNormalizedQueryString: $queryWithParams = ' . $queryWithParams);

	return $queryWithParams;
} # SqliteGetNormalizedQueryString()

sub SqliteQueryHashRef { # $query, @queryParams; calls sqlite with query, and returns result as array of hashrefs
# NOTE, THIS RETURNS A REFERENCE TO AN ARRAY OF HASHES, NOT A HASH, DESPITE THE NAME

# ATTENTION: first array element returned is an array of column names!

# example uses:
# 	my $hashRef1 = SqliteQueryHashRef('author_replies', @queryParams);
# 	my @authorReplies = @{$hashRef};
# 	my $hashRef2 = SqliteQueryHashRef('SELECT file_hash, item_title FROM item_flat', @queryParams);
# 	my @allItems = @{$hashRef};

#sub SqliteGetHash {
#sub SqliteGetHashRef {
#sub SqliteGetQueryHashRef {
#sub SqliteGetQuery {
#sub GetQuery {

#	WriteLog('SqliteQueryGetArrayOfHashRef: begin');
	WriteLog('SqliteQueryHashRef: begin; caller = ' . join(',', caller));

	my $query = shift;
	chomp $query;

	$query = SqliteGetQueryTemplate($query);

	my @queryParams = @_;
	my $queryWithParams = SqliteGetNormalizedQueryString($query, @queryParams);

	if ($queryWithParams) {
		#my $resultString = SqliteQueryCachedShell($queryWithParams);
		my $resultString = SqliteQuery($queryWithParams);

		WriteLog('SqliteQueryHashRef: $resultString is ' . ($resultString ? 'TRUE' : 'FALSE') . '; $queryWithParams = ' . $queryWithParams);

		if ($resultString) {
			my @resultsArray;
			my @resultStringLines = split("\n", $resultString);

			my @columns = ();
			while (@resultStringLines) {
				my $line = shift @resultStringLines;
				if (!@columns) {
					# first line is columns
					@columns = split ('\|', $line);
					push @resultsArray, \@columns;
					# store column names, next

					my %colTestTrack;
					for my $colText (@columns) {
						if (index($colText, '.') != -1) {
							WriteLog('SqliteQueryHashRef: warning: field name contains period character. $colText = ' . $colText);
						}
						if ($colTestTrack{$colText}) {
							WriteLog('SqliteQueryHashRef: warning: duplicate column name. $colText = ' . $colText);
						}
					}
				} else {
					my @fields = split('\|', $line);
					my %newHash;
					foreach my $field (@columns) {
						WriteLog('SqliteQueryHashRef: $field = ' . $field);
						$newHash{$field} = shift @fields;
					}
					push @resultsArray, \%newHash;
				}
			}

			return @resultsArray;
		} # if ($resultString)
	} # if ($query)
} # SqliteQueryHashRef()

sub SqliteQuery { # $query, @queryParams ; performs sqlite query via sqlite3 command
# returns whatever sqlite3 returns to STDOUT
	my $query = shift;
	if (!$query) {
		WriteLog('SqliteQuery: warning: called without $query');
		return;
	}
	chomp $query;
	my @queryParams = @_; # shift

	#WriteLog('SqliteQuery: $query = ' . $query);
	WriteLog('SqliteQuery: caller = ' . join(',', caller));
	$query = SqliteGetNormalizedQueryString($query, @queryParams);

	my $SqliteDbName = GetSqliteDbName();

	if ($SqliteDbName =~ m/^([_a-zA-Z0-9\/.]+)$/) {
		$SqliteDbName = $1;
		WriteLog('SqliteQuery: $SqliteDbName passed sanity check: ' . $SqliteDbName);
	} else {
		WriteLog('SqliteQuery: $SqliteDbName FAILED sanity check: ' . $SqliteDbName);
		return '';
	}

	if ($query =~ m/^(.+)$/s) {
#	if ($query =~ m/^([[:print:]\n\r\s]+)$/s) {
		# this is only a basic sanity check, but it's better than nothing
		$query = $1;
		WriteLog('SqliteQuery: $query passed sanity check');
	} else {
		my $outLogName = sha1_hex(time().$query).'.query';
		state $outLogDir = GetDir('log');
		PutFile("$outLogDir/$outLogName", $query);

		WriteLog('SqliteQuery: warning! non-printable characters found: ' . $outLogName);
		return '';
	}

	if ($query =~ m/\?/) {
		WriteLog('SqliteQuery: warning: $query contains QM; caller = ' . join(',', caller));
		# this may indicate that a variable placeholder was not filled
	}

	my $logName = substr(GetRandomHash(), 0, 16) . '.sqlerr';
	state $logDir = GetDir('log');
	my $sqliteErrorLog = $logDir . '/' . $logName;

	#$query = str_replace('$', '', $query);
	$query = str_replace('$', '\\$', $query);
	$query = str_replace('`', '\`', $query);
	#

	my $shCommand = "sqlite3 -header \"$SqliteDbName\" \"$query\" 2>$sqliteErrorLog";
	WriteLog('SqliteQuery: $shCommand = ' . $shCommand);
	#my $results = `sqlite3 -header "$SqliteDbName" "$query" 2>$sqliteErrorLog`;

	if (0 && GetConfig('debug')) {
		# used to generate a baseline of characters which can be in an sql query
		my $existingChars = GetFile('temp_sql.sh');
		for (my $i = 0; $i < length($shCommand); $i++) {
			my $thisChar = substr($shCommand, $i, 1);
			if (index($existingChars, $thisChar) == -1) {
				$existingChars .= $thisChar;
			}
		}
		PutCache('sqlite_encountered_characters', $existingChars);
	}
	
	if ($shCommand =~ m/^(.+)$/s) {
	# if ($shCommand =~ m/^([[:print:]\n\r\s]+)$/s) {
		# this is only a basic sanity check, but it's better than nothing
		WriteLog('SqliteQuery: $query passed sanity check');
		$shCommand = $1;
	} else {
		my $outLogName = sha1_hex(time().$shCommand).'.shcommand';
		state $outLogDir = GetDir('log');
		PutFile("$outLogDir/$outLogName", $shCommand);
		WriteLog('SqliteQuery: warning: $shCommand failed sanity check for printable characters only: ' . $outLogName);
		return '';
	}

	my $results = '';
	$results = `$shCommand`;

	if (index(trim(lc(GetFile($sqliteErrorLog))), 'locked') != -1) {
		#sometimes the database is locked for a moment, so we retry 3 times before giving up
		#hack
		WriteLog('SqliteQuery: warning: locked database detected. retrying');
		my $retryCount = 0;
		while ($retryCount < 3 && trim(GetFile($sqliteErrorLog))) {
			WriteLog('SqliteQuery: locked retrying in 0.25s. Error is: ' . trim(GetFile($sqliteErrorLog)));
			select(undef, undef, undef, 0.25);
			$retryCount++;
			$results = `$shCommand`;
		}
		WriteLog('SqliteQuery: locked: retry loop exited, Error is: ' . trim(GetFile($sqliteErrorLog)));
		if (trim(GetFile($sqliteErrorLog))) {
			WriteLog('SqliteQuery: unable to recover from locked state; $retryCount = ' . $retryCount);
			unlink($sqliteErrorLog);
		} else {
			WriteLog('SqliteQuery: recovered from locked state; $retryCount = ' . $retryCount);
		}
	}

	if ($?) {
		# this is a special perl thing which contains STDERR from most recent backtick command
		WriteLog('SqliteQuery: warning: error returned; caller = ' . join(',', caller));
		AppendFile($sqliteErrorLog, $query);
		AppendFile($sqliteErrorLog, 'caller: ' . join(',', caller));
		return '';
	}

	if (GetFile($sqliteErrorLog)) {
		WriteLog('SqliteQuery: warning: sqlite3 call wrote to stderr: ' . $sqliteErrorLog . '; caller = ' . join(',', caller));

		AppendFile('' . $sqliteErrorLog, $query . "\n");
		AppendFile('' . $sqliteErrorLog, join(',', caller));
		AppendFile('' . $sqliteErrorLog, GetTime());

		#retry once
		#my $callerString = join(',', caller);
		#my $callerSub = substr($callerString, 0, index($callerString, ','));

	} else {
		if (-e $sqliteErrorLog) {
			#output file exists, but is empty
			#this would be because of a locked database retry, for example
			unlink($sqliteErrorLog);
		}
	}

	return $results;
} # SqliteQuery()

sub SqliteGetQueryTemplate { # $query ; look up query in templates if necessary or just return $query
# sub SqliteGetQuery {
# sub GetQuery {
# sub ExpandQuery {
# sub GetQueryTemplate {
	my $query = shift;
	if (!$query) {
		WriteLog('SqliteGetQueryTemplate: warning: called without $query');
		return '';
	}
	chomp $query;

	if (index($query, ' ') == -1 && substr($query, 0, 1) ne '.') {
		if ($query =~ m/^([a-zA-Z0-9\-_.]+)$/) {
			my $querySane = $1;
			WriteLog('SqliteGetQueryTemplate: looking up query/' . $querySane);

			if (GetTemplate('query/' . $querySane)) {
				$querySane = GetTemplate('query/' . $querySane);
				return $querySane;
			} else {
				WriteLog('SqliteGetQueryTemplate: warning: query has no spaces, no template found; $query = ' . $query);
				return $querySane;
			}
		} else {
			WriteLog('SqliteGetQueryTemplate: warning: query has no spaces, failed sanity check; $query = ' . $query);
			return $query;
		}
	} else {
		WriteLog('SqliteGetQueryTemplate: query has space character(s), returning without change; caller = ' . join(',', caller));
		return $query;
	}
} # SqliteGetQueryTemplate()

sub SqliteGetPopulatedQuery { # $query, @queryParams ; look up query and populate parameters
	my $query = shift;
	if (!$query) {
		WriteLog('SqliteQueryCachedShell: warning: called without $query');
		return;
	}
	chomp $query;
	my @queryParams = @_;

	#todo count question marks and match with params #sanity



} # SqliteGetPopulatedQuery()

sub SqliteQueryCachedShell { # $query, @queryParams ; performs sqlite query via sqlite3 command
# uses cache with query text's hash as key
# sub CacheSqliteQuery {
	WriteLog('SqliteQueryCachedShell: caller: ' . join(', ', caller));

	my $withHeader = 1;

	my $query = shift;
	if (!$query) {
		WriteLog('SqliteQueryCachedShell: warning: called without $query');
		return;
	}
	chomp $query;
	my @queryParams = @_;

	$query = SqliteGetNormalizedQueryString($query, @queryParams);

	my $cachePath = md5_hex($query);
	if ($cachePath =~ m/^([0-9a-f]{32})$/) {
		$cachePath = $1;
	} else {
		WriteLog('SqliteQueryCachedShell: warning: $cachePath sanity check failed');
	}
	my $cacheTime = GetTime();

	if (0) {
		# this limits the cache to expiration of 1-100 seconds
		# #bug this does not account for milliseconds
		$cacheTime = substr($cacheTime, 0, length($cacheTime) - 2);
		$cachePath = "$cacheTime/$cachePath";
	}

	WriteLog('SqliteQueryCachedShell: $cachePath = ' . $cachePath);
	my $results;

	$results = GetCache("sqlite3_results/$cachePath");

	if ($results) {
		#cool
		WriteLog('SqliteQueryCachedShell: $results was populated from cache');
	} else {
		my $results = SqliteQuery($query);
		if ($results) {
			WriteLog('SqliteQueryCachedShell: PutCache: length($results) ' . length($results));
			PutCache('sqcs/'.$cachePath, $results);
		} else {
			WriteLog('SqliteQueryCachedShell: warning: $results was FALSE; $query = ' . $query);
			WriteLog('SqliteQueryCachedShell: warning: $results was FALSE; caller = ' . join(',', caller));
		}
	}

	if ($results) {
		return $results;
	}
} # SqliteQueryCachedShell()

sub DBGetVotesForItem { # Returns all votes (weighed) for item
	my $fileHash = shift;

	if (!IsItem($fileHash)) {
		WriteLog("DBGetVotesTable called with invalid parameter! returning");
		WriteLog("$fileHash");
		return '';
	}

	my $query;
	my @queryParams;

	$query = "
		SELECT
			file_hash,
			ballot_time,
			vote_value,
			author_key
		FROM vote
		WHERE file_hash = ?
	";
	@queryParams = ($fileHash);

	my @result = SqliteQueryHashRef($query, @queryParams);

	return @result;
} # DBGetVotesForItem()
#
sub DBGetAuthorFriends { # Returns list of authors which $authorKey has tagged as friend
# Looks for vote_value = 'friend' and items that contain 'pubkey' tag
	my $authorKey = shift;
	chomp $authorKey;
	if (!$authorKey) {
		return;
	}
	if (!IsFingerprint($authorKey)) {
		return;
	}

	my $query = "
		SELECT
			DISTINCT item_flat.author_key
		FROM
			vote
			LEFT JOIN item_flat ON (vote.file_hash = item_flat.file_hash)
		WHERE
			vote.author_key = ?
			AND vote_value = 'friend'
			AND ',' || item_flat.tags_list || ',' LIKE '%,pubkey,%'
		;
	";

	my @queryParams = ();
	push @queryParams, $authorKey;

	my @queryResult = SqliteQueryHashRef($query, @queryParams);
	return @queryResult;

} # DBGetAuthorFriends()

sub DBGetAuthorCount { # Returns author count.
# By default, all authors, unless $whereClause is specified

	my $authorCount;
	my $query = 'author_count';
	my $queryResult = SqliteGetValue($query);
	return $queryResult;
} # DBGetAuthorCount()

sub DBGetItemCount { # Returns item count.
# By default, all items, unless $whereClause is specified
	#my $whereClause = shift;

	my $itemCount;

	$itemCount = SqliteGetValue('item_count');
#	}
	if ($itemCount) {
		chomp($itemCount);
	}

	if (!$itemCount) {
		$itemCount = 0;
	}

	return $itemCount;
} # DBGetItemCount()

sub DBGetItemParents {# Returns all item's parents
# $itemHash = item's hash/identifier
# Sets up parameters and calls DBGetItemList
	my $itemHash = shift;

	if (!IsItem($itemHash)) {
		WriteLog('DBGetItemParents called with invalid parameter! returning');
		return '';
	}

	$itemHash = SqliteEscape($itemHash);

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE file_hash IN(SELECT item_hash FROM item_child WHERE item_hash = '$itemHash')";
	$queryParams{'order_clause'} = "ORDER BY add_timestamp"; #todo this should be by timestamp

	return DBGetItemList(\%queryParams);
} # DBGetItemParents()

sub DBGetTopLevelItem { # $item ; traverse parents until top-level item is reached
	#todo this can be a recursive sqlite query

	#todo sanity
	#todo immutable things?

	my $item = shift;

	my $firstParent = $item;
	my $newParent = $firstParent;

	while ($newParent) {
		$newParent = SqliteGetValue("SELECT parent_hash FROM item_parent WHERE item_hash = '$firstParent' LIMIT 1"); #todo parameterize ORDER BY score DESC?
		if ($newParent) {
			$firstParent = $newParent;
		} else {
			$newParent = 0;
		}
	}

	return $firstParent;
} # DBGetTopLevelItem()

sub DBGetItemReplies { # Returns replies for item (actually returns all child items)
# $itemHash = item's hash/identifier
# Sets up parameters and calls DBGetItemList
	my $itemHash = shift;
	if (!IsItem($itemHash)) {
		WriteLog('DBGetItemReplies: warning: sanity check failed, returning');
		return '';
	}
	if ($itemHash ne SqliteEscape($itemHash)) {
		WriteLog('DBGetItemReplies: warning: $itemHash contains escapable characters');
		return '';
	}
	WriteLog("DBGetItemReplies($itemHash)");

	my %queryParams;
	if (GetConfig('admin/expo_site_mode') && !GetConfig('admin/expo_site_edit')) {
		$queryParams{'where_clause'} = "WHERE ','||tags_list||',' NOT LIKE '%,notext,%' AND file_hash IN(SELECT item_hash FROM item_parent WHERE parent_hash = '$itemHash')";
	} else {
		$queryParams{'where_clause'} = "WHERE file_hash IN (SELECT item_hash FROM item_parent WHERE parent_hash = '$itemHash')";
	}
	$queryParams{'order_clause'} = "ORDER BY (tags_list NOT LIKE '%hastext%'), add_timestamp DESC";

	return DBGetItemList(\%queryParams);
} # DBGetItemReplies()

sub SqliteEscape { # Escapes supplied text for use in sqlite query
# Just changes ' to ''
	my $text = shift;

	if (defined $text) {
		$text =~ s/'/''/g;
	} else {
		$text = '';
	}

	return $text;
} # SqliteEscape()

sub SqliteGetCount {
# sub GetCount {
# sub GetQueryCount {

	my $query = shift;
	#todo sanity;
	#todo params

	my $queryText = SqliteGetNormalizedQueryString($query);
	WriteLog('SqliteGetCount: $queryText = ' . $queryText);

	my $queryItemCount = "SELECT COUNT(*) AS item_count FROM ($queryText) LIMIT 1";
	my $rowCount = SqliteGetValue($queryItemCount);

	return $rowCount;
} # SqliteGetCount()

sub SqliteGetValue {
# sub SqliteQueryGetValue {
# sub SqliteQueryValue {
# sub GetSqliteValue {
# sub GetQueryValue {
	my $query = shift;
	my @queryParams = @_;

	WriteLog('SqliteGetValue: caller: ' . join(',', caller));

	my @result = SqliteQueryHashRef($query, @queryParams);

	if (scalar(@result) > 2) {
		WriteLog('SqliteGetValue: warning: query returned more than one row. caller = ' . join(',', caller));
	}

	if (scalar(@result) > 1) {
		# the first item in the array is the headers, so it should have 2 or more members
		my @columns = @{$result[0]};

		my $columnCount = scalar(@columns);
		if (!$columnCount) {
			WriteLog('SqliteGetValue: warning: no columns! caller = ' . join(',', caller));
			return '';
		}
		if ($columnCount > 1) {
			WriteLog('SqliteGetValue: warning: query returned more than one column. caller = ' . join(',', caller));
		}

		my $firstColumn = $columns[0];  # name of the first column
		my %firstRow = %{$result[1]}; # first row
		my $return = $firstRow{$firstColumn}; # first column's value from first row

		WriteLog('SqliteGetValue: $return = ' . $return);

		return $return;
	} else {
		# nothing found, return nothing
		WriteLog('SqliteGetValue: $return FALSE');

		return '';
	}
} # SqliteGetValue()

sub DBGetItemTitle { # get title for item ($itemhash)
	my $itemHash = shift;

	if (!$itemHash || !IsItem($itemHash)) {
		return;
	}

	#my $query = 'SELECT title FROM item_title WHERE file_hash = ?';
	my @queryParams = ();
	#push @queryParams, $itemHash;

	#fuck parametrized queries
	my $query = 'SELECT title FROM item_title WHERE file_hash LIKE \'' . $itemHash . '%\'';

	my $itemTitle = SqliteGetValue($query, @queryParams);

	if ($itemTitle) {
		my $maxLength = shift;
		if ($maxLength) {
			if ($maxLength > 0 && $maxLength < 255) {
				#todo sanity check failed message
				if (length($itemTitle) > $maxLength) {
					$itemTitle = TrimUnicodeString($itemTitle, $maxLength);
					# $itemTitle = substr($itemTitle, 0, $maxLength) . '...';
				}
			}
		}

		return $itemTitle;
	} else {
		return '';
	}
} # DBGetItemTitle()

sub DBGetItemFilePath { # get path for item's source file
# sub GetItemFileName {
# sub GetItemFile {
	my $itemHash = shift;

	if (!$itemHash || !IsItem($itemHash)) {
		return;
	}

	my $query = 'SELECT file_path FROM item WHERE file_hash = ?';
	my @queryParams = ();

	push @queryParams, $itemHash;

	my $itemFile = SqliteGetValue($query, @queryParams);

	if ($itemFile) {
		return $itemFile;
	} else {
		return '';
	}
} # DBGetItemTitle()

sub DBGetItemType { # get type of item
# sub GetItemFileType {
# sub GetItemFile {
	my $itemHash = shift;

	if (!$itemHash || !IsItem($itemHash)) {
		return;
		#todo more sanity
	}

	my $query = 'SELECT item_type FROM item WHERE file_hash = ?';
	my @queryParams = ();

	push @queryParams, $itemHash;

	my $itemType = SqliteGetValue($query, @queryParams);

	if ($itemType) {
		return $itemType;
	} else {
		return '';
	}
} # DBGetItemType()

sub DBGetItemAuthor { # get author for item ($itemhash)
	my $itemHash = shift;

	if (!$itemHash || !IsItem($itemHash)) {
		return;
	}

	chomp $itemHash;

	WriteLog('DBGetItemAuthor(' . $itemHash . ')');

	my $query = 'SELECT author_key FROM item_flat WHERE file_hash = ?';
	my @queryParams = ();
	#
	push @queryParams, $itemHash;

	WriteLog('DBGetItemAuthor: $query = ' . $query);

	my $authorKey = SqliteGetValue($query, @queryParams);

	if ($authorKey) {
		return $authorKey;
	} else {
		return;
	}
} # DBGetItemAuthor()

sub DBAddConfigValue { # $key, $value, $resetFlag, $sourceItem ; add value to config table
	state $query;
	state @queryParams;

	my $key = shift;

	if (!$key) {
		WriteLog('DBAddConfigValue: warning: sanity check failed');
		return '';
	}

	if ($key eq 'flush') {
		WriteLog("DBAddConfigValue(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		$query = '';
		@queryParams = ();
	}

	my $value = shift;
	my $resetFlag = shift;
	my $sourceItem = shift;

	if ($key =~ m/^([a-z0-9_\/.]+)$/) {
		# sanity success
		$key = $1;
	} else {
		WriteLog('DBAddConfigValue: warning: sanity check failed on $key = ' . $key);
		return '';
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO config(key, value, reset_flag, file_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?)';
	push @queryParams, $key, $value, $resetFlag, $sourceItem;

	return;
} # DBAddConfigValue()

sub DBGetTouchedPages { # Returns items from task table, used for prioritizing which pages need rebuild
# index, rss, authors, stats, tags, and top are returned first
	my $touchedPageLimit = shift;

	WriteLog("DBGetTouchedPages($touchedPageLimit)");

	# sorted by most recent (touch_time DESC) so that most recently touched pages are updated first.
	# this allows us to call a shallow update and still expect what we just did to be updated.
	my $query = "
		SELECT
			task_name,
			task_param,
			touch_time,
			priority
		FROM task
		WHERE task_type = 'page' AND priority > 0
		ORDER BY priority DESC, touch_time DESC
		LIMIT ?;
	";

	my @params;
	push @params, $touchedPageLimit;

	my @results = SqliteQueryHashRef($query, @params);

	return @results;
} # DBGetTouchedPages()

sub DBGetAllPages { # Returns items from task table, used for prioritizing which pages need rebuild
# index, rss, authors, stats, tags, and top are returned first
	my $touchedPageLimit = shift;

	WriteLog("DBGetAllPages($touchedPageLimit)");

	# sorted by most recent (touch_time DESC) so that most recently touched pages are updated first.
	# this allows us to call a shallow update and still expect what we just did to be updated.
	my $query = "
		SELECT
			task_name,
			task_param,
			touch_time,
			priority
		FROM task
		WHERE task_type = 'page'
		ORDER BY priority DESC, touch_time DESC
		;
	";

	my @params;

	my @results = SqliteQueryHashRef($query, @params);

	return @results;
} # DBGetAllPages()

sub DBAddItemPage { # $itemHash, $pageType, $pageParam ; adds an entry to item_page table
# should perhaps be called DBAddItemPageReference
# purpose of table is to track which items are on which pages

	state $query;
	state @queryParams;

	my $itemHash = shift;

	if ($itemHash eq 'flush') {
		if ($query) {
			WriteLog("DBAddItemPage(flush)");

			if (!$query) {
				WriteLog('Aborting, no query');
				return;
			}

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = "";
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddItemPage('flush');
		$query = '';
		@queryParams = ();
	}

	my $pageType = shift;
	my $pageParam = shift;

	if (!$pageType) {
		WriteLog('DBAddItemPage: warning: called without $pageType');
		return;
	}
	if (!$pageParam) {
		$pageParam = '';
	}

	WriteLog("DBAddItemPage($itemHash, $pageType, $pageParam)");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item_page(item_hash, page_name, page_param) VALUES ";
	} else {
		$query .= ',';
	}

	$query .= '(?, ?, ?)';
	push @queryParams, $itemHash, $pageType, $pageParam;
} # DBAddItemPage()

sub DBResetPageTouch { # Clears the task table
# Called by clean-build, since it rebuilds the entire site
	WriteMessage("DBResetPageTouch() begin");

	my $query = "DELETE FROM task WHERE task_type = 'page'";
	my @queryParams = ();

	SqliteQuery($query, @queryParams);

	WriteMessage("DBResetPageTouch() end");
} # DBResetPageTouch()

sub DBDeletePageTouch { # $pageName, $pageParam
#todo optimize
	#my $query = 'DELETE FROM task WHERE page_name = ? AND page_param = ?';
	my $query = "UPDATE task SET priority = 0 WHERE task_type = 'page' AND task_name = ? AND task_param = ?";

	my $pageName = shift;
	my $pageParam = shift;

	my @queryParams = ($pageName, $pageParam);

	SqliteQuery($query, @queryParams);
} # DBDeletePageTouch()

sub DBDeleteItemReferences { # delete all references to item from tables
# sub RemoveItemReferences {
# #todo feels not up to date as of 1617729803 / march 6 2021
# #todo ensure that table lists are up to date
	WriteLog('DBDeleteItemReferences() ...');

	my @hashesToDelete;
	my $queryPlaceholders = '';
	
	while (my $hash = shift) {
		if (IsItem($hash)) {
			push @hashesToDelete, $hash;
			if ($queryPlaceholders) {
				$queryPlaceholders .= ', ?';
			} else {
				$queryPlaceholders .= '?';
			}
		}
	}
	
	if ( ! @hashesToDelete) {
		WriteLog('DBDeleteItemReferences: warning: @hashesToDelete was FALSE');
		return '';
	}

	WriteLog('DBDeleteItemReferences: scalar(@hashesToDelete) = ' . scalar(@hashesToDelete));

	#todo queue all pages in item_page ;
	#todo item_page should have all the child items for replies

	#file_hash
	my @tables = qw(
		author_alias
		config
		item
		item_attribute
	);
	foreach (@tables) {
		my $query = "DELETE FROM $_ WHERE file_hash IN ($queryPlaceholders)";
		SqliteQuery($query, @hashesToDelete);
	}

	#item_hash
	my @tables2 = qw(item_page item_parent location);
	foreach (@tables2) {
		my $query = "DELETE FROM $_ WHERE item_hash IN ($queryPlaceholders)";
		SqliteQuery($query, @hashesToDelete);
	}

	{ #dupe of below? #todo
		my $query = "DELETE FROM vote WHERE ballot_hash IN ($queryPlaceholders)";
		SqliteQuery($query, @hashesToDelete);
	}

	{
		my $query = "DELETE FROM item_attribute WHERE source IN ($queryPlaceholders)";
		SqliteQuery($query, @hashesToDelete);
	}

	#ballot_hash
	my @tables3 = qw(vote);
	foreach (@tables3) {
		my $query = "DELETE FROM $_ WHERE ballot_hash IN ($queryPlaceholders)";
		SqliteQuery($query, @hashesToDelete);
	}

	#todo
	#item_attribute.source
	#item_parent (?)
	#item_page (and refresh)
	#
	#
	#

	#todo any successes deleting stuff should result in a refresh for the affected page
} # DBDeleteItemReferences()

sub DBAddTask { # $taskType, $taskName, $taskParam, $touchTime # make new task
# DBAddTaskToQueue {

	state $query;
	state @queryParams;

	my $taskType = shift;

	if ($taskType eq 'flush') {
		# flush to database queue stored in $query and @queryParams
		if ($query) {
			WriteLog("DBAddTask(flush)");

			if (!$query) {
				WriteLog('DBAddTask: flush: no query, exiting');
				return;
			}

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = "";
			@queryParams = ();
		}

		return;
	}

	my $taskName = shift;
	my $taskParam = shift;
	my $touchTime = shift;

	WriteLog("DBAddTask($taskType, $taskName, $taskParam, $touchTime)");

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddTask('flush');
		$query = '';
		@queryParams = ();
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO task(task_type, task_name, task_param, touch_time) VALUES ";
	} else {
		$query .= ',';
	}

	$query .= "(?, ?, ?, ?)";
	push @queryParams, $taskType, $taskName, $taskParam, $touchTime;
} # DBAddTask()

sub DBAddPageTouch { # $pageName, $pageParam; Adds or upgrades in priority an entry to task table
# task table is used for determining which pages need to be refreshed
# is called from IndexTextFile() to schedule updates for pages affected by a newly indexed item
# if $pageName eq 'flush' then all the in-function stored queries are flushed to database.
	state $query;
	state @queryParams;

	my $pageName = shift;

	if ($pageName eq 'index') {
		#return;
		# this can be uncommented during testing to save time
		#todo optimize this so that all pages aren't rewritten at once
	}

	if ($pageName eq 'tag') {
		# if a tag page is being updated,
		# then the tags summary page must be updated also
		DBAddPageTouch('tags');
	}
	#
	# if ($pageName eq 'item') {
	# 	my @extraPages = qw(search bookmark data desktop manual manual_advanced manual_tokens chain compost deleted);
	# 	for my $extraPage (@extraPages) {
	# 		DBAddPageTouch($extraPage);
	# 		#todo this is an inefficient hack, fix it
	# 	}
	# }

	if ($pageName eq 'flush') {
		# flush to database queue stored in $query and @queryParams
		if ($query) {
			WriteLog("DBAddPageTouch(flush)");

			if (!$query) {
				WriteLog('Aborting DBAddPageTouch(flush), no query');
				return;
			}

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = "";
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddPageTouch('flush');
		$query = '';
		@queryParams = ();
	}

	my $pageParam = shift;

	if (!$pageParam) {
		$pageParam = 0;
	}

	my $touchTime = GetTime();

	if ($pageName eq 'author') {
		# cascade refresh items which are by this author
		#todo probably put this in another function
		# could also be done as
		# foreach (author's items) { DBAddPageTouch('item', $item); }
		#todo this is kind of a hack, sould be refactored, probably

		# touch all of author's items too
		#todo fix awkward time() concat
		my $queryAuthorItems = "
			UPDATE task
			SET priority = (priority + 1), touch_time = " . time() . "
			WHERE
				task_type = 'page' AND
				task_name = 'item' AND
				task_param IN (
					SELECT file_hash FROM item_flat WHERE author_key = ?
				)
		";
		my @queryParamsAuthorItems;
		push @queryParamsAuthorItems, $pageParam;

		SqliteQuery($queryAuthorItems, @queryParamsAuthorItems);
	}
	#
	# if ($pageName eq 'item') {
	# 	# cascade refresh items which are by this author
	# 	#todo probably put this in another function
	# 	# could also be done as
	# 	# foreach (author's items) { DBAddPageTouch('item', $item); }
	#
	# 	# touch all of author's items too
	# 	my $queryAuthorItems = "
	# 		UPDATE task
	# 		SET priority = (priority + 1)
	# 		WHERE
	#			task_type = 'page' AND
	# 			task_name = 'item' AND
	# 			task_param IN (
	# 				SELECT file_hash FROM item WHERE author_key = ?
	# 			)
	# 	";
	# 	my @queryParamsAuthorItems;
	# 	push @queryParamsAuthorItems, $pageParam;
	#
	# 	SqliteQuery($queryAuthorItems, @queryParamsAuthorItems);
	# }

	#todo need to incremenet priority after doing this

	WriteLog("DBAddPageTouch($pageName, $pageParam)");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO task(task_type, task_name, task_param, touch_time) VALUES ";
	} else {
		$query .= ',';
	}

	#todo
	# https://stackoverflow.com/a/34939386/128947
	# insert or replace into poet (_id,Name, count) values (
	# 	(select _id from poet where Name = "SearchName"),
	# 	"SearchName",
	# 	ifnull((select count from poet where Name = "SearchName"), 0) + 1)
	#
	# https://stackoverflow.com/a/3661644/128947
	# INSERT OR REPLACE INTO observations
	# VALUES (:src, :dest, :verb,
	#   COALESCE(
	#     (SELECT occurrences FROM observations
	#        WHERE src=:src AND dest=:dest AND verb=:verb),
	#     0) + 1);


	$query .= "(?, ?, ?, ?)";
	push @queryParams, 'page', $pageName, $pageParam, $touchTime;
} # DBAddPageTouch()

sub DBGetVoteCounts { # Get total vote counts by tag value
# Takes $orderBy as parameter, with vote_count being default;
#todo can probably be converted to parameterized query
	my $orderBy = shift;
	if ($orderBy) {
	} else {
		$orderBy = 'ORDER BY vote_count DESC';
	}

	my $query = "
		SELECT
			vote_value,
			vote_count
		FROM (
			SELECT
				vote_value,
				COUNT(vote_value) AS vote_count
			FROM
				vote
			WHERE
				file_hash IN (SELECT file_hash FROM item)
			GROUP BY
				vote_value
		)
		WHERE
			vote_count >= 1
		$orderBy;
	";

	my @result = SqliteQueryHashRef($query);

	return @result;
} # DBGetVoteCounts()

sub DBGetTagCount { # Gets number of distinct tag/vote values
	my $query = "
		SELECT
			COUNT(vote_value) AS vote_count
		FROM (
			SELECT
				DISTINCT vote_value
			FROM
				vote
			GROUP BY
				vote_value
		)
		LIMIT 1
	";

	my $result = SqliteGetValue($query);

	return $result;
} # DBGetTagCount()

sub DBGetItemLatestAction { # returns highest timestamp in all of item's children
# $itemHash is the item's identifier

	my $itemHash = shift;
	my @queryParams = ();

	# this is my first recursive sql query
	my $query = '
	SELECT MAX(add_timestamp) AS add_timestamp
	FROM item_flat
	WHERE file_hash IN (
		WITH RECURSIVE item_threads(x) AS (
			SELECT ?
			UNION ALL
			SELECT item_parent.item_hash
			FROM item_parent, item_threads
			WHERE item_parent.parent_hash = item_threads.x
		)
		SELECT * FROM item_threads
	)
	';

	push @queryParams, $itemHash;

	return SqliteGetValue($query, @queryParams);
} # DBGetItemLatestAction()

sub DBAddKeyAlias { # adds new author-alias record $key, $alias, $pubkeyFileHash
	# $key = user key
	# $alias = alias/name
	# $pubkeyFileHash = hash of file in which alias was established

	state $query;
	state @queryParams;

	my $key = shift;

	if ($key eq 'flush') {
		if ($query) {
			WriteLog("DBAddKeyAlias(flush)");

			if (!$query) {
				WriteLog('Aborting, no query');
				return;
			}

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = "";
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddKeyAlias('flush');
		$query = '';
		@queryParams = ();
	}

	my $alias = shift;
	my $pubkeyFileHash = shift;

	if (!$query) {
		$query = "INSERT OR REPLACE INTO author_alias(key, alias, file_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= "(?, ?, ?)";
	push @queryParams, $key, $alias, $pubkeyFileHash;

	ExpireAvatarCache($key); # does fresh lookup, no cache
	DBAddPageTouch('author', $key);
} # DBAddKeyAlias()

sub DBAddItemParent { # $itemHash, $parentItemHash ; Add item parent record.
# Usually this is when item references parent item, by being a reply or a vote, etc.
#todo replace with item_attribute
	state $query;
	state @queryParams;

	my $itemHash = shift;

	if ($itemHash eq 'flush') {
		if ($query) {
			WriteLog('DBAddItemParent(flush)');

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddPageTouch('flush');
		DBAddItemParent('flush');
		$query = '';
		@queryParams = ();
	}

	my $parentHash = shift;

	if (!$parentHash) {
		WriteLog('DBAddItemParent: warning: $parentHash missing');
		return;
	}

	if ($itemHash eq $parentHash) {
		WriteLog('DBAddItemParent: warning: $itemHash eq $parentHash');
		return;
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item_parent(item_hash, parent_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?)';
	push @queryParams, $itemHash, $parentHash;

	DBAddPageTouch('item', $itemHash);
	DBAddPageTouch('item', $parentHash);
} # DBAddItemParent()

sub DBAddItem2 {
	my $filePath = shift;
	my $fileHash = shift;
	my $itemType = shift;
	my $fileName = TrimPath($filePath);
	return DBAddItem($filePath, $fileName, '', $fileHash, $itemType, 0);
} # DBAddItem2()

sub DBAddItem { # $filePath, $fileName, $authorKey, $fileHash, $itemType, $verifyError ; Adds a new item to database
# $filePath = path to text file
# $fileName = item's file name
# $authorKey = author's gpg fingerprint
# $fileHash = hash of item
# $itemType = type of item (currently 'txt' is supported)
# $verifyError = whether there was an error with gpg verification of item

	state $query;
	state @queryParams;

	my $filePath = shift;

	if ($filePath eq 'flush') {
		if ($query) {
			WriteLog("DBAddItem(flush)");
			$query .= ';';
			SqliteQuery($query, @queryParams);
			$query = '';
			@queryParams = ();
			DBAddItemAttribute('flush');
		}

		return '';
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddItem('flush');
		$query = '';
		@queryParams = ();
	}

	if (-e $filePath) {
		#cool
	} else {
		WriteLog('DBAddItem: warning: -e $filePath returned FALSE; $filePath = ' . $filePath . '; caller = ' . join (',', caller));
	}

	my $fileAbsPath = GetAbsolutePath($filePath);
	if ($fileAbsPath) {
		if ($filePath eq $fileAbsPath) {
			#cool
		} else {
			if (-e $fileAbsPath) {
				WriteLog('DBAddItem: warning: $filePath ne $fileAbsPath, FIXING; caller = ' . join (',', caller));
				$filePath = $fileAbsPath;
			} else {
				WriteLog('DBAddItem: warning: sanity check failed (1); caller = ' . join (',', caller));
				return '';
			}
		}
	} else {
		WriteLog('DBAddItem: warning: sanity check failed (2); caller = ' . join (',', caller));
		return '';
	}

	my $fileName = shift;
	my $authorKey = shift;
	my $fileHash = shift;
	my $itemType = shift;
	my $verifyError = shift; #todo remove this and move it somewhere else

	if (!$itemType) {
		WriteLog('DBAddItem: warning: $itemType was FALSE');
		return ''; #todo
	}

	if (!$verifyError) {
		$verifyError = '';
	}

	#DBAddItemAttribute($fileHash, 'attribute', 'value', 'epoch', 'source');

	if (!$authorKey) {
		$authorKey = '';
	}

	if (!$fileName) {
		$fileName = 'Untitled';
		WriteLog('DBAddItem: warning: $fileName missing; $filePath = ' . $filePath . '; caller = ' . join(',', caller));
	}
#
#	if ($authorKey) {
#		DBAddItemParent($fileHash, DBGetAuthorPublicKeyHash($authorKey));
#	}

	WriteLog("DBAddItem($filePath, $fileName, $authorKey, $fileHash, $itemType, $verifyError);");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item(file_path, file_name, file_hash, item_type) VALUES ";
	} else {
		$query .= ",";
	}
	push @queryParams, $filePath, $fileName, $fileHash, $itemType;

	$query .= "(?, ?, ?, ?)";

	my $filePathRelative = $filePath;
	state $htmlDir = GetDir('html');
	$filePathRelative =~ s/$htmlDir\//\//;

	WriteLog('DBAddItem: $filePathRelative = ' . $filePathRelative . '; $htmlDir = ' . $htmlDir);

	DBAddItemAttribute($fileHash, 'sha1', $fileHash);

	if (GetConfig('setting/admin/index/extra_hashes')) {
		DBAddItemAttribute($fileHash, 'md5', md5_hex(GetFile($filePath)));
	}

	if (GetConfig('setting/admin/index/sha1sum')) {
		state $pathSha1sum = `which sha1sum`;
		if ($pathSha1sum) {
			if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
				#todo this should be somewhere else
				my $filePathSafe = $1;

				if (-f $filePathSafe) {
					#my $sha1sum = '';
					my $sha1sum = `sha1sum $filePathSafe | cut -d ' ' -f 1`;
					DBAddItemAttribute($fileHash, 'sha1sum', $sha1sum);

					if (GetConfig('setting/admin/index/extra_hashes')) {
						my $sha256sum = `sha256sum $filePathSafe | cut -d ' ' -f 1`;
						DBAddItemAttribute($fileHash, 'sha256sum', $sha256sum);
					}
				} else {
					#todo warning
				}
			} else {
				WriteLog('DBAddItem: warning: setting/admin/index/sha1sum is on, but command not found, skipping');
			}
		}
	}

	DBAddItemAttribute($fileHash, 'item_type', $itemType);
	DBAddItemAttribute($fileHash, 'file_path', $filePathRelative);

	if ($authorKey) {
		DBAddPageTouch('author', $authorKey);
	}

	if ($verifyError) {
		DBAddItemAttribute($fileHash, 'verify_error', '1');
	}
} # DBAddItem()

sub DBAddLocationRecord { # $itemHash, $latitude, $longitude, $signedBy ; Adds new location record from latlong token
	state $query;
	state @queryParams;

	WriteLog("DBAddLocationRecord()");

	my $fileHash = shift;

	if ($fileHash eq 'flush') {
		WriteLog("DBAddLocationRecord(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if (
		$query
			&&
		(
			length($query) >= DBMaxQueryLength()
				||
			scalar(@queryParams) > DBMaxQueryParams()
		)
	) {
		DBAddLocationRecord('flush');
		$query = '';
		@queryParams = ();
	}

	my $latitude = shift;
	my $longitude = shift;
	my $signedBy = shift;

	if (!$latitude || !$longitude) {
		WriteLog('DBAddLocationRecord() sanity check failed! Missing $latitude or $longitude');
		return;
	}

	chomp $latitude;
	chomp $longitude;

	if ($signedBy) {
		chomp $signedBy;
	} else {
		$signedBy = '';
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO location(item_hash, latitude, longitude, author_key) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?)';
	push @queryParams, $fileHash, $latitude, $longitude, $signedBy;
} # DBAddLocationRecord()

sub DBAddVoteRecord { # $fileHash, $ballotTime, $voteValue, $signedBy, $ballotHash ; Adds a new vote (tag) record to an item based on vote/ token
# sub DBAddVote {
# sub DBAddItemVote {
	state $query;
	state @queryParams;

	WriteLog("DBAddVoteRecord()");

	my $fileHash = shift;

	if ($fileHash eq 'flush') {
		WriteLog("DBAddVoteRecord(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if (!$fileHash) {
		WriteLog('DBAddVoteRecord: warning: called without $fileHash');
		return '';
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddVoteRecord('flush');
		DBAddPageTouch('flush');
		$query = '';
	}

	my $ballotTime = shift;
	my $voteValue = shift;
	my $signedBy = shift;
	my $ballotHash = shift;

	if (!$ballotTime) {
		WriteLog('DBAddVoteRecord: warning: missing $ballotTime; caller: ' . join(',', caller));
		$ballotTime = 0;
		#$ballotTime = time();
		#return '';
	}

#	if (!$signedBy) {
#		WriteLog("DBAddVoteRecord() called without \$signedBy! Returning.");
#	}

	chomp $fileHash;
	chomp $ballotTime;
	chomp $voteValue;

	if ($signedBy) {
		chomp $signedBy;
	} else {
		$signedBy = '';
	}

	if ($ballotHash) {
		chomp $ballotHash;
	} else {
		$ballotHash = '';
	}

	WriteLog('DBAddVoteRecord: ' . $fileHash . ', $ballotTime=' . $ballotTime . ', $voteValue=' . $voteValue . ', $signedBy = ' . $signedBy . ', $ballotHash = ' . $ballotHash . '; caller = ' . join(',', caller));

	if (!$query) {
		$query = "INSERT OR REPLACE INTO vote(file_hash, ballot_time, vote_value, author_key, ballot_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?, ?)';
	push @queryParams, $fileHash, $ballotTime, $voteValue, $signedBy, $ballotHash;

	DBAddPageTouch('tag', $voteValue);
	DBAddPageTouch('item', $fileHash);
} # DBAddVoteRecord()

sub DBGetItemAttributes { # $fileHash ; returns reference to hash of attributes
	my $fileHash = shift;

	if ($fileHash && $fileHash =~ m/^([a-f0-9]+)$/) {
		WriteLog('DBGetItemAttributes: sanity check passed on $fileHash = ' . $fileHash);
		$fileHash = $1;
	} else {
		WriteLog('DBGetItemAttributes: warning: sanity check FAILED on $fileHash = ' . $fileHash);
		return '';
	}

	state %memo;
	if ($memo{$fileHash}) {
		return $memo{$fileHash};
	}

	my $query = "SELECT attribute, value FROM item_attribute WHERE file_hash LIKE '$fileHash%'";
	my @results = SqliteQuery($query);

	my %itemAttributes;
	shift @results;
	while (@results) {
		my $rowReference = shift @results;
		my %row = %{$rowReference};
		$itemAttributes{$row{'attribute'}} = $row{'value'};
	}
	$memo{$fileHash} = \%itemAttributes;

	return $memo{$fileHash};
} # DBGetItemAttributes()

sub DBGetItemAttribute { # $fileHash, $attribute ; returns one attribute for item
# for getting multiple (all) attributes, use DBGetItemAttributes()
	my $fileHash = shift;
	my $attribute = shift;

	if ($fileHash && $fileHash =~ m/^([a-f0-9]+)$/) {
		WriteLog('DBGetItemAttribute: sanity check passed on $fileHash = ' . $fileHash);
		$fileHash = $1;
	} else {
		WriteLog('DBGetItemAttribute: warning: sanity check FAILED on $fileHash = ' . $fileHash);
		return '';
	}

	if ($attribute) {
		$attribute =~ s/[^a-zA-Z0-9_]//g;
		#todo add sanity check
	} else {
		WriteLog('DBGetItemAttribute: warning: $attribute is missing');
		return '';
	}

	my $attributesRef = DBGetItemAttributes($fileHash);
	my %attributes = %{$attributesRef};

	return $attributes{$attribute};
} # DBGetItemAttribute()

sub DBAddItemAttribute { # $fileHash, $attribute, $value, $epoch, $source # add attribute to item
# sub DBAddItemTitle {
# sub AddTitle {
# sub DBAddTitle {
# sub DBSetItemAttribute {
# sub SetItemAttribute {
# sub DBSetItemTitle {
# sub SetItemTitle {

# currently no constraints
	state $query;
	state @queryParams;

	WriteLog("DBAddItemAttribute()");

	my $fileHash = shift;#

	if (!$fileHash) {
		WriteLog('DBAddItemAttribute: warning: $fileHash is FALSE; caller = ' . join(',', caller));
		return '';
	}

	if ($fileHash eq 'flush') {
		WriteLog("DBAddItemAttribute(flush)");

		if ($query) {
			$query .= ';';

			WriteLog('DBAddItemAttribute: $query = ' . $query . ';');

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddItemAttribute('flush');
		$query = '';
	}

	my $attribute = shift;#
	my $value = shift;#
	my $epoch = shift;#
	my $source = shift;#

	if (!$attribute) {
		WriteLog('DBAddItemAttribute: warning: called without $attribute');
		return '';
	}

	if (!defined($value)) {
		WriteLog('DBAddItemAttribute: warning: called without $value, $attribute = ' . $attribute);
		return '';
	}

	chomp $fileHash;
	chomp $attribute;
	chomp $value;

	if ($attribute eq 'received') {
		#this is a hack to record "received" token as received_timestamp attribute
		#so that timestamp fields automatically appear formatted properly
		$attribute = 'received_timestamp';
	}

	if ($attribute eq 'chain_next' || $attribute eq 'chain_previous') {
		if (length($fileHash) > 40 || length($value) > 40) {
			#WriteLog('DBAddItemAttribute: warning: fixing chain_next or chain_previous');
			$fileHash = substr($fileHash, 0, 40);
			$value = substr($value, 0, 40);
			#todo unhack this
		}
	}

	if (!$epoch) {
		$epoch = '';
	}
	if (!$source) {
		$source = '';
	}

	chomp $epoch;
	chomp $source;

	if ($attribute eq 'title') {
		my $lengthBefore = length($value);
		$value =~ s/[\n\r]//g;
		if ($lengthBefore != length($value)) {
			WriteLog('DBAddItemAttribute: warning: value of title attribute was sanitized. caller = ' . join(',', caller));
		}
	}

	WriteLog("DBAddItemAttribute($fileHash, $attribute, $value, $epoch, $source)");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item_attribute(file_hash, attribute, value, epoch, source) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?, ?)';
	push @queryParams, $fileHash, $attribute, $value, $epoch, $source;
} # DBAddItemAttribute()

sub DBGetAddedTime { # return added time for item specified
	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('DBGetAddedTime: warning: $fileHash missing');
		return;
	}
	chomp ($fileHash);

	if (!IsItem($fileHash)) {
		WriteLog('DBGetAddedTime: warning: called with invalid parameter! returning');
		return;
	}

	if (!IsItem($fileHash) || $fileHash ne SqliteEscape($fileHash)) {
		WriteLog('DBGetAddedTime: warning: important sanity check failed! this should never happen: !IsItem($fileHash) || $fileHash ne SqliteEscape($fileHash)');
		return '';
	} #todo ideally this should verify it's a proper hash too

	WriteLog('DBGetAddedTime: $fileHash = ' . $fileHash);

	my $query = "
		SELECT
			MIN(value) AS add_timestamp
		FROM item_attribute
		WHERE
			file_hash = ? AND
			attribute IN ('chain_timestamp', 'gpg_timestamp', 'puzzle_timestamp', 'self_timestamp')
	";
	my @queryParams;
	push @queryParams, $fileHash;
	# my $query = "SELECT add_timestamp FROM added_time WHERE file_hash = '$fileHash'";

	my $returnValue = SqliteGetValue($query, @queryParams);

	if (!$returnValue) {
		WriteLog('DBGetAddedTime: warning: $returnValue was false! caller = ' . join(',', caller));
		$returnValue = '';
	}

	return $returnValue;
} # DBGetAddedTime()

sub DBGetItemListByTagList { #get list of items by taglist (as array)
# uses DBGetItemList()
	my @tagListArray = @_;

	foreach my $tag (@tagListArray) {
		if ($tag =~ m/^([0-9a-zA-Z-_]+)$/) {
			# ok
		} else {
			WriteLog('DBGetItemListByTagList: warning: tag failed sanity check, this could be due to non-Latin characters. $tag = ' . $tag);
		}
		if (index($tag, "'") != -1) {
			WriteLog('DBGetItemListByTagList: warning: tag contains single quote. returning empty string');
			return '';
		}
	}

	my $tagListCount = scalar(@tagListArray);
	my $tagListArrayText = "'" . join ("','", @tagListArray) . "'";

	WriteLog('DBGetItemListByTagList: @tagListArray contains: ' . join(',', @tagListArray));

	my %queryParams;
	my $whereClause = "
		WHERE file_hash IN (
			SELECT file_hash FROM (
				SELECT
					COUNT(id) AS vote_count,
						file_hash
				FROM vote
				WHERE vote_value IN ($tagListArrayText)
				GROUP BY file_hash
			) WHERE vote_count >= $tagListCount
		)
	";

	$queryParams{'where_clause'} = $whereClause;

	#todo this is currently an "OR" select, but it should be an "AND" select.

	return DBGetItemList(\%queryParams);
} # DBGetItemListByTagList()

sub DBGetItemListQuery {
	my $paramHashRef = shift;
	my %params = %{$paramHashRef};

	my $itemFields = DBGetItemFields();
	$itemFields = str_replace("\n", "\n\t\t\t", $itemFields);
	$itemFields = trim($itemFields);
	# indenting it for display on item listing page, kind of a hack

	my $query = '';

	$query = "
		SELECT
			$itemFields
		FROM
			item_flat
	";

	for my $paramName (keys %params) {
		if (index($params{$paramName}, ';') != -1) {
			WriteLog('DBGetItemListQuery: warning: parameter contains semicolon: $params{' . $paramName . '} = ' . $params{$paramName} . '; caller = ' . join(',', caller));
		}
	}

	if (defined ($params{'join_clause'})) {
		$query .= " " . $params{'join_clause'};
	}
	if (defined ($params{'where_clause'})) {
		$query .= " " . $params{'where_clause'};
	}
	if (defined ($params{'group_by_clause'})) {
		$query .= " " . $params{'group_by_clause'};
	}
	if (defined ($params{'order_clause'})) {
		$query .= " " . $params{'order_clause'};
	}
	if (defined ($params{'limit_clause'})) {
		$query .= " " . $params{'limit_clause'};
	}

	return $query;
} # DBGetItemListQuery()

sub DBGetItemList { # \%params;  get list of items from database. takes reference to hash of parameters
	my $paramHashRef = shift;
	my %params = %{$paramHashRef};

	#supported params:
	#where_clause
	#join_clause
	#order_clause
	#group_by_clause
	#limit_clause
	#include_headers

	my $query;
	$query = DBGetItemListQuery(\%params);

	WriteLog('DBGetItemList: $query = ' . $query);
	WriteLog('DBGetItemList: caller: ' . join(',', caller));

	my @resultsArray = SqliteQueryHashRef($query);
	WriteLog('DBGetItemList: scalar(@resultsArray) = ' . scalar(@resultsArray));

	if (!$params{'include_headers'}) {
		shift @resultsArray; #remove headers entry
	}

	return @resultsArray;
} # DBGetItemList()

sub SqliteGetColumnArray { # $query, $columnName ; gets column as array
# sub SqliteGetArray {
	my $query = shift;
	my $columnName = shift;

	my @result = SqliteQueryHashRef($query);

	if (!@result) {
		WriteLog('SqliteGetColumnArray: warning: @result is false; caller = ' . join(',', caller));
		return '';
	} else {
		my $columnsRef = shift @result;

		if (!$columnsRef) {
			WriteLog('SqliteGetColumnArray: warning: $columnsRef is false; caller = ' . join(',', caller));
			return '';
		} else {
			my @columns = @{$columnsRef};

			if (!scalar(@columns)) {
				WriteLog('SqliteGetColumnArray: sanity check failed, scalar(@columns) is false');
				return '';
			}

			if (!$columnName) {
				$columnName = $columns[0];
			}

			my @ary;

			for my $rowRef (@result) {
				my %row = %{$rowRef};
				push @ary, $row{$columnName}
			}

			WriteLog('SqliteGetColumnArray: scalar(@ary) = ' . scalar(@ary));
			return @ary;
		}
	}
} # SqliteGetColumnArray()

sub DBGetAllAppliedTags { # return all tags that have been used at least once
	my $query = "
		SELECT DISTINCT vote_value FROM vote
		JOIN item ON (vote.file_hash = item.file_hash)
	";
	#todo i'm not sure why this join is necessary, but i guess it should be a valid item?
	#todo it should join together different-case tags into the nicest looking version

	my @result = SqliteQuery($query);
	shift @result;

	my @ary;

	for my $rowRef (@result) {
		my %row = %{$rowRef};
		push @ary, $row{'vote_value'}
	}

	WriteLog('DBGetAllAppliedTags: scalar(@ary) = ' . scalar(@ary));

	return @ary;
} # DBGetAllAppliedTags()

sub DBGetItemListForAuthor { # return all items attributed to author
	my $author = shift;
	chomp($author);

	if (!IsFingerprint($author)) {
		WriteLog('DBGetItemListForAuthor called with invalid parameter! returning');
		return;
	}
	$author = SqliteEscape($author);

	my %params = {};

	$params{'where_clause'} = "WHERE author_key = '$author'";

	return DBGetItemList(\%params);
} # DBGetItemListForAuthor()

sub DBGetAuthorList { # returns list of all authors' gpg keys as array
	my $query = "SELECT key FROM author";
	my @resultsArray = SqliteGetColumnArray($query);
	WriteLog('DBGetAuthorList: scalar(@resultsArray) = ' . scalar(@resultsArray));
	return @resultsArray;
} # DBGetAuthorList()

sub DBGetAuthorAlias { # returns author's alias by gpg key
# sub GetAuthorUsername {
# sub DBGetAuthorUsername {
# sub GetAuthorAlias {
	my $key = shift;
	chomp $key;

	if (!IsFingerprint($key)) {
		WriteLog('DBGetAuthorAlias: warning: called with invalid parameter! returning');
		return;
	}

	$key = SqliteEscape($key);

	if ($key) {
		my $query = "SELECT alias FROM author_alias WHERE key = '$key'";
		return SqliteGetValue($query);
	} else {
		return "";
	}
} # DBGetAuthorAlias()

sub DBGetAuthorScore { # returns author's total score
# score is the sum of all the author's items' scores
# $key = author's gpg key
	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('Problem! DBGetAuthorScore called with invalid parameter! returning');
		return '';
	}

	WriteLog('DBGetAuthorScore(' . $key . '); caller = ' . join(',', caller));

	state %scoreCache;
	if (exists($scoreCache{$key})) {
		return $scoreCache{$key};
	}

	$key = SqliteEscape($key);

	if ($key) { #todo fix non-param sql
		my $query = "SELECT IFNULL(author_score, 0) author_score FROM author_score WHERE author_key = ?";
		my @queryParams = ($key);
		my $queryResult = SqliteGetValue($query, @queryParams);

		if (defined($queryResult) && int($queryResult) == $queryResult) {
			$scoreCache{$key} = $queryResult;
			WriteLog('DBGetAuthorScore(' . $key . ') = ' . $scoreCache{$key} . '; caller = ' . join(',', caller));
			return $scoreCache{$key};
		} else {
			WriteLog('DBGetAuthorScore: warning: $queryResult failed sanity check!');
			return 0;
		}
	} else {
		return 0;
	}
} # DBGetAuthorScore()

sub DBGetAuthorItemCount { # returns number of items attributed to author identified by $key
# $key = author's gpg key
	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('DBGetAuthorItemCount: warning: called with non-fingerprint parameter, returning');
		return 0;
	}
	if ($key ne SqliteEscape($key)) {
		# should be redundant, but what the heck
		WriteLog('DBGetAuthorItemCount: warning: $key != SqliteEscape($key)');
		return 0;
	}

	state %scoreCache;
	if (exists($scoreCache{$key})) {
		return $scoreCache{$key};
	}

	if ($key) {
		my $query = "SELECT COUNT(file_hash) file_hash_count FROM (SELECT DISTINCT file_hash FROM item_flat WHERE author_key = ?)";
		$scoreCache{$key} = SqliteGetValue($query, $key);
		return $scoreCache{$key};
	} else {
		return 0;
	}

	WriteLog('DBGetAuthorItemCount: warning: unreachable reached');
	return 0;
} # DBGetAuthorItemCount()

sub DBGetAuthorLastSeen { # return timestamp of last item attributed to author
# $key = author's gpg key
	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('Problem! DBGetAuthorLastSeen called with invalid parameter! returning');
		return;
	}

	state %lastSeenCache;
	if (exists($lastSeenCache{$key})) {
		return $lastSeenCache{$key};
	}

	$key = SqliteEscape($key);

	if ($key) { #todo fix non-param sql
		my $query = "SELECT MAX(item_flat.add_timestamp) AS last_seen FROM item_flat WHERE tags_list NOT LIKE '%,pubkey,%' AND author_key = '$key'";
		$lastSeenCache{$key} = SqliteGetValue($query);
		return $lastSeenCache{$key};
	} else {
		return "";
	}
} # DBGetAuthorLastSeen()

sub DBGetAuthorPublicKeyHash { # Returns the hash/identifier of the file containing the author's public key
# $key = author's gpg fingerprint
# cached in hash called %authorPubKeyCache

	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('Problem! DBGetAuthorPublicKeyHash called with invalid parameter! returning');
		return;
	}

	state %authorPubKeyCache;
	if (exists($authorPubKeyCache{$key}) && $authorPubKeyCache{$key}) {
		WriteLog('DBGetAuthorPublicKeyHash: returning from memo: ' . $authorPubKeyCache{$key});
		return $authorPubKeyCache{$key};
	}

	$key = SqliteEscape($key);

	if ($key) { #todo fix non-param sql
		my $query = "SELECT MAX(author_alias.file_hash) AS file_hash FROM author_alias WHERE key = '$key'";
		my $fileHashReturned = SqliteGetValue($query);
		if ($fileHashReturned) {
			$authorPubKeyCache{$key} = SqliteGetValue($query);
			WriteLog('DBGetAuthorPublicKeyHash: returning ' . $authorPubKeyCache{$key});
			return $authorPubKeyCache{$key};
		} else {
			WriteLog('DBGetAuthorPublicKeyHash: database drew a blank, returning 0');
			return 0;
		}
	} else {
		return "";
	}
} # DBGetAuthorPublicKeyHash()

sub DBGetServerKey {
	return DBGetAdminKey();
} # DBGetServerKey()

sub DBGetAdminCount { # ; returns number of admins in system
# admin is an author who has both #pubkey and #admin tags
	my $query = "
		SELECT
			COUNT(*) AS admin_count
		FROM
			author_flat
			LEFT JOIN item_flat ON (author_flat.file_hash = item_flat.file_hash)
		WHERE
			','||item_flat.tags_list||',' LIKE '%,admin,%' AND
			','||item_flat.tags_list||',' LIKE '%,pubkey,%'
	";

	my $adminCount = SqliteGetValue($query);

	return $adminCount;
} # DBGetAdminCount()

sub DBGetAdminKey { # Returns the pubkey id of the top-scoring admin (or nothing)
# cached in hash called %authorPubKeyCache

	WriteLog('DBGetAdminKey()');

	my $memoKey = 1; #hardcoded in case it needs to change

	state %memoHash;
	if (exists($memoHash{$memoKey}) && $memoHash{$memoKey}) {
		WriteLog('DBGetAdminKey: returning from memo: ' . $memoHash{$memoKey});
		return $memoHash{$memoKey};
	}

	my $key = 1;

	if ($key) { #todo fix non-param sql
		my $query = "SELECT MAX(author_flat.author_key) AS author_key FROM author_flat WHERE file_hash in (SELECT file_hash FROM item_flat WHERE ',' || tags_list || ',' LIKE '%,admin,%') LIMIT 1";
		my $valueReturned = SqliteQueryCachedShell($query);
		if ($valueReturned) {
			$memoHash{$memoKey} = SqliteQueryCachedShell($query);
			WriteLog('DBGetAdminKey: returning ' . $memoHash{$memoKey});
			return $memoHash{$memoKey};
		} else {
			WriteLog('DBGetAdminKey: database drew a blank, returning 0');
			return 0;
		}
	} else {
		WriteLog('DBGetAdminKey: warning: $key was false, returning empty string');
		return '';
	}

	WriteLog('DBGetAdminKey: warning: fall-through, returning empty string');
} # DBGetAdminKey()

sub DBGetItemFields { # Returns fields we typically need to request from item_flat table
# todo this shouldn't have a DB prefix
	my $itemFields = "
		item_flat.file_path file_path,
		item_flat.item_name item_name,
		item_flat.file_hash file_hash,
		item_flat.author_key author_key,
		item_flat.child_count child_count,
		item_flat.parent_count parent_count,
		item_flat.add_timestamp add_timestamp,
		item_flat.item_title item_title,
		item_flat.item_score item_score,
		item_flat.tags_list tags_list,
		item_flat.item_type item_type,
		item_flat.item_order item_order,
		item_flat.item_sequence item_sequence
	";

	#fix spaces
	$itemFields = trim($itemFields);
	$itemFields = str_replace("\t", '', $itemFields);
	#$itemFields =~ s/\s/ /g;
	#$itemFields =~ s/  / /g;

	return $itemFields;
} # DBGetItemFields()

sub DBGetTopAuthors { # Returns top-scoring authors from the database
	WriteLog('DBGetTopAuthors() begin');

	my $query = "
		SELECT
			author_key,
			author_alias,
			last_seen,
			item_count
		FROM author_flat
		ORDER BY item_count DESC
		LIMIT 1024;
	";

	my @queryParams = ();

	my $dbh = SqliteConnect();
	#todo rewrite better

	my $sth = $dbh->prepare($query);
	$sth->execute(@queryParams);

	my @resultsArray = ();

	while (my $row = $sth->fetchrow_hashref()) {
		push @resultsArray, $row;
	}

	return @resultsArray;
} # DBGetTopAuthors()

sub DBGetTopItems { # get top items minus flag (hard-coded for now)
	WriteLog('DBGetTopItems()');

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE item_score > 0";
	$queryParams{'order_clause'} = "ORDER BY add_timestamp DESC";
	$queryParams{'limit_clause'} = "LIMIT 100";
	my @resultsArray = DBGetItemList(\%queryParams);

	return @resultsArray;
} # DBGetTopItems()

sub DBGetItemsByPrefix { # $prefix ; get items whose hash begins with $prefix
	my $prefix = shift;
	if (!IsItemPrefix($prefix)) {
		WriteLog('DBGetItemsByPrefix: warning: $prefix sanity check failed');
		return '';
	}

	my $itemFields = DBGetItemFields();
	my $whereClause;
	$whereClause = "
		WHERE
			(file_hash LIKE '%$prefix')

	"; #todo remove hardcoding here

	my $query = "
		SELECT
			$itemFields
		FROM
			item_flat
		$whereClause
		ORDER BY
			add_timestamp DESC
		LIMIT 50;
	";

	WriteLog('DBGetItemsByPrefix: $query = ' . $query);
	my @queryParams;

	my $dbh = SqliteConnect();
	#todo rewrite better

	my $sth = $dbh->prepare($query);
	$sth->execute(@queryParams);

	my @resultsArray = ();
	while (my $row = $sth->fetchrow_hashref()) {
		push @resultsArray, $row;
	}

	WriteLog('DBGetItemsByPrefix: scalar(@resultsArray) = ' . @resultsArray);

	return @resultsArray;
} # DBGetItemsByPrefix()

sub DBGetItemVoteTotals2 { # get tag counts for specified item, returned as hash of [tag] -> count
	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('DBGetItemVoteTotals: warning: $fileHash missing, returning');
		return 0;
	}

	chomp $fileHash;

	if (!IsItem($fileHash)) {
		WriteLog('DBGetItemVoteTotals: warning: sanity check failed, returned');
		return 0;
	}

	WriteLog("DBGetItemVoteTotals2($fileHash)");

	my $query = "
		SELECT
			vote_value,
			COUNT(vote_value) AS vote_count
		FROM
			vote
		WHERE
			file_hash = ?
		GROUP BY
			vote_value
		ORDER BY
			vote_count DESC;
	";

	my @queryParams;
	push @queryParams, $fileHash;

	my @result = SqliteQueryHashRef($query, @queryParams);

	shift @result; # remove headers

	my %voteTotals;

	while (@result) {
		my $rowReference = shift @result;
		my %row = %{$rowReference};
		if ($row{'vote_value'}) {
			$voteTotals{$row{'vote_value'}} = $row{'vote_count'};
		}
	}

	return \%voteTotals;
} # DBGetItemVoteTotals2()

sub PrintBanner2 {
	my $string = shift; #todo sanity checks
	my $width = length($string);

	my $edge = "=" x $width;

	print "\n" ;
	print "\n";
	print $edge;
	print "\n"  ;
	print "\n"   ;
	print $string;
	print "\n"    ;
	print "\n"     ;
	print $edge;
	print "\n"      ;
	print "\n"       ;
} # PrintBanner2()

while (my $arg1 = shift @foundArgs) {
	#print("\n=========================\n");
	PrintBanner2("\nFOUND ARGUMENT: $arg1;\n");
	#print("\n=========================\n");

	# go through all the arguments one at a time
	if ($arg1) {
		if ($arg1 eq '--test') {

		}
	}
}

1;
