#!/usr/bin/perl -T

use strict;
use warnings;

sub GetChatPage {
	WriteLog('GetChatPage: caller: ' . join(',', caller));

	my $html = '';

	my $writeForm = GetWriteForm();

	$html =
		GetPageHeader('chat') .

		'<form action="/post.html" method=GET id=compose class=submit name=compose target=ifr>' .
		$writeForm .
		'</form>' .
		'<iframe name=ifr id=ifr height=20 width=20></iframe>' .

		GetTemplate('html/maincontent.template') .
		'</MAIN>' .
		GetPageFooter('chat');

	$html = InjectJs($html, qw(chat dragging settings));

	return $html;
}

1;
