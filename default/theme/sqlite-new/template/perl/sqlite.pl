#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl

# sqlite-new / ... / sqlite.pl

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
	# sub CreateSchema {

	WriteLog('SqliteMakeTables: begin');

	# Check for existing tables using DBI
	my $existingTablesQuery = "SELECT name FROM sqlite_master WHERE type='table'";
	my $existingTables = SqliteQuery($existingTablesQuery);
	if ($existingTables && $existingTables ne "name\n") {
		WriteLog('SqliteMakeTables: warning: tables already exist');
		#todo verify it is the same schema
		return '';
	}

	my $schemaQueries = '';
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/sane_defaults.sql');
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/schema.sql');
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/label_weight.sql');

	# Remove comments from schema
	$schemaQueries =~ s/^#.+$//mg; # Remove shell-style comments (lines starting with #)
	$schemaQueries =~ s/--[^\n]*//g; # Remove SQL single-line comments
	$schemaQueries =~ s!/\*.*?\*/!!gs; # Remove SQL multi-line comments
	
	# Split into individual queries and execute each one
	my @queries = split(/;\s*\n/, $schemaQueries);
	for my $query (@queries) {
		$query =~ s/^\s+|\s+$//g; # Trim whitespace
		if ($query) {
			SqliteQuery($query);
		}
	}

	DBIndexTagsets(); #todo

	# Verify tables were created successfully
	my $verifyResult = SqliteVerifyTables();
	if (!$verifyResult) {
		WriteLog('SqliteMakeTables: warning: table verification failed');
		return '';
	}

	WriteLog('SqliteMakeTables: tables verified successfully');
	#todo cache the result so that this can be skipped if building often
} # SqliteMakeTables()

sub SqliteVerifyTables { # returns 1 if tables exist, 0 if not
	WriteLog('SqliteVerifyTables: begin');

	my $tablesQuery = "SELECT name FROM sqlite_master WHERE type='table'";
	my $tables = SqliteQuery($tablesQuery);

	my $return = 1;
	
	if (!$tables || $tables eq "name\n") {
		WriteLog('SqliteVerifyTables: no tables found');
		return 0;
	}

	# Check for required tables based on schema.sql
	my @requiredTables = qw(
		item 
		item_attribute
		item_parent 
		author_alias
		item_label
		item_page
		location
		user_agent
		task
		config
		label_weight
		label_parent
	);

	# if debug mode, add table_test_fail
	if (GetConfig('debug')) {
		push @requiredTables, 'table_test_fail';
	}

	foreach my $table (@requiredTables) {
		if (index($tables, $table) == -1) {
			WriteLog('SqliteVerifyTables: warning: missing required table: ' . $table);
			$return = 0;
		}
	}

	# Check for required views
	my $viewsQuery = "SELECT name FROM sqlite_master WHERE type='view'";
	my $views = SqliteQuery($viewsQuery);

	my @requiredViews = qw(
		child_count
		parent_count 
		item_labels_list
		item_label_count
		item_score
		item_attribute_latest
		added_time
		item_title
		item_name
		item_order
		item_sequence
		item_author
		item_client
		item_flat
		item_flat_filtered
		author_score
		item_score_weighed
		author
		author_flat
		person_flat
		person_author
		item_score_relative
		author_alias_valid
	);

	# if debug mode, add view_test_fail
	if (GetConfig('debug')) {
		push @requiredViews, 'view_test_fail';
	}

	foreach my $view (@requiredViews) {
		if (index($views, $view) == -1) {
			WriteLog('SqliteVerifyTables: warning: missing required view: ' . $view);
			$return = 0;
		}
	}

	# Check for required indexes
	#todo

	WriteLog('SqliteVerifyTables: all required tables and views found');

	return $return;
} # SqliteVerifyTables()

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

