#!/usr/bin/perl -T

require './utils.pl';
require './sqlite.pl';

my $itemCount = SqliteGetValue('Select count(*) from item_flat');

my @files = SqliteQueryHashRef("
	SELECT 
		file_path 
	FROM 
		item_flat 
	WHERE
		( 
			tags_list LIKE '%meta%' OR 
			tags_list LIKE '%todo%' OR 
			tags_list LIKE '%bug%'
		)
		AND
		item_score > 0

	;
");

shift @files; #headers

WriteMessage('Total items indexed: ' . $itemCount);
WriteMessage('Found items with tags todo or bug: ' . scalar(@files));
WriteMessage("\n");

for my $file (@files) {
	my $filePath = $file->{'file_path'};
	chomp $filePath;
	if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
		$filePath = $1;
		print `cp -v "$filePath" ./doc/inbox/`;
		print "\n";
	} else {
		print $filePath;
		print "\n";
	}
}

1;
