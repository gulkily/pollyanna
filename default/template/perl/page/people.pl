#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPeoplePage {
	WriteLog('GetPeoplePage: caller = ' . join(',', caller));

	my $html = '';

	#my $dialog = GetQueryAsDialog('people');
	my @authors = SqliteQueryHashRef('people');
	shift @authors;

	my $people = '';
	{
		require_once('image_container.pl'); #todo move into widget
		require_once('widget/person.pl'); #todo move into widget
		for my $authorHashRef (@authors) {
			my %author = %{$authorHashRef};
			$people = $people . GetPersonDialog(\%author);

			#$dialog = $dialog . GetDialogX($author{'author_alias'}, $authorHashRef);
		}
	}

	my $pending = '';
	{
		$pending = GetQueryAsDialog('people_pending', 'Pending Approval');
	}

	$html =
		GetPageHeader('people') .
		$people .
		$pending .
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
