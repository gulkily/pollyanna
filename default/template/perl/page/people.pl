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

	for my $authorHashRef (@authors) {
		my %author = %{$authorHashRef};

		my $template = GetTemplate('html/widget/person.template');

		my $htmlThumbnail = GetImageContainer('9fd6ad2dacc9041bbce7480fc03bb9393f0468de', 'Picture of ' . HtmlEscape($author{'author_alias'}), 1);
		$htmlThumbnail = AddAttributeToTag($htmlThumbnail, 'img', 'width', '150');

		$template = str_replace('<span class=author_image></span>', '<span class=author_image>' . $htmlThumbnail . '</span>', $template);
		$template = str_replace('<span class=author_alias></span>', '<span class=author_alias>' . HtmlEscape($author{'author_alias'}) . '</span>', $template);
		$template = str_replace('<span class=author_key_count></span>', '<span class=author_key_count>' . HtmlEscape($author{'author_key_count'}) . '</span>', $template);
		$template = str_replace('<span class=author_seen></span>', '<span class=last_seen>' . GetTimestampWidget($author{'author_seen'}) . '</span>', $template);
		$template = str_replace('<span class=author_score></span>', '<span class=author_score>' . HtmlEscape($author{'author_score'}) . '</span>', $template);
		$template = str_replace('<span class=item_count></span>', '<span class=item_count>' . HtmlEscape($author{'item_count'}) . '</span>', $template);

		#$template = $template . join(',',keys(%author));

		$dialog = $dialog . GetDialogX($template, $author{'author_alias'});

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
