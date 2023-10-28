#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetKeychainDialog { # returns empty string if requirements not met
	if (
		GetConfig('setting/admin/js/enable') &&
		GetConfig('setting/admin/js/openpgp') &&
		GetConfig('setting/admin/js/openpgp_keychain')
	) {
		my $html =
			'<form name=formSelectKey>' .
			GetDialogX(GetTemplate('html/select_key.template'), 'Keychain') .
			'</form>'
		;
		return $html;
	}

	#return '<!-- GetKeychainDialog: warning: requirements not met -->'; #todo
	return '<!-- GetKeychainDialog: warning: requirements not met -->'; #todo
}

sub GetSessionPage { # returns session page
	#require_once('dialog/query_as_dialog.pl');
	require_once('page/profile.pl');
	#todo if this fails, it is only a warning in log.log/

	my $requirementsMet = 0;
	my $requirementsMessage = '';
	if (GetConfig('admin/js/enable') || GetConfig('admin/php/enable')) {
		#WriteLog('GetSessionPage: good');
		$requirementsMet = 1;
	} else {
		WriteLog('GetSessionPage: warning: js or php is required for profiles to work');
		$requirementsMessage = GetDialogX('js or php is required for profiles to work');
	}

	my $html =
		GetPageHeader('session') .
		GetTemplate('html/maincontent.template') .
		GetProfileDialog() .
		GetKeychainDialog() .
		GetQueryAsDialog('session', 'ActiveSessions') .
		GetQuerySqlDialog('session') .
		GetPageFooter('session')
	;

	if (GetConfig('admin/js/enable')) {
		$html = InjectJs($html, qw(avatar settings utils profile timestamp));
	} else {
		# js is disabled
	}

	# this is an alternative way of including the scripts, replaced by javascript-based way
	# ProfileOnLoad has the alternative way, but this way works too, and may have some unknown benefits
	#	my $scriptsInclude = '<script src="/openpgp.js"></script><script src="/crypto.js"></script>';
	#	$txtIndex =~ s/<\/body>/$scriptsInclude<\/body>/;

	return $html;
} # GetSessionPage()

return 1;
