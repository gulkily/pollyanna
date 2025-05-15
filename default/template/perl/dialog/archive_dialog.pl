#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

require_once('dialog.pl');

sub GetArchiveDialog { # $zipPath, $pageType, $fileCount = 0 ; returns dialog with archive info
	my $zipPath = shift;
	my $pageType = shift;
	my $fileCount = shift || 0;
	
	state $HTMLDIR = GetDir('html');
	
	if (!$zipPath) {
		WriteLog('GetArchiveDialog: warning: $zipPath missing; caller = ' . join(',', caller));
		return '';
	}
	
	if (!$pageType) {
		WriteLog('GetArchiveDialog: warning: $pageType missing; caller = ' . join(',', caller));
		return '';
	}
	
	if (file_exists("$HTMLDIR/$zipPath")) {
		# only advertise the file if it exists
		WriteLog('GetArchiveDialog: $zipPath = ' . $zipPath . '; $pageType = ' . $pageType . '; caller = ' . join(',', caller));
		my $zipLink = '<a href="' . $zipPath . '">' . GetZipFilename($zipPath, $pageType) . '</a>';
		my $zipSize = -s "$HTMLDIR/$zipPath";
		my $zipSizeWidget = GetFileSizeWidget($zipSize);
		$zipLink = '<fieldset>' . $zipLink . ' (' . $zipSizeWidget . ')' . '</fieldset>';
		return GetDialogX($zipLink, 'Archive');
	} elsif ($fileCount && $fileCount > 0) {
		return GetDialogX('<fieldset><p>There is no archive available.</p></fieldset>', 'Archive');
	} else {
		if ($pageType eq 'author') {
			return GetDialogX('<fieldset><p>This author has not posted anything yet, <br>so no archive is available.</p></fieldset>', 'Archive');
		} else {
			return GetDialogX('<fieldset><p>There are no items available, <br>so no archive is available.</p></fieldset>', 'Archive');
		}
	}
} # GetArchiveDialog()

sub GetZipFilename { # $zipPath, $pageType ; returns appropriate filename for zip file
	my $zipPath = shift;
	my $pageType = shift;

	if (!$zipPath) {
		WriteLog('GetZipFilename: warning: $zipPath missing; caller = ' . join(',', caller));
		return 'archive.zip';
	}

	if (!$pageType) {
		WriteLog('GetZipFilename: warning: $pageType missing; caller = ' . join(',', caller));
		return 'archive.zip';
	}
	
	if ($zipPath =~ m/([a-zA-Z0-9_\.\-\/]+\.zip)$/) {
		my $filename = $1;
		
		if ($pageType eq 'author' && $filename =~ m/author\/([A-F0-9]+)\.zip/) {
			return $1 . '.zip';
		}

		WriteLog('GetZipFilename: $zipPath = ' . $zipPath . '; $pageType = ' . $pageType . '; returning $filename = ' . $filename);
		
		return $filename;
	} else {
		WriteLog('GetZipFilename: warning: $zipPath = ' . $zipPath . '; $pageType = ' . $pageType . '; filename not found; caller = ' . join(',', caller));
		return '';
	}

	WriteLog('GetZipFilename: warning: $zipPath = ' . $zipPath . '; $pageType = ' . $pageType . '; filename not found; caller = ' . join(',', caller));

	return '';
} # GetZipFilename()

1;