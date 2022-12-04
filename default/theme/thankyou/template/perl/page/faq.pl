#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetFaqPage {
    my $html =
        GetPageHeader('faq') .
        GetWindowTemplate(GetTemplate('html/page/faq.template'), 'FAQ') .
        GetPageFooter('faq')
    ;

    return $html;
} # GetFaqPage()

1;
