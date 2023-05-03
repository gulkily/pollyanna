#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetTosDialog {
	my $tosText = GetString('tos');
	#$tosText = str_replace("\n", '<br>', $tosText); #todo improve this

	$tosText = '<p class=txt>' . $tosText . '</p>';
	#$tosText .= '<p><a href="/post.html?comment=tos">[Do You Agree?]</a></p>';
	my $tosWindow = GetDialogX(
		$tosText,
		'Terms of Service',
	);
	#	my @tosItems
	return $tosWindow;
}

1;