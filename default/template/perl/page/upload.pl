#!/usr/bin/perl -T

use strict;
use warnings;

require_once('dialog/upload.pl');

sub GetPasteDialog { # paste dialog for upload page
#todo what about text pasting?
	if (!GetConfig('setting/admin/upload/enable')) {
		WriteLog('GetPasteDialog: warning: called while admin/upload/enable was false');
		return '';
	}

	if (!GetConfig('setting/admin/js/enable')) {
		WriteLog('GetPasteDialog: warning: called while admin/js/enable was false');
		return '';
	}

	my $template = shift;
	if (!$template) {
		$template = 'html/form/paste.template';
	}
	my $title = 'Paste';

	my $pasteForm = GetTemplate($template);

	my $pasteWindow = GetDialogX($pasteForm, $title);
	return $pasteWindow;
} # GetPasteDialog()

sub GetUploadPage { # returns html for upload page
	my $html = '';
	my $title = 'Upload';

	if (GetConfig('setting/admin/php/enable') && GetConfig('setting/admin/upload/enable')) {
		my $template = shift;
		if (!$template) {
			$template = 'html/form/upload.template';
		}
		$html .= GetPageHeader('upload');
		$html .= GetTemplate('html/maincontent.template');
		$html .= GetUploadDialog($template);
		$html .= GetPasteDialog();
		$html .= GetPageFooter('upload');

		if (GetConfig('setting/admin/js/enable')) {
			$html = InjectJs($html, qw(utils settings avatar profile upload paste));
		}

	} else {
		$html .= GetPageHeader('upload');
		$html .= GetTemplate('html/maincontent.template');
		$html .= GetDialogX(GetTemplate('html/form/upload_no.template'), $title);
		# $html .= GetDialogX('<p>Upload feature is not available. Apologies.</p>', $title);
		$html .= GetPageFooter('upload');
		if (GetConfig('setting/admin/js/enable')) {
			$html = InjectJs($html, qw(utils settings avatar profile));
		}
	}

	return $html;
} # GetUploadPage()

1;
