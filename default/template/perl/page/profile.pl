#!/usr/bin/perl -T

use strict;
use warnings;

sub GetProfileDialog {
# sub GetProfileForm {
	my $profileWindowContents = GetTemplate('html/form/profile.template');

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/openpgp')) {
		#my $gpg2Choices = GetTemplate('html/gpg2.choices.template');
		#$profileWindowContents =~ s/\$gpg2Algochoices/$gpg2Choices/;

		$profileWindowContents = AddAttributeToTag($profileWindowContents, 'input id=btnRegister', 'onclick', "if (window.btnRegister_Click) { return btnRegister_Click(this); }");
	} else {
		$profileWindowContents =~ s/\$gpg2Algochoices//;
	}

	my $profileWindow = GetDialogX(
		$profileWindowContents,
		'Profile',
	);

	return $profileWindow;
} # GetProfileDialog()

sub GetProfilePage { # returns profile page (allows sign in/out)
#not the author page

#called by page.pl
	my $txtIndex = "";
	my $title = "Profile";
	my $titleHtml = "Profile";

	if (GetConfig('admin/js/enable') || GetConfig('admin/php/enable')) {
		# js or php is required for profiles to work

		$txtIndex = GetPageHeader('identity');
		$txtIndex .= GetTemplate('html/maincontent.template');

		# my $profileWindowContents = GetTemplate('html/form/profile.template');
		#
		# if (GetConfig('admin/gpg/use_gpg2')) {
		# 	my $gpg2Choices = GetTemplate('html/gpg2.choices.template');
		# 	$profileWindowContents =~ s/\$gpg2Algochoices/$gpg2Choices/;
		# } else {
		# 	$profileWindowContents =~ s/\$gpg2Algochoices//;
		# }
		#
		my $profileWindow = GetProfileDialog();
		#my $tosWindow = GetTosDialog();
		$txtIndex .= $profileWindow;

		$txtIndex .=
			'<span class=advanced><form name=formSelectKey>' .
			GetDialogX(GetTemplate('html/select_key.template'), 'Keychain') .
			'</form></span>'
		;

		#$txtIndex .= $tosWindow;
		$txtIndex .= GetPageFooter('identity');

		if (GetConfig('admin/js/enable')) {
			$txtIndex = InjectJs($txtIndex, qw(avatar settings utils profile timestamp));
		} else {
			# js is disabled
		}
	} else {
		# profile feature is not available

		$txtIndex = GetPageHeader('identity');
		$txtIndex .= GetTemplate('html/maincontent.template');

		my $profileWindowContents = GetTemplate('html/form/profile_no.template');
		my $profileWindow = GetDialogX(
			$profileWindowContents,
			'Profile'
		);

		$txtIndex .= $profileWindow;
		$txtIndex .= GetPageFooter('identity');
	}

	# this is an alternative way of including the scripts, replaced by javascript-based way
	# ProfileOnLoad has the alternative way, but this way works too, and may have some unknown benefits
	#	my $scriptsInclude = '<script src="/openpgp.js"></script><script src="/crypto.js"></script>';
	#	$txtIndex =~ s/<\/body>/$scriptsInclude<\/body>/;

	return $txtIndex;
} # GetProfilePage()

1;