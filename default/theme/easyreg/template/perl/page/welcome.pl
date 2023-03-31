#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	my $html =
		GetPageHeader('welcome') .
		GetDialogX(GetTemplate('html/page/welcome.template'), ' ') . # this is a bit of a hack, should really not be a titlebar
		GetDialogX(GetTemplate('html/page/content.template'), 'Please Share') .
		GetDialogX(GetTemplate('html/page/rules.template'), 'Ground Rules') .
		GetDialogX(GetTemplate('html/page/privacy.template'), 'Privacy') .
		GetDialogX(GetTemplate('html/form/enter.template'), 'Create Profile') .
		GetDialogX(GetTemplate('html/form/guest.template'), 'Guest') .
		#GetDialogX(GetTemplate('html/form/emergency.template'), 'Emergency Contact Form') .
		'<span class=advanced>' . GetWriteDialog() . '</span>' .
		GetPageFooter('welcome')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils profile write puzzle clock easyreg settings);
		$html = InjectJs($html, @js);

		$html = AddAttributeToTag($html, 'input id=member', 'onclick', "if (window.EasyMember) { this.value = 'Meditate...'; setTimeout('EasyMember()', 50); return false; }");

		# this is supposed to add a timestamp field to the guest form
		# to prevent the form response from being cached
		# something is broken here though
		# $html = AddAttributeToTag($html, 'input id=guest', 'onclick', "
		# 	if (document.createElement && document.formRegisterGuest) {
		# 		var d = new Date();
		# 		var n = d.getTime();
		# 		var inputTime = document.createElement('input');
		# 		inputTime.setAttribute('type', 'hidden');
		# 		inputTime.setAttribute('name', 'clicktime');
		# 		inputTime.setAttribute('value', n);
		# 		document.formRegisterGuest.appendChild(inputTime);
		# 	}
		# ");
	}

	return $html;
} # GetWelcomePage()

1;

