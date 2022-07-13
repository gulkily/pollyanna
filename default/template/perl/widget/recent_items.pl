#!/usr/bin/perl -T

use strict;
use warnings;

sub GetRecentItemsDialog {
	my $query = "
		SELECT
			item_title,
			add_timestamp,
			file_hash
		FROM
			item_flat
		WHERE
			item_score > 0
		ORDER BY
			add_timestamp DESC
		LIMIT 10
	";

	my $dialog = GetQueryAsDialog($query, 'Recently Posted');

	return $dialog;
}

1;