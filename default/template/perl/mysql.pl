#!/usr/bin/perl -T

# not tested yet, but committed for safety

use strict;
use warnings;
use 5.010;
use utf8;
use DBI;

my $USE_MYSQL = 1; # Set to 1 for MySQL, 0 for SQLite

sub MysqlConnect {
	if ($USE_MYSQL) {
		# MySQL connection
		my $host = GetMysqlHost();
		my $dbname = GetMysqlDbName();  # Note: This function is used for both MySQL and SQLite
		my $username = GetMysqlUser();
		my $password = GetMysqlPassword();

		my $dsn = "DBI:mysql:database=$dbname;host=$host;port=3306";
		my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1 });
		WriteLog('MysqlConnect: connected to ' . $dsn);
		return $dbh;
	} else {
		# SQLite connection (return nothing as it's file-based)
		WriteLog('MysqlConnect: warning: called with $USE_MYSQL = 0');
		return;
	}
} # MysqlConnect()

sub GetMysqlHost {
	return 'localhost';
}

sub GetMysqlDbName {
	return 'pollyanna';
}

sub GetMysqlUser {
	return 'pollyanna';
}

sub GetMysqlPassword {
	return 'password';
}

sub DBQuery {
	WriteLog('DBQuery: mysql version called; caller = ' . join(',', caller));
	my ($query, @params) = @_;
	if ($USE_MYSQL) {
		my $dbh = MysqlConnect();
		my $sth = $dbh->prepare($query);
		$sth->execute(@params);
		my $result = $sth->fetchall_arrayref({});
		$sth->finish();
		$dbh->disconnect();
		return $result;
	} else {
		return SqliteQueryHashRef($query, @params);
	}
} # DBQuery()

sub MysqlQueryHashRef {
	WriteLog('MysqlQueryHashRef: mysql version called; caller = ' . join(',', caller));
	return DBQuery(@_);
}

sub SqliteQuery {
	WriteLog('SqliteQuery: mysql version called; caller = ' . join(',', caller));
	my ($query, @params) = @_;
	my $result = DBQuery($query, @params);
	# Format result to match SQLite output
	# (You may need to adjust this based on your specific needs)
	return join("\n", map { join("|", values %$_) } @$result);
} # SqliteQuery()

sub SqliteGetValue {
	my ($query, @params) = @_;
	my $result = DBQuery($query, @params);
	return $result->[0]->{(keys %{$result->[0]})[0]} if @$result;
	return '';
} # SqliteGetValue()

sub SqliteGetColumnArray {
	my ($query, $columnName) = @_;
	my $result = DBQuery($query);
	return map { $_->{$columnName} } @$result;
} # SqliteGetColumnArray()

sub SqliteEscape {
	my $text = shift;
	if ($USE_MYSQL) {
		my $dbh = MysqlConnect();
		return $dbh->quote($text);
	} else {
		$text =~ s/'/''/g if defined $text;
		return defined $text ? $text : '';
	}
} # SqliteEscape()

sub GetMysqlHost {
	return 'localhost';
}

sub GetSqliteDbName {
	return 'pollyanna';
}

sub GetMysqlUser {
	return 'pollyanna';
}

sub GetMysqlPassword {
	return 'password';
}

