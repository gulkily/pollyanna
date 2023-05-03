#!/usr/bin/perl -T

use strict;
use warnings;

sub GetPostPage { # Target page for the submit page
	my $postPage =
		GetPageHeader('post') .
		GetTemplate('html/maincontent.template') .
		GetTemplate('html/page/post.template') . #todo this needs better detection if template path is missing
		GetPageFooter('post');

	$postPage = InjectJs($postPage, qw(settings avatar post));

	if (GetConfig('admin/js/enable')) {
		$postPage =~ s/<body /<body onload="makeRefLink();" /;
		$postPage =~ s/<body>/<body onload="makeRefLink();">/;
	}

	return $postPage;
}

1;

