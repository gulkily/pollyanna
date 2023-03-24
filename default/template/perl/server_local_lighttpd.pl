#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl

use strict;
use warnings;
use 5.010;
use utf8;

require './utils.pl';

sub GetYes { # $message, $defaultYes ; print $message, and get Y response from the user
	# $message is printed to output
	# $defaultYes true:  allows pressing enter
	# $defaultYes false: user must type Y or y

	my $message = shift;
	chomp $message;

	my $defaultYes = shift;
	chomp $defaultYes;

	print $message;
	if ($defaultYes) {
		print ' [Y] ';
	} else {
		print " Enter 'Y' to proceed: ";
	}

	my $input = <STDIN>;
	chomp $input;

	if ($input eq 'Y' || $input eq 'y' || ($defaultYes && $input eq '')) {
		print "====================================================\n";
		print "====== Thank you for your vote of confidence! ======\n";
		print "====================================================\n";

		return 1;
	}
	return 0;
} # GetYes()

if (!GetConfig('admin/lighttpd/enable')) {
	if (GetConfig('admin/dev/dont_confirm') || GetYes('admin/lighttpd/enable is false, set to true?', 1)) {
		PutConfig('admin/lighttpd/enable', 1);
	}
} # if (!GetConfig('admin/lighttpd/enable'))

