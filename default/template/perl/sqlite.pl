#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl

use strict;
use warnings;
use 5.010;
use utf8;

use Data::Dumper;
use Carp;

my @foundArgs;
while (my $argFound = shift) {
	push @foundArgs, $argFound;
}

sub SetSqliteDbName { # $requestedName ; sets path to sqlite db
	my $requestedName = shift;
	if (!$requestedName) {
		WriteLog('SetSqliteDbName: warning: called without $requestedName; caller = ' . join(',', caller));
		return '';
	}
	if ($requestedName =~ m/^([a-zA-Z0-9_\-\/.]+)$/) {
		$requestedName = $1;
	} else {
		WriteLog('SetSqliteDbName: warning: $requestedName failed sanity check; caller = ' . join(',', caller));
		return '';
	}
	return GetSqliteDbName($requestedName);
} # SetSqliteDbName()

sub GetSqliteDbName { # $requestedName ; returns path to sqlite db
	# has a default value, but can be overridden with $requestedName
	# sub GetIndexPath {
	# sub GetDatabase {
	# sub GetDatabasePath {
	# sub GetDatabaseFilename {
	# sub GetDbFilename {
	# sub GetDbPath {
	# sub GetDbName {
	# sub SqliteGetDbName {

	my $requestedName = shift;

	state $cacheDir = GetDir('cache');
	state $cacheVersion = GetMyCacheVersion();

	state $fileName = '';
	if ($requestedName) {
		if ($requestedName =~ m/^([a-zA-Z0-9_\-\/.]+)$/) {
			$requestedName = $1;
		} else {
			WriteLog('SetSqliteDbName: warning: $requestedName failed sanity check; caller = ' . join(',', caller));
			return '';
		}
		$fileName = $requestedName;
	}
	if (!$fileName) {
		$fileName = 'index.sqlite3';
	}

	state $SqliteDbName = '';
	if (!$SqliteDbName) {
		$SqliteDbName = "$cacheDir/$cacheVersion/$fileName"; # path to sqlite db
	}

	return $SqliteDbName;
} # GetSqliteDbName()

sub SqliteQuery2 {
	my $query = shift;
	my @params = @_;
	return SqliteQuery($query, @params);
} # SqliteQuery2()

sub SqliteMakeTables { # creates sqlite schema
	# sub SqliteCreateTables {
	# sub SqliteMakeTables {
	# sub SqliteMakeSchema {
	# sub DBMakeTables {

	WriteLog('SqliteMakeTables: begin');

	my $existingTables = SqliteQueryCachedShell('.tables');
	if ($existingTables) {
		WriteLog('SqliteMakeTables: warning: tables already exist');

		#todo verify it is the same schema

		return '';
	}

	my $schemaQueries = '';
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/sane_defaults.sql');
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/schema.sql');
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/label_weight.sql');

	$schemaQueries =~ s/^#.+$//mg; # remove sh-style comments (lines which begin with #)

	#confess $schemaQueries;

	SqliteQuery($schemaQueries);

	DBIndexTagsets(); #todo

	my $SqliteDbName = GetSqliteDbName();

	#todo cache the result so that this can be skipped if building often
} # SqliteMakeTables()

