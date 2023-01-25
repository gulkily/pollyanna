#!/usr/bin/perl -T

# author_replies.pl

use strict;
use warnings;
use 5.010;

sub GetAuthorRepliesDialog { # $authorKey
# returns dialog with replies to author's posts
# sub GetAuthorReplies {
# sub GetReplies {

	my $authorKey = shift;

	#$authorKey = IsFingerprint($authorKey);

	if (!IsFingerprint($authorKey)) {
		WriteLog('GetAuthorRepliesDialog: warning: $authorKey failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	WriteLog('GetAuthorRepliesDialog(' . $authorKey . '); caller = ' . join(',', caller));

	my @queryParams;
	push @queryParams, $authorKey;
	push @queryParams, $authorKey;
	push @queryParams, $authorKey;
	my $authorRepliesQuery = SqliteGetNormalizedQueryString('author_replies', @queryParams);

	my $authorAlias = DBGetAuthorAlias($authorKey);
	my $dialogTitle = 'Recent Replies to Author ' . $authorAlias;

	#my $hashRef = SqliteQueryHashRef('author_replies', @queryParams);
	#my @authorReplies = @{$hashRef};

	require_once('dialog/query_as_dialog.pl');

	my %dialogFlags;
	$dialogFlags{'no_no_results'} = 1;

	my $dialog = GetQueryAsDialog($authorRepliesQuery, $dialogTitle, '', \%dialogFlags);

	return $dialog;
} # GetAuthorRepliesDialog()

sub PutAuthorRepliesDialog { # $authorKey
# sub MakeAuthorRepliesDialog {
	my $authorKey = shift;
	#todo sanity

	require_once('dialog/author_replies.pl');
	my $dialog = GetAuthorRepliesDialog($authorKey);
	PutHtmlFile('dialog/replies/' . $authorKey . '.html', $dialog);
}

1;
