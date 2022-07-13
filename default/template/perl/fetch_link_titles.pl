#!/usr/bin/perl -T

require './utils.pl';
require './sqlite.pl';

my @links = SqliteQueryHashRef("
	select 
		file_hash, 
		value as url 
	from 
		item_attribute
	where 
		attribute in ('http', 'https')
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
		if ($urlContents =~ m|<title>([^\<]+)</title>|) {
			$title = $1;
			
			DBAddItemAttribute($fileHash, 'title', $title, GetTime(), $fileHash);
			#print "\n";
		}
	}
}
