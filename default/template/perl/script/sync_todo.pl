print "this script is not finished";
exit;

require('./utils.pl');
require_once('index.pl');

# if ( condition ) { # probably newest item is newer than todo.txt ? or manually activated
	# put items back into todo.txt
#} else {
	# write todo.txt out into items

	my $todo = GetFile('doc/todo.txt');
	my @todoArray = split("\n\n", $todo);
	my $i = 0;

	my $todoReply = "";

	for my $todoItem (@todoArray) {
		$i++;

		my $fileContent =
			"#$i\n"
			.
			"$todoItem\n"
			#.
			#. "===\n"
		;

		PutFile("html/txt/todo/$i.txt", $fileContent);
		$newFileHash = IndexFile("html/txt/todo/$i.txt");
		if ($newFileHash) {
			DBAddVoteRecord($newFileHash, 0, 'todo');
			print $newFileHash;
		} else {
			exit;
		}

		#$newFileHash = GetFileHash("html/txt/todo/$i.txt");
	}

	#call index files
#}
