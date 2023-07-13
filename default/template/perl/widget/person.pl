#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPersonDialog { # \%author
	my $authorReference = shift;
	my %author = %{$authorReference};

	my $template = GetTemplate('html/widget/person.template');

	my $htmlThumbnail = GetImageContainer('9fd6ad2dacc9041bbce7480fc03bb9393f0468de', 'Picture of ' . HtmlEscape($author{'author_alias'}), 1);
	$htmlThumbnail = AddAttributeToTag($htmlThumbnail, 'img', 'width', '150');

	$template = str_replace('<span class=author_image></span>', '<span class=author_image>' . $htmlThumbnail . '</span>', $template);
	$template = str_replace('<span class=author_alias></span>', '<span class=author_alias>' . HtmlEscape($author{'author_alias'}) . '</span>', $template);
	$template = str_replace('<span class=author_key_count></span>', '<span class=author_key_count>' . HtmlEscape($author{'author_key_count'}) . '</span>', $template);
	$template = str_replace('<span class=author_seen></span>', '<span class=last_seen>' . GetTimestampWidget($author{'author_seen'}) . '</span>', $template);
	$template = str_replace('<span class=author_score></span>', '<span class=author_score>' . HtmlEscape($author{'author_score'}) . '</span>', $template);
	$template = str_replace('<span class=item_count></span>', '<span class=item_count>' . HtmlEscape($author{'item_count'}) . '</span>', $template);

	my $dialog = GetDialogX($template, $author{'author_alias'});

	return $dialog;
} # GetPersonDialog()

1;