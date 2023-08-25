#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPersonPage { # $personName
	my $personName = shift;

	if ($personName =~ m/^([a-zA-Z0-9]+)$/) { # #todo use a validator function instead of regex
		$personName = $1;
		WriteLog('GetPersonPage: sanity check passed, $personName = ' . $personName);
	} else {
		WriteLog('GetPersonPage: warning: sanity check failed on $personName; caller = ' . join(',', caller));
		return '';
	}

	#todo add person.template ;
	#GetPersonDialog(\%author);

	# COLLECT LIST OF APPROVED KEYS
	my $keyList = '';
	{
		#my %params;
		#		$params{'where_clause'} = "
		#			WHERE
		#				tags_list LIKE '%,pubkey,%' AND
		#				tags_list LIKE '%,approve,%' AND
		#				file_hash IN (
		#					SELECT file_hash
		#					FROM item_flat
		#					WHERE author_key IN(
		#						SELECT author_key
		#						FROM author_flat
		#						WHERE author_alias = '$personName'
		#					)
		#				)
		#		";
		#my @files = DBGetItemList(\%params);
		#$keyList = GetItemListHtml(\@files); #todo use GetAuthorInfoBox()

		#todo templatize query
		my $queryApprovedKeys = "
			SELECT
				file_hash,
				item_title,
				add_timestamp,
				'' AS tagset_pubkey
			FROM item_flat
			WHERE
            				tags_list LIKE '%,pubkey,%' AND
            				tags_list LIKE '%,approve,%' AND
            				file_hash IN (
            					SELECT file_hash
            					FROM item_flat
            					WHERE author_key IN(
            						SELECT author_key
            						FROM author_flat
            						WHERE author_alias = '$personName'
            					)
            				)
		";
		$keyList = GetQueryAsDialog($queryApprovedKeys, 'Approved Keys');
	}

	# COLLECT LIST OF PENDING (NOT APPROVED) KEYS
	my $pendingKeyList = '';
	{
		#		my %params;
		#		$params{'where_clause'} = "
		#			WHERE
		#				tags_list LIKE '%,pubkey,%' AND
		#				tags_list NOT LIKE '%,approve,%' AND
		#				file_hash IN (
		#					SELECT file_hash
		#					FROM item_flat
		#					WHERE author_key IN(
		#						SELECT author_key
		#						FROM author_flat
		#						WHERE author_alias = '$personName'
		#					)
		#				)
		#		";
		#		my @files = DBGetItemList(\%params);
		#		$pendingKeyList = GetItemListHtml(\@files); #todo use GetAuthorInfoBox()
		#todo templatize query
		my $queryPendingKeys = "
					SELECT
        				file_hash,
        				add_timestamp,
        				author_id,
        				author_key,
        				'' AS tagset_pending
        			FROM item_flat
        			WHERE
                    				tags_list LIKE '%,pubkey,%' AND
                    				tags_list NOT LIKE '%,approve,%' AND
                    				file_hash IN (
                    					SELECT file_hash
                    					FROM item_flat
                    					WHERE author_key IN(
                    						SELECT author_key
                    						FROM author_flat
                    						WHERE author_alias = '$personName'
                    					)
                    				)
		";
		$pendingKeyList = GetQueryAsDialog($queryPendingKeys, 'Pending Keys');

	}

	# COLLECT LIST OF ITEMS BY APPROVED AUTHORS
	my $itemList = '';
	{
		my $queryItemList = "
			SELECT
				file_hash,
				item_title,
				add_timestamp
			FROM
				item_flat
				JOIN person_author ON (person_author.author_key = item_flat.author_key)
			WHERE person_author.author_alias = '$personName'
			ORDER BY add_timestamp DESC
			LIMIT 15
		";
		$itemList = GetQueryAsDialog($queryItemList, 'Recent Activity');
		#todo templatize the query, use parameter injection
	}

	#todo: my $dialogPerson = GetPersonDialog(...);

	my $personDialog = GetDialogX('<fieldset><p>This page is about a person named ' . HtmlEscape($personName) . '.</p></fieldset>', HtmlEscape($personName));

	# BUILD HTML PAGE OUT OF ABOVE UNITS
	my $html =
		GetPageHeader('person', HtmlEscape($personName)) .
		$personDialog .
		$itemList .
		#"\n<hr>\n" .
		#GetDialogX('<p>Approved Keys</p>') .
		$keyList .
		#"\n<hr>\n" .
		#GetDialogX('<p>Pending Approval</p>') .
		$pendingKeyList .
		GetPageFooter('person')
	;

	# INJECT NECESSARY JS
	my @jsToInject = qw(settings timestamp voting utils profile);
	if (GetConfig('setting/admin/js/fresh')) {
		push @jsToInject, 'fresh';
	}
	if (GetConfig('setting/html/reply_cart')) {
		push @jsToInject, 'reply_cart';
	}
	$html = InjectJs($html, @jsToInject);

	# RETURN HTML
	return $html;
} # GetPersonPage()

1;
