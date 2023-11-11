#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPersonPage { # $personName
# sub MakePersonPage {
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
	my $keyListQuery = '';
	{
		#my %params;
		#		$params{'where_clause'} = "
		#			WHERE
		#				labels_list LIKE '%,pubkey,%' AND
		#				labels_list LIKE '%,approve,%' AND
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
				(labels_list LIKE '%,pubkey,%' OR labels_list LIKE '%,my_name_is,%') AND
				labels_list LIKE '%,approve,%' AND
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
		$keyList = GetQueryAsDialog($queryApprovedKeys, 'ApprovedKeys');
		#todo templatize the query, use parameter injection
		$keyListQuery = $queryApprovedKeys;

		#$keyList = GetQueryAsDialog($queryApprovedKeys, 'Approved Keys');
	}

	# COLLECT LIST OF PENDING (NOT APPROVED) KEYS
	my $pendingKeyList = '';
	{
		#		my %params;
		#		$params{'where_clause'} = "
		#			WHERE
		#				labels_list LIKE '%,pubkey,%' AND
		#				labels_list NOT LIKE '%,approve,%' AND
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
        				author_key AS author_id,
        				author_key,
        				'' AS tagset_pending,
        				'' AS cart
        			FROM item_flat
        			WHERE
						(labels_list LIKE '%,pubkey,%' OR labels_list LIKE '%,my_name_is,%') AND
						labels_list NOT LIKE '%,approve,%' AND
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
		$pendingKeyList = GetQueryAsDialog($queryPendingKeys, 'PendingKeys');
		#if (!$pendingKeyList) {
		#	$pendingKeyList = GetDialogX('<fieldset><p>There are no authors awaiting approval.</p></fieldset>', 'Notice');
		#}

	}

	# COLLECT LIST OF ITEMS BY APPROVED AUTHORS
	my $itemList = '';
	{
		# #todo templatize this in default/template/query
		my $queryItemList = "
			SELECT
				file_hash,
				item_title,
				add_timestamp,
				person_author.author_key AS author_id,
				'' AS cart
			FROM
				item_flat
				JOIN person_author ON (person_author.author_key = item_flat.author_key)
			WHERE person_author.author_alias = '$personName'
			ORDER BY add_timestamp DESC
			LIMIT 30
		";
		#todo remove hard-coded limit of 30 itesm
		$itemList = GetQueryAsDialog($queryItemList, 'RecentActivity');
		#todo templatize the query, use parameter injection
	}

	#todo: my $dialogPerson = GetPersonDialog(...);

	my $personDialog = GetDialogX('<fieldset><p>This page is about a person named ' . HtmlEscape($personName) . '.</p></fieldset>', HtmlEscape($personName));

	my $zipDialog = '';
	if (GetConfig('setting/zip/person')) {
		#todo sanity checks, make sure zip file name has no spaces
		my $zipName = "/person/$personName/$personName.zip";

		if ($zipName) {
			require_once('make_zip.pl');
			my %zipOptions;
			$zipOptions{'where_clause'} = "WHERE author_key IN (SELECT author_key FROM person_author WHERE author_alias = '$personName')"; #todo use parameter injection
			my @zipFiles = DBGetItemList(\%zipOptions);
			MakeZipFromItemList($zipName, \@zipFiles);
		}

		#MakeZipFromItemList($zipName, \@itemList); #todo
		$zipDialog = GetDialogX('<fieldset><p><a href="/person/' . HtmlEscape($personName) . '/' . HtmlEscape($personName) . '.zip">' . HtmlEscape($personName) . '.zip' . '</a><br>(Under Construction)</p></fieldset>', 'Archive');

	}

	# BUILD HTML PAGE OUT OF ABOVE UNITS
	my $html =
		GetPageHeader('person', HtmlEscape($personName)) .
		$personDialog .
		$itemList .
		$zipDialog .
		#"\n<hr>\n" .
		#GetDialogX('<p>Approved Keys</p>') .
		$keyList .
		GetQuerySqlDialog($keyListQuery, 'ApprovedKeys') . #todo actually create template for the query etc
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
