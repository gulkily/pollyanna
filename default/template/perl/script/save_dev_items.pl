#!/usr/bin/perl -T

# save development items into todo.txt BASIC

# scans for items with #todo or #bug tags,
#   checks to see if they're already added to doc/todo.txt
#      adds them to the file if they're not

#todo
# add replies sub-items, indented
# strip hashtags from the added text
# condense added text to not have too much whitespace

use strict;
use warnings;
use 5.010;

require('./utils.pl');
require_once('sqlite.pl');

my $SCRIPTDIR = GetDir('script');

my $dividerString = "\n\n===\n\n";
my $todoPath = "$SCRIPTDIR/doc/todo.txt";
my $todoContents = GetFile($todoPath);

my %queryParams;
$queryParams{'where_clause'} = "WHERE (tags_list LIKE '%,bug,%' OR tags_list LIKE '%,todo,%')";
my @files = DBGetItemList(\%queryParams);

my $itemsAdded = 0;

for my $fileRef (@files) {
	my %file = %{$fileRef};
	#print($file{'file_path'});
	#print($file{'file_hash'});
	my $fileMessage = GetFileMessage($file{'file_hash'});

	if (index($todoContents, $fileMessage) != -1) {
		# already present
	} else {
		$todoContents .= $dividerString;
		$todoContents .= $fileMessage;
		$itemsAdded += 1;
	}
}

PutFile($todoPath, $todoContents);

WriteMessage('Items added: ' . $itemsAdded);