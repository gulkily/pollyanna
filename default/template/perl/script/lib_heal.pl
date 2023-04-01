#!/usr/bin/perl

# test for missing libraries and try to fill them in from default

$result = system("perl -e 'use lib qw(lib); use URI::Encode;'");
if ($result) {
    # problem including URI::Encode
    system("mkdir lib; mkdir lib/URI; cp default/template/perl/lib/URI/Encode.pm lib/URI/Encode.pm");
} else {
    # 0 means it is ok
}

#$result = system("perl -e 'use lib qw(lib); use URI::Escape;'");

#print $result;