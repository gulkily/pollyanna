#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDialogToolboxItemPublish { # $filePath, $fileHash = '' ; returns dialog with links to publish to other instances
	my $filePath = shift;
	my $fileHash = shift;

	if (!IsSaneFilename($filePath)) {
		WriteLog('GetDialogToolboxItemPublish: warning: $filePath failed sanity check! caller = ' . join(',', caller));
		return '';
	}

	if (!IsItem($fileHash)) {
		WriteLog('GetDialogToolboxItemPublish: warning: $fileHash failed sanity check! caller = ' . join(',', caller));
		return '';
	}

	if (!file_exists($filePath)) {
		WriteLog('GetDialogToolboxItemPublish: warning: $filePath does not exist! caller = ' . join(',', caller));
		return '';
	}

	my $htmlToolbox = '';

	my $urlParamFullText = '';

	$urlParamFullText = GetFile($filePath);
	$urlParamFullText = uri_escape($urlParamFullText);
	#$urlParamFullText = uri_encode($urlParamFullText);
	$urlParamFullText = str_replace('+', '%2b', $urlParamFullText);
	$urlParamFullText = str_replace('#', '%23', $urlParamFullText);
	#todo other chars like ? & =


	$htmlToolbox .= "<p>";
	#$htmlToolbox .= '<b>Publish:</b><br>';

	#$htmlToolbox = GetPublishButton('localhost:2784', $file{'file_path'});

	$htmlToolbox .=
		'<a href="http://localhost:2784/post.html?comment=' .
			$urlParamFullText .
			'">' .
			'localhost:2784' .
			'</a><br>' . "\n";

	$htmlToolbox .=
		'<a href="http://localhost:31337/post.html?comment=' .
			$urlParamFullText .
			'">' .
			'diary' .
			'</a><br>' . "\n";

	$htmlToolbox .=
		'<a href="http://www.rocketscience.click/post.html?comment=' .
			$urlParamFullText .
			'">' .
			'RocketScience' .
			'</a><br>' . "\n";

	$htmlToolbox .=
		'<a href="http://www.yavista.com/post.html?comment=' .
			$urlParamFullText .
			'">' .
			'Yavista' .
			'</a><br>' . "\n";

	$htmlToolbox .=
		'<a href="http://qdb.us/post.html?comment=' .
			$urlParamFullText .
			'">' .
			'qdb.us' .
			'</a><br>' . "\n";
	;

	my $htmlToolboxDialog = GetDialogX($htmlToolbox, 'Publish');

	return $htmlToolboxDialog;
} # GetDialogToolboxItemPublish()

1;