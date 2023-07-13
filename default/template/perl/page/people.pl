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

	my $dialog = '';

	require_once('image_container.pl'); #todo move into widget
	require_once('widget/person.pl'); #todo move into widget

	for my $authorHashRef (@authors) {
		my %author = %{$authorHashRef};

		$dialog = $dialog . GetPersonDialog(\%author);

		#$dialog = $dialog . GetDialogX($author{'author_alias'}, $authorHashRef);
	}

	$html =
		GetPageHeader('people') .
		$dialog .
		GetQuerySqlDialog('people') .
		GetPageFooter('people')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php'; # write.html
		}
		$html = InjectJs($html, @js);
	}

	return $html;
}

1;
