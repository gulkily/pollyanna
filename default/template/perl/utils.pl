#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl -T
#
# utils.pl BEGIN
# utilities which haven't found their own file yet
# typically used by another file
# performs basic state validation whenever run
# 


$ENV{PATH}="/bin:/usr/bin"; #this is needed for -T to work
#gitbash: $ENV{PATH}="/bin:/usr/bin:/mingw64/bin"; #this is needed for -T to work
# /mingw64/bin is default location for gitbash on windows

#freebsd: $ENV{PATH}="/bin:/usr/bin:/usr/local/bin"; #this is needed for -T to work

use strict;
use warnings;
use utf8;
use 5.010;

use lib qw(lib); #needed for when we use included libs, such as on dreamhost
use POSIX 'strftime';
use Data::Dumper;
use Cwd qw(cwd);
use Digest::MD5 qw( md5_hex );
use File::Basename qw( fileparse );
use URI::Encode qw( uri_decode uri_encode );
use URI::Escape;
use Storable;
use Digest::SHA qw( sha1_hex );
use File::Spec qw( abs2rel );
use Time::HiRes qw(time);
use POSIX qw(strftime);

sub trim { # trims whitespace from beginning and end of $string
	my $s = shift;

	if (defined($s)) {
		$s =~ s/\s+$//g;
		$s =~ s/^\s+//g;
		return $s;
	}

	return;
} # trim()

require('./config/template/perl/config.pl');
# config.pl is required for looking up the paths using require_once()

#todo these may not need to be included for every load of utils.pl?
my @modules = qw(
	string
	cache
	html
	file
	sqlite
	gpgpg
	makepage
	token_defs
	page/calendar
	render_field
	resultset_as_dialog
	item_page
	format_message
	item_template
	widget
	index_text_file
);
#	get_template
# 	compare_page

for my $module (@modules) {
	require_once("$module.pl");
} # for my $module (@modules)

sub ensure_module { # $path ; ensures module is available under config/
# sub EnsureModule {
# the reason it is not EnsureModule() is to match reuquire_once(), 
# which is styled after PHP's function of the same name
	my $module = shift;
	chomp $module;

	if (!$module) {
		WriteLog('ensure_module: warning: module was FALSE, returning; caller = ' . join(',', caller));
		return 0;
	}

	WriteLog('ensure_module(' . $module . ')');

	state $path = GetDir('config') . '/template/perl/' . $module;
	my $localPath = './' . $module;
	my $moduleContent = GetTemplate("perl/$module");

	if (!-e $path) {
		if ($moduleContent) {
			PutConfig("template/perl/$path", $moduleContent);
		} else {
			WriteLog('ensure_module: warning: $moduleContent is FALSE; caller = ' . join(',', caller));
		}
	}

	if (!-e $localPath) {
		# PutFile($localPath, $moduleContent);
	}

	if (!$path || !-e $path) {
		WriteLog('ensure_module: warning sanity check failed');
		return 0;
	}
} # ensure_module()

sub require_once { # $path ; use require() unless already done
# sub RequireOnce {
# styled after PHP's require_once()
	my $module = shift;
	chomp $module;

	if (!$module) {
		WriteLog('require_once: warning sanity check failed; $module is FALSE; caller = ' . join(',', caller));
		return 0;
	}

	if ($module =~ m/^([a-zA-Z0-9_\/]+\.pl)$/) {
		# sanity check passed
		$module = $1;
	} else {
		WriteLog('require_once: warning: sanity check failed; $module = ' . $module);
		return '';
	}

	WriteLog('require_once(' . $module . ')');

	my $path = GetDir('config') . '/template/perl/' . $module;

	#todo my $path = GetTemplateFilePath("perl/$module");

	#todo state?

	ensure_module($module); # this ensures module is copied to config

	state %state;
	if (defined($state{$module})) {
		WriteLog('require_once: already required: ' . $module);
		return 0;
	}

	if (-e $path) {
		require $path;
		$state{$module} = 1;
		return 1;
	} else {
		WriteLog('require_once: warning: not found: $path = ' . $path . '; caller = ' . join(',', caller));
	}
} # require_once()

