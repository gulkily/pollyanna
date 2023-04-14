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

if (!GetConfig('admin/python3_server/enable')) {
    if (GetConfig('admin/dev/dont_confirm') || GetYes('admin/python3_server/enable is false, set to true?', 1)) {
        PutConfig('admin/python3_server/enable', 1);
    }
} # if (!GetConfig('admin/python3_server/enable'))

sub FindBinPath { # $binName, $configPath ; tries to figure out local path for a binary
    # sub GetBinPath {
    # sub FindBinaryPath {
    # $binName is the name of the binary, e.g. python3
    # $configPath is where the path may be stored in config

    # READ ARGUMENTS #####
    my $binName = shift;
    chomp $binName;
    my $configPath = shift;
    chomp $configPath;

    # INITIALIZE RETURN VALUE #####
    my $binPath = '';

    # SANITY CHECK ARGUMENTS #####
    if ($binName =~ m/^([a-zA-Z0-9\-_]+)$/) {
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

sub StartHttpServer { # run command to start local python3 http.server instance
    WriteLog('StartHttpServer() BEGIN');
    if (!-e './log') {
        mkdir('./log');
    }

    my $insanityLevel = 2; # track sanity checklist
    my $portNumber = GetConfig('admin/python3_server/port');
    if ($portNumber =~ m/^([0-9]+)/) {
        $portNumber = $1;
    } else {
        WriteLog('StartHttpServer: warning: $portNumber failed sanity check');
        return '';
    }
    $portNumber = int($portNumber);
    if ($portNumber > 0 && $portNumber <= 65535 ) {
        $insanityLevel--;
    }
    my $port = $portNumber;

    my $pathPython3 = FindBinPath('python3', 'setting/admin/python3_server/path');
    WriteLog('StartHttpServer: $pathPython3 = ' . $pathPython3);

    if (-e $pathPython3) {
        WriteLog('StartHttpServer: path found is good, continuing; $pathPython3 = ' . $pathPython3);
    } # if (-e $pathPython3)
    else {
        WriteLog('StartHttpServer: warning: $pathPython3 is FALSE');
    } # else (!-e $pathPython3)

    if ($pathPython3 =~ m/^([^\s]+)$/) {
        $pathPython3 = $1;
        $insanityLevel--;
    }

    WriteLog('StartHttpServer: $pathPython3 = ' . $pathPython3);
    WriteLog('StartHttpServer: $port = ' . $port);
    WriteLog('StartHttpServer: $insanityLevel = ' . $insanityLevel);

    if ($insanityLevel == 0) {
        print "\n";
        my $docRoot = GetDir('html');

        if (GetConfig('setting/admin/cgi/enable')) {
            system("$pathPython3 -m http.server -d $docRoot --cgi $port 2> log/p3access.log");
        } else {
            system("$pathPython3 -m http.server -d $docRoot $port 2> log/p3access.log");
        }

        #todo background it if opening browser
    } # if ($insanityLevel == 0)
    else {
        WriteMessage('StartHttpServer: python3 path missing or failed sanity check. $insanityLevel = ' . $insanityLevel);
    }
} # StartHttpServer()

if (GetConfig('admin/python3_server/enable')) {
    # python3_server module enabled
    WriteMessage("admin/python3_server/enable was true");

    if (GetConfig('admin/http_auth/enable')) {
        #todo
        WriteMessage('Warning: python3_server is not compatible with http_auth at this time');
    }

    WriteMessage("===================\n");
    WriteMessage("Starting server!...\n");
    WriteMessage('http://localhost:' . GetConfig('admin/python3_server/port') . '/help.html' . "\n");
    WriteMessage("===================\n");
    StartHttpServer();
} # if (GetConfig('admin/python3_server/enable'))
else {
    WriteMessage("server_local_python.pl: WARNING: admin/python3_server/enable was false, not starting server");
}

1;