sub SqliteQueryHashRef { # $query, @queryParams; calls sqlite with query using DBI, returns result as array of hashrefs
	WriteLog('SqliteQueryHashRef: begin; caller = ' . join(',', caller));

	my $query = shift;
	chomp $query;

	$query = SqliteGetQueryTemplate($query);
	my @queryParams = @_;

	my @resultsArray;
	my $dbh = DBI->connect("dbi:SQLite:dbname=" . GetSqliteDbName(), "", "", {
		RaiseError => 0,
		PrintError => 0,
		AutoCommit => 1
	});

	if ($dbh) {
		my $sth = $dbh->prepare($query);
		if ($sth) {
			if ($sth->execute(@queryParams)) {
				my @columns = @{$sth->{NAME}};
				push @resultsArray, \@columns;

				# Validate column names
				my %colTestTrack;
				for my $colText (@columns) {
					if (index($colText, '.') != -1) {
						WriteLog('SqliteQueryHashRef: warning: field name contains period character. $colText = ' . $colText);
					}
					if ($colTestTrack{$colText}) {
						WriteLog('SqliteQueryHashRef: warning: duplicate column name. $colText = ' . $colText);
					}
					$colTestTrack{$colText} = 1;
				}

				while (my $row = $sth->fetchrow_hashref) {
					push @resultsArray, $row;
				}
			}
			$sth->finish();
		}
		$dbh->disconnect();
	}

	return @resultsArray;
} # SqliteQueryHashRef()

sub SqliteQuery { # $query, @queryParams ; performs sqlite query via DBI
	# Uses DBI interface to execute a SQLite query
	# Returns query results as a pipe-delimited string with column headers
	# Parameters:
	#   $query - SQL query string to execute
	#   @queryParams - Array of parameters to bind to query placeholders
	my $query = shift;
	if (!$query) {
		WriteLog('SqliteQuery: warning: called without $query');
		return;
	}
	chomp $query;
	my @queryParams = @_;

	# Generate a unique ID for this query for logging
	my $queryId = substr(md5_hex(GetTime() . $query), 0, 5);
	LogSqliteQuery($queryId, $query, join(',', caller));

	# Normalize and sanitize the query and database name
	$query = SqliteGetNormalizedQueryString($query, @queryParams);
	my $SqliteDbName = GetSanitizedDbName($queryId);
	if (!$SqliteDbName) { return ''; }

	$query = SanitizeQueryString($queryId, $query);
	if (!$query) { return ''; }

	# Connect to the SQLite database
	my $dbh = DBI->connect("dbi:SQLite:dbname=$SqliteDbName", "", "", {
		RaiseError => 0,  # Don't die on error
		PrintError => 0,  # Don't print errors to STDERR
		AutoCommit => 1   # Commit each statement immediately
	});

	if (!$dbh) {
		WriteLog('SqliteQuery: ' . $queryId . ' Failed to connect to database');
		return '';
	}

	# Prepare the SQL statement
	my $sth = $dbh->prepare($query);
	if (!$sth) {
		WriteLog('SqliteQuery: ' . $queryId . ' Failed to prepare query: ' . $dbh->errstr);
		$dbh->disconnect();
		return '';
	}

	# Execute the query with any parameters
	my $success = $sth->execute(@queryParams);
	if (!$success) {
		WriteLog('SqliteQuery: ' . $queryId . ' Failed to execute query: ' . $sth->errstr);
		$sth->finish();
		$dbh->disconnect();
		return '';
	}

	# Build the results string starting with column headers
	my $results = '';
	my @columns = @{$sth->{NAME}};
	$results .= join('|', @columns) . "\n";

	# Fetch and format each row of results
	while (my @row = $sth->fetchrow_array()) {
		# Replace any undefined/NULL values with empty string
		for my $value (@row) {
			if (!defined($value)) {
				$value = '';
			}
		}
		# Join row values with pipe separator and add newline
		$results .= join('|', @row) . "\n";
	}

	# Clean up database resources
	$sth->finish();
	$dbh->disconnect();

	return $results;
} # SqliteQuery()