sub EscapeShellChars { # $string ; escapes string for including as parameter in shell command
	#todo #security this is still probably not safe and should be improved upon #security

	my $string = shift;
	chomp $string;

	$string =~ s/([\"|\$`\\])/\\$1/g;
	# chars are: " | $ ` \

	return $string;
} # EscapeShellChars()

sub GetDir { # $dirName ; returns path to special directory specified
# 'html' = html root
# 'script'
# 'txt'
# 'image'
# 'php'
# 'cache'
# 'config'
# 'default'
# 'log'

	my $dirName = shift;
	if (!$dirName) {
		WriteLog('GetDir: warning: $dirName missing');
		return '';
	}
	WriteLog('GetDir: $dirName = ' . $dirName);

	#my $scriptDir = cwd();
	#my $scriptDir = `pwd`;
	#$scriptDir = trim($scriptDir);

	state $scriptDir = trim(`pwd`); #todo replace this?

	if ($scriptDir =~ m/^([\.0-9a-zA-Z_\/]+)$/) {
		$scriptDir = $1;
		WriteLog('GetDir: $scriptDir sanity check passed');
	} else {
		WriteLog('GetDir: warning: sanity check failed on $scriptDir');
		return '';
	}
	WriteLog('GetDir: $scriptDir = ' . $scriptDir);

	if ($dirName eq 'script') {
		WriteLog('GetDir: return ' . $scriptDir);
		return $scriptDir;
	}

	if ($dirName eq 'html') {
		WriteLog('GetDir: return ' . $scriptDir . '/html');
		return $scriptDir . '/html';
	}

	if ($dirName eq 'php') {
		WriteLog('GetDir: return ' . $scriptDir . '/html');
		return $scriptDir . '/html';
	}

	if ($dirName eq 'txt') {
		WriteLog('GetDir: return ' . $scriptDir . '/html/txt');
		return $scriptDir . '/html/txt';
	}

	if ($dirName eq 'image') {
		WriteLog('GetDir: return ' . $scriptDir . '/html/image');
		return $scriptDir . '/html/image';
	}

	if ($dirName eq 'cache') {
		WriteLog('GetDir: return ' . $scriptDir . '/cache');
		return $scriptDir . '/cache';
	}

	if ($dirName eq 'config') {
		WriteLog('GetDir: return ' . $scriptDir . '/config');
		return $scriptDir . '/config';
	}

	if ($dirName eq 'default') {
		WriteLog('GetDir: return ' . $scriptDir . '/default');
		return $scriptDir . '/default';
	}

	if ($dirName eq 'log') {
		WriteLog('GetDir: return ' . $scriptDir . '/log');
		return $scriptDir . '/log';
	}

	WriteLog('GetDir: warning: fallthrough on $dirName = ' . $dirName);
	#todo WriteLog('GetDir: warning: fallthrough on $dirName = ' . $dirName . '; caller = ' . join(',', caller));
	return '';
} # GetDir()

#my $SCRIPTDIR = GetDir('script');
my $SCRIPTDIR = cwd();
if (!$SCRIPTDIR) {
	die ('Sanity check failed: $SCRIPTDIR is false!');
} # (!$SCRIPTDIR)

#my $SCRIPTDIR = cwd();
#if (!$SCRIPTDIR) {
#	die ('Sanity check failed: $SCRIPTDIR is false!');
#} # (!$SCRIPTDIR)


#my $HTMLDIR = $SCRIPTDIR . '/html';
#my $TXTDIR = $HTMLDIR . '/txt';
#my $IMAGEDIR = $HTMLDIR . '/txt';

sub WriteLog { # $text; Writes timestamped message to console (stdout) AND log/log.log
	my $text = shift;
	if (!$text) {
		$text = '(empty string)';
	}
	chomp $text;

	my $callerInfo = join(',', ((caller 1)[3]));
	$callerInfo = (split('::', $callerInfo))[1];

	if ($text && $callerInfo && (substr($text, 0, length($callerInfo)) ne $callerInfo)) {
		$text = $callerInfo . ': ' . $text;
	}

	if ($text && index(lc($text), 'warning') != -1) {
		if (index(lc($text), 'caller') == -1 && caller(1)) {
			#$text .= '; caller = ' . join(',', caller(1));
			#todo
		}
	}

	# Only if debug mode is enabled
	state $debugOn;
	#todo state $debugOn = -e 'config/debug'; #todo this path should not be hardcoded?
	my $timestamp = '';

	#todo if ($debugOn) {
	if ($debugOn || -e 'config/debug') {
		$timestamp = GetTime(); # set timestamp

		# adjust timestamp formatating to always have the same number
		# of digits after the decimal point, if included
		if ($timestamp =~ m/^[0-9]+\.[0-9]{1}$/) {
			$timestamp .= '0';
		}
		if ($timestamp =~ m/^[0-9]+\.[0-9]{2}$/) {
			$timestamp .= '0';
		}
		if ($timestamp =~ m/^[0-9]+\.[0-9]{3}$/) {
			$timestamp .= '0';
		}
		if ($timestamp =~ m/^[0-9]+\.[0-9]{4}$/) {
			$timestamp .= '0';
		}

		if (0) { # debug use milliseconds #featureflag
			#deprecated feature which gets differently formatted timestamp
			my $t = time;
			my $date = $timestamp;#strftime "%Y%m%d %H:%M:%S", localtime $t;
			$date .= sprintf ".%03d", ($t-int($t))*1000; # without rounding
			$timestamp = $date;
		}

		#AppendFile("log/log.log", $timestamp . " " . $text); # (happens later)
		$debugOn = 1; #verbose #quiet mode #quietmode #featureflag
	}

	my $charPrefix = '';

	if ($debugOn) { # this is the part which prints the snow #snow
		my $firstWord = substr($text, 0, index($text, ' '));
		if (index($firstWord, '(') != -1) {
			$firstWord = substr($firstWord, 0, index($firstWord, '('));
		}
		if (index($firstWord, ':') != -1) {
			$firstWord = substr($firstWord, 0, index($firstWord, ':'));
		}
		if ($firstWord ne 'WriteMessage') {
			# add one character to the snow

			my $firstWordHash = md5_hex($firstWord);
			my $firstWordHashFirstChar = substr($firstWordHash, 0, 1);
			$firstWordHashFirstChar =~ tr/0123456789abcdef/.;]\-,<">'+[:`_|+/; #brainfuckXL
			#todo use 2 characters of the hash, convert to 1 out of 64 characters

			WriteMessage($firstWordHashFirstChar); #todo make config/

			# FOR DEBUGGING PURPOSES
			#		print('$firstWord = ' . $firstWord . "\n");
			#		print('$firstWordHash = ' . $firstWordHash . "\n");
			#		print('$firstWordHashFirstChar = ' . $firstWordHashFirstChar . "\n");
			#		print("\n");

			if (!$firstWordHashFirstChar && !($firstWordHashFirstChar == 0)) {
				$firstWordHashFirstChar = '?';
			}

			$charPrefix = $firstWordHashFirstChar;
		} # if ($firstWord ne 'WriteMessage')
	} # if ($debugOn)

	if ($debugOn) {
		if ($charPrefix eq '') {
			$charPrefix = '$';
		}
		if (1) {
			#fully verbose
			AppendFile("log/log.log", $timestamp . " " . $charPrefix . " " . $text);
		} else {
			#only print first line
			$text = trim($text);
			if (index($text, "\n") != -1) {
				$text = substr($text, 0, index($text, "\n"));
			}
			if (length($text) >= 60) {
				#$text = substr($text, 0, 80);
			}
			AppendFile("log/log.log", $timestamp . " " . $charPrefix . " " . $text);
		}
	} # if ($debugOn)
} # WriteLog()

sub WriteMessage { # Writes timestamped message to console (stdout)
	#todo fix WriteLog('WriteMessage: caller = ' . join(',', caller));

	my $timestamp = GetTime();
	my $text = shift;

	if ($timestamp =~ m/^[0-9]+\.[0-9]{1}$/) {
		$timestamp .= '0';
	}
	if ($timestamp =~ m/^[0-9]+\.[0-9]{2}$/) {
		$timestamp .= '0';
	}
	if ($timestamp =~ m/^[0-9]+\.[0-9]{3}$/) {
		$timestamp .= '0';
	}
	if ($timestamp =~ m/^[0-9]+\.[0-9]{4}$/) {
		$timestamp .= '0';
	}

	if (!$text) {
		print('WriteMessage: warning: $text is false; caller = ' . join(',', caller) . "\n");
		return '';
	}

	chomp $text;
	state $previousText = '';

	state $snowPrinted;
	state $snowPrintedBefore = 0;

	if ($text eq '.' || length($text) == 1) {
		$previousText = $text;

		state @chars;
		if (!@chars) {
			#@chars = qw(, . - ' `); # may generate warning
			#@chars = (',', '.', '-', "'", '`');
			#@chars = ('.', ',');
			#@chars = (qw(0 1 2 3 4 5 6 7 8 9 A B C D E F));
		}

		#my @chars=('a'..'f','0'..'9');
		#print $chars[rand @chars];

		#print "\b";
		print $text;
		# my $randomString;
		# foreach (1..40) {
		# 	$randomString.=$chars[rand @chars];
		# }
		# return $randomString;

		if (!$snowPrinted) {
			$snowPrinted = $text;
		} else {
			$snowPrinted .= $text;
		}

		if (!$snowPrintedBefore || length($snowPrinted) >= 60) {
			## this starts a new line in the snow
			## this is NOT the part that prints a text message
			print "\n$timestamp ";
			WriteLog('WriteMessage: ' . $snowPrinted);
			$snowPrinted = '';
			$snowPrintedBefore = 1;
		}

		return;
	}
	if ($snowPrinted) {
		#WriteLog($snowPrinted);
	}
	$snowPrinted = '';

	# just an idea
	# doesn't seem to work well because the console freezes up if there's no \n coming
	# if ($text =~ m/^[0-9]+$/) {
	# 	$previousText = $text;
	# 	print $text . " ";
	# 	return;
	# }

	#WriteLog('WriteMessage: ' . $timestamp . ' ' . $text);

	WriteLog('WriteMessage: ' . $timestamp . ' ' . $text);

	my $output = "$text";
	if (0 && length($output) > 60) {
		$output = substr($output, 0, 60) . '...';
	}

#todo
#	print("\n");
#	print($timestamp);
#	print($output);
#
#	print("\n");
#	print($timestamp);
#	print(" =======================================================");
#
#	print("\n");
#	print($timestamp);
#	print(" ");

	# THIS is the part that prints the message
	# this code is not approved for public viewing
	#todo print "\n================================================================================\n";
	print "\n$timestamp $output\n$timestamp =======================================================\n$timestamp ";

	$previousText = $text;
} # WriteMessage()

sub MakePath { # $newPath ; ensures all subdirs for path exist
	my $newPath = shift;
	chomp $newPath;

	if (! $newPath) {
		#todo WriteLog('MakePath: warning: failed sanity check, $newPath missing; caller = ' . join(',', caller));
		WriteLog('MakePath: warning: failed sanity check, $newPath missing');
		return '';
	}

	if (-e $newPath) {
		WriteLog('MakePath: path already exists, returning');
		#todo WriteLog('MakePath: path already exists, returning; caller = ' . join(',', caller));
		return '';
	}

	if (! $newPath =~ m/^[0-9a-zA-Z\/]+$/) {
		#todo WriteLog('MakePath: warning: failed sanity check; caller = ' . join(',', caller));
		WriteLog('MakePath: warning: failed sanity check');
		return '';
	}

	WriteLog("MakePath($newPath)");

	my @newPathArray = split('/', $newPath);
	my $newPathCreated = '';

	while (@newPathArray) {
		$newPathCreated .= shift @newPathArray;
		if ($newPathCreated && !-e $newPathCreated) {
			WriteLog('MakePath: mkdir ' . $newPathCreated);
			mkdir $newPathCreated;
		}
		if (1 || $newPathCreated) { #todo
			$newPathCreated .= '/';
		}
	}
} # MakePath()

sub EnsureSubdirs { # $fullPath ; ensures that subdirectories for a file exist
	# takes file's path as argument
	# returns 0 for failure, 1 for success
	my $fullPath = shift;
	chomp $fullPath;

	state $scriptDir = GetDir('script');

	if (
		substr($fullPath, 0, 1) eq '/' &&
		substr($fullPath, 0, length($scriptDir)) ne $scriptDir
	) {
		WriteLog('EnsureSubdirs: warning: $fullPath begins with / AND does not begin with $scriptDir = ' . $scriptDir);
		#todo WriteLog('EnsureSubdirs: warning: $fullPath begins with / AND does not begin with $scriptDir = ' . $scriptDir . '; caller = ' . join(',', caller));
	}

	if (index($fullPath, '..') != -1 ) {
		WriteLog('EnsureSubdirs: warning: $fullPath contains .. ' . $fullPath);
		#todo WriteLog('EnsureSubdirs: warning: $fullPath contains .. ' . $fullPath . '; ' . join(',', caller));
	}

	WriteLog("EnsureSubdirs($fullPath)");

	#todo remove requirement of external module
	my ( $file, $dirs ) = fileparse $fullPath;

	if ( !$file ) {
		WriteLog('EnsureSubdirs: warning: $file was not set; $file = ' . $file . '; caller = ' . join(',', caller));
		#return 0;
		#this return is commented out because sometimes we want to ensure a subdir without a file
		#this is done from GetConfig() when inflating javascript library templates

		#$fullPath = File::Spec->catfile($fullPath, $file);
	}

	if ( !-d $dirs && !-e $dirs ) {
		if ( $dirs =~ m/^([^\s]+)$/ ) { #security #taint
			$dirs = $1; #untaint
			MakePath($dirs);
			return 1;
		} else {
			WriteLog('EnsureSubdirs: warning: $dirs failed sanity check, returning');
			return 0;
		}
	}
} # EnsureSubdirs()

sub TrimUnicodeString { # $string, $maxLength ; trims string to $maxLength in a unicode-friendly way
# sub SubstrUnicode {
# sub UnicodeSubstr {
# sub TrimTitle {
# sub trim {
# sub substr {
# this subprocedure is meant to address the issue with substr() cutting unicode characters apart
	my $string = shift;
	my $maxLength = shift;

	#todo sanity

	# code below tries to account for environments where Unicode::String is missing
	# it falls back on regular substr(), which has the downside of sometimes cutting
	# unicode characters in half. this can probably be detected and remedied, but I don't know how yet
	eval(
		'require Unicode::String qw(utf8);'
	);
	if (exists(&{'utf8'})) {
		my $us = utf8($string);
		my $stringLength = $us->length;
		WriteLog('TrimUnicodeString: $string = ' . $string . '; $stringLength = ' . $stringLength);

		if ($stringLength > $maxLength) {
			my $stringNew = $us->substr(0, $maxLength) . '...';
			WriteLog('TrimUnicodeString: $stringNew = ' . $stringNew);

			return $stringNew;
		} else {
			WriteLog('TrimUnicodeString: not trimming');
		}
	} else {
		my $stringLength = length($string);
		if ($stringLength > $maxLength) {
			my $stringNew = substr($string, 0, $maxLength);
			WriteLog('TrimUnicodeString: fallback mode: $stringNew = ' . $stringNew);
			return $stringNew;
		} else {
			WriteLog('TrimUnicodeString: fallback mode: not trimming');
		}
	}

	return $string;
} # TrimUnicodeString()

sub GetMyVersion { # Get the currently checked out version (current commit's hash from git)
# sub GetVersion {

	state $gitExists = !!`which git`;

	if ($gitExists) {
		# ok
	} else {
		return '7dc8eb9d3b1573755aec2f5c5e2af0ea10082f02';
	}

	state $myVersion;
	my $ignoreSaved = shift;

	if (!$ignoreSaved && $myVersion) {
		# if we already looked it up once, return that
		return $myVersion;
	}

	$myVersion = `git rev-parse HEAD`;
	#todo windows gitbash doesn't like this, even though `which git` works
	#

	#freebsd: $myVersion = `/usr/local/bin/git rev-parse HEAD`;
	if (!$myVersion) {
		WriteLog('GetMyVersion: warning: sanity check failed, returning default');
		$myVersion = sha1_hex('hello, world!');
	}
	chomp($myVersion);
	return $myVersion;
} # GetMyVersion()

sub GetFileHash { # $fileName ; returns hash of file contents
# sub GetItemHash {
# sub GetHash {
	WriteLog("GetFileHash()");

	my $fileName = shift;

	if (!$fileName) {
		WriteLog('GetFileHash: warning: $fileName is FALSE; caller = ' . join(',', caller));
		return '';
	}

	chomp $fileName;
	WriteLog("GetFileHash($fileName)");
	#todo normalize path (static vs full)
	state %memoFileHash;
	if ($memoFileHash{$fileName}) {
		WriteLog('GetFileHash: memo hit ' . $memoFileHash{$fileName});
		return $memoFileHash{$fileName};
	}
	WriteLog('GetFileHash: memo miss for $fileName = ' . $fileName);

	if (-e $fileName) {
		my $fileContent = GetFile($fileName);
		# if (!utf8::is_utf8($fileContent)) {
		# 	$fileContent = Encode::encode_utf8($fileContent);
		# }
		# $memoFileHash{$fileName} = sha1_hex(GetFile($fileName));
		# $memoFileHash{$fileName} = sha1_hex(Encode::encode_utf8($fileContent));
		$memoFileHash{$fileName} = GetSHA1(GetFile($fileName));
		return $memoFileHash{$fileName};
	} else {
		return '';
	}

	return '';
} # GetFileHash()

sub GetSHA1 {
	my $string = shift;
	my $hash = sha1_hex(Encode::encode_utf8($string));
	return $hash;
} # GetSHA1()

sub GetMD5 {
	my $string = shift;
	my $hash = md5_hex(Encode::encode_utf8($string));
	return $hash;
} # GetMD5()

sub GetFileMessageHash { # $fileName ; returns hash of file contents
# sub GetItemHash {
# sub GetHash {
# sub GetMessageHash {
# tries to hash the text rather than the exact bytes
# meaning that similar messages with minor differences would get the same hash

	my $fileName = shift;
	if (!$fileName) {
		WriteLog('GetFileMessageHash: warning: $fileName is FALSE; caller = ' . join(',', caller));
		return '';
	}

	chomp $fileName;
	WriteLog("GetFileMessageHash($fileName)");

	my $memoPath = GetAbsolutePath($fileName);

	state %memoFileHash;
	if ($memoFileHash{$memoPath}) {
		WriteLog('GetFileMessageHash: memo hit on $fileName = ' . $fileName);
		WriteLog('GetFileMessageHash: returning ' . $memoFileHash{$fileName});
		return $memoFileHash{$fileName};
	}
	WriteLog('GetFileMessageHash: memo miss for $fileName = ' . $fileName);

	if (-e $fileName) {
		if ((lc(substr($fileName, length($fileName) - 4, 4)) eq '.txt')) {
			my $fileContent = GetFile($fileName);
			WriteLog('GetFileMessageHash: text file detected; length = ' . length($fileContent));
			while (index($fileContent, "\n-- \n") > -1) { #\n--
				# exclude footer content from hashing
				$fileContent = substr($fileContent, 0, index($fileContent, "\n-- \n")); #\n--
			}
			$fileContent = trim($fileContent);
			WriteLog('GetFileMessageHash: length after removing signature and trim = ' . length($fileContent));
			WriteLog('GetFileMessageHash: $fileContent = ' . $fileContent);
			# $memoFileHash{$fileName} = sha1_hex($fileContent);
			$memoFileHash{$fileName} = GetSHA1($fileContent);
			WriteLog('GetFileMessageHash: returning ' . $memoFileHash{$fileName});
			return $memoFileHash{$fileName};
		} else {
			$memoFileHash{$fileName} = sha1_hex(GetFile($fileName));
			return $memoFileHash{$fileName};
		}
	} else {
		return '';
	}

	WriteLog('GetFileMessageHash: warning: unreachable reached');
	return '';
} # GetFileMessageHash()

sub GetRandomHash { # returns a random sha1-looking hash, lowercase
	my @chars=('a'..'f','0'..'9');
	my $randomString;
	foreach (1..40) {
		$randomString .= $chars[rand @chars];
	}
	WriteLog('GetRandomHash: returning $randomString = ' . $randomString . '; caller = ' . join(',', caller));
	return $randomString;
} # GetRandomHash()

sub GetTemplateFilePath { # $templateName, like 'perl/dialog/write.pl'
# sub GetTemplatePath {
	#todo
} # GetTemplateFilePath()

sub GetTemplate { # $filename ; returns specified template from template directory
# returns empty string if template not found
# here is how the template file is chosen:
# 1. template's existence is checked in config/template/ or default/template/
#    a. if it is found, it is THEN looked up in the config/theme/template/ and default/theme/template/
#    b. if it is not found in the theme directory, then it is looked up in config/template/, and then default/template/
# this allows themes to override existing templates, but not create new ones
#
	my $filename = shift;
	chomp $filename;
	#	$filename = "$SCRIPTDIR/template/$filename";

	my $isHtmlTemplate = 0;
	if ($filename =~ m/^html/) {
		$isHtmlTemplate = 1;
	}

	state $CONFIGDIR = GetDir('config');
	state $DEFAULTDIR = GetDir('default');

	WriteLog("GetTemplate($filename) caller: " . join(', ', caller));
	state %templateMemo; #stores local memo cache of template
	if ($templateMemo{$filename}) {
		#if already been looked up, return memo version
		WriteLog('GetTemplate: returning from memo for ' . $filename);
		if (trim($templateMemo{$filename}) eq '') {
			WriteLog('GetTemplate: warning: returning empty string for ' . $filename);
		}
		return $templateMemo{$filename};
	}

	if (!-e ($CONFIGDIR . '/template/' . $filename) && !-e ($DEFAULTDIR . '/template/' . $filename)) {
		#todo this should not fail if there is a template in the current theme
		#shim for rename
		if (-e ($CONFIGDIR . '/html/' . $filename) || -e ($DEFAULTDIR . '/html/' . $filename)) {
			WriteLog('GetTemplate: warning: template reference needs to be prepended with html: ' . $filename);
			return GetTemplate('html/' . $filename);
		}

		# if template doesn't exist
		# and we are in debug mode
		# report the issue
		WriteLog('GetTemplate: warning: template missing; $filename = ' . $filename . '; $DEFAULTDIR = ' . $DEFAULTDIR . '; $CONFIGDIR = ' . $CONFIGDIR);
		WriteLog('GetTemplate: warning: template missing; $filename = ' . $filename . '; caller = ' . join(',', caller));
		#WriteLog('GetTemplate: warning: template missing; ' . ($CONFIGDIR . '/template/' . $filename));
		#WriteLog('GetTemplate: warning: template missing; ' . ($DEFAULTDIR . '/template/' . $filename));
	}

	#information about theme
#	my $themeName = GetConfig('theme');
#	my $themePath = 'theme/' . $themeName . '/template/' . $filename;

	my $template = '';
	if (GetThemeAttribute('template/' . $filename)) {
		WriteLog('GetTemplate: Found GetThemeAttribute(template/' . $filename . ')');
		#if current theme has this template, override default
		$template = GetThemeAttribute('template/' . $filename);
	} elsif (GetConfig('template/' . $filename)) {
		WriteLog('GetTemplate: found GetConfig(template/' . $filename . ')');
		#otherwise use regular template
		$template = GetConfig('template/' . $filename);
	} else {
		WriteLog('GetTemplate: warning: found neither GetThemeAttribute(template/' . $filename . ') nor GetConfig(template/' . $filename . '); caller = ' . join(',', caller));
		$template = '';
	}

	# add \n to the end because it makes the resulting html look nicer
	# and doesn't seem to hurt anything else
	$template .= "\n";

	if ($isHtmlTemplate && GetConfig('debug')) {
		#todo this is buggy
		#$template .= '<!-- ' . join(', ', caller) . '-->' . "\n";
	}

	if ($isHtmlTemplate) {
		if (substr($template, 0, 4) eq '<!--') {
			# add newline to make it look nicer in the html source
			$template = "\n" . $template;
		}
	}

	if ($template) {
		#if template contains something, cache it
		$templateMemo{$filename} = $template;
		return $template;
	} else {
		if (index($filename, 'query') != -1) {
			# if template is under template/query and it doesn't have an .sql extension, try it with the sql extension
			# this shouldn't be necessary eventually #todo
			#todo this doesn't seem to work, as with query/tag_dozen
			if (index($filename, '.sql') == -1) {
				$template = GetTemplate($filename . '.sql');
				if ($template) {
					$templateMemo{$filename} = $template;
					return $template;
				}
			}
		}

		#if result is blank, report it
		WriteLog("GetTemplate: warning: GetTemplate() returning empty string for $filename.");
		return '';
	}
} # GetTemplate()

sub GetList { # $listName ; reads a list from a template and returns it as an array
# GetTagSet {
# tagsets are also lists, so use this
# Examples:
# my @menu = GetList('list/menu');
# my @tagsForMe = GetList('tagset/me');

	my $listName = shift;
	#todo sanity

	chomp $listName;
	if (!$listName) {
		WriteLog('GetList: warning: sanity check failed on $listName');
		return '';
	}

	WriteLog('GetList(' . $listName . '); caller = ' . join(',', caller));

	my $templateContents = GetTemplate($listName);
	#todo sanity

	my @arrayReturn = split("\n", $templateContents);

	return @arrayReturn;
} # GetList()

sub RenameFile { # $filePrevious, $fileNew, $hashNew ; renames file with a bit of sanity checking and logging
# sub FileRename {

	my $filePrevious = shift;
	my $fileNew = shift;
	my $hashNew = shift;
	#todo sanity

	chomp $filePrevious;
	chomp $fileNew;

	if ($hashNew) {
		# ok
		chomp $hashNew;
	} else {
		# hash not specified, get it
		$hashNew = GetFileHash($filePrevious);
	}

	WriteLog("RenameFile: $filePrevious, $fileNew); caller = " . join(',', caller));
	my $hashPrevious = SqliteGetValue("SELECT file_hash FROM item WHERE file_path = '$filePrevious'"); #todo safety

	if ($hashPrevious) {
		WriteLog('RenameFile: $hashPrevious = ' . $hashPrevious . '; $hashNew = ' . $hashNew);
		#todo sanity check on $hashPrevious
		DBAddItemParent($hashNew, $hashPrevious);
		AppendFile("log/rename.log", $hashNew . "|" . $hashPrevious); #todo proper path
		#todo log and sanity check on $renameResult
	} else {
		WriteLog('RenameFile: warning: $hashPrevious was FALSE');
		#return '';
	}

	my $renameResult = rename($filePrevious, $fileNew);
	return $renameResult;
} # RenameFile()

sub encode_entities2 { # returns $string with html entities <>"& encoded
	my $string = shift;
	if (!$string) {
		return;
	}

	WriteLog('encode_entities2() BEGIN, length($string) is ' . length($string));
	#WriteLog('encode_entities2() BEGIN, $string = ' . $string);

	$string =~ s/&/&amp;/g;
	$string =~ s/\</&lt;/g;
	$string =~ s/\>/&gt;/g;
	$string =~ s/"/&quot;/g;

	return $string;
} # encode_entities2()

sub GetAlias { # $fingerprint, $noCache ; Returns alias for an author
	my $fingerprint = shift;

	if (!$fingerprint) {
		WriteLog('GetAlias: warning: $fingerprint was missing; caller = ' . join(',', caller));
		return '';
	}

	chomp $fingerprint;

	WriteLog("GetAlias($fingerprint)");

	my $noCache = shift;
	$noCache = ($noCache ? 1 : 0);

	state %aliasCache;
	if (!$noCache) {
		if (exists($aliasCache{$fingerprint})) {
			return $aliasCache{$fingerprint};
		}
	}

	my $alias = DBGetAuthorAlias($fingerprint);

	if ($alias) {
		{ # remove email address, if any
			$alias =~ s|<.+?>||g;
			$alias = trim($alias);
			chomp $alias;
		}

		if ($alias && length($alias) > 24) {
			$alias = substr($alias, 0, 24);
		}

		$aliasCache{$fingerprint} = $alias;
		return $aliasCache{$fingerprint};
	} else {
		#return $fingerprint;
		return '';
		#		return 'unregistered';
	}
} # GetAlias()

sub GetFileExtension { # $fileName ; returns file extension, naively
	my $fileName = shift;

	if ($fileName) {
		if ($fileName =~ m/.+\/.+\.(.+)/) {
			return $1;
		} else {
			return '';
		}
	} else {
		return '';
	}
} # GetFileExtension()

sub GetFile { # Gets the contents of file $fileName
	my $fileName = shift;
	if (!$fileName) {
		WriteLog('GetFile: warning: $fileName missing or false');
		return '';
	}

	chomp $fileName;

	if ($fileName =~ m/^([0-9a-zA-Z\/._-]+)$/) {
		$fileName = $1;
		WriteLog('GetFile: $fileName passed sanity check: ' . $fileName);
	} else {
		WriteLog('GetFile: warning: $fileName FAILED sanity check: ' . $fileName);
		return '';
	}

	my $length = shift || 209715200;
	# default to reading a max of 2MB of the file. #scaling #bug #todo

	WriteLog('GetFile: trying to open file...');
	use open qw(:utf8);
	if (
		-e $fileName # file exists
			&&
		!-d $fileName # not a directory
			&&
		open(my $file, "<", $fileName) # opens successfully
	) {
		WriteLog('GetFile: opened successfully, trying to read...');
		my $return;
		read($file, $return, $length);
		#WriteLog('GetFile: read success, returning.');
		#WriteLog('GetFile: read success, returning. $return = ' . $return);
		#WriteLog('GetFile: read success, returning. length($return) = ' . ($return ? length($return) : 'FALSE'));
		return $return;
	} else {
		WriteLog('GetFile: warning: open failed! $fileName = ' . $fileName);
	}

	return;
	#todo do something for a file which is missing
} # GetFile()

sub GetTime () { # Returns time in epoch format.
	# Just returns time() for now, but allows for converting to 1900-epoch time
	# instead of Unix epoch

	#	return (time() + 2207520000);
	return (time());
} # GetTime()

sub GetClockFormattedTime() { # returns current time in appropriate format from config
	# this formats the user-facing time, like the clock on the pages (if enabled)
	# formats supported: 24hour, union, epoch (default)

	my $clockFormat = GetConfig('html/clock_format');
	chomp $clockFormat;

	if ($clockFormat eq '24hour') {
		my $time = GetTime();
		my $hours = strftime('%H', localtime $time);
		my $minutes = strftime('%M', localtime $time);
		my $clockFormattedTime = $hours . ':' . $minutes;

		if (0) { # 24-hour with seconds
			my $seconds = strftime('%S', localtime $time);
			my $clockFormattedTime = $hours . ':' . $minutes . ':' . $seconds;
		}

		return $clockFormattedTime;
	}

	if ($clockFormat eq 'union') {
		my $time = GetTime();

		#todo implement this, for now it's only js
		#$clockFormattedTime = 'union_clock_format';
		# my $timeDate = strftime '%Y/%m/%d %H:%M:%S', localtime $time;
		#
		# var hours = now.getHours();
		# var minutes = now.getMinutes();
		# var seconds = now.getSeconds();
		my $hours = strftime('%H', localtime $time);
		my $minutes = strftime('%M', localtime $time);
		my $seconds = strftime('%S', localtime $time);
		#

		my $milliseconds = '000';
		# if (now.getMilliseconds) {
		# 	milliseconds = now.getMilliseconds();
		# } else if (Math.floor && Math.random) {
		# 	milliseconds = Math.floor(Math.random() * 999)
		# }
		#
		# var hoursR = 23 - hours;
		# if (hoursR < 10) {
		# 	hoursR = '0' + '' + hoursR;
		# }
		my $hoursR = 23 - $hours;
		if ($hoursR < 10) {
			$hoursR = '0' . $hoursR;
		}

		# var minutesR = 59 - minutes;
		# if (minutesR < 10) {
		# 	minutesR = '0' + '' + minutesR;
		# }
		my $minutesR = 59 - $minutes;
		if ($minutesR < 10) {
			$minutesR = '0' . $minutesR;
		}

		# var secondsR = 59 - seconds;
		# if (secondsR < 10) {
		# 	secondsR = '0' + '' + secondsR;
		# }
		my $secondsR = 59 - $seconds;
		if ($secondsR < 10) {
			$secondsR = '0' . $secondsR;
		}

		#
		# if (milliseconds < 10) {
		# 	milliseconds = '00' + '' + milliseconds;
		# } else if (milliseconds < 100) {
		# 	milliseconds = '0' + '' + milliseconds;
		# }
		#

		my $clockFormattedTime = $hours . $minutes . $seconds . $milliseconds . $secondsR . $minutesR . $hoursR;

		return $clockFormattedTime;
	}

	# this is fallback, with sanity check
	my $fallbackTime = time();
	if (
		$fallbackTime =~ m/^([0-9]+)\.([0-9]+)$/ ||
		$fallbackTime =~ m/^([0-9]+)$/
	) {
		# sanity check passed
		$fallbackTime = $1;
	}
	else {
		# sanity check failed
		$fallbackTime = '';
	}

	return $fallbackTime;
} # GetClockFormattedTime()

sub PutFile { # Writes content to a file; $file, $content, $binMode
# sub PutTextFile {
	# $file = file path
	# $content = content to write
	# $binMode = whether or not to use binary mode when writing
	# ensures required subdirectories exist
	#
	WriteLog("PutFile(...)");

	my $file = shift;

	if (!$file) {
		return;
	}

	WriteLog("PutFile($file)");

	# keep track of files written so we can report them to user
	state @debugFilesWritten;
	# my $timeBegin = GetTime(); #todo
	if ($file eq 'report_files_written') {
		return @debugFilesWritten;
	}
	push @debugFilesWritten, GetPaddedEpochTimestamp() . ' ' . $file;

	WriteLog("PutFile: EnsureSubdirs($file)");

	EnsureSubdirs($file);

	WriteLog("PutFile: $file, ...");

	my $content = shift;
	my $binMode = shift;

	if (!defined($content)) {
		WriteLog('PutFile: $content not defined, returning');
		return;
	}

	#	if (!$content) {
	#		return;
	#	}
	if (!$binMode) {
		$binMode = 0;
		WriteLog('PutFile: $binMode: 0');
	} else {
		$binMode = 1;
		WriteLog('PutFile: $binMode: 1');
	}

	WriteLog('PutFile: $file = ' . $file . ', $content = (' . length($content) . 'b), $binMode = ' . $binMode);
	#WriteLog("==== \$content ====");
	#WriteLog($content);
	#WriteLog("====");

	#todo use temp file and rename (see php version)

	if ($file =~ m/^([^\s]+)$/) { #todo this is overly permissive #security #taint
		$file = $1;
		use open qw(:utf8);
		if (open(my $fileHandle, ">", $file)) {
#		if (open(my $fileHandle, ">:encoding(UTF-8)", $file)) {
			WriteLog('PutFile: file handle opened, $file = ' . $file);
			if ($binMode) {
				WriteLog('PutFile: binmode $fileHandle = ' . $fileHandle . ', :utf8;');
				#binmode $fileHandle, ':utf8';
			}

			# if ($content =~ m/[^\x00-\xFF]/) {
			# 	WriteLog('PutFile: warning: $content contains wide characters, setting :utf8; caller = ' . join(',', caller));
			# 	binmode $fileHandle, ':utf8';
			# }

			if ($content =~ m/[^\x00-\xFF]/) {
				#WriteLog('PutFile: warning: $content contains wide characters, setting :utf8; caller = ' . join(',', caller));
				#binmode $fileHandle, ':utf8';
			}

			WriteLog('PutFile: print $fileHandle $content;');
			print $fileHandle $content; #todo wide character warning here why??

			WriteLog('PutFile: close $fileHandle;');
			close $fileHandle;

			return 1;
		}
	} else {
		WriteLog('PutFile: warning: sanity check failed: $file contains space');
	}
} # PutFile()

sub EpochToHuman { # returns epoch time as human readable time
	my $time = shift;

	return strftime('%F %T', localtime($time));
} # EpochToHuman()

sub EpochToHuman2 { # not sure what this is supposed to do, and it's unused 
	my $time = shift;

	my ($seconds, $minutes, $hours, $day_of_month, $month, $year, $wday, $yday, $isdst) = localtime($time);
	$year = $year + 1900;
	$month = $month + 1;

} # EpochToHuman2()

sub GetPaddedEpochTimestamp { # returns zero-padded formatted epoch time
	# this is used to get log timestamps to line up nicely when float/millisecond is used
	# if there is no period, it should return unchanged.

	my $time = GetTime();

	if ($time =~ m/^[0-9]+\.[0-9]{1}$/) {
		$time .= '0';
	}
	if ($time =~ m/^[0-9]+\.[0-9]{2}$/) {
		$time .= '0';
	}
	if ($time =~ m/^[0-9]+\.[0-9]{3}$/) {
		$time .= '0';
	}
	if ($time =~ m/^[0-9]+\.[0-9]{4}$/) {
		$time .= '0';
	}

	return $time;
} # GetPaddedEpochTimestamp()

sub str_replace { # $replaceWhat, $replaceWith, $string ; emulates some of str_replace() from php
#props http://www.bin-co.com/perl/scripts/str_replace.php
	# fourth $count parameter not implemented yet
	my $replace_this = shift;
	my $with_this  = shift;
	my $string   = shift;

	my $stringLength = length($string);

	if (!defined($string) || !$string) {
		#todo edge cases like '0', 0, ''
		#what to do for ''??
		WriteLog('str_replace: warning: $string not supplied; caller = ' . join(',', caller));
		return "";
	}

	if (length($replace_this) < 32 && length($with_this) < 32) {
		WriteLog("str_replace($replace_this, $with_this, ($stringLength)); caller = " . join(',', caller));
	} else {
		WriteLog('str_replace($replace_this = ' . length($replace_this) . 'b, $with_this = ' . length($with_this) . 'b , ($stringLength = ' . $stringLength . ')); caller = ' . join (',', caller));
	}

	if (!defined($replace_this) || !defined($with_this)) {
		WriteLog('str_replace: warning: sanity check failed, missing $replace_this or $with_this');
		return $string;
	}

	if ($replace_this eq $with_this) {
		WriteLog('str_replace: warning: $replace_this eq $with_this; caller: ' . join(', ', caller));
		return $string;
	}

	#WriteLog("str_replace: sanity check passed, proceeding");

	WriteLog('str_replace: sanity check passed, proceeding');
	$string =~ s/\Q$replace_this/$with_this/g;
	WriteLog('str_replace: length($string) = ' . length($string));
	# WriteLog('str_ireplace: $string = ' . $string);

	# RETURN ###############
	# RETURN ###############
	# RETURN ###############
	# RETURN ###############
	# RETURN ###############
	return $string;


	if (0) { #buggy code, not used
		my $length = length($string);
		my $target = length($replace_this);

		for (my $i = 0; $i < $length - $target + 1; $i++) {
			#todo there is a bug here
			if (!defined(substr($string, $i, $target))) {
				WriteLog("str_replace: warning: !defined(substr($string, $i, $target))");
			}
			elsif (substr($string, $i, $target) eq $replace_this) {
				$string = substr ($string, 0, $i) . $with_this . substr($string, $i + $target);
				$i += length($with_this) - length($replace_this); # when new string contains old string
				$length += length($with_this) - length($replace_this); # string is getting shorter or longer
			} else {
				# do nothing
			}
		}

		WriteLog('str_replace: length($string) = ' . length($string));

		return $string;
	}
} # str_replace()

sub str_ireplace { # $replaceWhat, $replaceWith, $string ; emulates some of str_ireplace() from php
#props http://www.bin-co.com/perl/scripts/str_replace.php
	# fourth $count parameter not implemented yet
	#todo this definitely has a performance problem
	# and also possible bugs
	#todo
	my $replace_this = shift;
	my $with_this  = shift;
	my $string   = shift;

	# this workaround has a problem with regex syntax
	# $string =~ s/$replace_this/$with_this/gi;
	# return $string;

	#todo make below more efficient

	if (!defined($string) || !$string) {
		WriteLog('str_ireplace: warning: $string not supplied');
		return "";
	}

	my $stringLength = length($string);

	if (length($replace_this) < 32 && length($with_this) < 32) {
		WriteLog("str_ireplace($replace_this, $with_this, ($stringLength))");
	} else {
		WriteLog('str_ireplace($replace_this = ' . length($replace_this) . 'b, $with_this = ' . length($with_this) . 'b , ($stringLength = ' . $stringLength . ')); caller = ' . join (',', caller));
	}

	if ($replace_this eq $with_this) {
		WriteLog('str_ireplace: warning: $replace_this eq $with_this');
		WriteLog('str_ireplace: caller: ' . join(', ', caller));
		return $string;
	}

	WriteLog('str_ireplace: sanity check passed, proceeding');
	$string =~ s/\Q$replace_this/$with_this/gi;
	WriteLog('str_ireplace: length($string) = ' . length($string));
	# WriteLog('str_ireplace: $string = ' . $string);
	return $string;

	######## below is old code, not used
	######## below is old code, not used
	######## below is old code, not used
	######## below is old code, not used
	######## below is old code, not used

	my $length = length($string);
	my $target = length($replace_this);

	my $loopCounter = 0;

	for (my $i = 0; $i < $length - $target + 1; $i++) {
		if (lc(substr($string, $i, $target)) eq lc($replace_this)) {
			$string = substr ($string, 0, $i) . $with_this . substr($string, $i + $target);
			$i += length($with_this) - length($replace_this); # when new string contains old string
		}

		$loopCounter++;

		if ($loopCounter > 1000) {
			WriteLog('str_ireplace: warning: loop has reached 1000 iterations, stopping');
			last;
		}
	}

	WriteLog('str_ireplace: length($result) = ' . length($string));

	return $string;
} # str_replace()

sub ReplaceStrings { # automatically replaces strings in html with looked up values
#todo finish it
	my $content = shift;
	my $newLanguage = shift;

	if (!$newLanguage) {
		$newLanguage = GetConfig('language');
	}

	my $contentStripped = $content;
	$contentStripped =~ s/\<[^>]+\>/<>/sg;
	my @contentStrings = split('<>', $contentStripped);

	foreach my $string (@contentStrings) {
		$string = trim($string);
		if ($string && length($string) >= 5) {
			my $stringHash = md5_hex($string);
			WriteLog('ReplaceStrings, replacing ' . length($string) . '-char-long string (' . $stringHash . ')');
			#WriteLog('ReplaceStrings, replacing ' . $string . ' (' . $stringHash . ')');
			my $newString = GetConfig('string/' . $newLanguage . '/' . $stringHash);
			if ($newString) {
				if ($string ne $newString) {
					$content = str_replace($string, $newString, $content);
				}
			} else {
				PutConfig('string/' . $newLanguage . '/' . $stringHash, $string);
			}
		}
	}

	return $content;
} # ReplaceStrings()

sub ServerSign { # $filePath
	return '';
	#todo sanity
	my $newFilePath = shift;
	chomp $newFilePath;
	`gpg --clearsign $newFilePath`;
	`mv $newFilePath.asc $newFilePath`;
	IndexRecentTextFiles();
}

sub IsUrl { # add basic isurl()
	return 1;
} # IsUrl()

sub PutHtmlFile { # $file, $content ; writes content to html file, with special rules; parameters: $file, $content
# sub WriteHtmlFile {

	# * if config/admin/html/ascii_only is set, all non-ascii characters are stripped from output to file
	# * if $file matches config/html/home_page, the output is also written to index.html
	# * if config/html/relativize_urls is true, rewrites links to be relative, e.g. /foo.html to ./foo.html
	#
	#   also keeps track of whether home page has been written, and returns the status of it
	#   if $file is 'check_homepage'
	#
	#   also keeps track of all files written and returns the list as an array
	#   if $file is 'report_files_written'

	my $file = shift;
	my $content = shift;

	if (!$file) {
		return;
	}

	#todo more sanity

	# keep track of files written so we can report them to user
	state @debugFilesWritten;
	# my $timeBegin = GetTime(); #todo
	if ($file eq 'report_files_written') {
		return @debugFilesWritten;
	}
	push @debugFilesWritten, GetPaddedEpochTimestamp() . ' ' . $file;

	WriteLog("PutHtmlFile($file) ; caller = " . join(',', caller));

	state $HTMLDIR = GetDir('html');
	#todo sanitycheck $HTMLDIR

	WriteLog('PutHtmlFile: $HTMLDIR = ' . $HTMLDIR);
	#WriteLog('PutHtmlFile: caller = ' . join(',', caller));

	if ($HTMLDIR && !-e $HTMLDIR) {
		WriteLog('PutHtmlFile: warning: $HTMLDIR was missing, trying to mkdir(' . $HTMLDIR . ')');
		mkdir($HTMLDIR);
	}

	if (!$HTMLDIR || !-e $HTMLDIR) {
		WriteLog('PutHtmlFile: $HTMLDIR is missing: ' . $HTMLDIR);
		return '';
	}

	if (!$content) {
		WriteLog('PutHtmlFile: warning: $content missing; caller = ' . join(',', caller));
		$content = '';
	}

	# remember what the filename provided is, so that we can use it later
	my $fileProvided = $file;
	$file = "$HTMLDIR/$file";

	my $postUrl = GetConfig('admin/post/post_url');
	if ($postUrl) {
		# replace target for form submissions from current site to somewhere else
		if ($postUrl ne '/post.html') {
			#todo sanity
			if (index($content, '/post.html') != -1) {
				str_replace('/post.html', $postUrl, $content);
				$content =~ s/\/post.html/$postUrl/g;
			}
		}
	}

	# controls whether linked urls are converted to relative format
	# meaning they go from e.g. /write.html to ./write.html
	# this breaks the 404 page links so disable that for now

	my $relativizeUrls = (GetConfig('html/relativize_urls') ? 1 : 0);
	if (TrimPath($file) eq '404') {
		$relativizeUrls = 0;
	}
	if ($file eq "$HTMLDIR/stats-footer.html") {
		#note this means footer links will be broken if hosted on non-root dir on a domain
		$relativizeUrls = 0;
	}

	WriteLog('PutHtmlFile: $file = ' . $file . ', $content = (' . length($content) . 'b)');

	# $stripNonAscii remembers value of admin/html/ascii_only
	# this might be duplicate work
	state $stripNonAscii;
	if (!defined($stripNonAscii)) {
		$stripNonAscii = GetConfig('admin/html/ascii_only');
		if (!defined($stripNonAscii)) {
			$stripNonAscii = 0;
		}
		if ($stripNonAscii != 1) {
			$stripNonAscii = 0;
		}
	}

	# if $stripNonAscii is on, strip all non-ascii characters from the output
	# in the future, this can, perhaps, for example, convert unicode-cyrillic to ascii-cyrillic
	if ($stripNonAscii == 1) {
		WriteLog('PutHtmlFile: $stripNonAscii == 1, removing non-ascii characters');
		my $lengthBefore = length($content);
		$content =~ s/[^[:ascii:]]//g;
		if (length($content) != $lengthBefore) {
			if (index(lc($content), '</body>') != -1) {
				my $messageNotification = 'Non-ASCII characters removed during page printing: ' . ($lengthBefore - length($content));
				if (GetConfig('debug')) {
					#$messageNotification .= '<br><form><textarea>'.HtmlEscape('<script>alert()</script>').'</textarea></form>';
				}
				$content = str_ireplace('</body>', GetDialogX($messageNotification, 'Notice') . '</body>', $content);
			}
		}
	}


	if (0) { #todo quick-write setting #quickwrite #quick-write #quick_write
		my $quickWriteWindow = GetDialogX(GetTemplate('html/form/write/write-quick.template'), 'Quick-Write');
		$quickWriteWindow =
			'<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' . #todo
			$quickWriteWindow .
			'</form>';

		$quickWriteWindow = '<span class=advanced>' . $quickWriteWindow . '</span>';

		$content = str_ireplace('</body>', $quickWriteWindow . '</body>', $content);
	}

	# convert urls to relative if $relativizeUrls is set
	if ($relativizeUrls == 1) {
		WriteLog('PutHtmlFile: $relativizeUrls == 1, relativizing urls');
		# only the following *exact* formats are converted
		# thus it is important to maintain this exact format throughout the html and js templates
		# src="/
		# href="/
		# .src = '/
		# .location = '/

		# first we determine how many levels deep our current file is
		# we do this by counting slashes in $file
		my $count = ($fileProvided =~ s/\//\//g) + 1;

		# then we build the path prefix.
		# the same prefix is used on all links
		# this can be done more efficiently on a per-link basis
		# but most subdirectory-located files are of the form /aa/bb/aabbcc....html anyway
		my $subDir;
		if ($count == 1) {
			$subDir = './';
		} else {
			if ($count < 1) {
				WriteLog('PutHtmlFile: relativize_urls: sanity check failed, $count is < 1');
			} else {
				# $subDir = '../' x ($count - 1);
				$subDir = str_repeat('../', ($count - 1));
			}
		}

		# here is where we do substitutions
		# it may be wiser to use str_replace() here
		#todo test this more

		# html
		$content =~ s/src="\//src="$subDir/ig;
		$content =~ s/href="\//href="$subDir/ig;
		$content =~ s/background="\//background="$subDir/ig;
		$content =~ s/action="\//action="$subDir/ig;
		$content =~ s/src=\//src=$subDir/ig;
		$content =~ s/href=\//href=$subDir/ig;
		$content =~ s/background=\//background=$subDir/ig;
		$content =~ s/action=\//action=$subDir/ig;

		# javascript
		$content =~ s/\.src = '\//.src = '$subDir/ig;
		$content =~ s/\.location = '\//.location = '$subDir/ig;

		# css
		$content =~ s/url\(\/\//url=$subDir/ig;
	} # if ($relativizeUrls)

	# fill in colors
	{
		my $colorTopMenuTitlebarText = GetThemeColor('top_menu_titlebar_text') || GetThemeColor('titlebar_text');
		$content =~ s/\$colorTopMenuTitlebarText/$colorTopMenuTitlebarText/g;#

		my $colorTopMenuTitlebar = GetThemeColor('top_menu_titlebar') || GetThemeColor('titlebar');
		$content =~ s/\$colorTopMenuTitlebar/$colorTopMenuTitlebar/g;

		my $colorTitlebarText = GetThemeColor('titlebar_text');#
		$content =~ s/\$colorTitlebarText/$colorTitlebarText/g;#

		my $colorTitlebar = GetThemeColor('titlebar');#
		$content =~ s/\$colorTitlebar/$colorTitlebar/g;#

		my $colorBackground = GetThemeColor('background');#
		$content =~ s/\$colorBackground/$colorBackground/g;#

		my $borderDialog = GetThemeAttribute('color/border_dialog');
		#todo rename it in all themes and then here
		# not actually a color, but the entire border definition
		$content =~ s/\$borderDialog/$borderDialog/g;

		my $colorWindow = GetThemeColor('window');
		$content =~ s/\$colorWindow/$colorWindow/g;
	}

	# #internationalization #i18n
	if (GetConfig('language') ne 'en') {
		$content = ReplaceStrings($content);
	}

	# this allows adding extra attributes to the body tag
	my $bodyAttr = GetThemeAttribute('tag/body');
	if ($bodyAttr) {
		$bodyAttr = FillThemeColors($bodyAttr);
		$content =~ s/\<body/<body $bodyAttr/i;
		$content =~ s/\<body>/<body $bodyAttr>/i;
	}

	#if (GetConfig('html/debug')) {
		# this would make all one-liner html comments visible if it worked
		#$content =~ s/\<\!--(.+)--\>/<p class=advanced>$1<\/p>/g;
	#}

	# if (GetConfig('debug')) {
	# 	my $hashSetting = trim(GetFile(GetDir('config') . '/hash_setting'));
	# 	if ($hashSetting) {
	# 		$content .= '' . $hashSetting . '';
	# 	}
	# }

	{ # tests and warnings
		if (index($content, '$') > -1) {
			# test for $ character in html output, warn/crash if it is there
			if (!($fileProvided eq 'openpgp.js')) {
				# except for openpgp.js, most files should not have $ characters
				WriteLog('PutHtmlFile: warning: $content contains $ symbol! $file = ' . ($file ? $file : '-'));
				# $content = GetPageHeader('error') . GetDialogX('This page is under construction.', 'Under Construction') . GetPageFooter('error');
			}
		}
		if (index($content, 'maincontent') == -1) {
			# ensure document contains a mainconvent-tagged element
			# typically: <MAIN ID=maincontent><A NAME=maincontent></A>
			if (index($fileProvided, '.js') != -1) {
				# it's cool
			} else {
				#todo /dialog/.. files should be excluded
				WriteLog('PutHtmlFile: warning: "maincontent" not found in file! $file = ' . ($file ? $file : '-'));
			}
		}
		if (
			index(lc($content), '<td></td>') != -1 ||
			index(lc($content), '<td class=advanced></td>') != -1 #||
			#$content =~ m|<td[^>]+></td>| #todo make this work
		) {
			# empty table cells present rendering issues in netscape,
			# and may also be a sign of larger problems.
			WriteLog('PutHtmlFile: warning: content has empty table cells <td></td> ; caller = ' . join(',', caller));
			$content = str_ireplace('<td></td>', '<td>-</td>', $content);
			$content = str_ireplace('<td class=advanced></td>', '<td class=advanced>-</td>', $content);
			#$content =~ s|(<td[^>]+>)(</td>)|$1-$2|i; #todo make this work
		}
		if ($content =~ m/<html.+<html/i) {
			# test for duplicate <html> tag
			WriteLog('PutHtmlFile: warning: $content contains duplicate <html> tags');
		}
		if (index($content, 'replyCartButton') != -1) {
			# reply buttons are present on page
			if (index($content, 'reply_cart.js') == -1) {
				# reply_cart.js is not present on page
				WriteLog('PutHtmlFile: warning: $content contains replyCartButton, but not reply_cart.js; caller = ' . join(',', caller));
			}
		}
	} # tests and warnings

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/debug')) {
		if ($file =~ m/dialog/) {
			# do not inject js debug button
		} else {
			# add "jsdebug" button if js debugging is enabled
			if (index(lc($content), '<script') != -1 && index($content, 'debug_button') == -1) {
				$content = GetTemplate('html/widget/debug_button.template') . $content;
			} else {
				WriteLog('InjectJs: warning: wanted to inject debug_button, but it is already in $html');
			}
			#todo make nicer
		}
	} # jsdebug button

	if (GetConfig('html/generator_meta')) {
		# add generator meta tag to head
		if (index(lc($content), '</head>')) {
			#die;
			my $progName = 'RocketScience';
			my $versionSeq = '1337';
			my $versionGit = '01234abc';

			my $generatorMeta = '<meta name="GENERATOR" content="' . $progName . ' ' . $versionSeq . ' (' . $versionGit . ')">';
			my $contentPrev = $content;
			#$content = str_ireplace('</head>', $generatorMeta . "\n" . '</head>', $content); #todo retain capitalization of head tag
			$content =~ s|(</head>)|$generatorMeta\n$1|;
		}
	} # html/generator_meta

	#############################################
	## WRITE TO FILE ############################
	#############################################
	my $putFileResult = PutFile($file, $content);
	#############################################
	############################ WRITE TO FILE ##
	#############################################

	if (!-e ($HTMLDIR . '/index.html')) {
		# if index is missing replace it with anything that comes along
		if (
			$file =~ m/profile/ ||
			$file =~ m/welcome/ ||
			$file =~ m/read/ ||
			$file =~ m/write/ ||
			$file =~ m/help/
		) {
			WriteLog('PutHtmlFile: warning: index.html was missing, fixing it with $file = ' . $file);
			my $putIndexFileName = PutHtmlFile("$HTMLDIR/index.html", $content);
			WriteLog('PutHtmlFile: $putIndexFileName = ' . $putIndexFileName);
		}
	} # missing /index.html

	return $putFileResult;
} # PutHtmlFile()

sub GetFileAsHashKeys { # returns file as hash of lines
	# currently not used, can be used for detecting matching lines later
	my $fileName = shift;
	my @lines = split('\n', GetFile($fileName));
	my %hash;
	foreach my $line (@lines) {
		$hash{$line} = 0;
	}
	return %hash;
} # GetFileAsHashKeys()

sub AppendFile { # appends something to a file; $file, $content to append
	# mainly used for writing to log files
	my $file = shift;
	my $content = shift;

	# uncomment this for debugging AppendFile()
	# cannot use WriteLog() here because it calls this sub
	#print('AppendFile($file = ' . $file . '; $content = ' . length($content) . ' bytes)');

	#use open qw(:utf8);
	#if (open(my $fileHandle, ">>", $file)) {
	if (open(my $fileHandle, ">>:encoding(UTF-8)", $file)) {
		say $fileHandle $content; #note that this appends \n automatically
		close $fileHandle;
	}
} # AppendFile()

sub AuthorHasTag { # $key ; returns 1 if user is admin, otherwise 0
	# will probably be redesigned in the future
	my $key = shift;
	my $tagInQuestion = shift;

	if (!IsFingerprint($key)) {
		WriteLog('AuthorHasTag: warning: $key failed sanity check, returning 0; caller = ' . join(',', caller));
		return 0;
	}

	if (!trim($tagInQuestion)) {
		WriteLog('AuthorHasTag: warning: $tagInQuestion failed sanity check, returning 0; caller = ' . join(',', caller));
		return 0;
	}

	#todo $tagInQuestion sanity check

	WriteLog("AuthorHasTag($key, $tagInQuestion)");

	my $pubKeyHash = DBGetAuthorPublicKeyHash($key);
	if ($pubKeyHash) {
		WriteLog('AuthorHasTag: $pubKeyHash = ' . $pubKeyHash);

		my $pubKeyVoteTotalsRef = DBGetItemVoteTotals2($pubKeyHash);
		my %pubKeyVoteTotals = %{$pubKeyVoteTotalsRef};
		WriteLog('AuthorHasTag: join(",", keys(%pubKeyVoteTotals)) = ' . join(",", keys(%pubKeyVoteTotals)));

		if ($pubKeyVoteTotals{$tagInQuestion}) {
			WriteLog('AuthorHasTag: $tagInQuestion FOUND, return 1');
			return 1;
		} else {
			WriteLog('AuthorHasTag: $tagInQuestion NOT found, return 0');
			return 0;
		}
	} else {
		WriteLog('AuthorHasTag: warning, no $pubKeyHash, how did we even get here? caller = ' . join(',', caller));
		return 0;
	}

	WriteLog('AuthorHasTag: warning: unreachable fallthrough');
	return 0;
} # AuthorHasTag()

sub IsAdmin { # $key ; returns 1 if user is admin, otherwise 0
# sub UserIsAdmin {
	# returns 2 if user is root admin.

	my $key = shift;
	if (!$key || !IsFingerprint($key)) {
		WriteLog('IsAdmin: warning: $key failed sanity check, returning 0');
		return 0;
	}
	WriteLog("IsAdmin($key)");

	my $rootAdminKey = ''; #GetRootAdminKey();
	if (!$rootAdminKey) {
		$rootAdminKey = '';
	}

	if ($key eq $rootAdminKey) {
		WriteLog('IsAdmin: $key eq $rootAdminKey, return 2 ');
		return 2; # is admin, return true;
	} else {
		if (GetConfig('admin/allow_admin_permissions_tag_lookup')) {
			WriteLog('IsAdmin: not root admin, checking tags');
			return AuthorHasTag($key, 'admin');
		} else {
			WriteLog('IsAdmin: allow_admin_permissions_tag_lookup is false, stopping here');
			return 0;
		}
	}

	WriteLog('IsAdmin: warning: unreachable reached'); #should never reach here
} # IsAdmin()

sub TrimPath { # $string ; Trims the directories AND THE FILE EXTENSION from a file path
# sub GetFileName {
# sub RemovePath {
# sub StripPath {

	my $string = shift;
	while (index($string, "/") >= 0) {
		$string = substr($string, index($string, "/") + 1);
	}
	if (rindex($string, ".") != -1) {
		$string = substr($string, 0, rindex($string, ".") + 0);
	}
	return $string;
} # TrimPath()

sub IsSha1 { # returns 1 if parameter is in sha1 hash format, 0 otherwise
	my $string = shift;

	if (!$string) {
		return 0;
	}

	if ($string =~ m/[a-fA-F0-9]{40}/) {
		return 1;
	} else {
		return 0;
	}
} # IsSha1()

sub IsImageFile { # $file ; returns 1 if image file, 0 if not
	my $file = shift;
	if (!$file) {
		return 0;
	}
	chomp $file;
	if (!$file) {
		return 0;
	}

	if (
		-e $file
			&&
		(
			substr(lc($file), length($file) -4, 4) eq ".jpg" ||
			substr(lc($file), length($file) -5, 5) eq ".jpeg" ||
			substr(lc($file), length($file) -4, 4) eq ".gif" ||
			substr(lc($file), length($file) -4, 4) eq ".png" ||
			substr(lc($file), length($file) -4, 4) eq ".bmp" ||
			substr(lc($file), length($file) -4, 4) eq ".svg" ||
			substr(lc($file), length($file) -5, 5) eq ".jfif" ||
			substr(lc($file), length($file) -5, 5) eq ".webp"
		)
	) {
		return 1;
	} else {
		return 0;
	}
	return 0;
} # IsImageFile()

sub IsTextFile { # $file ; returns 1 if txt file, 0 if not
	my $file = shift;
	if (!$file) {
		return 0;
	}
	chomp $file;
	if (!$file) {
		return 0;
	}

	if (
		-e $file
			&&
		(
			substr(lc($file), length($file) -4, 4) eq ".txt"
		)
	) {
		return 1;
	} else {
		return 0;
	}
	return 0;
} # IsTextFile()

sub IsSaneFilename {
# sub IsValidFile {
# sub IsFile {
	my $fileName = shift;

	if ($fileName) {
		if ($fileName =~ m/^([0-9a-zA-Z\/\._:\-]+)$/) {
			return 1;
		} else {
			return 0;
		}
	} else {
		return 0;
	}
} # IsSaneFilename()

sub IsItem { # $string ; returns untained string, 0 if not item
#sub IsHash {
# should be called IsValidItemHash {
# todo more validation
	my $string = shift;

	if (!$string) {
		return 0;
	}

	if ($string =~ m/^([0-9a-f]{40})$/) {
		return $1;
	}

	if ($string =~ m/^([0-9a-f]{8})$/) {
		return $1;
	}

	return 0;
} # IsItem()

sub IsItemPrefix { # $string ; returns sanitized value if parameter is in item prefix format (4 lowercase hex chars), 0 otherwise
# todo more validation
	WriteLog('IsItemPrefix()');

	my $string = shift;

	if (!$string) {
		return 0;
	}

	chomp $string;

	WriteLog('IsItemPrefix: $string = ' . $string);

	if ($string =~ m/^([0-9a-f]{8})$/) {
		WriteLog('IsItemPrefix: returning $1 = ' . $1);

		return $1; # returned sanitized value, in case it is needed
	}

	return 0;
} # IsItemPrefix()

sub IsMd5 { # returns 1 if parameter is md5 hash, 0 otherwise
	my $string = shift;

	if (!$string) {
		return 0;
	}

	if ($string =~ m/[a-fA-F0-9]{32}/) {
		return 1;
	} else {
		return 0;
	}
} # IsMd5()

sub IsDate {
	my $string = shift;
	
	if (!$string) {
		return 0;
	}
	
	if ($string =~ m/[0-9]{4}-[0-9]{2}-[0-9]{2}/) {
		return 1;
	} else {
		return 0;
	}
} # IsDate()

sub IsFingerprint { # returns valid fingerprint if parameter is a valid user fingerprint, 0 otherwise
# sub IsAuthor {
# sub IsPubKey {
	my $string = shift;

	if (!$string) {
		WriteLog('IsFingerprint: warning: $string is FALSE; caller = ' . join(',', caller));
		return 0;
	}

	if ($string =~ m/^([A-F0-9]{16})$/) {
		WriteLog('IsFingerprint(' . $string . ') = ' . $1 . '; caller = ' . join(',', caller));
		return $1;
	} else {
		WriteLog('IsFingerprint(' . $string . ') = FALSE; caller = ' . join(',', caller));
		return 0;
	}
} # IsFingerprint()

sub AddItemToConfigList { # Adds a line to a list stored in config
	# $configPath = reference to setting stored in config
	# $item = item to add to the list (appended to the file)

	my $configPath = shift;
	chomp($configPath);

	my $item = shift;
	chomp($item);

	# get existing list
	my $configList = GetConfig($configPath);

	if ($configList) {
		# if there is something already there, go through all this stuff
		my @configListAsArray = split("\n", $configList);

		foreach my $h (@configListAsArray) {
			# loop through each item on list and check if already exists
			if ($h eq $item) {
				# item already exists in list, nothing else to do
				return;
			}
		}

		#append to list
		$configList .= "\n";
		$configList .= $item;
		$configList = trim($configList);
		$configList .= "\n";
	} else {
		# if nothing is there, just add the requested item
		$configList = $item . "\n";
	}

	# remove any blank lines
	$configList =~ s/\n\n/\n/g;

	# put it back
	PutConfig($configPath, $configList);
} # AddItemToConfigList()

sub CheckForInstalledVersionChange {
	WriteLog('CheckForInstalledVersionChange() begin');

	my $lastVersion = GetConfig('current_version');
	my $currVersion = GetMyVersion();

	if (!$lastVersion) {
		$lastVersion = 0;
	}

	if (!$currVersion) {
		WriteLog('CheckForInstalledVersionChange: warning: sanity check failed, no $currVersion');
		return '';
	}

	if ($lastVersion ne $currVersion) {
		WriteLog("CheckForInstalledVersionChange: $lastVersion ne $currVersion, posting changelog");

		#my $serverKey = `gpg --list-keys hikeserver`;

		#WriteLog("gpg --list-keys CCEA3752");
		#WriteLog($serverKey);

		my $changeLogFilename = 'changelog_' . GetTime() . '.txt';
		#todo this should be a template;
		my $changeLogMessage =
			'Software Updated to Version ' . substr($currVersion, 0, 8) . '..' . "\n\n" .
			'Installed software version has changed from ' . $lastVersion . ' to ' . $currVersion . "\n\n";

		WriteLog('CheckForInstalledVersionChange: $changeLogFilename = ' . $changeLogFilename);

		if (!$lastVersion) {
			$lastVersion = 0;
		}

		if ($lastVersion) {
			#my $changeLogList = "Version has changed from $lastVersion to $currVersion";
			if ($lastVersion =~ m/^([0-9a-f]+)$/) {
				$lastVersion = $1;
			}
			if ($currVersion =~ m/^([0-9a-f]+)$/) {
				$currVersion = $1;
			}
			my $changeLogListCommand = "git log --oneline $lastVersion..$currVersion";
			my $changeLogList = `$changeLogListCommand`;
			$changeLogList = trim($changeLogList);
			$changeLogMessage .= "$changeLogList";
		} else {
			$changeLogMessage .= 'This is the initial install of the software, so no changelog is generated.';
			#$changeLogMessage .= 'No changelog will be generated because $lastVersion is false';
		}

		$changeLogMessage .= "\n\n#changelog";
		state $TXTDIR = GetDir('txt');
		my $newChangelogFile = "$TXTDIR/$changeLogFilename";

		WriteLog('About to PutFile() to $newChangelogFile = ' . $newChangelogFile);

		PutFile($newChangelogFile, $changeLogMessage);

		if (GetConfig('setting/admin/gpg/sign_git_changelog')) {
			ServerSign($newChangelogFile);
		}

		#my $changelogIndexResult = IndexFile($newChangelogFile);
		#if (!$changelogIndexResult) {
		#	WriteLog('CheckForInstalledVersionChange: warning: $changelogIndexResult was FALSE');
		#}

		PutConfig('current_version', $currVersion);

		return $currVersion;
	} else {
		return 0;
	}
} # CheckForInstalledVersionChange()

sub IsFileDeleted { # $file, $fileHash ; checks for file's hash in deleted.log and removes it if found
#todo rename to IsFileMarkedAsDeleted()
# only one or the other is required
	my $file = shift;
	WriteLog("IsFileDeleted($file)");

	if ($file && !-e $file) {
		# file already doesn't exist
		WriteLog('IsFileDeleted: file already gone, returning 1');
		return 1;
	}

	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('IsFileDeleted: $fileHash not specified, calling GetFileHash()');
		$fileHash = GetFileHash($file);
	}
	WriteLog("IsFileDeleted($file, $fileHash)");

	if ($file && $file =~ m/^([0-9a-zA-Z.\-_\/]+)$/) {
		$file = $1;
	} else {
		WriteLog('IsFileDeleted: warning: $file failed sanity check: $file = ' . $file);
		return '';
	}


	if ($fileHash && -e 'log/deleted.log' && GetFile('log/deleted.log') =~ $fileHash) {
		# if the file is present in deleted.log, get rid of it and its page, return
		# write to log
		WriteLog("IsFileDeleted: MATCHED! $fileHash exists in deleted.log, removing $file");

		# unlink the file itself
		if (-e $file) {
			if (GetConfig('setting/admin/index/unlink_deleted_files')) {
				if ($file =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
					my $fileSafe = $1;
					WriteLog("IsFileDeleted: warning: file exists, calling unlink($fileSafe)");

					my $LOGDIR = GetDir('log');
					if ( ! -d "$LOGDIR/deleted" ) {
						WriteLog('IsFileDeleted: mkdir(' . "$LOGDIR/deleted" . ')');
						mkdir("$LOGDIR/deleted");
					}

					if (-d "$LOGDIR/deleted") {
						#unlink($fileSafe); #todo -T
						my $justFilename = TrimPath($fileSafe);
						my $newFilename = "$LOGDIR/deleted/$justFilename";

						WriteLog('IsFileDeleted: rename(' . $fileSafe . ', ' . $newFilename . ')');

						rename($fileSafe, $newFilename);
					} else {
						WriteLog('IsFileDeleted: warning: $LOGDIR/deleted does not exist, even after attempt to create');
					}
				} else {
					WriteLog('IsFileDeleted: warning: did not unlink, sanity check failed on $file = ' . $file);
				}
			} else {
				WriteLog("IsFileDeleted: warning: file exists, would call unlink($file)");
			}
		}

		WriteLog("IsFileDeleted($file, $fileHash) = YES (via deleted.log)");
		WriteLog('IsFileDeleted: $fileHash = ' . $fileHash);

		my $htmlFilename = GetHtmlFilename($fileHash); # IsFileDeleted()

		if ($htmlFilename) {
			if ($htmlFilename =~ m/^([a-zA-Z0-9._\/]+\.html)/) {
				$htmlFilename = $1;

				state $HTMLDIR = GetDir('html');
				$htmlFilename = $HTMLDIR . '/' . $htmlFilename; #todo this could be a sub?
				if (-e $htmlFilename) {
					WriteLog('IsFileDeleted: warning: calling unlink: $htmlFilename = ' . $htmlFilename);
					unlink($htmlFilename);
				} else {
					WriteLog('IsFileDeleted: warning: file NOT exist: $htmlFilename = ' . $htmlFilename);
				}
			} else {
				WriteLog('IsFileDeleted: warning: failed sanity check: $htmlFilename = ' . $htmlFilename);
			}
		}

		return 1;
	} # $fileHash is in 'log/deleted.log'

	WriteLog("IsFileDeleted($file, $fileHash) = FALSE");

	return 0;
} # IsFileDeleted()

sub file_exists { # $file ; port of php file_exists()
	my $file = shift;
	if (!$file) {
		return 0;
	}
	if (-e $file && -f $file && !-d $file) {
		return 1;
	} else {
		return 0;
	}
	return 0; #unreachable code
} # file_exists()

sub GetItemDetokenedMessage { # $itemHash, $filePath ; retrieves item's message using cache or file path
	WriteLog('GetItemDetokenedMessage()');

	my $itemHash = shift;
	if (!$itemHash) {
		WriteLog('GetItemDetokenedMessage: warning: missing $itemHash');
		return '';
	}

	chomp $itemHash;

	if (!IsItem($itemHash)) {
		WriteLog('GetItemDetokenedMessage: warning: $itemHash failed sanity check');
		return '';
	}

	WriteLog("GetItemDetokenedMessage($itemHash)");

	my $message = '';
	my $messageCacheName = GetMessageCacheName($itemHash);

	if (!-e $messageCacheName) {
		WriteLog('GetItemDetokenedMessage: warning: NO FILE: $messageCacheName = ' . $messageCacheName);

	} else {
		WriteLog('GetItemDetokenedMessage: $message = GetFile(' . $messageCacheName . ');');
		$message = GetFile($messageCacheName);
		if (!$message) {
			WriteLog('GetItemDetokenedMessage: cache exists, but $message was missing');

			my $filePath = shift;
			if (!$filePath) {
				$filePath = '';
			}

			WriteLog('GetItemDetokenedMessage: $filePath = ' . $filePath);

			if (!$filePath) {
				$filePath = GetPathFromHash($itemHash);
				WriteLog('GetItemDetokenedMessage: missing $filePath, using GetPathFromHash(): ' . $filePath);
			}

			if (!$filePath || !-e $filePath) {
				$filePath = DBGetItemAttributeValue($itemHash, 'file_path');
				chomp $filePath;
				WriteLog('GetItemDetokenedMessage: missing $filePath, using DBGetItemAttributeValue(): ' . $filePath);
			}

			WriteLog('GetItemDetokenedMessage: $filePath = ' . $filePath);

			if ($filePath && -e $filePath) {
				WriteLog('GetItemDetokenedMessage = GetFile(' . $filePath . ');');
				$message = GetFile($filePath);
			} else {
				WriteLog('GetItemDetokenedMessage: warning: no $filePath or file is missing');
				$message = '';
			}
		}
	}

	if (!$message) {
		WriteLog('GetItemDetokenedMessage: warning: $message is false');
	}

	return $message;
} # GetItemDetokenedMessage()

sub GetItemMeta { # retrieves item's metadata
	# $itemHash, $filePath

	WriteLog('GetItemMeta()');

	my $itemHash = shift;
	if (!$itemHash) {
		return;
	}

	chomp $itemHash;
	if (!IsItem($itemHash)) {
		return;
	}

	WriteLog("GetItemMeta($itemHash)");

	my $filePath = shift;
	if (!$filePath) {
		return;
	}

	chomp $filePath;

	if (-e $filePath) {
		my $fileHash = GetFileHash($filePath);

		if ($fileHash eq $filePath) {
			my $metaFileName = $filePath . '.nfo';

			if (-e $metaFileName) {
				my $metaText;

				$metaText = GetFile($metaFileName);

				return $metaText;
			}
			else {
				return; # no meta file
			}
		} else {
			WriteLog('GetItemMeta: WARNING: called with hash which did not match file hash');

			return;
		}
	} else {
		return; # file doesn't exist
	}
} # GetItemMeta()

sub GetPrefixedUrl { # returns url with relative prefix 
	my $url = shift;
	chomp $url;
	return $url;
} # GetPrefixedUrl()

sub UpdateUpdateTime { # updates cache/system/last_update_time, which is used by the stats page
	my $lastUpdateTime = GetTime();
	PutCache("system/last_update_time", $lastUpdateTime);
} # UpdateUpdateTime()

sub RemoveEmptyDirectories { #looks for empty directories under $path and removes them
	my $path = shift;
	#todo probably more sanitizing
	$path = trim($path);
	if (!$path) {
		return;
	}
	#system('find $path -type d -empty -delete'); #todo uncomment when bugs fixed
} # RemoveEmptyDirectories()

sub GetFileHashPath { # $file ; Returns text file's standardized path given its filename
# GetFilename {
	# e.g. /01/23/0123abcdef0123456789abcdef0123456789a.txt
	my $file = shift;

	# file should exist and not be a directory
	if (!-e $file || -d $file) {
		WriteLog('GetFileHashPath: warning: $file sanity check failed, $file = ' . $file . '; caller = ' . join(',', caller));
		return '';
	}
	# WriteLog("GetFileHashPath($file)");

	if ($file) {
		WriteLog('GetFileHashPath: $file = ' . $file);
		my $fileHash = GetFileHash($file);
		#my $fileHash = GetFileMessageHash($file); #todo
		my $fileHashPath = GetPathFromHash($fileHash);
		WriteLog('GetFileHashPath: $file = ' . $file . '; $fileHash = ' . $fileHash . '; $fileHashPath = ' . $fileHashPath);

		return $fileHashPath;
	} else {
		WriteLog('GetFileHashPath: warning: $file was FALSE; caller = ' . join(',', caller));
		return '';
	}
} # GetFileHashPath()

sub GetPathFromHash { # guesses path of text file based on hash
# sub GetFilePath {
# sub GetHashPath {

	# relies on config/admin/organize_files = 1
	#todo fix
	my $fileHash = shift;
	chomp $fileHash;

	if (!$fileHash) {
		WriteLog('GetPathFromHash: warning: $fileHash is false');
		return '';
	}

	chomp $fileHash;
	WriteLog('GetPathFromHash: $fileHash = '. $fileHash);

	state $TXTDIR = GetDir('txt');

	WriteLog('GetPathFromHash: $TXTDIR = '. $TXTDIR);

#	state $TXTDIR = GetDir('txt');


	if ($fileHash =~ m/^([0-9a-f]+)$/) { #todo should this be unlimited length?
		$fileHash = $1;
		WriteLog('GetPathFromHash: $fileHash sanity check passed: ' . $fileHash);
	} else {
		WriteLog('GetPathFromHash: warning: $fileHash sanity check failed!');
		return '';
	}

	if (!-e $TXTDIR . '/' . substr($fileHash, 0, 2)) {
		WriteLog('GetPathFromHash: mkdir ' . $TXTDIR . '/' . substr($fileHash, 0, 2));
		system('mkdir ' . $TXTDIR . '/' . substr($fileHash, 0, 2));
	}

	if (!-e $TXTDIR . '/' . substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2)) {
		system('mkdir ' . $TXTDIR . '/' . substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2));
	}

	my $fileHashSubDir = substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2);

	if ($fileHash) {
		my $fileHashPath = $TXTDIR . '/' . $fileHashSubDir . '/' . $fileHash . '.txt';
		WriteLog('GetPathFromHash: $fileHashPath = ' . $fileHashPath);
		return $fileHashPath;
	}
} # GetPathFromHash()

