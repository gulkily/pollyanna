#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	my $html =
		GetPageHeader('welcome') .
			GetWindowTemplate(GetTemplate('html/page/welcome.template'), '') . # this is a bit of a hack, should really not be a titlebar
			#GetWindowTemplate(GetTemplate('html/page/content.template'), 'Please Share') .
			#GetWindowTemplate(GetTemplate('html/page/rules.template'), 'Ground Rules') .
			#GetWindowTemplate(GetTemplate('html/page/privacy.template'), 'Privacy') .
			#GetWindowTemplate(GetTemplate('html/form/enter.template'), 'Create Profile') .
			#GetWindowTemplate(GetTemplate('html/form/guest.template'), 'Guest') .
			#GetWindowTemplate(GetTemplate('html/form/emergency.template'), 'Emergency Contact Form') .
			'<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' .
			GetWriteForm('Prayer') .
			'</form>' . #todo unhack this
			GetPageFooter('welcome')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils profile write puzzle clock easyreg settings);
		$html = InjectJs($html, @js);

		$html = AddAttributeToTag($html, 'input id=member', 'onclick', "if (window.EasyMember) { this.value = 'Meditate...'; setTimeout('EasyMember()', 50); return false; }");
	}

	return $html;
} # GetWelcomePage()

1;