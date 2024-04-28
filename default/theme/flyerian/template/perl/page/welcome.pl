#!/usr/bin/perl -T

sub GetWelcomePage {
	require_once('page/profile.pl');
	my $welcomePage =
		GetPageHeader('welcome') .
			GetDialogX(GetTemplate('html/page/welcome.template'), 'Welcome') .
			GetDialogX(GetTemplate('html/page/welcome_token.template'), 'Token') .
			GetWriteDialog() .
			#GetProfileDialog() .
			#GetQueryAsDialog('threads', 'Threads') .
			#GetQueryAsDialog('tags_welcome', 'Tags') .
			GetPageFooter('welcome');

	if (GetConfig('setting/admin/js/enable')) {
		my @js = qw(avatar puzzle settings profile utils timestamp clock fresh table_sort voting write);
		if (GetConfig('setting/admin/php/enable')) {
			push @js, 'write_php'; # write.html
		}
		$welcomePage = InjectJs($welcomePage, @js)

	}

	return $welcomePage;
}

1;