sub array_unique { # @array ; returns array of unique items from @array
# modeled after php's array_unique()
	my @list = @_;
	my %finalList;
	foreach(@list) {
		$finalList{$_} = 1; # delete double values
	}
	return (keys(%finalList));
} # array_unique()

sub in_array { # $needle, @haystack ; emulates php's in_array()
# sub array_contains {
	my $needle = shift;
	my @haystack = @_;

#	if($needle ~~ @haystack) {
#		return 1;
#	} else {
#		return 0;
#	}
	WriteLog('in_array: caller = ' . join(',', caller));

	my %params = map { $_ => 1 } @haystack;
	if(exists($params{$needle})) {
		WriteLog('in_array: $needle = ' . $needle . '; @haystack = ' . join(',', @haystack) . ' = 1');
		return 1;
	} else {
		WriteLog('in_array: $needle = ' . $needle . '; @haystack = ' . join(',', @haystack) . ' = 0');
		return 0;
	}
} # in_array()

sub Sha1Test {
	print "\n";
	print GetFileHash('utils.pl');
	print "\n";
	print(`sha1sum utils.pl | cut -f 1 -d ' '`);
	# print "\n";
	print(`php -r "print(sha1_file('utils.pl'));"`);
	print "\n";
} # Sha1Test()

sub GetPasswordLine { # $username, $password ; returns line for .htpasswd file
	my $username = shift;
	chomp $username;

	my $password = shift;
	chomp $password;

	return $username.":".crypt($password,$username)."\n";
} # GetPasswordLine()