sub MysqlQuery { # $query, @queryParams ; performs mysql query via mysql command
# returns whatever mysql returns to STDOUT
	my $query = shift;
	if (!$query) {
		WriteLog('MysqlQuery: warning: called without $query');
		return;
	}
	chomp $query;
	my @queryParams = @_; # shift

	my $queryId = substr(md5_hex(GetTime() . $query), 0, 5);

	if (GetConfig('debug')) {
		my $LOGDIR = GetDir('log');
		PutFile("$LOGDIR/mysqlquery.$queryId", $query);
	}

	#WriteLog('MysqlQuery: $query = ' . $query);
	WriteLog('MysqlQuery: ' . $queryId . ' caller = ' . join(',', caller));
	$query = MysqlGetNormalizedQueryString($query, @queryParams);

	my $MysqlDbName = GetMysqlDbName();
	my $MysqlUser = GetMysqlUser();
	my $MysqlPassword = GetMysqlPassword();
	my $MysqlHost = GetMysqlHost();

	if ($MysqlDbName =~ m/^([_a-zA-Z0-9\/.]+)$/) {
		$MysqlDbName = $1;
		WriteLog('MysqlQuery: ' . $queryId . ' $MysqlDbName passed sanity check: ' . $MysqlDbName);
	} else {
		WriteLog('MysqlQuery: ' . $queryId . ' $MysqlDbName FAILED sanity check: ' . $MysqlDbName);
		return '';
	}

	if ($query =~ m/^(.+)$/s) {
	# if ($query =~ m/^([[:print:]\n\r\s]+)$/s) {
		# this is only a basic sanity check, but it's better than nothing
		$query = $1;
		WriteLog('MysqlQuery: ' . $queryId . ' $query passed sanity check');
	} else {
		my $outLogName = sha1_hex(time().$query).'.query';
		state $outLogDir = GetDir('log');
		PutFile("$outLogDir/$outLogName", $query);

		WriteLog('MysqlQuery: ' . $queryId . ' warning! non-printable characters found: ' . $outLogName);
		return '';
	}

	if ($query =~ m/\?/) {
		WriteLog('MysqlQuery: ' . $queryId . ' warning: $query contains QM; caller = ' . join(',', caller));
		# this may indicate that a variable placeholder was not filled
	}

	my $logName = substr(GetRandomHash(), 0, 16) . '.sqlerr';
	state $logDir = GetDir('log');
	my $mysqlErrorLog = $logDir . '/' . $logName;

	$query = str_replace('$', '\\$', $query);
	$query = str_replace('`', '\`', $query);

	my $shCommand = "mysql -h $MysqlHost -u $MysqlUser -p$MysqlPassword $MysqlDbName -e \"$query\" 2>$mysqlErrorLog";
	#todo send to /dev/null if debug mode is not enabled?

	WriteLog('MysqlQuery: ' . $queryId . ' $shCommand = ' . $shCommand);

	if ($shCommand =~ m/^(.+)$/s) {
	# if ($shCommand =~ m/^([[:print:]\n\r\s]+)$/s) {
		# this is only a basic sanity check, but it's better than nothing
		WriteLog('MysqlQuery: ' . $queryId . ' $query passed sanity check');
		$shCommand = $1;
	} else {
		my $outLogName = GetSHA1(time().$shCommand).'.shcommand';
		state $outLogDir = GetDir('log');
		PutFile("$outLogDir/$outLogName", $shCommand);
		WriteLog('MysqlQuery: ' . $queryId . ' warning: $shCommand failed sanity check for printable characters only: ' . $outLogName);
		return '';
	}

	###########################################################################
	###########################################################################
	### RUN QUERY VIA SHELL ###################################################
	### RUN QUERY VIA SHELL ###################################################

	my $results = '';
	if ($shCommand =~ m/^(.+)$/s) {
		$shCommand = $1;

		my $timeBefore = GetTime();

		###########################################################################
		###########################################################################
		### RUN QUERY VIA SHELL ###################################################
		### RUN QUERY VIA SHELL ###################################################
		$results = `$shCommand`;

		my $timeAfter = GetTime();

		WriteLog('MysqlQuery: ' . $queryId . ' $results = ' . $results);

		WriteLog('MysqlQuery: ' . $queryId . ' $time = ' . ($timeAfter - $timeBefore));

		if (index($results, '90f7c1d87f56afbf1fc18ce49b9031f035e92a95') != -1) {
			print($results);
			#die($results);
		}
	}

	### RUN QUERY VIA SHELL ###################################################
	### RUN QUERY VIA SHELL ###################################################
	###########################################################################
	###########################################################################

	if (index(trim(lc(GetFile($mysqlErrorLog))), 'locked') != -1) {
		#sometimes the database is locked for a moment, so we retry 3 times before giving up
		#hack
		WriteLog('MysqlQuery: ' . $queryId . ' warning: locked database detected. retrying');
		my $retryCount = 0;
		while ($retryCount < 3 && trim(GetFile($mysqlErrorLog))) {
			WriteLog('MysqlQuery: ' . $queryId . ' locked retrying in 0.25s. Error is: ' . trim(GetFile($mysqlErrorLog)));
			select(undef, undef, undef, 0.25);
			$retryCount++;
			$results = `$shCommand`;
		}
		WriteLog('MysqlQuery: ' . $queryId . ' locked: retry loop exited, Error is: ' . trim(GetFile($mysqlErrorLog)));
		if (trim(GetFile($mysqlErrorLog))) {
			WriteLog('MysqlQuery: ' . $queryId . ' unable to recover from locked state; $retryCount = ' . $retryCount);
			unlink($mysqlErrorLog);
		} else {
			WriteLog('MysqlQuery: ' . $queryId . ' recovered from locked state; $retryCount = ' . $retryCount);
		}
	}

	if ($?) {
		# this is a special perl thing which contains STDERR from most recent backtick command
		WriteLog('MysqlQuery: ' . $queryId . ' warning: error returned; log = ' . $mysqlErrorLog . '; caller = ' . join(',', caller));
		AppendFile($mysqlErrorLog, $query);
		AppendFile($mysqlErrorLog, 'caller: ' . join(',', caller));

		my @caller1 = caller(1);
		my $caller1string = (@caller1 ? ($caller1[0] . ',' . $caller1[1] . ',' . $caller1[2]) : 'undef');
		AppendFile($mysqlErrorLog, 'caller: ' . $caller1string);

		my @caller2 = caller(2);
		my $caller2string = (@caller2 ? ($caller2[0] . ',' . $caller2[1] . ',' . $caller2[2]) : 'undef');
		AppendFile($mysqlErrorLog, 'caller: ' . $caller2string);

		return '';
	}

	if (GetFile($mysqlErrorLog)) {
		WriteLog('MysqlQuery: ' . $queryId . ' warning: mysql call wrote to stderr: ' . $mysqlErrorLog . '; caller = ' . join(',', caller));

		AppendFile('' . $mysqlErrorLog, $query . "\n");
		AppendFile('' . $mysqlErrorLog, join(',', caller));
		AppendFile('' . $mysqlErrorLog, GetTime());

	} else {
		if (-e $mysqlErrorLog) {
			#output file exists, but is empty
			#this would be because of a locked database retry, for example
			unlink($mysqlErrorLog);
		}
	}

	return $results;
} # MysqlQuery()

