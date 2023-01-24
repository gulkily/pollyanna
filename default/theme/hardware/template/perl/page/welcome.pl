#!/usr/bin/perl -T

use strict;
use warnings;

sub GetTagCategoriesDialog { # $rootTag ; traverses all tagsets under a tag and generates links with item counts
	my $rootTag = shift;
	#todo sanity

	my @tagsets = GetList('tagset/' . $rootTag);
	my $html = '';

	my $somethingWasFound = 0;

	my @tagCountsArray = SqliteQueryHashRef("SELECT vote_value, COUNT(*) vote_count FROM vote GROUP BY vote_value");
	shift @tagCountsArray; # remove the first array item, which contains header
	my %tagCounts;
	for my $tagCount (@tagCountsArray) {
		my %tagCount = %{$tagCount};
		$tagCounts{$tagCount{'vote_value'}} = $tagCount{'vote_count'};
	}

	for my $tagset (@tagsets) {
		my $queryTagsetCount = "
			SELECT
				COUNT(file_hash) FROM vote
			WHERE
				vote_value IN(
					SELECT tag FROM tag_parent WHERE tag_parent = ?
				)
			GROUP BY
				file_hash
		";

		my @queryTagsetCountParams;
		push @queryTagsetCountParams, $tagset;
		my $tagsetCount = SqliteGetValue($queryTagsetCount, @queryTagsetCountParams);

		my $tagsetHeader = '<h3>' . GetTagLink($tagset, $tagsetCount) . '</h3>';
		my @tags = split("\n", GetTemplate('tagset/'.$tagset));
		my $comma = '';

		for my $tag (@tags) {
			if ($tagCounts{$tag}) {
				$html .= $tagsetHeader;
				$html .= $comma;
				$html .= GetTagLink($tag, $tagCounts{$tag});
				$comma = '; ';
				$tagsetHeader = '';

				$somethingWasFound = 1;
			}
		}

		$html .= '<br>';
	}

	if (!$somethingWasFound) {
		$html = '<p>This space reserved for future content.</p>';
	}

	return $html;
} # GetTagCategoriesDialog()

sub GetWelcomePage {
	my $welcomePage =
		GetPageHeader('welcome') .
			GetDialogX(GetTemplate('html/page/welcome.template'), 'Welcome') .
			GetDialogX(GetTagCategoriesDialog('suggest'), 'Browse') .
			GetDialogX(GetTemplate('html/page/create_new.template'), 'Create New') .
			GetQueryAsDialog('top', 'Top Items') .
			GetPageFooter('welcome');

	if (GetConfig('admin/js/enable')) {
		$welcomePage = InjectJs($welcomePage, qw(avatar settings profile utils timestamp clock fresh table_sort))
	}

	return $welcomePage;
}

sub GetClonePage {
	my $page =
		GetPageHeader('clone') .
		GetDialogX(GetTemplate('html/page/clone_instructions.template'), 'Cloning Instructions') .
		GetPageFooter('clone')
	;
	if (GetConfig('admin/js/enable')) {
		$page = InjectJs($page, qw(avatar settings profile utils timestamp clock fresh table_sort));
	}
	return $page;
}

PutHtmlFile(
	'welcome.html',
	GetWelcomePage()
);

PutHtmlFile(
	'index.html',
	GetWelcomePage()
);

PutHtmlFile(
	'clone.html',
	GetClonePage()
);

1;