sub VerifyThirdPartyAccount {
	my $fileHash = shift;
	my $thirdPartyUrl = shift;
} # verify token

sub ProcessTextFile { # $file ; add new text file to index
	my $file = shift;
	if ($file eq 'flush') {
		IndexFile('flush');
	}
	my $relativePath = File::Spec->abs2rel($file, $SCRIPTDIR); #todo this shouldn't have a ::
	if ($file ne $relativePath) {
		$file = $relativePath;
	}
	my $addedTime = GetTime2();
	WriteLog('ProcessTextFile: $file = ' . $file . '; $addedTime = ' . $addedTime);

	# get file's hash from git
	my $fileHash = GetFileHash($file);
	if (!$fileHash) {
		return 0;
	}

	WriteLog('ProcessTextFile: $fileHash = ' . $fileHash);

	# if deletion of this file has been requested, skip
	if (IsFileDeleted($file, $fileHash)) {
		WriteLog('ProcessTextFile: IsFileDeleted() returned true, skipping');
		WriteLog('ProcessTextFile: return 0');

		return 0;
	}

	if (GetConfig('admin/organize_files')) {
		my $fileNew = OrganizeFile($file); # ProcessTextFile()
		if ($fileNew eq $file) {
			WriteLog('ProcessTextFile: $fileNew eq $file');
		} else {
			WriteLog('ProcessTextFile: changing $file to new value per OrganizeFile()');
			$file = $fileNew;
			WriteLog('ProcessTextFile: $file = ' . $file);
		}
	} else {
		WriteLog("ProcessTextFile: organize_files is off, continuing");
	}

	if (!GetCache('indexed/' . $fileHash)) {
		WriteLog('ProcessTextFile: ProcessTextFile(' . $file . ') not in cache/indexed, calling IndexFile');

		IndexFile($file);
		IndexFile('flush');
	} else {
		# return 0 so that this file is not counted
		WriteLog('ProcessTextFile: already indexed ' . $fileHash . ', return 0');
		return 0;
	}

	WriteLog('ProcessTextFile: return ' . $fileHash);
	return $fileHash;

	# run commands to
	#	  add changed file to git repo
	#    commit the change with message 'hi' #todo
	#    cd back to pwd


	#		# below is for debugging purposes
	#
	#		my %queryParams;
	#		$queryParams{'where_clause'} = "WHERE file_hash = '$fileHash'";
	#
	#		my @files = DBGetItemList(\%queryParams);
	#
	#		WriteLog("Count of new items for $fileHash : " . scalar(@files));

} # ProcessTextFile()

