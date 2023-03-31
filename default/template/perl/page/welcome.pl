#!/usr/bin/perl -T

sub GetWelcomePage {
	my $welcomePage =
		GetPageHeader('welcome') .
			GetDialogX(GetTemplate('html/page/welcome.template'), 'Welcome') .
			#GetWriteDialog() .
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
