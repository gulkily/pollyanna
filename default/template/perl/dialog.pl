#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

# GetDialogX()
#	 $body = what's inside the dialog
# 	$title = title
# 	$headings
# 		comma-separated list of headings
# 		-or-
# 		number of columns (integer)
# 	$status = what goes in the status bar
# 	$menu = goes at the top of the window, below the title
# 	calls GetDialogX2()

# GetDialogX3()
#	$body
#	$title
#	\%paramHash (see above)

sub GetDialogX { # $body, $title, $headings, $status, $menu ; returns html with window/dialog
# renamed from GetWindowTemplate()
# it's called GetDialogX instead of GetDialog to make it easier to search for
# calls GetDialogX2()

# sub GetWindowTemplate {
# sub GetDialog {
# sub GetDialogPage {
	my %param = ();

	$param{'body'} = shift;
	$param{'title'} = shift || '';
	# $param{'title'} = shift || 'Untitled';
	$param{'headings'} = shift || '';
	$param{'status'} =  shift || '';
	$param{'menu'} = shift || '';

	if (!trim($param{'body'})) {
		WriteLog('GetDialogX: warning: body is FALSE; title = ' . $param{'title'} . '; caller = ' . join(',', caller));
		return '';
	} else {
		#WriteLog('GetDialogX: warning: body is TRUE; title = ' . $param{'title'} . '; caller = ' . join(',', caller));
	}

	WriteLog('GetDialogX: $param{title}: ' . $param{'title'} . '; caller = ' . join(',', caller));

	#hack
	my $id = lc($param{'title'});
	if (
		$id eq 'read' ||
		$id eq 'write' ||
		$id eq 'settings' ||
		$id eq 'help' ||
		$id eq 'profile' ||
		$id eq 'tags' ||
		$id eq 'authors' ||
		$id eq 'upload' ||
		$id eq 'introduction'
	) {
		$param{'id'} = $id;
	} else {
		if ($param{'title'}) {
			$param{'id'} = $param{'title'};
			$param{'id'} =~ s/[^a-zA-Z0-9]//g;
		}
		# default window's id to hash of title
		#$param{'id'} = substr(md5_hex($param{'title'}), 0, 8);
	}

	WriteLog('GetDialogX: $id = ' . ($param{'id'} ? $param{'id'} : 'FALSE'));

	if (!$param{'title'}) {
		#WriteLog('GetDialogX: warning: untitled window; caller = ' . join(',', caller));
		#$param{'title'} = 'Untitled';
		$param{'title'} = '';
	}

	if (!$param{'id'}) {
		WriteLog('GetDialogX: warning: id missing, setting to title = ' . $param{'title'} . '; caller = ' . join(',', caller));
		$param{'id'} = $param{'title'};
	}

	if (GetConfig('debug')) {
		$param{'debug_message'} = 'GetDialogX: caller = ' . join(',', caller);
	}

	#todo check for dialogAnchor?

	return GetDialogX2(\%param);
} # GetDialogX()

sub GetDialogX3 { # $body $title \%param
	# use when need several parameters and not much else
	my $body = shift;
	my $title = shift;

	my $paramHashRef = shift;
	my %param;
	if ($paramHashRef) {
		%param = %{$paramHashRef};
	}

	WriteLog('GetDialogX3(length($body) = (' . length($body) . '); $title = ' . $title . '; %param has ' . length(keys(%param)) . '); caller = ' . join(',', caller));

	$param{'body'} = $body;
	$param{'title'} = $title;

	return GetDialogX2(\%param);
} # GetDialogX3()

sub GetDialogIcon {
	my $dialogName = shift;
	chomp $dialogName;

	$dialogName = lc($dialogName);

	if ($dialogName eq 'session') {
		return '🤝';
	}
	elsif ($dialogName eq 'keychain') {
		return '🔑';
	}
	elsif ($dialogName =~ m/sql$/) {
		return '🔍';
	}
	elsif (GetString($dialogName, 'emoji')) {
		return GetString($dialogName, 'emoji', 1);
	}
	else {
		return '🌌';
	}
} # GetDialogIcon()

require_once('dialog_builder.pl');

1;
