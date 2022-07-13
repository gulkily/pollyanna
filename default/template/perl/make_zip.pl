#!/usr/bin/perl -T

use strict;
use warnings;

sub MakeZipFromItemList {
	my $zipName = shift;
	my $refItems = shift;
	my @items = @{$refItems};

	WriteLog('MakeZipFromItemList: $zipName = ' . $zipName . '; scalar(@items) = ' . scalar(@items));

	if ($zipName =~ m/^([0-9a-zA-Z\/._-]+)$/) {
		$zipName = $1;
	}

	my $HTMLDIR = GetDir('html');
	my $zipPath = "$HTMLDIR/$zipName";
	unlink($zipPath);

	my $zipCommand = "zip -qrj $zipPath ";

	for my $row (@items) {
		my $fileName = $row->{'file_path'};
		if ($fileName =~ m/^([0-9a-zA-Z\/._-]+)$/) {
			$fileName = $1;

			system("$zipCommand $fileName");
			#my %item = %{$refItem};
			#my $fileName = $item{'file_name'};
			WriteLog('MakeZipFromItemList: $fileName = ' . $fileName);
		} else {
			WriteLog('MakeZipFromItemList: warning: sanity check failed on $fileName = ' . $fileName);
		}
	}
} # MakeZipFromItemList()

1;
