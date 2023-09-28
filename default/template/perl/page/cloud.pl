#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetCloudPage { # print list of tag pairs
# rough draft
	my $cloudPage;

	my @tags = SqliteGetColumnArray('SELECT DISTINCT label FROM item_label');

	my @tagPairs;

	foreach my $tag (@tags) {
		my $tagsPairedQuery = "
			SELECT
				DISTINCT label AS label
			FROM
				item_label
			WHERE
				label != '$tag' AND
				file_hash IN (
					SELECT file_hash FROM item_label WHERE label = '$tag'
				)
		";

		my @tagsPaired = SqliteGetColumnArray($tagsPairedQuery);

		foreach my $tagPair (@tagsPaired) {
			push @tagPairs, $tagPair . ',' . $tag;
			#$tagPairs{$tagPair} = 1;
		}
	}

	my $dialogContent = '';

	my %tagPairsPrinted; # to avoid printing same pair twice

	foreach my $tagPair (@tagPairs) {
		my ($tag1, $tag2) = split(',', $tagPair);

		if (!$tagPairsPrinted{"$tag1,$tag2"} && !$tagPairsPrinted{"$tag2,$tag1"}) {
			# only print each pair once
			$tagPairsPrinted{"$tag1,$tag2"} = 1;
			#todo sanity
			my $count = SqliteGetValue("
				SELECT COUNT(file_hash) AS count
				FROM item_flat
				WHERE
					labels_list LIKE '%,$tag1,%' AND
					labels_list LIKE '%,$tag2,%'
			");
			$dialogContent .= "<tr><td>$tag1</td><td>$tag2</td><td>$count</td></tr>\n";
		}
	}

	$cloudPage =
		GetPageHeader('stats') .
			GetTemplate('html/maincontent.template') .
			GetDialogX($dialogContent, 'Cloud', 'tag1,tag2,item_count') .
			GetPageFooter('cloud');

	$cloudPage = InjectJs($cloudPage, qw(utils settings avatar timestamp pingback profile));

	return $cloudPage;
}

1;































































