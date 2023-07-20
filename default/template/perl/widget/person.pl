#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetPersonDialog { # \%author
	my $authorReference = shift;
	my %author = %{$authorReference};

	my $template = GetTemplate('html/widget/person.template');

	#todo refactor this from basic version
	#todo it should be called profile picture, not avatar, right?
		# because avatars are the text-based things like this: [!$#]
	my $avatarQuery = SqliteGetQueryTemplate('person_avatar');
	my $authorAlias = $author{'author_alias'};
	#todo sanity check on author_alias
	#todo use proper query parametrizing
	$avatarQuery = str_replace('?', "'$authorAlias'", $avatarQuery);
	WriteLog('GetPersonDialog: $avatarQuery = ' . $avatarQuery);
	my $personAvatar = SqliteGetValue($avatarQuery);
	WriteLog('GetPersonDialog: $personAvatar = ' . $personAvatar);
	#todo get person avatar

	if ($personAvatar) {
		my $htmlThumbnail = GetImageContainer($personAvatar, 'Picture of ' . HtmlEscape($author{'author_alias'}), 1);
		$htmlThumbnail = AddAttributeToTag($htmlThumbnail, 'img', 'width', '150');
		$template = str_replace('<span class=author_image></span>', '<span class=author_image>' . $htmlThumbnail . '</span>', $template);
	} else {
		# nothing needed, we can leave the span empty
	}

	require_once('widget/person_link.pl');
	$template = str_replace('<span class=author_alias></span>', '<span class=author_alias>' . GetPersonLink($author{'author_alias'}) . '</span>', $template);
#	$template = str_replace('<span class=author_alias></span>', '<span class=author_alias>' . HtmlEscape($author{'author_alias'}) . '</span>', $template);
	$template = str_replace('<span class=author_key_count></span>', '<span class=author_key_count>' . HtmlEscape($author{'author_key_count'}) . '</span>', $template);
	$template = str_replace('<span class=author_seen></span>', '<span class=last_seen>' . GetTimestampWidget($author{'author_seen'}) . '</span>', $template);
	$template = str_replace('<span class=author_score></span>', '<span class=author_score>' . HtmlEscape($author{'author_score'}) . '</span>', $template);
	$template = str_replace('<span class=item_count></span>', '<span class=item_count>' . HtmlEscape($author{'item_count'}) . '</span>', $template);

	my $dialog = GetDialogX($template, $author{'author_alias'});

	return $dialog;
} # GetPersonDialog()

1;