#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl -T

# indexes one file or all files eligible for indexing
# --all .... all eligible files
# [path] ... index specified file
# --chain .. chain.log file (contains timestamps)

use strict;
use warnings;
use utf8;
use 5.010;
#use HTML::Entities qw(decode_entities);

my @argsFound;
while (my $argFound = shift) {
	push @argsFound, $argFound;
}

use Digest::SHA qw(sha512_hex);
use POSIX qw(floor);

# use threads (
# 	'yield',
# 	'stack_size' => 64*4096,
# 	'exit' => 'threads_only',
# 	'stringify'
# );

require('./config/template/perl/utils.pl');
require_once('gpgpg.pl');
require_once('sqlite.pl');
require_once('index_text_file.pl');
require_once('chain.pl');

sub IndexHtmlFile { # $file | 'flush' ; indexes one text file into database
# DRAFT
# DRAFT
# DRAFT
# DRAFT
# DRAFT
	state $SCRIPTDIR = GetDir('script');
	state $HTMLDIR = GetDir('html');
	state $TXTDIR = GetDir('txt');

	my $file = shift;
	chomp($file);

	if ($file eq 'flush') {
		IndexTextFile('flush');
	}

	my $html = GetFile($file);
	my @matches;

	print length($html)."\n";

	$html =~ s/\<span[^>]+\>/<span>/g;

	print length($html)."\n";

	sleep 3;

	while ($html =~/(?<=<span>)(.*?)(?=<\/span>)/g) {
		push @matches, $1;
	}

	foreach my $m (@matches) {
		print trim($m), "\n===\n";
		#todo htmldecode

		$m = str_replace('<p>', "\n\n", $m);
		#$m = decode_entities($m);
		my $mHash = sha1_hex($m);
		my $mFilename = GetPathFromHash($mHash);
		PutFile($mFilename, $m);
	}

	#if ($html =~ m/<span.+>(.+)<\/span>/g) {
		#print Dumper($1);
		#print ';-)';
#		print "Word is $1, ends at position ", pos $x, "\n";
		sleep 3;
	#}#

	sleep 3;
} # IndexHtmlFile()
#todo this should be in its own module/file

require_once('index_cpp_file.pl');
require_once('index_py_file.pl');
require_once('index_pl_file.pl');
require_once('index_zip_file.pl');
require_once('run_item.pl');

sub uniq { # @array ; return array without duplicate elements
# copied from somewhere like perlmonks
	my %seen;
	grep !$seen{$_}++, @_;
} # uniq()

require_once('index_image_file.pl');

require_once('index_video_file.pl');