sub FindBinPath { # $binName, $configPath ; tries to figure out local path for a binary
# sub GetBinPath {
# sub FindBinaryPath {
	# $binName is the name of the binary, e.g. lighttpd or php-cgi
	# $configPath is where the path may be stored in config

	# READ ARGUMENTS #####
	my $binName = shift;
	chomp $binName;
	my $configPath = shift;
	chomp $configPath;

	# INITIALIZE RETURN VALUE #####
	my $binPath = '';

	# SANITY CHECK ARGUMENTS #####
	if ($binName =~ m/^([a-zA-Z\-_]+)$/) {
		$binName = $1;
		WriteLog('FindBinPath: $binName sanity check passed');
	} else {
		WriteLog('FindBinPath: warning: $binName failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	if ($configPath) {
		if (ConfigKeyValid($configPath)) {
			$binPath = GetConfig($configPath);
			WriteLog('FindBinPath: $configPath = ' . $configPath);
		} else {
			WriteLog('FindBinPath: warning: $configPath was specified, but failed sanity check; caller = ' . join(',', caller));
			return '';
		}
	} # if ($configPath)
	else {
		WriteLog('FindBinPath: $configPath was not specified');
	}

	# WAS PATH SPECIFIED IN CONFIG VALID? #####
	# if (file_exists($binPath)) { # #todo
	if (-e $binPath) {
		WriteLog('FindBinPath: path found in config is good, returning; $binPath = ' . $binPath);
		return $binPath;
	}

	# TRY TO FIND A PATH #####
	else {
		WriteLog('FindBinPath: there is no file at $binPath, looking for alternatives');

		$binPath = `which $binName`; # for some reason this may return empty string
		chomp $binPath;
		WriteLog('FindBinPath: which $binName returned $binPath = ' . $binPath);

		if (!$binPath) {
			WriteLog('FindBinPath: `which` did not work, trying some common paths...');

			my @options;
			push @options, '/bin/'; # GNU/Linux
			push @options, '/usr/local/bin/'; # Mac OS X / macOS
			push @options, '/usr/sbin/'; # GNU/Linux
			push @options, '/usr/local/sbin/'; # FreeBSD

			for my $prefix (@options) {
				if (-e ($prefix . $binName)) { #todo use file_exists()
					$binPath = $prefix . $binName;
					last;
				}
			}
		}
		if (-e $binPath) {
			WriteLog('FindBinPath: valid path found after looking! Saving to config, $binPath = ' . $binPath);
			PutConfig($configPath, $binPath);
			return $binPath;
		} else {
			WriteLog('FindBinPath: warning: valid path still not found; $binName = ' . $binName . '; caller = ' . join(',', caller));
			return '';
		}
	} # else (!-e $binPath)
} # FindBinPath()

sub StartLighttpd { # run command to start local lighttpd instance
	WriteLog('StartLighttpd() BEGIN');
	if (!-e './log') {
		mkdir('./log');
	}

	my $screenCommand;

	#$screenCommand = `which screen`;
	#if ($screenCommand) {
	#	#use screen command
	#	$screenCommand = 1;
	#} else {
	#	$screenCommand = 0;
	#}
	$screenCommand = 0; # using screen requires some tweaking, disable for now
	WriteLog('StartLighttpd: $screenCommand = ' . $screenCommand);

	my $insanityLevel = 2; # track sanity checklist
	my $portNumber = GetConfig('admin/lighttpd/port');
	$portNumber = int($portNumber);
	if ($portNumber > 0 && $portNumber <= 65535 ) {
		$insanityLevel--;
	}
	my $port = $portNumber;

	my $pathLighttpd = GetConfig('admin/lighttpd/path');
	WriteLog('StartLighttpd: path found in config; $pathLighttpd = ' . $pathLighttpd);

	if (-e $pathLighttpd) {
		WriteLog('StartLighttpd: path found in config is good, continuing; $pathLighttpd = ' . $pathLighttpd);
	}
	else {
		WriteLog('StartLighttpd: valid path not found, trying to find it');
		$pathLighttpd = `which lighttpd`;
		chomp $pathLighttpd;
		if (!$pathLighttpd) {
			if (-e '/usr/local/sbin/lighttpd') {
				# FreeBSD
				$pathLighttpd = '/usr/local/sbin/lighttpd';
			}
			elsif (-e '/usr/bin/lighttpd') {
				# GNU/Linux
				$pathLighttpd = '/usr/bin/lighttpd';
			}
			elsif (-e '/usr/sbin/lighttpd') {
				# GNU/Linux
				$pathLighttpd = '/usr/sbin/lighttpd';
			}
		}
		if (-e $pathLighttpd) {
			#todo
			#Macs-MacBook-Pro:~ mac$ find ~ | grep lighttpd$ | xargs file | grep -i executable
			#/Users/mac/lighttpd-1.4.63/src/lighttpd:        POSIX shell script text executable, ASCII text
			#/Users/mac/lighttpd-1.4.63/src/.libs/lighttpd:  Mach-O 64-bit executable x86_64

			WriteLog('StartLighttpd: valid path found after looking! Saving to config, $pathLighttpd = ' . $pathLighttpd);
		}
	} # else (!-e $pathLighttpd)

	if ($pathLighttpd =~ m/^([^\s]+)$/) {
		$pathLighttpd = $1;
		$insanityLevel--;
	}

	WriteLog('StartLighttpd: $pathLighttpd = ' . $pathLighttpd);
	WriteLog('StartLighttpd: $insanityLevel = ' . $insanityLevel);

	if ($insanityLevel == 0) {
		if ($screenCommand) {
#			if (!GetConfig('admin/dev/dont_confirm') || GetYes('kill existing lighttpd process?', 1)) {
#				#kill existing instance using killall lighttpd
#				`killall lighttpd`;
#
#				#kill existing instance using screen's session name
#				#todo this doesn't work yet for some reason
#				WriteMessage("StartLighttpd: screen -X -S hike$port kill");
#				`screen -X -S hike$port kill`;
#			}
#			#system("screen -m -S hike$port $pathLighttpd -D -f config/lighttpd/lighttpd.conf");
#			system("screen -m -S hike$port $pathLighttpd -f config/lighttpd/lighttpd.conf &");
		} # if ($screenCommand)
		else {
			print "\n";
			system("$pathLighttpd -D -f config/lighttpd/lighttpd.conf");
		}
		#todo background it if opening browser
	} # if ($insanityLevel == 0)
	else {
		WriteMessage('StartLighttpd: lighttpd path missing or failed sanity check. $insanityLevel = ' . $insanityLevel);
	}
} # StartLighttpd()

sub GetLighttpdConfig { # generate contents for lighttpd.conf file based on settings
	my $conf = GetTemplate('lighttpd/lighttpd.conf.template');

#	my $pwd = `pwd`;
	my $pwd = cwd();
	chomp $pwd; # get rid of tailing newline

	my $docRoot = GetDir('html');

	WriteLog('GetLighttpdConfig(); caller = ' . join(',', caller));

	my $serverPort = GetConfig('admin/lighttpd/port') || 2784;
	#my $serverPort = GetConfig('admin/lighttpd/port');
	if ($serverPort =~ m/^([0-9]+)$/) {
		$serverPort = $1;
	} else {
		WriteLog('GetLighttpdConfig: warning: sanity check failed on $serverPort');
		return '';
	}

	my $errorFilePrefix = $docRoot . '/error/error-';

	$conf =~ s/\$serverDocumentRoot/$docRoot\//;
	$conf =~ s/\$serverPort/$serverPort/;
	$conf =~ s/\$errorFilePrefix/$errorFilePrefix/;

	if (GetConfig('admin/php/enable')) {
		WriteLog('GetLighttpdConfig: admin/php/enable is TRUE');

		my $phpConf = GetTemplate('lighttpd/lighttpd_php.conf.template');

		my $phpCgiPath = FindBinPath('php-cgi', 'admin/php/php_path');

		WriteLog('GetLighttpdConfig: $phpCgiPath = ' . $phpCgiPath);

		if ($phpCgiPath) {
			#$phpConf =~ s/\/bin\/php-cgi/$phpCgiPath/g;
			WriteLog('GetLighttpdConfig: $phpCgiPath = ' . $phpCgiPath);
			$phpConf = str_replace('/bin/php-cgi', $phpCgiPath, $phpConf);
		} else {
			WriteLog('GetLighttpdConfig: warning: php enabled with lighttpd, but php-cgi missing');
		}

		WriteLog('$phpConf beg =====');
		WriteLog($phpConf);
		WriteLog('$phpConf end =====');

		$conf .= "\n" . $phpConf;

		my $rewriteSetting = GetConfig('admin/php/rewrite');
		if ($rewriteSetting) {
			if ($rewriteSetting eq 'all') {
				my $phpRewriteAllConf = GetTemplate('lighttpd/lighttpd_php_rewrite_all.conf.template');

				if (GetConfig('setting/admin/php/url_alias_friendly')) {
					$phpRewriteAllConf = str_replace('#"(.+)" => "/route.php?path=$1"', '"(.+)" => "/route.php?path=$1"', $phpRewriteAllConf);
					#todo unhack this
				}

				$conf .= "\n" . $phpRewriteAllConf;
			}
			if ($rewriteSetting eq 'query') {
				my $phpRewriteQueryConf = GetTemplate('lighttpd/lighttpd_php_rewrite_query.conf.template');
				$conf .= "\n" . $phpRewriteQueryConf;
			}
		}
	}

	if (GetConfig('admin/ssi/enable')) {
		my $ssiConf = GetTemplate('lighttpd/lighttpd_ssi.conf.template');

		WriteLog('$ssiConf beg =====');
		WriteLog($ssiConf);
		WriteLog('$ssiConf end =====');

		$conf .= "\n" . $ssiConf;
	}
	if (GetConfig('admin/http_auth/enable')) {
		my $basicAuthConf = GetTemplate('lighttpd/lighttpd_basic_auth.conf.template');

		WriteLog('$basicAuthConf beg =====');
		WriteLog($basicAuthConf);
		WriteLog('$basicAuthConf end =====');

		$conf = $basicAuthConf . "\n" . $conf;
	}

	return $conf;
} # GetLighttpdConfig()

if (GetConfig('admin/lighttpd/enable')) {
	# lighttpd module enabled
	WriteMessage("admin/lighttpd/enable was true");
	my $lighttpdConf = GetLighttpdConfig();

	WriteLog('===== beg $lighttpdConf =====');
	WriteLog($lighttpdConf);
	WriteLog('===== end $lighttpdConf =====');

	WriteMessage('PutFile(\'config/lighttpd/lighttpd.conf\', $lighttpdConf);');
	PutFile('config/lighttpd/lighttpd.conf', $lighttpdConf);

	if (GetConfig('admin/http_auth/enable')) {
		my $basicAuthUserFile = GetTemplate('lighttpd/lighttpd_password.template');
		PutFile('config/lighttpd/lighttpd_password.conf', $basicAuthUserFile);

		my $htpasswdAuthUserFile = GetConfig('admin/http_auth/htpasswd');
		PutFile('config/lighttpd/lighttpd_htpasswd.conf', $htpasswdAuthUserFile);
	}

	if (GetConfig('admin/lighttpd/open_browser_after_start')) {
#		WriteMessage('Opening browser in 3...');
#		sleep 2;
#		WriteMessage('Opening browser in 2...');
#		sleep 2;
#		WriteMessage('Opening browser in 1...');
#		sleep 2;
		my $portNumber = GetConfig('admin/lighttpd/port');
		if ($portNumber =~ m/^([0-9]+)$/) {
			$portNumber = $1;
			my $openString = 'screen -S test -d -m xdg-open "http://localhost:' . $portNumber . '/help.html"';
			WriteMessage('Opening browser with `' . $openString . '`');
			
			my $openResult = `$openString`;
			WriteMessage('$openResult = ' . $openResult);
		}
	}

	WriteMessage("===================\n");
	WriteMessage("Starting server!...\n");
	WriteMessage('http://localhost:' . GetConfig('admin/lighttpd/port') . '/help.html' . "\n");
	WriteMessage("===================\n");
	StartLighttpd();
} # if (GetConfig('admin/lighttpd/enable'))
else {
	WriteMessage("server_local_lighttpd.pl: WARNING: admin/lighttpd/enable was false, not starting server");
}

1;
