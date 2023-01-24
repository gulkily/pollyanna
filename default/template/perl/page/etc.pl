#!/usr/bin/perl -T

use strict;
use warnings;

sub GetEtcPage { # returns html for etc page (/etc.html)
	my $txtIndex = "";

	my $title = "More";
	my $titleHtml = "More";

	$txtIndex = GetPageHeader('etc');

	$txtIndex .= GetTemplate('html/maincontent.template');

	require_once('widget/menu.pl');

	my $menuItems = GetMenuFromList('menu', 'html/menuitem-p.template'); # GetEtcPage()
	$menuItems .= GetMenuFromList('menu_advanced', 'html/menuitem-p.template'); # GetEtcPage()
	$menuItems .= GetMenuFromList('menu_admin', 'html/menuitem-p.template'); # GetEtcPage()

	my $etcPageContent = GetTemplate('html/etc.template');

	$etcPageContent =~ s/\$etcMenuItems/$menuItems/;

	my $etcPageWindow = GetDialogX($etcPageContent, 'More');

	$txtIndex .= $etcPageWindow;

	$txtIndex .= GetPageFooter('etc');

	$txtIndex = InjectJs($txtIndex, qw(utils clock settings avatar profile));

#	my $scriptsInclude = '<script src="/openpgp.js"></script><script src="/crypto.js"></script>';
#	$txtIndex =~ s/<\/body>/$scriptsInclude<\/body>/;

	# if (GetConfig('admin/js/enable')) {
	#	$txtIndex =~ s/<body /<body onload="SettingsOnload();" /;
	# }

	return $txtIndex;
}

1;
