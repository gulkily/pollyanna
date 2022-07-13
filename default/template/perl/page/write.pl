#!/usr/bin/perl -T

use strict;
use warnings;

sub GetWritePage { # returns html for write page
	# $writePageHtml stores html page output
	my $writePageHtml = "";

	my $title = "Write";
	my $titleHtml = "Write";

	#	my $itemCount = DBGetItemCount();
	#	my $itemLimit = GetConfig('number/item_limit');
	#	if (!$itemLimit) {
	#		$itemLimit = 9000;
	#	}

	$writePageHtml = GetPageHeader('write');
	$writePageHtml .= GetTemplate('html/maincontent.template');

	my $writeForm = GetWriteForm();

	WriteLog('GetWriteForm: js is on, adding write_options.template');
	my $writeOptions =
		'<span class=advanced>' .
		AddAttributeToTag(
			GetWindowTemplate(GetTemplate('html/form/write/write_options.template'), 'Options'),
			'a href="/frame.html"',
			'accesskey',
			GetAccessKey('Keyboard')
		).
		'</span>'
	; #todo this is a hack

	$writePageHtml .= '<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>'; #todo
	$writePageHtml .= $writeForm;
	$writePageHtml .= $writeOptions;
	$writePageHtml .= '</form>'; #todo

	#if (GetConfig('admin/js/enable')) {
	#	$writePageHtml .= GetWindowTemplate(GetTemplate('html/form/writing.template'), 'Options');
	#}
	#
	# if (GetConfig('setting/html/reply_cart')) {
	# 	require_once('dialog/reply_cart.pl');
	# 	$writePageHtml .= GetReplyCartDialog(); # GetWriteDialog()
	# } # if (GetConfig('setting/html/reply_cart'))

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/zalgo')) {
		$writePageHtml .= GetWindowTemplate(GetTemplate('html/form/write/write_zalgo_button.template'), 'Zalgo');
	}

	#	if (defined($itemCount) && defined($itemLimit) && $itemCount) {
	#		my $itemCounts = GetTemplate('html/form/itemcount.template');
	#		$itemCounts =~ s/\$itemCount/$itemCount/g;
	#		$itemCounts =~ s/\$itemLimit/$itemLimit/g;
	#	}
	#
	$writePageHtml .= GetPageFooter('write');

	if (GetConfig('admin/js/enable')) {
		# $writePageHtml = str_replace(
		# 	'<span id=spanInputOptions></span>',
		# 	'<span id=spanInputOptions>
		# 		<noscript>More input options available with JavaScript</noscript>
		# 	</span>',
		# 	$writePageHtml
		# );
		# I decided against this approach
		# Because displaying the links with appendChild()
		# would exclude many browsers who would otherwise support keyboard

		my @js = qw(settings avatar write profile utils timestamp);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php'; # write.html
		}
		#if (GetConfig('admin/upload/enable')) {
		#	push @js, 'upload';
		#	push @js, 'paste';
		#}
		if (GetConfig('admin/token/puzzle')) {
			push @js, 'puzzle';
			# push @js, 'puzzle', 'sha512';
		}
		if (GetConfig('admin/js/translit')) {
			if (GetConfig('admin/html/ascii_only')) {
				WriteLog('GetWritePage: warning: admin/js/translit conflicts with admin/html/ascii_only');
			} else {
				push @js, 'translit';
			}
		}

		if (GetConfig('html/reply_cart')) {
			push @js, 'reply_cart';
		}

		if (GetConfig('admin/js/zalgo')) {
			if (GetConfig('admin/html/ascii_only')) {
				WriteLog('GetWritePage: warning: admin/js/zalgo conflicts with admin/html/ascii_only');
			} else {
				push @js, 'lib/zalgo';
			}
		}

		$writePageHtml = InjectJs($writePageHtml, @js);
	} # GetConfig('admin/js/enable')

	return $writePageHtml;
} # GetWritePage()

1;
