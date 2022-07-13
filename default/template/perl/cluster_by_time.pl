#!/usr/bin/perl
#
#
# groups items using nearby timestamps
# max interval is 1000 seconds
#
use strict;

use Digest::MD5 qw(md5_hex);

my $tims = `sqlite3 cache/b/index.sqlite3 "SELECT file_hash, add_timestamp FROM item_flat ORDER BY add_timestamp;"`;

require './utils.pl';

my @timss = split("\n", $tims);

my $prevTim = 0;
my $items = '';
my $itemsCount = 0;
my $groupsCreatedCount = 0;

for my $tim (@timss) {
	#print $tim;
	my @timm = split('\|', $tim);
	my $item = $timm[0];
	my $tim = $timm[1];
	#my ($item, $tim) = split('|', $tim);

	if (index($tim, '.') != -1) {
		$tim = substr($tim, 0, index($tim, '.'));
	}

	if ($tim - $prevTim > 1000) {
		if ($items && $itemsCount > 1) {
			#my $newTag = '#' . substr(md5_hex($items), 0, 8);
			my $fileName = './html/txt/' . md5_hex($items . $tim) . ".txt.tmp";
			my $newTag = '#' . $tim;

			chomp $items;
			$items = trim($items);

			my $newText = '';
			$newText .= $items;
			$newText .= "\n";
			$newText .= $newTag;
			#my $newText = $items . "\n\n#tims " .  $newTag;

			PutFile($fileName, $newText);
			rename($fileName, GetFileHashPath($fileName));
			$groupsCreatedCount++;

			$items = '';
			$itemsCount = 0;

		}
	}

	$prevTim = $tim;
	$items .= ">>" . $item . "\n";
	$itemsCount++;
}

print "Done!";
print "\n";
print "=====";
print "\n";
print "Groups created: " . $groupsCreatedCount;