sub LogSqliteQuery { # $queryId, $query, $caller
	my ($queryId, $query, $caller) = @_;
	if (GetConfig('debug')) {
		my $LOGDIR = GetDir('log');
		PutFile("$LOGDIR/sqlitequery.$queryId", $query);
	}
	WriteLog('SqliteQuery: ' . $queryId . ' caller = ' . $caller);
} # LogSqliteQuery()

sub GetSanitizedDbName { # $queryId
	my $queryId = shift;
	my $SqliteDbName = GetSqliteDbName();
	
	if ($SqliteDbName =~ m/^([_a-zA-Z0-9\/.]+)$/) {
		$SqliteDbName = $1;
		WriteLog('SqliteQuery: ' . $queryId . ' $SqliteDbName passed sanity check: ' . $SqliteDbName);
		return $SqliteDbName;
	}
	WriteLog('SqliteQuery: ' . $queryId . ' $SqliteDbName FAILED sanity check: ' . $SqliteDbName);
	return '';
} # GetSanitizedDbName()

sub SanitizeQueryString { # $queryId, $query
	my ($queryId, $query) = @_;
	
	if ($query =~ m/^(.+)$/s) {
		$query = $1;
		WriteLog('SqliteQuery: ' . $queryId . ' $query passed sanity check');
		
		if ($query =~ m/\?/) {
			WriteLog('SqliteQuery: ' . $queryId . ' warning: $query contains QM; caller = ' . join(',', caller));
		}
		return $query;
	}
	
	my $outLogName = sha1_hex(time().$query).'.query';
	state $outLogDir = GetDir('log');
	PutFile("$outLogDir/$outLogName", $query);
	WriteLog('SqliteQuery: ' . $queryId . ' warning! non-printable characters found: ' . $outLogName);
	return '';
} # SanitizeQueryString()

sub BuildSqliteCommand { # $dbName, $query
	my ($dbName, $query) = @_;
	$query = str_replace('$', '\\$', $query);
	$query = str_replace('`', '\`', $query);
	return "sqlite3 -header \"$dbName\" \"$query\"";
} # BuildSqliteCommand()

sub GetSqliteErrorLogPath {
	my $logName = substr(GetRandomHash(), 0, 16) . '.sqlerr';
	state $logDir = GetDir('log');
	return $logDir . '/' . $logName;
} # GetSqliteErrorLogPath()

sub SanitizeShellCommand { # $queryId, $shCommand
	my ($queryId, $shCommand) = @_;
	
	if ($shCommand =~ m/^(.+)$/s) {
		WriteLog('SqliteQuery: ' . $queryId . ' $query passed sanity check');
		return $1;
	}
	
	my $outLogName = GetSHA1(time().$shCommand).'.shcommand';
	state $outLogDir = GetDir('log');
	PutFile("$outLogDir/$outLogName", $shCommand);
	WriteLog('SqliteQuery: ' . $queryId . ' warning: $shCommand failed sanity check for printable characters only: ' . $outLogName);
	return '';
} # SanitizeShellCommand()

sub ExecuteSqliteQuery { # $queryId, $shCommand, $errorLog
	my ($queryId, $shCommand, $errorLog) = @_;
	my $results = '';
	
	if ($shCommand =~ m/^(.+)$/s) {
		$shCommand = $1;
		my $timeBefore = GetTime();
		$results = `$shCommand 2>$errorLog`;
		my $timeAfter = GetTime();
		
		WriteLog('SqliteQuery: ' . $queryId . ' $results = ' . $results);
		WriteLog('SqliteQuery: ' . $queryId . ' $time = ' . ($timeAfter - $timeBefore));
		
		if (index($results, '90f7c1d87f56afbf1fc18ce49b9031f035e92a95') != -1) {
			print($results);
		}
	}
	return $results;
} # ExecuteSqliteQuery()

