#!/usr/bin/perl -T

# not tested yet, but committed for safety

use strict;
use warnings;
use 5.010;
use utf8;

my $USE_MYSQL = 1; # Set to 1 for MySQL, 0 for SQLite

sub DBConnect {
    if ($USE_MYSQL) {
        # MySQL connection
        my $dsn = "DBI:mysql:database=your_db_name;host=your_host;port=3306";
        my $dbh = DBI->connect($dsn, 'username', 'password', { RaiseError => 1 });
        return $dbh;
    } else {
        # SQLite connection (return nothing as it's file-based)
        return;
    }
}

sub DBQuery {
    my ($query, @params) = @_;
    if ($USE_MYSQL) {
        my $dbh = DBConnect();
        my $sth = $dbh->prepare($query);
        $sth->execute(@params);
        my $result = $sth->fetchall_arrayref({});
        $sth->finish();
        $dbh->disconnect();
        return $result;
    } else {
        return SqliteQueryHashRef($query, @params);
    }
}

sub SqliteQueryHashRef {
    return DBQuery(@_);
}

sub SqliteQuery {
    my ($query, @params) = @_;
    my $result = DBQuery($query, @params);
    # Format result to match SQLite output
    # (You may need to adjust this based on your specific needs)
    return join("\n", map { join("|", values %$_) } @$result);
}

sub SqliteGetValue {
    my ($query, @params) = @_;
    my $result = DBQuery($query, @params);
    return $result->[0]->{(keys %{$result->[0]})[0]} if @$result;
    return '';
}

sub SqliteGetColumnArray {
    my ($query, $columnName) = @_;
    my $result = DBQuery($query);
    return map { $_->{$columnName} } @$result;
}

sub SqliteEscape {
    my $text = shift;
    if ($USE_MYSQL) {
        my $dbh = DBConnect();
        return $dbh->quote($text);
    } else {
        $text =~ s/'/''/g if defined $text;
        return defined $text ? $text : '';
    }
}

sub GetMysqlHost {
    if ($USE_MYSQL) {
        return 'localhost';
    } else {
        # Existing SQLite logic
    }
}

sub GetSqliteDbName {
    if ($USE_MYSQL) {
        return 'pollyanna';
    } else {
        # Existing SQLite logic
    }
}

sub GetMysqlUser {
    if ($USE_MYSQL) {
        return 'pollyanna';
    } else {
        # Existing SQLite logic
    }
}

sub GetMysqlPassword {
    if ($USE_MYSQL) {
        return 'password';
    } else {
        # Existing SQLite logic
    }
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