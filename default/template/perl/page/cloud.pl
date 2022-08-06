#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetCloudPage { # print list of tag pairs
# rough draft
	my $cloudPage;

	my @tags = SqliteGetColumnArray('SELECT DISTINCT vote_value FROM vote');

	my @tagPairs;

	foreach my $tag (@tags) {
		my $tagsPairedQuery = "
			SELECT
				DISTINCT vote_value AS vote_value
			FROM
				vote
			WHERE
				vote_value != '$tag' AND
				file_hash IN (
					SELECT file_hash FROM vote WHERE vote_value = '$tag'
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
					tags_list LIKE '%$tag1%' AND
					tags_list LIKE '%$tag2%'
			");
			$dialogContent .= "<tr><td>$tag1</td><td>$tag2</td><td>$count</td></tr>\n";
		}
	}

	$cloudPage =
		GetPageHeader('stats') .
			GetTemplate('html/maincontent.template') .
			GetWindowTemplate($dialogContent, 'Cloud', 'tag1,tag2,item_count') .
			GetPageFooter('cloud');

	$cloudPage = InjectJs($cloudPage, qw(utils settings avatar timestamp pingback profile));

	return $cloudPage;
}

1;































