sub EnsureDirsThatShouldExist { # creates directories expected later
# sub EnsureDirs {
	WriteLog('EnsureDirsThatShouldExist() begin');
	# make a list of some directories that need to exist
	state $HTMLDIR = GetDir('html');
	state $CACHEDIR = GetDir('cache');
	state $CONFIGDIR = GetDir('config');

	state $cacheVersion = GetMyCacheVersion();

	WriteLog('EnsureDirsThatShouldExist: $HTMLDIR = ' . $HTMLDIR . '; $CACHEDIR = ' . $CACHEDIR . '; $CONFIGDIR = ' . $CONFIGDIR);

	#todo this should be ... improved upon
	my @dirsThatShouldExist = (
		"log",
		"$HTMLDIR",
		"$HTMLDIR/utils",
		"$HTMLDIR/txt",
		"$HTMLDIR/image",
		"$HTMLDIR/cpp",
		"$HTMLDIR/py",
		"$HTMLDIR/perl",
		"$HTMLDIR/mp4",
		"$HTMLDIR/thumb", #thumbnails
		"$CACHEDIR/$cacheVersion", #ephemeral data
		"$HTMLDIR/author",
		"$HTMLDIR/dialog/replies",
		"$HTMLDIR/action",
		"$HTMLDIR/tag", #tag items for tags
		"$CONFIGDIR",
		"$CONFIGDIR/template",
		"$CONFIGDIR/setting/admin",
		"$CONFIGDIR/setting/admin/php",
		"$CONFIGDIR/setting/admin/php/post",
		"$CONFIGDIR/setting/admin/php/upload",
		"$HTMLDIR/upload", #uploaded files go here
		"$HTMLDIR/error", #error pages
		"$SCRIPTDIR/once" #used for registering things which should only happen once e.g. scraping
	);

	push @dirsThatShouldExist, $CACHEDIR;
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion;
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/key';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/file';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/avatar';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/message';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/gpg';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/gpg_message';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/gpg_stderr';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/response';

	# create directories that need to exist
	foreach my $dir (@dirsThatShouldExist) {
		if ($dir =~ m/^([a-zA-Z0-9_\/]+)$/) {
			$dir = $1;
		} else {
			WriteLog('EnsureDirsThatShouldExist: warning: sanity check failed during @dirsThatShouldExist');
			WriteLog('EnsureDirsThatShouldExist: $dir = ' . $dir);
			next;
		}
		if (-e $dir && !-d $dir) {
			WriteLog('EnsureDirsThatShouldExist: warning: file exists where directory should be: ' . $dir);
			next;
		}
		if (!-d $dir && !-e $dir) {
			WriteLog('EnsureDirsThatShouldExist: directory does not exist, creating: ' . $dir);
			mkdir $dir;
		}
		if (!-e $dir || !-d $dir) {
			WriteLog('EnsureDirsThatShouldExist: warning: $dir should exist, but does not: $dir = ' . $dir);
		}
	}
} # EnsureDirsThatShouldExist()