sub MakeIndex { # indexes all available text files, and outputs any config found
# sub IndexFiles {
# sub IndexAllFiles
	WriteLog( "MakeIndex()...\n");

	state $TXTDIR = GetDir('txt');
	WriteLog('MakeIndex: $TXTDIR = ' . $TXTDIR);

	#my @filesToInclude = split("\n", `grep txt\$ ~/index/home.txt`); #homedir #~
	#my @filesToInclude = split("\n", `find $TXTDIR -name \\\*.txt -o -name \\\*.html`); #includes html files #indevelopment
	my $txtFilesCommand = "find $TXTDIR -type f -name '*.txt'";
	WriteLog('MakeIndex: $txtFilesCommand = ' . $txtFilesCommand);
	my @filesToInclude = split("\n", `$txtFilesCommand`);

	my $filesCount = scalar(@filesToInclude);
	my $currentFile = 0;
	foreach my $file (@filesToInclude) {
		#$file =~ s/^./../;

		$currentFile++;
		my $percent = floor(($currentFile / $filesCount) * 100);
		my $printedFilename = str_replace($TXTDIR . '/', '', $file);
		WriteMessage("[$percent%] $currentFile/$filesCount  $printedFilename");
		IndexFile($file); # aborts if cache/.../indexed/filehash exists
	}
	IndexFile('flush');

	#WriteIndexedConfig(); # MakeIndex

	if (GetConfig('admin/image/enable')) {
		state $HTMLDIR = GetDir('html');

		my $imageFilesCommand = "find $HTMLDIR/image";
		WriteLog('MakeIndex: $imageFilesCommand = ' . $imageFilesCommand);
		my @imageFiles = split("\n", `$imageFilesCommand`);
		my $imageFilesCount = scalar(@imageFiles);
		my $currentImageFile = 0;
		WriteLog('MakeIndex: $imageFilesCount = ' . $imageFilesCount);

		foreach my $imageFile (@imageFiles) {
			$currentImageFile++;
			my $percentImageFiles = floor($currentImageFile / $imageFilesCount * 100);
			WriteMessage("[$percentImageFiles%] $currentImageFile/$imageFilesCount  $imageFile");
			#WriteMessage("*** MakeIndex: $currentImageFile/$imageFilesCount ($percentImageFiles %) $imageFile");
			IndexImageFile($imageFile);
		}

		IndexImageFile('flush');
	} # admin/image/enable

	if (GetConfig('admin/video/enable')) {
		state $HTMLDIR = GetDir('html');

		my $videoFilesCommand = "find $HTMLDIR/image -type f -name '*.mp4'";
		WriteLog('MakeIndex: $videoFilesCommand = ' . $videoFilesCommand);
		my @videoFiles = split("\n", `$videoFilesCommand`);
		my $videoFilesCount = scalar(@videoFiles);
		my $currentVideoFile = 0;
		WriteLog('MakeIndex: $videoFilesCount = ' . $videoFilesCount);

		foreach my $videoFile (@videoFiles) {
			$currentVideoFile++;
			my $percentVideoFiles = floor($currentVideoFile / $videoFilesCount * 100);
			WriteMessage("[$percentVideoFiles%] $currentVideoFile/$videoFilesCount  $videoFile");
			#WriteMessage("*** MakeIndex: $currentVideoFile/$videoFilesCount ($percentVideoFiles %) $videoFile");
			IndexVideoFile($videoFile);
		}

		IndexVideoFile('flush');
	} # admin/video/enable

	if (GetConfig('admin/cpp/enable')) {
		state $HTMLDIR = GetDir('html');

		my $cppFilesCommand = "find $HTMLDIR/cpp -type f -name '*.cpp'";
		WriteLog('MakeIndex: $cppFilesCommand = ' . $cppFilesCommand);

		my @cppFiles = split("\n", `$cppFilesCommand`);
		my $cppFilesCount = scalar(@cppFiles);
		my $currentCppFile = 0;
		WriteLog('MakeIndex: $cppFilesCount = ' . $cppFilesCount);

		foreach my $cppFile (@cppFiles) {
			$currentCppFile++;
			my $percentCppFiles = floor($currentCppFile / $cppFilesCount * 100);
			WriteMessage("[$percentCppFiles%] $currentCppFile/$cppFilesCount  $cppFile");
			IndexCppFile($cppFile);
		}

		IndexCppFile('flush');
	} # admin/cpp/enable
	if (GetConfig('admin/python3/enable')) {
		state $HTMLDIR = GetDir('html');

		my $pyFilesCommand = "find $HTMLDIR/py -type f -name '*.py'";
		WriteLog('MakeIndex: $pyFilesCommand = ' . $pyFilesCommand);

		my @pyFiles = split("\n", `$pyFilesCommand`);
		my $pyFilesCount = scalar(@pyFiles);
		my $currentPyFile = 0;
		WriteLog('MakeIndex: $pyFilesCount = ' . $pyFilesCount);

		foreach my $pyFile (@pyFiles) {
			$currentPyFile++;
			my $percentPyFiles = floor($currentPyFile / $pyFilesCount * 100);
			WriteMessage("[$percentPyFiles%] $currentPyFile/$pyFilesCount  $pyFile");
			IndexPyFile($pyFile);
		}

		IndexPyFile('flush');
	} # admin/python3/enable
	if (GetConfig('admin/perl/enable')) {
		state $HTMLDIR = GetDir('html');

		my $perlFilesCommand = "find $HTMLDIR/perl -type f -name '*.pl'";
		WriteLog('MakeIndex: $perlFilesCommand = ' . $perlFilesCommand);

		my @perlFiles = split("\n", `$perlFilesCommand`);
		my $perlFilesCount = scalar(@perlFiles);
		my $currentPerlFile = 0;
		WriteLog('MakeIndex: $perlFilesCount = ' . $perlFilesCount);

		foreach my $perlFile (@perlFiles) {
			$currentPerlFile++;
			my $percentPerlFiles = floor($currentPerlFile / $perlFilesCount * 100);
			WriteMessage("[$percentPerlFiles%] $currentPerlFile/$perlFilesCount  $perlFile");
			IndexPerlFile($perlFile);
		}

		IndexPerlFile('flush');
	} # admin/perl/enable
} # MakeIndex()

