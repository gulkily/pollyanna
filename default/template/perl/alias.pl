#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAlias { # $fingerprint, $noCache ; Returns alias for an author
    my $fingerprint = shift;

    if (!$fingerprint) {
        WriteLog('GetAlias: warning: $fingerprint was missing; caller = ' . join(',', caller));
        return '';
    }

    chomp $fingerprint;

    if ($fingerprint = IsFingerprint($fingerprint)) {
        # sanity check passed
    } else {
        WriteLog('GetAlias: warning: $fingerprint failed sanity check; caller = ' . join(',', caller));
        return '';
    }

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
        # alias was found, sanitize and return

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
        # alias was not found, return empty string
        return '';
    }
} # GetAlias()

1;