#!/usr/bin/perl -T

use strict;
use warnings;

sub GetUploadDialog { # upload window for upload page
	if (!GetConfig('admin/upload/enable')) {
		WriteLog('GetUploadDialog: warning: called while admin/upload/enable was false');
		return '';
	}

	my $template = shift;
	if (!$template) {
		$template = 'html/form/upload.template';
	}
	my $title = 'Upload';
	if (index(lc($template), 'multi') != -1) {
		$title = 'Upload Multiple Files';
	}

	my $uploadForm = GetTemplate($template);
	if (GetConfig('admin/js/enable')) {
		# $uploadForm = AddAttributeToTag($uploadForm, 'input name=uploaded_file', 'onchange', "if (document.upload && document.upload.submit && document.upload.submit.value == 'Upload') { document.upload.submit.click(); }");
		# this caused back button breaking
		$uploadForm = AddAttributeToTag($uploadForm, 'input name=uploaded_file', 'onchange', "if (window.UploadedFileOnChange) { UploadedFileOnChange(this); }");
		$uploadForm = AddAttributeToTag($uploadForm, 'input name="uploaded_file[]"', 'onchange', "if (window.UploadedFileMultiOnChange) { UploadedFileMultiOnChange(this); }");
		$uploadForm = AddAttributeToTag($uploadForm, 'input name=submit', 'onclick', "this.value='Meditate...';");
	}
	my $allowFiles = GetConfig('admin/image/allow_files');

	$allowFiles = str_replace("\n", ' ', $allowFiles);

	WriteLog('GetUploadDialog: $allowFiles = ' . $allowFiles);

	$uploadForm = str_replace('<span id=allowFiles></span>', '<span id=allowFiles>' . $allowFiles . '</span>', $uploadForm);

	my $uploadWindow = GetWindowTemplate($uploadForm, $title);
	return $uploadWindow;
} # GetUploadDialog()

sub GetUploadPage { # returns html for upload page
	my $html = '';
	my $title = 'Upload';

	if (GetConfig('admin/php/enable') && GetConfig('admin/upload/enable')) {
		my $template = shift;
		if (!$template) {
			$template = 'html/form/upload.template';
		}
		$html .= GetPageHeader('upload');
		$html .= GetTemplate('html/maincontent.template');
		$html .= GetUploadDialog($template);
		$html .= GetPageFooter('upload');

		if (GetConfig('admin/js/enable')) {
			$html = InjectJs($html, qw(utils settings avatar profile upload paste));
		}

	} else {
		$html .= GetPageHeader('upload');
		$html .= GetTemplate('html/maincontent.template');
		$html .= GetWindowTemplate(GetTemplate('html/form/upload_no.template'), $title);
		# $html .= GetWindowTemplate('<p>Upload feature is not available. Apologies.</p>', $title);
		$html .= GetPageFooter('upload');
		if (GetConfig('admin/js/enable')) {
			$html = InjectJs($html, qw(utils settings avatar profile));
		}
	}

	return $html;
} # GetUploadPage()

1;