sub PopulateResource { # populate resources needed by all active themes
# this is a rather naive way of doing it, but it works for now
# searches for each resource in active themes and copies to html root if found
	my $themesValue = GetConfig('theme');
	$themesValue =~ s/[\s]+/ /g;
	my @activeThemes = split(' ', $themesValue);

	#my @activeThemes = split("\n", GetConfig('theme'));
	my @resources = split("\n", `find default/res`);

	use File::Basename;
	use File::Copy qw(copy);
	state $htmlDir = GetDir('html');

	foreach my $themeName (@activeThemes) {
		foreach my $resource (@resources) {
			if ($resource =~ m/^([0-9a-zA-Z.\/]+)$/) {
				$resource = $1;
				if (-e $resource && !-d $resource) {
					my $resourceFilename = basename($resource);

					if ($themeName =~ m/^([0-9a-zA-Z]+)$/) {
						$themeName = $1;

						if ($resourceFilename =~ m/^([0-9a-zA-Z.]+)$/) {
							$resourceFilename = $1;

							if (`grep -ri "$resourceFilename" default/theme/$themeName`) {
								#print $resourceFilename . "-" . $themeName . "\n";
								copy($resource, $htmlDir);
							}
						}
					}
				}
			}
		}
	}
} # PopulateResource()

sub StorePostUrl {
	# this exists to synchronize two redundant ways of getting the url to post things
	# config/setting/admin/post/post_url and GetTargetPath('post')
	if (GetConfig('setting/admin/post/post_url') ne GetTargetPath('post')) {
		WriteLog('StorePostUrl: warning: config/setting/admin/post/post_url did not match GetTargetPath(post), updating it');
		PutConfig('setting/admin/post/post_url', GetTargetPath('post'));
	}
}

StorePostUrl();

EnsureDirsThatShouldExist();

CheckForInstalledVersionChange();

my $utilsPl = 1;

1;
