#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetDocumentationPage {
    my $html =
        GetPageHeader('documentation') .
        GetWindowTemplate(GetTemplate('html/page/documentation.template'), 'Documentation') .
        GetPageFooter('documentation')
    ;

    return $html;
} # GetDocumentationPage()

1;