sub DeindexMissingFiles { # remove from index data for files which have been removed
# takes no parameters
#
	# get all items in database
	my %queryParams = ();
	my @items = DBGetItemList(\%queryParams);
	my $itemsDeletedCount = 0;

	WriteLog('DeindexMissingFiles scalar(@items) is ' . scalar(@items));
	WriteMessage("Checking for deleted items... ");

	#print Dumper(@items);

	if (@items) {
		# for each of the items, check if the file still exists
		foreach my $item (@items) {

			if ($item->{'file_path'}) {
				if (!-e $item->{'file_path'}) {
					# if file does not exist, remove its references
					WriteLog('DeindexMissingFiles: Found a missing text file, removing references. ' . $item->{'file_path'});
					DBDeleteItemReferences($item->{'file_hash'});
					$itemsDeletedCount++;
				}
			}
		}

		if ($itemsDeletedCount) {
			# if any files were de-indexed, report this, and pause for 3 seconds to inform operator
			WriteMessage('DeindexMissingFiles: deleted items found and removed: ' . $itemsDeletedCount);
			#WriteIndexedConfig(); # DeindexMissingFiles()
			WriteMessage(`sleep 2`);
		}
	}

	return $itemsDeletedCount;
} # DeindexMissingFiles()

require_once('index_file.pl');

sub SweepDeleted { # cleans up files which have been deleted or marked deleted
# looks for files in the index database which have gone away
# also looks for files which have been added to deleted.log and sweeps them
# #todo also sweeps html files which reference the deleted items with grep
# takes no parameters

	my %queryParams;
	my @files = DBGetItemList(\%queryParams);

	my $itemsDeletedCounter = 0;
	
	my @deletedHash;

	foreach my $file (@files) {
		my $fileName = $file->{'file_path'};
		my $fileHash = $file->{'file_hash'};

		WriteMessage($fileHash . ' = ' . $fileName);
		
		if (IsFileDeleted($fileName, $fileHash)) {
			WriteMessage('Found deleted item: $fileHash = ' . $fileHash);
			push @deletedHash, $fileHash;
			
			if (scalar(@deletedHash) > 100) {
				DBDeleteItemReferences(@deletedHash);
				@deletedHash = ();
			}
			
			$itemsDeletedCounter++;
		}
	}
	if (@deletedHash) {
		DBDeleteItemReferences(@deletedHash);
	}
	
	my @attribs = SqliteQueryHashRef(
		"SELECT value, file_hash FROM item_attribute WHERE attribute = 'file_path';"
	);
	shift @attribs; # first one is headers

	state $htmlDir1 = GetDir('html'); #todo is txt always under html? only for now
	
	foreach my $file (@attribs) {
		my $fileName = $file->{'value'};
		my $fileHash = $file->{'file_hash'};
		
		if ( ! -e $htmlDir1 . $fileName) {
			WriteMessage('Found missing file in attribute: $fileName = ' . $fileName);
			my $query1 = "Delete from item_attribute WHERE value = ? AND file_hash = ?";
			my @qParams1;
			push @qParams1, $fileName;
			push @qParams1, $fileHash;
			SqliteQuery($query1, @qParams1);
			$itemsDeletedCounter++;
		}
	}

	WriteMessage('Total deleted items found: ' . $itemsDeletedCounter);

	#if ($itemsDeletedCounter) {
		DeindexMissingFiles();
	#}

} # SweepDeleted()

my $flagNoCache = 0; # GetCache('indexed/' . $fileHash)

my $didSomething = 0;

sub PrintHelp {
	print "index.pl: --clear-cache\n";
	print "index.pl: --all\n";
	print "index.pl: --sweep\n";
	print "index.pl: --chain\n";
	#print "index.pl: --write-indexed-config (-C) calls WriteIndexedConfig\n";
} # PrintHelp()

