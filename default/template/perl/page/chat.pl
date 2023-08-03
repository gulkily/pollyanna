#!/usr/bin/perl -T

use strict;
use warnings;

sub GetChatPage {
	WriteLog('GetChatPage: caller: ' . join(',', caller));

	my $html = '';

	my $writeDialog = GetWriteDialog();

	#todo the form tag needs a target change to point to the iframe

	$html =
		GetPageHeader('chat') .
		str_replace('target=_top', 'target=ifr', $writeDialog) . #todo this is a hack
		'<iframe name=ifr id=ifr height=20 width=20></iframe>' .
		GetTemplate('html/maincontent.template') .
		'</MAIN>' .
		GetPageFooter('chat');

	$html = InjectJs($html, qw(chat dragging settings));

	return $html;
}

1;
