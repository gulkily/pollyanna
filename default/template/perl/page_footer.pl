#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetPageFooter { # $pageType ; returns html for page footer
# sub GetFooter {

# uses html/htmlend.template
# adds menubar if setting/html/menu_bottom is true
# adds loading_end.js if setting/admin/js/loading is true
# adds html/widget/back_to_top_button.template if setting/html/back_to_top_button is true
# adds html/widget/reset_button.template if setting/html/reset_button is true
# adds stats_footer_ssi.template if setting/admin/ssi/enable is true
# adds GetRecentItemsDialog() if setting/html/recent_items_footer is true
# adds no-js notice if js/enable is true

	WriteLog('GetPageFooter()');

	my $pageType = shift;
	if (!$pageType) {
		$pageType = '';
	}

	if (
		!$pageType ||
		(index($pageType, ' ') != -1)
	) {
		WriteLog('GetPageFooter: warning: $pageType failed sanity check; caller = ' . join(',', caller));
	}

	my $txtFooter = GetTemplate('html/htmlend.template');

	#my $disclaimer = GetString('disclaimer');
	#$txtFooter =~ s/\$disclaimer/$disclaimer/g;

	$txtFooter = FillThemeColors($txtFooter);

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/loading')) { #finished loading
		$txtFooter = InjectJs2($txtFooter, 'after', '</html>', qw(loading_end));

		# # #templatize #loading
		#this would hide all dialogs until they are ready to be shown
		#it is a major impediment for many browsers, and should not be enabled willy-nilly
		#it's challenging to show the dialogs reliably, especially with the !important bit
		#todo how to override this style and remove it? remove node?
		#the reason for trying this is trying to avoid windows changing position after page load
		# # #
		#$txtFooter .= "<style><!-- .dialog { display: table !important; } --></style>";
		# # #
	}

	if (GetConfig('html/back_to_top_button')) {
		# add back to top button to the bottom of the page, right before </body>
		my $backToTopTemplate = GetTemplate('html/widget/back_to_top_button.template');
		$backToTopTemplate = FillThemeColors($backToTopTemplate);
		$txtFooter =~ s/\<\/body>/$backToTopTemplate<\/body>/i;

		$txtFooter = InjectJs2($txtFooter, 'after', '</html>', qw(back_to_top_button));
	}

	if (GetConfig('setting/html/reset_button')) {
		if (GetConfig('setting/admin/php/enable') && GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
			my $resetButton = GetTemplate('html/widget/reset_button.template');
			$resetButton = FillThemeColors($resetButton);
			$txtFooter =~ s/\<\/body>/$resetButton<\/body>/i;
		} else {
			WriteLog('GetPageFooter: warning: reset_button requires php, js, and draggable. not adding reset button.');
		}
	}

	if (GetConfig('admin/ssi/enable') && GetConfig('admin/ssi/footer_stats')) {
		#footer stats inserted by ssi
		WriteLog('GetPageFooter: ssi footer conditions met!');
		# footer stats
		$txtFooter = str_replace(
			'</body>',
			GetTemplate('stats_footer_ssi.template') . '</body>',
			$txtFooter
		);
	} # ssi footer stats
	else {
		WriteLog('GetPageFooter: ssi footer conditions NOT met!');
	}

	if (
		GetConfig('html/menu_bottom') ||
		(
			GetConfig('html/menu_top') &&
			($pageType eq 'item')
			# for item pages, we still put the menu at the bottom, because the item's content
			# is the most important part of the page.
			# #todo this is confusing the way it's written right now, improve on it somehow
		)
	) {
		if ($pageType eq 'welcome' && GetConfig('admin/php/route_welcome_desktop_logged_in') && GetConfig('admin/php/force_profile')) {
			# when force_profile setting is on, there should be
			# no menu on welcome page if not logged in
		} else {
			require_once('widget/menu.pl');
			my $menuBottom = GetMenuTemplate($pageType); # GetPageFooter()

			# if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging') && GetConfig('admin/js/controls_footer')) {
			# 	my $dialogControls = GetTemplate('html/widget/dialog_controls.template'); # GetPageFooter()
			# 	$dialogControls = GetDialogX($dialogControls, 'Controls'); # GetPageFooter()
			# 	#$dialogControls = '<span class=advanced>' . $dialogControls . '</span>';
			# 	$menuBottom .= $dialogControls;
			# }

			$txtFooter = str_replace(
				'</body>',
				'<br>' . $menuBottom . '</body>',
				$txtFooter
			);
		}
	}

	if (GetConfig('setting/admin/js/enable')) {
		require_once('dialog.pl');
		my $noJsInfo = GetDialogX('<b class=noscript>*</b> Some features may require JavaScript', 'Notice'); # GetDialog()
		$noJsInfo = '<noscript>' . $noJsInfo . '</noscript>';
		$txtFooter = str_replace(
			'</body>',
			'<br>' . $noJsInfo . '</body>',
			$txtFooter
		);
	}

	if (GetConfig('html/recent_items_footer')) {
		require_once('widget/recent_items.pl');
		$txtFooter = GetRecentItemsDialog() . $txtFooter;
	}

	# if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging') && GetConfig('admin/js/controls_footer')) {
	# 	my $dialogControls = GetTemplate('html/widget/dialog_controls.template'); # GetPageFooter()
	# 	$dialogControls = GetDialogX($dialogControls, 'Controls');
	# 	#$dialogControls = '<span class=advanced>' . $dialogControls . '</span>';
	# 	$txtFooter = str_replace(
	# 		'</body>',
	# 		'<br>' . $dialogControls . '</body>',
	# 		$txtFooter
	# 	);
	# }

	return $txtFooter;
} # GetPageFooter()

1;