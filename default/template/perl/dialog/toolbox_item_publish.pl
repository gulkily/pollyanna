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
	$urlParamFullText = uri_escape_utf8($urlParamFullText);
	# $urlParamFullText = uri_escape_utf8($urlParamFullText); #todo do this if ascii_only
	#$urlParamFullText = uri_encode($urlParamFullText);
	$urlParamFullText = str_replace('+', '%2b', $urlParamFullText);
	$urlParamFullText = str_replace('#', '%23', $urlParamFullText);
	#todo other chars like ? & =


	$htmlToolbox .= "<p>";
	#$htmlToolbox .= '<b>Publish:</b><br>';

	#$htmlToolbox = GetPublishButton('localhost:2784', $file{'file_path'});

	my @neighbors = GetConfigListAsArray('neighbor');

	if (!@neighbors) {
		WriteLog('GetDialogToolboxItemPublish: warning: @neighbors is empty! using default hard-coded list; caller = ' . join(',', caller));
		@neighbors = qw(localhost:2784 localhost:31337 www.hypercode.com www.rocketscience.click www.yavista.com qdb.us ilyagulko.com shitmyself.com);
	}

	for my $neighbor (@neighbors) {
		my $neighborUrl = 'http://' . $neighbor . '/post.html?comment=' . $urlParamFullText;
		my $neighborName = $neighbor;
		if (index($neighborName, ':') != -1) {
			# if no other neighbor has the same hostname, remove the port number, otherwise leave it alone
			my $otherNeighborHasSameHostname = 0;
			for (@neighbors) {
                if (index($_, $neighborName) != -1) {
                    # do nothing
                } else {
                    $otherNeighborHasSameHostname = 1;
                }
            }
            if ($otherNeighborHasSameHostname) {
                # do nothing
            } else {
                $neighborName = substr($neighborName, 0, index($neighborName, ':'));
            }


		} else {
			$neighborName = $neighborName;
		}
		if (index($neighborName, 'www.') == 0) {
			$neighborName = substr($neighborName, 4);
		} else {
			# do nothing
		}

		$htmlToolbox .=
			'<a href="http://' .
				$neighbor .
				'/post.html?comment=' .
				$urlParamFullText .
				'">' .
				$neighborName .
				'</a><br>' . "\n"
		;
	}

	my $htmlToolboxDialog = GetDialogX($htmlToolbox, 'Publish');
	# publishtoolbox toolbox

	return $htmlToolboxDialog;
} # GetDialogToolboxItemPublish()

1;