sub HandleLockedDatabase { # $queryId, $shCommand, $errorLog
	my ($queryId, $shCommand, $errorLog) = @_;
	if (index(trim(lc(GetFile($errorLog))), 'locked') != -1) {
		WriteLog('SqliteQuery: ' . $queryId . ' warning: locked database detected. retrying');
		my $retryCount = 0;
		my $results = '';
		while ($retryCount < 3 && trim(GetFile($errorLog))) {
			WriteLog('SqliteQuery: ' . $queryId . ' locked retrying in 0.25s. Error is: ' . trim(GetFile($errorLog)));
			select(undef, undef, undef, 0.25);
			$retryCount++;
			$results = `$shCommand`;
		}
		WriteLog('SqliteQuery: ' . $queryId . ' locked: retry loop exited, Error is: ' . trim(GetFile($errorLog)));
		if (trim(GetFile($errorLog))) {
			WriteLog('SqliteQuery: ' . $queryId . ' unable to recover from locked state; $retryCount = ' . $retryCount);
			unlink($errorLog);
		} else {
			WriteLog('SqliteQuery: ' . $queryId . ' recovered from locked state; $retryCount = ' . $retryCount);
		}
		return $results;
	}
	return '';
} # HandleLockedDatabase()

sub HandleSqliteErrors { # $queryId, $errorLog, $query
	my ($queryId, $errorLog, $query) = @_;
	
	if ($?) {
		WriteLog('SqliteQuery: ' . $queryId . ' warning: error returned; log = ' . $errorLog . '; caller = ' . join(',', caller));
		AppendFile($errorLog, $query);
		AppendFile($errorLog, 'caller: ' . join(',', caller));
		
		my @caller1 = caller(1);
		my $caller1string = (@caller1 ? ($caller1[0] . ',' . $caller1[1] . ',' . $caller1[2]) : 'undef');
		AppendFile($errorLog, 'caller: ' . $caller1string);
		
		my @caller2 = caller(2);
		my $caller2string = (@caller2 ? ($caller2[0] . ',' . $caller2[1] . ',' . $caller2[2]) : 'undef');
		AppendFile($errorLog, 'caller: ' . $caller2string);
		return;
	}
	
	if (GetFile($errorLog)) {
		WriteLog('SqliteQuery: ' . $queryId . ' warning: sqlite3 call wrote to stderr: ' . $errorLog . '; caller = ' . join(',', caller));
		AppendFile($errorLog, $query . "\n");
		AppendFile($errorLog, join(',', caller));
		AppendFile($errorLog, GetTime());
	} elsif (-e $errorLog) {
		unlink($errorLog);
	}
} # HandleSqliteErrors()

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
		WriteLog('SqliteGetQueryTemplate: warning: called without $query; caller = ' . join(',', caller));
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
				WriteLog('SqliteGetQueryTemplate: found with added .sql extension: $querySane = ' . $querySane . '; $queryTemplate = ' . length($queryTemplate));
				return $queryTemplate;
			} elsif (GetTemplate('query/' . $querySane)) {
				my $queryTemplate = GetTemplate('query/' . $querySane);
				WriteLog('SqliteGetQueryTemplate: found without added .sql extension: $querySane = ' . $querySane . '; $queryTemplate = ' . length($queryTemplate));
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
	$results = GetCache("sqlite3_result/$cachePath"); #todo this should match below?

	if ($results) {
		#cool
		WriteLog('SqliteQueryCachedShell: $results was populated from cache');
	} else {
		my $results = SqliteQuery($query);
		if ($results) {
			WriteLog('SqliteQueryCachedShell: PutCache: length($results) ' . length($results));
			PutCache('sqlite3_result/'.$cachePath, $results); #todo this should match above?
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

		WriteLog('SqliteGetValue: $return = ' . ($return ? $return : 'FALSE') . '; caller = ' . join(',', caller));

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
