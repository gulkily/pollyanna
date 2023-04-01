#!/usr/bin/perl -T

# for items with urls, fetches linked pages and stores their titles

require './utils.pl';
require_once('sqlite.pl');

my @links = SqliteQueryHashRef("
	SELECT
		file_hash,
		value AS url
	FROM
		item_attribute
	WHERE
		attribute IN('http', 'https')
");

shift @links;

print "Links in database: " . scalar(@links) . "\n";
print "Continue? ";

my $input = <STDIN>;

for my $link (@links) {
	my %row = %{$link};
	
	my $url = $row{'url'};
	my $fileHash = $row{'file_hash'};
	
	my $urlHash = sha1_hex('fetch_' . $url);
	my $oncePath = 'once/' . $urlHash;
	
	my $urlContents = GetFile($oncePath);
	
	if (!$urlContents) {
		if (index($url, '"') != -1) {
			continue;
		}
		
		if ($url =~ m/(.+)/) {
			$url = $1;
		}
		
		PutFile($oncePath, '1');
		
		$urlContents = `curl -k "$url"`;
		
		if ($urlContents) { 
			PutFile($oncePath, $urlContents);
		} else {
			PutFile($oncePath, '2');
		}
	}
	
	if ($urlContents) {
		my $title = '';
		if ($urlContents =~ m|<title>([^\<]+)</title>|i) {
			$title = $1;
			
			DBAddItemAttribute($fileHash, 'title', $title, GetTime(), $fileHash);
			#print "\n";
		}
	}
}
