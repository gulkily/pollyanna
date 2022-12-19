#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	my $html =
		GetPageHeader('welcome') .
		GetWindowTemplate(GetTemplate('html/page/welcome.template'), 'Welcome') .
		GetWindowTemplate(GetTemplate('html/form/enter.template'), 'Enter') .
		#GetWindowTemplate(GetTemplate('html/form/emergency.template'), 'Emergency Contact Form') .
		'<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' .
		GetWriteForm() .
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