sub SqliteGetNormalizedQueryString { # $query, @queryParams ; returns normalized query string
	# sub SqliteNormalizeQuery {
	# sub NormalizeQuery {
	# sub NormalizedQuery {
	# sub SqliteGetQueryText {
	# sub GetQueryText {
	# sub SqliteGetFormattedQuery {
	my $query = shift;
	chomp $query;

	my @queryParams = @_;

	if ($query =~ m/^(.+)$/s) { #todo real sanity check
		$query = $1;
	} else {
		WriteLog('SqliteGetNormalizedQueryString (default): warning: sanity check failed on $query; caller = ' . join(',', caller));
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

sub SqliteGetRow { # $query, @queryParams ; returns first row of query result as array
	#todo sanity
	my @array = SqliteQueryHashRef(@_);
	WriteLog('SqliteGetRow: scalar(@array) = ' . scalar(@array) . '; caller = ' . join(', ', caller));

	shift @array; # the headers list
	my $firstRowRef = shift @array;
	my %firstRow;

	if ($firstRowRef && ref($firstRowRef) eq 'HASH') {
		%firstRow = %{$firstRowRef};
	}

	return \%firstRow;
} # SqliteGetRow()

sub SqliteQueryHashRef { # $query, @queryParams; calls sqlite with query, and returns result as array of hashrefs
	# NOTE, THIS RETURNS A REFERENCE TO AN ARRAY OF HASHES, NOT A HASH, DESPITE THE NAME

	# ATTENTION: first array element returned is an array of column names!

	# example uses:
	# 	my $hashRef1 = SqliteQueryHashRef('author_replies', @queryParams);
	# 	my @authorReplies = @{$hashRef};
	# 	my $hashRef2 = SqliteQueryHashRef('SELECT file_hash, item_title FROM item_flat', @queryParams);
	# 	my @allItems = @{$hashRef};

	#sub SqliteGetHash {
	#sub SqliteGetResults {
	#sub SqliteGetHashRef {
	#sub SqliteGetQueryHashRef {
	#sub SqliteGetQuery {
	#sub GetQuery {
	#sub GetQueryAsHash {
	#sub DBGetQueryResult {
	#sub GetQueryAsArray {
	#sub GetQueryAsArrayOfHashRefs {

	#WriteLog('SqliteQueryGetArrayOfHashRef: begin');
	WriteLog('SqliteQueryHashRef: begin; caller = ' . join(',', caller));

	my $query = shift;
	chomp $query;

	$query = SqliteGetQueryTemplate($query);

	my @queryParams = @_;
	my $queryWithParams = SqliteGetNormalizedQueryString($query, @queryParams);

	if ($queryWithParams) {
		#my $resultString = SqliteQueryCachedShell($queryWithParams);
		my $resultString = SqliteQuery($queryWithParams);
		#my $queryBegin = GetTime();
		#my $resultString = SqliteQuery($queryWithParams);
		#my $resultRef = SqliteQueryWithTime($queryWithParams);
		#my %resultHash = %{$resultRef};
		#my $resultString = %resultHash{'results'};
		#my $queryBegin = $resultRef->{'time_begin'};
		#my $queryFinish = $resultRef->{'time_finish'};
		#my $queryDuration = $resultRef->{'duration'};
		#my $queryFinish = GetTime();

		WriteLog('SqliteQueryHashRef: $resultString is ' . ($resultString ? 'TRUE' : 'FALSE') . '; $queryWithParams = ' . $queryWithParams);
		#WriteLog('SqliteQueryHashRef: $resultString = ' . ($resultString ? $resultString : 'FALSE'));


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

	my $queryId = substr(md5_hex(GetTime() . $query), 0, 5);

	if (GetConfig('debug')) {
		my $LOGDIR = GetDir('log');
		PutFile("$LOGDIR/sqlitequery.$queryId", $query);
	}

	#WriteLog('SqliteQuery: $query = ' . $query);
	WriteLog('SqliteQuery: ' . $queryId . ' caller = ' . join(',', caller));
	$query = SqliteGetNormalizedQueryString($query, @queryParams);

	my $SqliteDbName = GetSqliteDbName();

	if ($SqliteDbName =~ m/^([_a-zA-Z0-9\/.]+)$/) {
		$SqliteDbName = $1;
		WriteLog('SqliteQuery: ' . $queryId . ' $SqliteDbName passed sanity check: ' . $SqliteDbName);
	} else {
		WriteLog('SqliteQuery: ' . $queryId . ' $SqliteDbName FAILED sanity check: ' . $SqliteDbName);
		return '';
	}

	if ($query =~ m/^(.+)$/s) {
	# if ($query =~ m/^([[:print:]\n\r\s]+)$/s) {
		# this is only a basic sanity check, but it's better than nothing
		$query = $1;
		WriteLog('SqliteQuery: ' . $queryId . ' $query passed sanity check');
	} else {
		my $outLogName = sha1_hex(time().$query).'.query';
		state $outLogDir = GetDir('log');
		PutFile("$outLogDir/$outLogName", $query);

		WriteLog('SqliteQuery: ' . $queryId . ' warning! non-printable characters found: ' . $outLogName);
		return '';
	}

	if ($query =~ m/\?/) {
		WriteLog('SqliteQuery: ' . $queryId . ' warning: $query contains QM; caller = ' . join(',', caller));
		# this may indicate that a variable placeholder was not filled
	}

	my $logName = substr(GetRandomHash(), 0, 16) . '.sqlerr';
	state $logDir = GetDir('log');
	my $sqliteErrorLog = $logDir . '/' . $logName;

	#$query = str_replace('$', '', $query);
	$query = str_replace('$', '\\$', $query);
	$query = str_replace('`', '\`', $query);
	#

	my $shCommand = "sqlite3 -header \"$SqliteDbName\" \"$query\" 2>$sqliteErrorLog"; # $sqliteCommand #sqlite3Command
	#todo send to /dev/null if debug mode is not enabled?

	WriteLog('SqliteQuery: ' . $queryId . ' $shCommand = ' . $shCommand);
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
		WriteLog('SqliteQuery: ' . $queryId . ' $query passed sanity check');
		$shCommand = $1;
	} else {
		my $outLogName = GetSHA1(time().$shCommand).'.shcommand';
		state $outLogDir = GetDir('log');
		PutFile("$outLogDir/$outLogName", $shCommand);
		WriteLog('SqliteQuery: ' . $queryId . ' warning: $shCommand failed sanity check for printable characters only: ' . $outLogName);
		return '';
	}

	###########################################################################
	###########################################################################
	### RUN QUERY VIA SHELL ###################################################
	### RUN QUERY VIA SHELL ###################################################

	my $results = '';
	#use open ':std', ':encoding(UTF-8)';
	if ($shCommand =~ m/^(.+)$/s) {
		$shCommand = $1;

		my $timeBefore = GetTime();

		###########################################################################
		###########################################################################
		### RUN QUERY VIA SHELL ###################################################
		### RUN QUERY VIA SHELL ###################################################
		$results = `$shCommand`;

		my $timeAfter = GetTime();

		WriteLog('SqliteQuery: ' . $queryId . ' $results = ' . $results);

		WriteLog('SqliteQuery: ' . $queryId . ' $time = ' . ($timeAfter - $timeBefore));

		if (index($results, '90f7c1d87f56afbf1fc18ce49b9031f035e92a95') != -1) {
			print($results);
			#die($results);
		}
	}
	#utf8::encode($results);

	#print($results);

	#todo utf8 decoding is broken here, results are returned as bytes instead of chars (?)
	### RUN QUERY VIA SHELL ###################################################
	### RUN QUERY VIA SHELL ###################################################
	###########################################################################
	###########################################################################

	if (index(trim(lc(GetFile($sqliteErrorLog))), 'locked') != -1) {
		#sometimes the database is locked for a moment, so we retry 3 times before giving up
		#hack
		WriteLog('SqliteQuery: ' . $queryId . ' warning: locked database detected. retrying');
		my $retryCount = 0;
		while ($retryCount < 3 && trim(GetFile($sqliteErrorLog))) {
			WriteLog('SqliteQuery: ' . $queryId . ' locked retrying in 0.25s. Error is: ' . trim(GetFile($sqliteErrorLog)));
			select(undef, undef, undef, 0.25);
			$retryCount++;
			$results = `$shCommand`;
		}
		WriteLog('SqliteQuery: ' . $queryId . ' locked: retry loop exited, Error is: ' . trim(GetFile($sqliteErrorLog)));
		if (trim(GetFile($sqliteErrorLog))) {
			WriteLog('SqliteQuery: ' . $queryId . ' unable to recover from locked state; $retryCount = ' . $retryCount);
			unlink($sqliteErrorLog);
		} else {
			WriteLog('SqliteQuery: ' . $queryId . ' recovered from locked state; $retryCount = ' . $retryCount);
		}
	}

	if ($?) {
		# this is a special perl thing which contains STDERR from most recent backtick command
		WriteLog('SqliteQuery: ' . $queryId . ' warning: error returned; log = ' . $sqliteErrorLog . '; caller = ' . join(',', caller));
		AppendFile($sqliteErrorLog, $query);
		AppendFile($sqliteErrorLog, 'caller: ' . join(',', caller));

		my @caller1 = caller(1);
		my $caller1string = (@caller1 ? ($caller1[0] . ',' . $caller1[1] . ',' . $caller1[2]) : 'undef');
		AppendFile($sqliteErrorLog, 'caller: ' . $caller1string);

		my @caller2 = caller(2);
		my $caller2string = (@caller2 ? ($caller2[0] . ',' . $caller2[1] . ',' . $caller2[2]) : 'undef');
		AppendFile($sqliteErrorLog, 'caller: ' . $caller2string);

		return '';
	}

	if (GetFile($sqliteErrorLog)) {
		WriteLog('SqliteQuery: ' . $queryId . ' warning: sqlite3 call wrote to stderr: ' . $sqliteErrorLog . '; caller = ' . join(',', caller));

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

sub SqliteQueryWithTime {
	my $timeBegin = GetTime();
	my $results = SqliteQuery(@_);
	my $timeFinish = GetTime();

	my %fullReturn;
	$fullReturn{'results'} = $results;
	$fullReturn{'duration'} = $timeFinish - $timeBegin;

	#for debugging only?
	state $debugMode = GetConfig('debug');
	if ($debugMode && 0) {
		$fullReturn{'query'} = 'SELECT HI';
		$fullReturn{'time_begin'} = $timeBegin;
		$fullReturn{'time_finish'} = $timeFinish;
	}

	#return \%fullReturn;
	return $results;
} # SqliteQueryWithTime()

sub SqliteGetQueryTemplate { # $query ; look up query in templates if necessary or just return $query
	# looks up query in template/query/$query or template/query/$query.sql
	# exceptions:
	#   if $query contains one or more spaces
	#   if $query begins with period character (.) the way sqlite utility queries do
	#   if $query does not match /^([a-zA-Z0-9\-_.]+)$/

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

	if (
		(index($query, ' ') == -1) &&  # if it has a space, it's probably already an sql query if it has a space
		(substr($query, 0, 1) ne '.')  # if it begins with a period, it's probably a query like '.tables'
	) {
		if ($query =~ m/^([a-zA-Z0-9\-_.\/]+)$/) { # sanity check
			my $querySane = $1;
			WriteLog('SqliteGetQueryTemplate: looking up query/' . $querySane);

			if (GetTemplate('query/' . $querySane . '.sql')) {
				my $queryTemplate = GetTemplate('query/' . $querySane . '.sql');
				WriteLog('SqliteGetQueryTemplate: found with added sql: $querySane = ' . $querySane . '; $queryTemplate = ' . length($queryTemplate));
				return $queryTemplate;
			} elsif (GetTemplate('query/' . $querySane)) {
				my $queryTemplate = GetTemplate('query/' . $querySane);
				WriteLog('SqliteGetQueryTemplate: found without added sql: $querySane = ' . $querySane . '; $queryTemplate = ' . length($queryTemplate));
				return $queryTemplate;
			} else {
				WriteLog('SqliteGetQueryTemplate: warning: query has no spaces, and no template found; $query = ' . $query . '; caller = ' . join(',', caller));
				return $querySane;
			}
		} else {
			WriteLog('SqliteGetQueryTemplate: warning: query has no spaces, failed sanity check; $query = ' . $query . '; caller = ' . join(',', caller));
			return '';
		}
	} else {
		WriteLog('SqliteGetQueryTemplate: query has space character(s), returning without change; caller = ' . join(',', caller));
		return $query;
	}
} # SqliteGetQueryTemplate()

sub SqliteQueryCachedShell { # $query, @queryParams ; performs sqlite query via sqlite3 command
	# uses cache with query text's hash as key
	# sub CacheSqliteQuery {
	# sub SqliteGetQuery {
	# sub SqliteGetPSV {
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

	#todo this should not be used (or should be rewritten) if cache-sqlite is enabled?
	$results = GetCache("sqlite3_results/$cachePath");

	if ($results) {
		#cool
		WriteLog('SqliteQueryCachedShell: $results was populated from cache');
	} else {
		my $results = SqliteQuery($query);
		if ($results) {
			WriteLog('SqliteQueryCachedShell: PutCache: length($results) ' . length($results));
			PutCache('sqlite_cached/'.$cachePath, $results);
		} else {
			WriteLog('SqliteQueryCachedShell: warning: $results was FALSE; $query = ' . $query);
			WriteLog('SqliteQueryCachedShell: warning: $results was FALSE; caller = ' . join(',', caller));
		}
	}

	if ($results) {
		return $results;
	}
} # SqliteQueryCachedShell()

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

sub SqliteGetCount { # query ; returns COUNT(*) of provided query
	# sub GetCount {
	# sub GetQueryCount {

	my $query = shift;
	#todo sanity;
	#todo params

	if ($query =~ m/(LIMIT [0-9]+)$/i) {
		# detect query which has a limit, this is usually not something we want to do when using SqliteGetCount()
		WriteLog('SqliteGetCount: warning: $query seems to have LIMIT clause; caller = ' . join(',', caller));
	}

	my $queryText = SqliteGetNormalizedQueryString($query);
	WriteLog('SqliteGetCount: $queryText = ' . $queryText . '; caller = ' . join(',', caller));

	my $queryItemCount = "SELECT COUNT(*) AS item_count FROM ($queryText) LIMIT 1";
	my $rowCount = SqliteGetValue($queryItemCount);

	return $rowCount;
} # SqliteGetCount()

sub SqliteGetValue { # $query ; Returns the first column from the first row returned by sqlite $query
	# #todo should allow returning columns other than 0
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

sub SqliteGetColumnArray { # $query, $columnName ; gets column as array
	# sub GetColumn {
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

require_once('database.pl');

while (my $arg1 = shift @foundArgs) {
	#print("\n=========================\n");
	PrintBanner2("\nFOUND ARGUMENT: $arg1;\n");
	#print("\n=========================\n");

	# go through all the arguments one at a time
	if ($arg1) {
		if ($arg1 eq '--test') {

		}
	}
} # while (my $arg1 = shift @foundArgs)

1;
