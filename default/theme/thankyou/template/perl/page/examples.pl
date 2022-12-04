#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetExamplesPage {
    my $html =
        GetPageHeader('examples') .
        GetWindowTemplate(GetTemplate('html/page/examples.template'), 'Examples') .
        GetPageFooter('examples')
    ;

    return $html;
} # GetExamplesPage()

1;
