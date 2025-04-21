#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl

# first version of sqlite.pl which uses DBI
# DOES NOT WORK YET, just checking it in

use strict;
use warnings;
use 5.010;
use utf8;

use Data::Dumper;
use Carp;
use DBI;

my @foundArgs;
while (my $arg1 = shift) {
	push @foundArgs, $arg1;
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

sub GetDbHandle {
	state $dbh;
	if (!$dbh) {
		my $dbFile = GetSqliteDbName();
		$dbh = DBI->connect("dbi:SQLite:dbname=$dbFile","","", {
			RaiseError => 1,
			AutoCommit => 1,
			sqlite_unicode => 1,
		});
	}
	return $dbh;
}

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

	# equivalent of .tables
	my $existingTables = SqliteQuery("SELECT name FROM sqlite_master WHERE type='table'");
	if ($existingTables) {
		WriteLog('SqliteMakeTables: warning: tables already exist');
		return '';
	}

	my $schemaQueries = '';
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/sane_defaults.sql');
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/schema.sql');
	$schemaQueries .= "\n;\n" . GetTemplate('sqlite3/label_weight.sql');

	$schemaQueries =~ s/^#.+$//mg; # remove sh-style comments

	SqliteQuery($schemaQueries);

	DBIndexTagsets(); #todo

	my $SqliteDbName = GetSqliteDbName();
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
		WriteLog('SqliteGetNormalizedQueryString (sqlite-dbi): warning: sanity check failed on $query; caller = ' . join(',', caller));
		return '';
	}

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

	return $queryOneLine;
} # SqliteGetNormalizedQueryString()

sub SqliteQuery { # $query, @queryParams ; performs sqlite query via DBI
	my $query = shift;
	if (!$query) {
		WriteLog('SqliteQuery: warning: called without $query');
		return;
	}
	chomp $query;
	my @queryParams = @_;

	my $queryId = substr(md5_hex(GetTime() . $query), 0, 5);

	if (GetConfig('debug')) {
		my $LOGDIR = GetDir('log');
		PutFile("$LOGDIR/sqlitequery.$queryId", $query);
	}

	WriteLog('SqliteQuery: ' . $queryId . ' caller = ' . join(',', caller));
	$query = SqliteGetNormalizedQueryString($query);

	if ($query =~ m/^(.+)$/s) {
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
	}

	my $dbh = GetDbHandle();
	my $results = '';

	eval {
		my $sth = $dbh->prepare($query);
		$sth->execute(@queryParams);

		if ($query =~ /^\s*SELECT/i) {
			my @rows;
			push @rows, join('|', @{$sth->{NAME}}); # Column headers
			while (my @row = $sth->fetchrow_array()) {
				push @rows, join('|', @row);
			}
			$results = join("\n", @rows);
		}
		$sth->finish();
	};

	if ($@) {
		WriteLog('SqliteQuery: ' . $queryId . ' warning: error returned: ' . $@);
		return '';
	}

	return $results;
} # SqliteQuery()

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

sub SqliteQueryCachedShell { # $query, @queryParams ; performs sqlite query with caching
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
		$cacheTime = substr($cacheTime, 0, length($cacheTime) - 2);
		$cachePath = "$cacheTime/$cachePath";
	}

	WriteLog('SqliteQueryCachedShell: $cachePath = ' . $cachePath);
	my $results;

	$results = GetCache("sqlite3_result/$cachePath");

	if ($results) {
		WriteLog('SqliteQueryCachedShell: $results was populated from cache');
	} else {
		my $results = SqliteQuery($query);
		if ($results) {
			WriteLog('SqliteQueryCachedShell: PutCache: length($results) ' . length($results));
			PutCache('sqlite3_result/'.$cachePath, $results);
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

	if ($query =~ m/(LIMIT [0-9]+)$/i) {
		WriteLog('SqliteGetCount: warning: $query seems to have LIMIT clause; caller = ' . join(',', caller));
	}

	my $queryText = SqliteGetNormalizedQueryString($query);
	WriteLog('SqliteGetCount: $queryText = ' . $queryText . '; caller = ' . join(',', caller));

	my $queryItemCount = "SELECT COUNT(*) AS item_count FROM ($queryText) LIMIT 1";
	my $rowCount = SqliteGetValue($queryItemCount);

	return $rowCount;
} # SqliteGetCount()

sub SqliteQueryHashRef { # $query, @queryParams ; Returns array of hashrefs for query results
	my $query = shift;
	my @queryParams = @_;

	my $dbh = GetDbHandle();
	my @results;

	eval {
		my $sth = $dbh->prepare($query);
		$sth->execute(@queryParams);

		# First element will be arrayref of column names
		push @results, $sth->{NAME};

		# Remaining elements will be hashrefs of row data
		while (my $row = $sth->fetchrow_hashref()) {
			push @results, $row;
		}
		$sth->finish();
	};

	if ($@) {
		WriteLog('SqliteQueryHashRef: warning: error returned: ' . $@);
		return ();
	}

	return @results;
} # SqliteQueryHashRef()

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
	my $string = shift;
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
	PrintBanner2("\nFOUND ARGUMENT: $arg1;\n");

	if ($arg1) {
		if ($arg1 eq '--test') {

		}
	}
} # while (my $arg1 = shift @foundArgs)

1;
