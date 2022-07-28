require('./utils.pl');

my $todo = GetFile('doc/todo.txt');

my @todoArray = split("\n\n", $todo);
my $i = 0;
for my $todoItem (@todoArray) {
	$i++;	
	print '#'.$i;
	print "\n";
	print $todoItem;
	print "\n===\n";
}
