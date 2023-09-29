#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetUploadDialog { # $template, $replyTo ; upload dialog for upload page
    if (!GetConfig('admin/upload/enable')) {
	WriteLog('GetUploadDialog: warning: called while admin/upload/enable was false');
	return '';
    }

	#todo rename $template to $templatePath or $templateName

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

		if (index($uploadForm, '$replyTo') != -1) {
			my $replyTo = shift;
			#todo sanity check
			$uploadForm = str_replace('$replyTo', $replyTo, $uploadForm);
		}

		# single upload form
		$uploadForm = AddAttributeToTag($uploadForm, 'input name=uploaded_file', 'onchange', "if (window.UploadedFileOnChange) { UploadedFileOnChange(this); }");

		# multi upload form
		$uploadForm = AddAttributeToTag($uploadForm, 'input name="uploaded_file[]"', 'onchange', "if (window.UploadedFileMultiOnChange) { UploadedFileMultiOnChange(this); }");

		# both forms
		$uploadForm = AddAttributeToTag($uploadForm, 'input name=submit', 'onclick', "this.value='Meditate...';");
    }
    my $allowFiles = GetConfig('admin/image/allow_files'); #imagetypes

    $allowFiles = str_replace("\n", ' ', $allowFiles);

    WriteLog('GetUploadDialog: $allowFiles = ' . $allowFiles);

    my @otherPossibleFiles = qw(perl python3 cpp zip);
    # my $allowedFiles = # for searching through code
    # my @allowedFiles = # for searching through code
    for my $possibleFile (@otherPossibleFiles) {
	if (GetConfig("admin/$possibleFile/enable")) {
	    if ($possibleFile eq 'perl') {
			$possibleFile = 'pl';
	    }
	    if ($possibleFile eq 'python3') {
			$possibleFile = 'py';
	    }
	    $allowFiles .= ' ' . $possibleFile;
	}
    }

    $uploadForm = str_replace(
		'<span id=allowFiles></span>',
		'<span id=allowFiles>' . $allowFiles . '</span>',
		$uploadForm
    );

    my $uploadWindow = GetDialogX($uploadForm, $title);
    return $uploadWindow;
} # GetUploadDialog()

1;