while (my $arg1 = shift @argsFound) {
	WriteLog('index.pl: $arg1 = ' . $arg1);
	if ($arg1) {
		$arg1 = trim($arg1);

		$didSomething++;
		if ($arg1 eq '--help') {
			print "index.pl: --help\n";
			PrintHelp();
		}
		if ($arg1 eq '--no-cache') {
			print "index.pl: --no-cache\n";
			$flagNoCache = 1;
		}
		if ($arg1 eq '--clear-cache') {
			print "index.pl: --clear-cache\n";
			print `rm -vrf cache/b/indexed/*`;
		}
		if ($arg1 eq '--all') {
			print "index.pl: --all\n";

			my $operatorPlease = GetConfig('setting/admin/token/operator_please');
			PutConfig('setting/admin/token/operator_please', 0);
			my $hikeSet = GetConfig('setting/admin/token/hike_set');
			PutConfig('setting/admin/token/hike_set', 0);
			MakeIndex();
			PutConfig('setting/admin/token/hike_set', $hikeSet);
			PutConfig('setting/admin/token/operator_please', $operatorPlease);

			print "\n";
			print "=========================\n";
			print "index.pl: --all finished!\n";
			print "=========================\n";
		}
		if ($arg1 eq '--sweep') {
			# sweep deleted files
			# checks for:
			# * items which no longer have a .txt file supporting them
			# * items which have been added to deleted.log
			print "index.pl: --sweep\n";
			SweepDeleted();
		}
		if ($arg1 eq '--chain') {
			# html/chain.log
			print "index.pl: --chain\n";
			if (GetConfig('setting/admin/index/read_chain_log')) {
				MakeChainIndex(); # index.pl --chain
			} else {
				print "index.pl: MakeChainIndex() SKIPPED because of setting/admin/index/read_chain_log = FALSE\n";
				print "index.pl: MakeChainIndex() SKIPPED because of setting/admin/index/read_chain_log = FALSE\n";
				print "index.pl: MakeChainIndex() SKIPPED because of setting/admin/index/read_chain_log = FALSE\n";
			}
		}
		if ($arg1 eq '--squash-chain' || $arg1 eq '-S') {
			# html/chain.log
			print "index.pl: --squash-chain -S\n";
			if (GetConfig('setting/admin/index/read_chain_log')) {
				SquashChain(); # index.pl --squash-chain
			} else {
				print "index.pl: SquashChain() SKIPPED because of setting/admin/index/read_chain_log = FALSE\n";
				print "index.pl: SquashChain() SKIPPED because of setting/admin/index/read_chain_log = FALSE\n";
				print "index.pl: SquashChain() SKIPPED because of setting/admin/index/read_chain_log = FALSE\n";
			}
		}
#		if ($arg1 eq '--write-indexed-config' || $arg1 eq '-C') {
#			# sweep deleted files
#			print "index.pl: --write-indexed-config (-C) calls WriteIndexedConfig()\n";
#			WriteIndexedConfig(); # index.pl '--write-indexed-config'
#		}
		if (-e $arg1) {
			my $fileHash = GetFileHash($arg1);
			if ($fileHash && $flagNoCache) {
				#if (GetCache('indexed/' . $fileHash)) {
				if (IsFileAlreadyIndexed($arg1, $fileHash)) {
					print "Removing indexed marker\n";
					#UnlinkCache("indexed/$fileHash");
				}
			}
			WriteMessage("IndexFile($arg1) " . '(' . scalar(@argsFound) . ' left)');

			my $indexFileResult = IndexFile($arg1);

			if ($arg1 =~ m/([0-9a-f]{40})/) {
				my $fileHashFromFilename = $1;
				if ($indexFileResult ne $fileHashFromFilename) {
					if ($fileHashFromFilename && ($fileHash ne $fileHashFromFilename)) {
						AppendFile("log/rename.log", $indexFileResult . "|" . $fileHashFromFilename); #todo proper path
						DBAddItemAttribute($indexFileResult, 'alt_hash', $fileHashFromFilename);
					}
				}
			}
			else {
				WriteLog('IndexFile: $fileHashFromFilename was FALSE; caller = ' . join(',', caller));
			}

			WriteMessage("IndexFile($arg1) result: $indexFileResult");

			#my $htmlFilename = GetHtmlFilename($indexFileResult); # IndexFile()

			#WriteMessage("IndexFile($arg1) returned: http://localhost:2784/" . $htmlFilename);
			IndexFile('flush');
		} # if (-e $arg1)
		else {
			WriteMessage("index.pl: what is $arg1");
			PrintHelp();
		}
	}
} # while (my $arg1 = shift @argsFound)

if (!$didSomething) {
	PrintHelp();
}

print "\n";

1;
