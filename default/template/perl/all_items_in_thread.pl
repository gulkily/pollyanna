#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub DBGetAllItemsInThread {
	my $itemHash = shift;

	#my $query = "SELECT item_hash FROM item_parent WHERE parent_hash = ? OR item_hash = ?";
	my $query = "
		SELECT
		file_hash,
		file_path
		FROM
		item_parent
		JOIN item_flat ON(item_parent.item_hash = item_flat.file_hash)
		WHERE parent_hash = ?
		UNION ALL
		SELECT
		file_hash,
		file_path
		FROM
		item_flat
		WHERE
		file_hash = ?
	";

	my %return;

	my @queryParams = ($itemHash, $itemHash);
	my @result = SqliteQueryHashRef($query, @queryParams);

	shift @result; #todo sanity check column names

	WriteLog('DBGetAllItemsInThread: $itemHash = ' . $itemHash . '; @result = ' . scalar(@result) . '; caller = ' . join(',', caller));

	for my $r (@result) {
		my %row = %{$r};
		my $key = $row{'file_hash'};

		$return{$key} = \%row;

		if ($key ne $itemHash) {
			my $subR = DBGetAllItemsInThread($key);
			my %sub = %{$subR};

			WriteLog('DBGetAllItemsInThread: $subR = ' . scalar(keys %{$subR}));

			for my $subKey (keys %sub) {
				WriteLog('DBGetAllItemsInThread: $subKey = ' . $subKey);
				my %subHash = %{$sub{$subKey}};
				$return{$subKey} = \%subHash;
			}
		}
	}

	return \%return;
}

1;