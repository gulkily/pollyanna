#!/usr/bin/perl -T

# test that DBGetAllItemsInThread() works

use strict;
use warnings;
use 5.010;

require('./utils.pl');

my $item = shift;
if ($item = IsItem($item)) {
	# sanity check passed
} else {
	print("Need valid item, example: 17c2a8e8745296ee216913ff8dc42f205fa3daeb\n");
	return;
}

my $resultRef = DBGetAllItemsInThread($item);
my %result = %{$resultRef};

print("\n");

print(length(%result));

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
