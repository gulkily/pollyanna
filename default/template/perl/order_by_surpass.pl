#!/usr/bin/perl -T

use strict;

require './utils.pl';
require './sqlite.pl';

my @items = SqliteQueryHashRef("
	select * from item_flat 
	where 
	file_hash in (select file_hash from item_attribute where attribute = 'surpass') 
	OR file_hash in (select value from item_attribute where attribute = 'surpass')
");

shift @items;

print "items: " . scalar(@items) . "\n";

my $i = 0;
my $j = 0;

for ($i = 0; $i < scalar(@items); $i++) {
	my %item = %{$items[$i]};
	print $item{'file_hash'};
	print "\n";
}

sleep 2;

my $swapHappened = 1;

my $counter = 0;

while ($swapHappened && ($counter < scalar(@items)*5)) {
	#print 1;
	
	$swapHappened = 0;
	for ($i = 0; $i < (scalar(@items)); $i++) {
		#print 2;
		
		for ($j = 0; $j < (scalar(@items)); $j++) {
			#print 3;
			my %a = %{$items[$i]};
			my %b = %{$items[$j]};
			if (DBCheckItemSurpass($a{'file_hash'}, $b{'file_hash'})) {
				#print 'YES';
				
				$swapHappened++;
				my $temp = $items[$i];
				$items[$i] = $items[$j];
				$items[$j] = $temp;
			} else {
				#print 'NO';
			}
		}
		
		#print "\n";
		#print $i;
		#print "\n";
		#print "\n";
	}
	
	$counter++;
	
	#print "\n";
	#print "=======\n";
	#print $counter . ": " . $swapHappened;
	#print "\n";
	#print "=======\n";
	#sleep 1;
}

print "=======\n";

for ($i = 0; $i < scalar(@items); $i++) {
	my %item = %{$items[$i]};
	print $item{'file_hash'};
	print "\n";
}
