#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub MakeFeed { # writes a bare-bones txt file with items list
# sub GetFeed {
# sub PutFeed {
	my $feed = shift;
	chomp $feed;

	WriteLog('MakeFeed: $feed = ' . $feed . '; caller = ' . join(',', caller));

	#todo make templates for this, e.g. template/query/feed/new.sql
	my $plaintextList = '';

	my $htmlDir = GetDir('html');
	my $fileOut = "$htmlDir/$feed.txt";

	if ($feed eq 'new') {
		$plaintextList = SqliteQuery("SELECT file_hash, CAST(add_timestamp AS INT) AS add_timestamp, file_path FROM item_flat ORDER BY add_timestamp DESC LIMIT 20");
	}
	elsif ($feed eq 'scores') {
		$plaintextList = SqliteQuery("SELECT author_key, author_score FROM author_score WHERE author_key ORDER BY author_score DESC LIMIT 100");
	}
	elsif ($feed eq 'author') {
		my $authorKey = shift;
		if ($authorKey = IsFingerprint($authorKey)) {
			$plaintextList = SqliteQuery("SELECT file_hash, CAST(add_timestamp AS INT) AS add_timestamp FROM item_flat WHERE author_key = ?", $authorKey);
			$fileOut = "$htmlDir/author/$authorKey.txt";
		}
	}
	elsif (GetTemplate("query/$feed.sql")) {
		$plaintextList = SqliteQuery($feed);
	}
	else {
		WriteLog('MakeFeed: warning: $feed unrecognized; caller = ' . join(',', caller));
	}
	$plaintextList =~ s/^[^\n]+\n//s;

	WriteLog('MakeFeed: length($plaintextList) = ' . length($plaintextList));

	if ($plaintextList) {
		$plaintextList = str_replace($htmlDir, '', $plaintextList); # this is a horrible hack #todo

		WriteLog('MakeFeed: $fileOut = ' . $fileOut);
		PutFile($fileOut, $plaintextList);
	} else {
		WriteLog('MakeFeed: warning: $plaintextList is FALSE; caller = ' . join(',', caller));
	}
} # MakeFeed()

1;
