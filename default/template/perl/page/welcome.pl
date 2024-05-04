#!/usr/bin/perl -T

sub GetWelcomePage {
	WriteLog('GetWelcomePage()');
	my $isNewInstall = GetConfig('setting/admin/welcome_install_message') ? 1 : 0;
	my $newInstallDialog = '';
	if ($isNewInstall) {
		WriteLog('GetWelcomePage() isNewInstall = TRUE');
		$newInstallDialog = GetDialogX(GetTemplate('html/page/welcome_install.template'), 'New Installation Message');
	}

	my $welcomePage =
		GetPageHeader('welcome') .
			GetDialogX(GetTemplate('html/page/welcome.template'), 'Welcome') .
			$newInstallDialog .
			#GetWriteDialog() .
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
