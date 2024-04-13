#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub MakeZipFromItemList { # $zipName, \@refItems ; create a zip file from item list
# sub MakeZip {
# sub MakeZipFile {
# @{$refItems} is an array of hash references, should have at least {'file_path'}
	my $zipName = shift;
	my $refItems = shift;
	my @items = @{$refItems};

	if ($zipName =~ m/^([0-9a-zA-Z\/._-]+)$/) {
		$zipName = $1;
	} else {
		WriteLog('MakeZipFromItemList: warning: $zipName failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	WriteLog('MakeZipFromItemList: $zipName = ' . $zipName . '; scalar(@items) = ' . scalar(@items));

	if (!scalar(@items)) {
		WriteLog('MakeZipFromItemList: scalar(@items) is false, returning');
		return '';
	}

	my $HTMLDIR = GetDir('html');
	my $zipPath = "$HTMLDIR/$zipName";
	unlink($zipPath);

	my $zipCommand = "zip -qrj $zipPath ";

	#shift @items;
	for my $row (@items) {
		if (1) { #todo this should check if $row is a hash reference
			my $fileName = $row->{'file_path'};
			if ($fileName =~ m/^([0-9a-zA-Z\/._-]+)$/) {
				$fileName = $1;
				if (file_exists($fileName)) {
					WriteLog('MakeZipFromItemList: $zipCommand $fileName = ' . "$zipCommand $fileName");
					system("$zipCommand $fileName");
					#my %item = %{$refItem};
					#my $fileName = $item{'file_name'};
				} else {
					WriteLog('MakeZipFromItemList: warning: file_exists() was FALSE; $fileName = ' . $fileName);
				}
			} else {
				WriteLog('MakeZipFromItemList: warning: sanity check failed on $fileName = ' . $fileName);
			}
		} else {
			WriteLog('MakeZipFromItemList: warning: $row->{file_path} was not defined; caller = ' . join(',', caller));
		}
	}
} # MakeZipFromItemList()

1;
