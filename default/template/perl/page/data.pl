#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDataDialog {
	WriteLog('GetDataDialog()');

	MakeDataZips();

	my $dialog = GetTemplate('html/data.template');

	state $HTMLDIR = GetDir('html');
	my $sizeTxtZip = -s "$HTMLDIR/txt.zip";
	my $sizeImageZip = -s "$HTMLDIR/image.zip";
	my $sizeSqliteZip = -s "$HTMLDIR/index.sqlite3.zip";

	$sizeTxtZip = GetFileSizeWidget($sizeTxtZip);
	if (!$sizeTxtZip) {
		$sizeTxtZip = 0;
	}

	$sizeImageZip = GetFileSizeWidget($sizeImageZip);
	if (!$sizeImageZip) {
		$sizeImageZip = 0;
	}

	$sizeSqliteZip = GetFileSizeWidget($sizeSqliteZip);
	if (!$sizeSqliteZip) {
		$sizeSqliteZip = 0;
	}

	$dialog = str_replace('<span id=sizeTxtZip></span>', '<span id=sizeTxtZip>' . $sizeTxtZip . '</span>', $dialog);
	$dialog = str_replace('<span id=sizeImageZip></span>', '<span id=sizeImageZip>' . $sizeImageZip . '</span>', $dialog);
	$dialog = str_replace('<span id=sizeSqliteZip></span>', '<span id=sizeSqliteZip>' . $sizeSqliteZip . '</span>', $dialog);

	#$dialog =~ s/\$sizeTxtZip/$sizeTxtZip/g;
	#$dialog =~ s/\$sizeImageZip/$sizeImageZip/g;
	#$dialog =~ s/\$sizeSqliteZip/$sizeSqliteZip/g;

	my $dialogWithFrame = GetDialogX(
		$dialog,
		'Data'
	);

	return $dialogWithFrame;
} # GetDataDialog()

sub MakeDataZips {
	my $zipInterval = 1;
	my $touchZip = GetCache('touch/zip');
	if (!$touchZip) {
		$touchZip = 0;
	}
	WriteLog('MakeDataZips: $zipInterval = ' . $zipInterval . '; $touchZip = ' . $touchZip);

	state $zipExists = !!`which zip`;
	state $gitExists = !!`which git`;

	# option:
	# if zip or git not in env, it could cause a problem
	#state $zipExists = !!`which zip 2>/dev/null`;
	#state $gitExists = !!`which git 2>/dev/null`;

	if (!$touchZip || (GetTime() - $touchZip) > $zipInterval) {
		WriteLog('MakeDataZips: Making zip files...');
		state $HTMLDIR = GetDir('html');
		WriteLog('MakeDataZips: $HTMLDIR = ' . $HTMLDIR);

		# zip -qr foo.zip somefile
		# -q for quiet
		# -r for recursive

		if ($gitExists) {
			system("git archive --format zip --output $HTMLDIR/tree.tmp.zip master");
			rename("$HTMLDIR/tree.tmp.zip", "$HTMLDIR/tree.zip");
		} else {
			WriteLog('MakeDataZips: warning: $gitExists was FALSE; caller = ' . join(',', caller));
		}

		if ($zipExists) {
			system("zip -qr $HTMLDIR/image.tmp.zip $HTMLDIR/image/");
			rename("$HTMLDIR/image.tmp.zip", "$HTMLDIR/image.zip");

			system("zip -qr $HTMLDIR/txt.tmp.zip $HTMLDIR/txt/ $HTMLDIR/chain.log");
			rename("$HTMLDIR/txt.tmp.zip", "$HTMLDIR/txt.zip");

			system("zip -qr $HTMLDIR/index.sqlite3.zip.tmp cache/" . GetMyCacheVersion() . "/index.sqlite3");
			rename("$HTMLDIR/index.sqlite3.zip.tmp", "$HTMLDIR/index.sqlite3.zip");

			PutCache('touch/zip', GetTime());
		} else {
			WriteLog('MakeDataZips: warning: $zipExists was FALSE; caller = ' . join(',', caller));
			return '';
		}
	} else {
		WriteLog("MakeDataZips: Zip file was made less than $zipInterval ago, too lazy to do it again");
	}
} # MakeDataZips()

sub GetDataPage { # writes /data.html (and zip files if needed) # MakeZip txt.zip
	# sub MakeDataPage {
	# sub WriteDataPage {
	#This makes the zip file as well as the data.html page that lists its size
	WriteLog('GetDataPage() called');

	my $dataPage = GetPageHeader('data');
	$dataPage .= GetTemplate('html/maincontent.template');

	my $dataDialog = GetDataDialog();

	$dataPage .= $dataDialog;
	$dataPage .= GetPageFooter('data');
	$dataPage = InjectJs($dataPage, qw(settings avatar profile utils));

	return $dataPage;
} # GetDataPage()

1;