sub MysqlMakeTables { # creates mysql schema
	# sub MysqlCreateTables {
	# sub MysqlMakeTables {
	# sub MysqlMakeSchema {
	# sub DBMakeTables {

	WriteLog('MysqlMakeTables: begin');

	my $existingTables = MysqlQueryCachedShell('.tables');
	if ($existingTables) {
		WriteLog('MysqlMakeTables: warning: tables already exist');

		#todo verify it is the same schema

		return '';
	}

	my $schemaQueries = GetTemplate('mysql/schema.sql');
	$schemaQueries .= "\n;\n" . GetTemplate('mysql/label_weight.sql');

	$schemaQueries =~ s/^#.+$//mg; # remove sh-style comments (lines which begin with #)

	#confess $schemaQueries;

	MysqlQuery($schemaQueries);

	#DBIndexTagsets(); #todo

	my $MysqlDbName = GetMysqlDbName();

	#todo cache the result so that this can be skipped if building often
} # MysqlMakeTables()

sub MysqlGetQueryTemplate { # $query ; look up query in templates if necessary or just return $query
# looks up query in template/query/$query or template/query/$query.sql
# exceptions:
#   if $query contains one or more spaces
#   if $query begins with period character (.) the way mysql utility queries do
#   if $query does not match /^([a-zA-Z0-9\-_.]+)$/

# sub MysqlGetQuery {
# sub GetQuery {
# sub ExpandQuery {
# sub GetQueryTemplate {
	my $query = shift;
	if (!$query) {
		WriteLog('MysqlGetQueryTemplate: warning: called without $query');
		return '';
	}
	chomp $query;

	if (
		(index($query, ' ') == -1) &&  # if it has a space, it's probably already an sql query if it has a space
		(substr($query, 0, 1) ne '.')  # if it begins with a period, it's probably a query like '.tables'
	) {
		if ($query =~ m/^([a-zA-Z0-9\-_.\/]+)$/) { # sanity check
			my $querySane = $1;
			WriteLog('MysqlGetQueryTemplate: looking up query/' . $querySane);

			if (GetTemplate('query/' . $querySane . '.sql')) {
				my $queryTemplate = GetTemplate('query/' . $querySane . '.sql');
				WriteLog('MysqlGetQueryTemplate: found with added sql: $querySane = ' . $querySane . '; $queryTemplate = ' . length($queryTemplate));
				return $queryTemplate;
			} elsif (GetTemplate('query/' . $querySane)) {
				my $queryTemplate = GetTemplate('query/' . $querySane);
				WriteLog('MysqlGetQueryTemplate: found without added sql: $querySane = ' . $querySane . '; $queryTemplate = ' . length($queryTemplate));
				return $queryTemplate;
			} else {
				WriteLog('MysqlGetQueryTemplate: warning: query has no spaces, and no template found; $query = ' . $query . '; caller = ' . join(',', caller));
				return $querySane;
			}
		} else {
			WriteLog('MysqlGetQueryTemplate: warning: query has no spaces, failed sanity check; $query = ' . $query . '; caller = ' . join(',', caller));
			return '';
		}
	} else {
		WriteLog('MysqlGetQueryTemplate: query has space character(s), returning without change; caller = ' . join(',', caller));
		return $query;
	}
} # MysqlGetQueryTemplate()

