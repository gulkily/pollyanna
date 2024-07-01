#!/usr/bin/perl -T

# go through doc/todo.txt,
# find items that include #bug tag,
# move items to doc/bug.txt

use strict;
use warnings;
use 5.010;

require('./utils.pl');

my $todo = GetFile('doc/todo.txt');

my @todoItems = split("\n===\n", $todo);

my $i = 0;

my $newTodo = '';
my $newBug = '';

for my $todoItem (@todoItems) {
	$todoItem = trim($todoItem);
	if ($todoItem eq '') {
		next;
	}
	if ($todoItem =~ /#bug/) {
		$todoItem =~ s/#bug//g;
		$todoItem = trim($todoItem);
		$newBug .= $todoItem . "\n\n===\n\n"
	} else {
		$newTodo .= $todoItem . "\n\n===\n\n";
	}
	$i++;
}

PutFile('doc/todo.txt', $newTodo);

$newBug = trim($newBug);
if ($newBug) {
	AppendFile('doc/bug.txt', "\n\n===\n\n" . $newBug);
}