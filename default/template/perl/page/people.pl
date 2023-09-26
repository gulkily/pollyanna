#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPeoplePage {
	WriteLog('GetPeoplePage: caller = ' . join(',', caller));

	my $html = '';

	my @people = SqliteQueryHashRef('people');
	shift @people;

	my $people = '';
	if (scalar(@people)) {
		require_once('image_container.pl'); #todo move into widget
		require_once('widget/person.pl'); #todo move into widget
		for my $authorHashRef (@people) {
			my %author = %{$authorHashRef};
			$people = $people . GetPersonDialog(\%author);

			#$dialog = $dialog . GetDialogX($author{'author_alias'}, $authorHashRef);
		}
	} else {
		$people = GetDialogX('<fieldset><p>No people found.</p></fieldset>', 'People');
	}

	my $pending = '';
	{
		my %params;
		$params{'no_empty'} = 1;
		$pending = GetQueryAsDialog('people_pending', 'Awaiting Approval', '', \%params);
	}

	my $guests = '';
	{
		my %params;
		$params{'no_empty'} = 1;
		$guests = GetQueryAsDialog('people_guest', 'Guests', '', \%params);
	}

	my $queryTextDialog = GetQuerySqlDialog('people');

	$html =
		GetPageHeader('people') .
		$people .
		$queryTextDialog .
		'<hr>' .
		$pending .
		$guests .
		# GetQuerySqlDialog('people') .
		GetPageFooter('people')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php'; # write.html
		}
		if (GetConfig('setting/html/reply_cart')) {
			push @js, 'reply_cart';
		}
		$html = InjectJs($html, @js);
	}

	return $html;
} # GetPeoplePage()

1;
