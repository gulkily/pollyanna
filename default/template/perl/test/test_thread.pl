#!/usr/bin/perl -T

# test that DBGetAllItemsInThread() works

use strict;
use warnings;
use 5.010;

require('./utils.pl');

my $HTMLDIR = GetDir('html');
my $TXTDIR = GetDir('txt');

require_once('index_file.pl');

PutFile("$TXTDIR/test.txt", 'test');
my $fileHash = IndexFile("$TXTDIR/test.txt");
my $item = $fileHash;

my $reply = ">>$fileHash\ntest1";
print("\n\n\n" . $reply);
PutFile("$TXTDIR/test2.txt", $reply);
my $replyHash = IndexFile("$TXTDIR/test2.txt");

my $reply2 = ">>$replyHash\ntest2";
print("\n\n\n" . $reply2);
PutFile("$TXTDIR/test3.txt", $reply2);
my $reply2Hash = IndexFile("$TXTDIR/test3.txt");

print("\n");

print('$fileHash = ' . $fileHash . "\n");


my $resultRef = DBGetAllItemsInThread($item);
my %result = %{$resultRef};

print("\n");

print(scalar(keys %result));

print("\n");

for my $r (keys %result) {
	my %row = %{$result{$r}};

	print('$r = ' . $r);
	print("\n");

	for my $key (keys %row) {
		print($key . ' = ' . $row{$key});
		print("\n");
	}

	print("\n");
}

print("\n");
