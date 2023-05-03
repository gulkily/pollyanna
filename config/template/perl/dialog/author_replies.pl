#!/usr/bin/perl -T

# author_replies.pl

use strict;
use warnings;
use 5.010;

sub GetAuthorRepliesDialog { # $authorKey
# returns dialog with replies to author's posts
# sub GetAuthorReplies {
# sub GetReplies {
# sub GetInboxDialog {
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
	# the $authorKey parameter is used three times in the default author_replies query
	# this means that there are three question mark (?) placeholders in the query for it
	# in the future, there may be a way to do this more gracefully, but for now we just
	# push the same parameter three times.
	# this also means that if we replace the query in a theme, such as in the shadowme theme,
	# we still need to have three placeholders, otherwise the query builder will complain
	# about the mismatch.
	# todo make this more automatic like a for loop for number of question marks
	my $authorRepliesQuery = SqliteGetNormalizedQueryString('author_replies', @queryParams);

	my $authorAlias = DBGetAuthorAlias($authorKey);
	my $dialogTitle = 'Inbox'; # shadowme
	# my $dialogTitle = 'Messages For ' . $authorAlias;
	# my $dialogTitle = 'Recent Replies to Author ' . $authorAlias;

	#my $hashRef = SqliteQueryHashRef('author_replies', @queryParams);
	#my @authorReplies = @{$hashRef};

	require_once('dialog/query_as_dialog.pl');

	my %dialogFlags;
	#$dialogFlags{'no_no_results'} = 1;

	my $dialog = GetQueryAsDialog($authorRepliesQuery, $dialogTitle, '', \%dialogFlags);

	return $dialog;
} # GetAuthorRepliesDialog()

sub PutAuthorRepliesDialog { # $authorKey
# sub MakeAuthorRepliesDialog {
# sub MakeInbox {
# sub WriteInbox {
# sub NakeIndexDialog {
# sub PutInboxDialog {
# sub GetInboxDialog {
	my $authorKey = shift;
	#todo sanity
	WriteLog('PutAuthorRepliesDialog: $authorKey = ' . $authorKey . '; caller = ' . join(',', caller));

	require_once('dialog/author_replies.pl');
	my $dialog = GetAuthorRepliesDialog($authorKey);
	PutHtmlFile('dialog/replies/' . $authorKey . '.html', $dialog);
}

1;