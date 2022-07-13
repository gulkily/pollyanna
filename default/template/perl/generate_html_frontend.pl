#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl -T

use strict;
use 5.010;
use utf8;

require('./utils.pl');
#require_once('./pages.pl');
MakeSummaryPages(); # generate_html_frontend.pl
BuildTouchedPages(); # generate_html_frontend.pl

1;
