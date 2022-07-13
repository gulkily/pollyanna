#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDataPage { # writes /data.html (and zip files if needed) # MakeZip txt.zip
	# sub MakeDataPage {
	# sub WriteDataPage {
	#This makes the zip file as well as the data.html page that lists its size
	WriteLog('GetDataPage() called');

	my $zipInterval = 1;
	my $touchZip = GetCache('touch/zip');
	if (!$touchZip) {
		$touchZip = 0;
	}
	WriteLog('GetDataPage: $zipInterval = ' . $zipInterval . '; $touchZip = ' . $touchZip);

	if (!$touchZip || (GetTime() - $touchZip) > $zipInterval) {
		WriteLog('GetDataPage: Making zip files...');
		state $HTMLDIR = GetDir('html');
		WriteLog('GetDataPage: $HTMLDIR = ' . $HTMLDIR);

		# zip -qr foo.zip somefile
		# -q for quiet
		# -r for recursive

		system("git archive --format zip --output $HTMLDIR/tree.tmp.zip master");
		rename("$HTMLDIR/tree.tmp.zip", "$HTMLDIR/tree.zip");

		system("zip -qr $HTMLDIR/image.tmp.zip $HTMLDIR/image/");
		rename("$HTMLDIR/image.tmp.zip", "$HTMLDIR/image.zip");

		system("zip -qr $HTMLDIR/txt.tmp.zip $HTMLDIR/txt/ $HTMLDIR/chain.log");
		rename("$HTMLDIR/txt.tmp.zip", "$HTMLDIR/txt.zip");

		system("zip -qr $HTMLDIR/index.sqlite3.zip.tmp cache/" . GetMyCacheVersion() . "/index.sqlite3");
		rename("$HTMLDIR/index.sqlite3.zip.tmp", "$HTMLDIR/index.sqlite3.zip");

		PutCache('touch/zip', GetTime());
	} else {
		WriteLog("Zip file was made less than $zipInterval ago, too lazy to do it again");
	}
	my $dataPage = GetPageHeader('data');
	$dataPage .= GetTemplate('html/maincontent.template');
	my $dataPageContents = GetTemplate('html/data.template');

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

	$dataPageContents = str_replace('<span id=sizeTxtZip></span>', '<span id=sizeTxtZip>' . $sizeTxtZip . '</span>', $dataPageContents);
	$dataPageContents = str_replace('<span id=sizeImageZip></span>', '<span id=sizeImageZip>' . $sizeImageZip . '</span>', $dataPageContents);
	$dataPageContents = str_replace('<span id=sizeSqliteZip></span>', '<span id=sizeSqliteZip>' . $sizeSqliteZip . '</span>', $dataPageContents);

	#$dataPageContents =~ s/\$sizeTxtZip/$sizeTxtZip/g;
	#$dataPageContents =~ s/\$sizeImageZip/$sizeImageZip/g;
	#$dataPageContents =~ s/\$sizeSqliteZip/$sizeSqliteZip/g;

	$dataPageContents = $dataPageContents;

	my $dataPageWindow = GetWindowTemplate(
		$dataPageContents,
		'Data'
	);

	$dataPage .= $dataPageWindow;
	$dataPage .= GetPageFooter('data');
	$dataPage = InjectJs($dataPage, qw(settings avatar profile utils));

	return $dataPage;
} # GetDataPage()

1;