sub MysqlGetNormalizedQueryString { # $query, @queryParams ; returns normalized query string
# sub MysqlNormalizeQuery {
# sub NormalizeQuery {
# sub NormalizedQuery {
# sub MysqlGetQueryText {
# sub GetQueryText {
# sub MysqlGetFormattedQuery {
	my $query = shift;
	chomp $query;

	my @queryParams = @_;

	if ($query =~ m/^(.+)$/s) { #todo real sanity check
		$query = $1;
	} else {
		WriteLog('MysqlGetNormalizedQueryString: warning: sanity check failed on $query');
		return '';
	}

	#WriteLog('MysqlGetNormalizedQueryString: $query = ' . $query);

	$query = MysqlGetQueryTemplate($query);

	# remove any non-space space characters and make it one line
	my $queryOneLine = $query;
	$queryOneLine =~ s/\s/ /g;
	while ($queryOneLine =~ m/\s\s/) {
		$queryOneLine =~ s/  / /g;
	}
	$queryOneLine = trim($queryOneLine);

	WriteLog('MysqlGetNormalizedQueryString: $queryOneLine = ' . $queryOneLine);
	WriteLog('MysqlGetNormalizedQueryString: caller: ' . join(', ', caller));

	my $queryWithParams = $queryOneLine;

	my @qmPositions;
	for (my $i = 0; $i < length($queryWithParams); $i++) {
		if (substr($queryWithParams, $i, 1) eq '?') {
			push @qmPositions, $i;
		}
	}

	if (scalar(@qmPositions) != scalar(@queryParams)) {
		WriteLog('MysqlGetNormalizedQueryString: warning: scalar(@qmPositions) != scalar(@queryParams); caller = ' . join(',', caller));
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
				# don't allow pipes because they are separator for mysql output
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

	WriteLog('MysqlGetNormalizedQueryString: $queryWithParams = ' . $queryWithParams);

	return $queryWithParams;
} # MysqlGetNormalizedQueryString()

sub MysqlQueryCachedShell { # $query, @queryParams ; performs mysql query and caches result
# uses cache with query text's hash as key
# sub CacheMysqlQuery {
# sub MysqlGetQuery {
# sub MysqlGetPSV {
	WriteLog('MysqlQueryCachedShell: caller: ' . join(', ', caller));

	my $withHeader = 1;

	my $query = shift;
	if (!$query) {
		WriteLog('MysqlQueryCachedShell: warning: called without $query');
		return;
	}
	chomp $query;
	my @queryParams = @_;

	$query = MysqlGetNormalizedQueryString($query, @queryParams);

	my $cachePath = md5_hex($query);
	if ($cachePath =~ m/^([0-9a-f]{32})$/) {
		$cachePath = $1;
	} else {
		WriteLog('MysqlQueryCachedShell: warning: $cachePath sanity check failed');
	}
	my $cacheTime = GetTime();

	if (0) {
		# this limits the cache to expiration of 1-100 seconds
		# #bug this does not account for milliseconds
		$cacheTime = substr($cacheTime, 0, length($cacheTime) - 2);
		$cachePath = "$cacheTime/$cachePath";
	}

	WriteLog('MysqlQueryCachedShell: $cachePath = ' . $cachePath);
	my $results;

	$results = GetCache("mysql_results/$cachePath");

	if ($results) {
		#cool
		WriteLog('MysqlQueryCachedShell: $results was populated from cache');
	} else {
		my $results = MysqlQuery($query);
		if ($results) {
			WriteLog('MysqlQueryCachedShell: PutCache: length($results) ' . length($results));
			PutCache('mysql_cache/' . $cachePath, $results);
		} else {
			WriteLog('MysqlQueryCachedShell: warning: $results was FALSE; $query = ' . $query);
			WriteLog('MysqlQueryCachedShell: warning: $results was FALSE; caller = ' . join(',', caller));
		}
	}

	if ($results) {
		return $results;
	}
} # MysqlQueryCachedShell()

sub MysqlGetCount { # query ; returns COUNT(*) of provided query
# sub GetCount {
# sub GetQueryCount {

	my $query = shift;
	#todo sanity;
	#todo params

	if ($query =~ m/(LIMIT [0-9]+)$/i) {
		# detect query which has a limit, this is usually not something we want to do when using MysqlGetCount()
		WriteLog('MysqlGetCount: warning: $query seems to have LIMIT clause; caller = ' . join(',', caller));
	}

	my $queryText = MysqlGetNormalizedQueryString($query);
	WriteLog('MysqlGetCount: $queryText = ' . $queryText . '; caller = ' . join(',', caller));

	my $queryItemCount = "SELECT COUNT(*) AS item_count FROM ($queryText) LIMIT 1";
	my $rowCount = SqliteGetValue($queryItemCount);

	return $rowCount;
} # MysqlGetCount()

sub MysqlGetValue { # $query ; Returns the first column from the first row returned by mysql $query
# #todo should allow returning columns other than 0
# sub MysqlQueryGetValue {
# sub MysqlQueryValue {
# sub GetMysqlValue {
# sub GetQueryValue {
	my $query = shift;
	my @queryParams = @_;

	WriteLog('MysqlGetValue: caller: ' . join(',', caller));

	my @result = MysqlQueryHashRef($query, @queryParams);

	if (scalar(@result) > 2) {
		WriteLog('MysqlGetValue: warning: query returned more than one row. caller = ' . join(',', caller));
	}

	if (scalar(@result) > 1) {
		# the first item in the array is the headers, so it should have 2 or more members
		my @columns = @{$result[0]};

		my $columnCount = scalar(@columns);
		if (!$columnCount) {
			WriteLog('MysqlGetValue: warning: no columns! caller = ' . join(',', caller));
			return '';
		}
		if ($columnCount > 1) {
			WriteLog('MysqlGetValue: warning: query returned more than one column. caller = ' . join(',', caller));
		}

		my $firstColumn = $columns[0];  # name of the first column
		my %firstRow = %{$result[1]}; # first row
		my $return = $firstRow{$firstColumn}; # first column's value from first row

		WriteLog('MysqlGetValue: $return = ' . $return);

		return $return;
	} else {
		# nothing found, return nothing
		WriteLog('MysqlGetValue: $return FALSE');

		return '';
	}
} # MysqlGetValue()

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

	my $queryText = MysqlGetNormalizedQueryString($query);
	WriteLog('SqliteGetCount: $queryText = ' . $queryText . '; caller = ' . join(',', caller));

	my $queryItemCount = "SELECT COUNT(*) AS item_count FROM ($queryText) LIMIT 1";
	my $rowCount = MysqlGetValue($queryItemCount);

	return $rowCount;
} # SqliteGetCount()

1;