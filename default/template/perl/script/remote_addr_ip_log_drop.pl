#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

require('./utils.pl');

sub DropTable {
	my $query = "DROP TABLE IF EXISTS remote_addr_ip_log";
	SqliteQuery($query);
	WriteLog("DropTable: remote_addr_ip_log dropped");
	WriteMessage("DropTable: remote_addr_ip_log dropped");
} # DropTable()

SetSqliteDbName('remote.sqlite3');

DropTable();

1;
