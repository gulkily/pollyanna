#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAuthors2Page {
	WriteLog('GetAuthors2Page: caller = ' . join(',', caller));

    my $html = '';

	#my $dialog = GetQueryAsDialog('authors2');
	my @authors = SqliteQueryHashRef('authors2');
	shift @authors;

	my $dialog = '';

	for my $authorHashRef (@authors) {
		my %author = %{$authorHashRef};

		my $template = GetTemplate('html/widget/author2.template');

		#todo sanity checks on each field

		$template = str_replace('<span class=author_alias></span>', '<span class=author_alias>' . HtmlEscape($author{'author_alias'}) . '</span>', $template);
		$template = str_replace('<span class=author_key_count></span>', '<span class=author_key_count>' . HtmlEscape($author{'author_key_count'}) . '</span>', $template);
		$template = str_replace('<span class=last_seen></span>', '<span class=last_seen>' . GetTimestampWidget($author{'last_seen'}) . '</span>', $template);
		$template = str_replace('<span class=author_score></span>', '<span class=author_score>' . HtmlEscape($author{'author_score'}) . '</span>', $template);
		$template = str_replace('<span class=item_count></span>', '<span class=item_count>' . HtmlEscape($author{'item_count'}) . '</span>', $template);

		#$template = $template . join(',',keys(%author));

		$dialog = $dialog . GetDialogX($template, $author{'author_alias'});

		#$dialog = $dialog . GetDialogX($author{'author_alias'}, $authorHashRef);
	}

    $html =
        GetPageHeader('authors2') .
        $dialog .
		GetQuerySqlDialog('authors2') .
        GetPageFooter('authors2')
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