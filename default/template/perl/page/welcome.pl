#!/usr/bin/perl -T

sub GetWelcomePage {
	my $welcomePage =
		GetPageHeader('welcome') .
			GetWindowTemplate(GetTemplate('html/page/welcome.template'), 'Welcome') .
			#'<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' .
			#GetWriteForm() .
			#'</form>' . #todo unhack this
			#GetProfileDialog() .
			#GetQueryAsDialog('threads', 'Threads') .
			#GetQueryAsDialog('tags_welcome', 'Tags') .
			GetPageFooter('welcome');

	if (GetConfig('admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php'; # write.html
		}
		$welcomePage = InjectJs($welcomePage, @js)

	}

	return $welcomePage;
}

1;
