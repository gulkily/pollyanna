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
			WriteLog('GetPageFooter: warning: reset_button requires php, js, and js/dragging. not adding reset button.');
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

	if (GetConfig('setting/html/css/footer_edit')) { #todo setting/html/css/footer_edit
		WriteLog('GetPageFooter: adding css textarea');

		my $pageStylesheet = GetPageStylesheet($pageType);
		if ($pageStylesheet) {

			my $escapedCssOutput = HtmlEscape($pageStylesheet);
			my $textareaCss = '<textarea name=newCss cols=80 rows=10>' . $escapedCssOutput . '</textarea>';
			my $inputPageType = '<input type=hidden name=pageType value=' . $pageType . '>';
			my $inputReturnTo = '<input type=hidden name=returnTo value=' . "/$pageType.html" . '>'; #todo
			my $buttonSave = '<input type=submit value=Save>';
			my $form = '<form class=advanced action="/post.html" method=GET>' . GetDialogX($textareaCss . '<br>' . $buttonSave . $inputPageType . $inputReturnTo, 'Style Editor') . '</form>';

			# footer stats
			$txtFooter = str_replace(
				'</body>',
				$form . '</body>',
				$txtFooter
			);
		} else {
			my $escapedCssOutput = HtmlEscape('');
			my $textareaCss = '<textarea name=newCss cols=80 rows=10>' . $escapedCssOutput . '</textarea>';
			my $inputPageType = '<input type=hidden name=pageType value=' . $pageType . '>';
			my $buttonSave = '<input type=submit value=Save>';
			my $form = '<form action="/post.html" method=GET>' . $textareaCss . '<br>' . $buttonSave . $inputPageType . '</form>';

			# footer stats
			$txtFooter = str_replace(
				'</body>',
				$form . '</body>',
				$txtFooter
			);
		}
	}
	else {
		WriteLog('GetPageFooter: NOT adding css textarea');
	}

	if (
		GetConfig('html/menu_bottom') ||
		(
			GetConfig('html/menu_top') &&
			($pageType eq 'item') &&
			GetConfig('html/item_page_menu_bottom')
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
			$noJsInfo . '</body>',
			$txtFooter
		);
	}

	if (GetConfig('html/recent_items_footer')) {
		require_once('widget/recent_items.pl');
		#$txtFooter = $txtFooter . GetRecentItemsDialog();
		$txtFooter = str_replace(
			'</body>',
			GetRecentItemsDialog() . '</body>',
			$txtFooter
		);
	}

	if (GetConfig('setting/html/footer_page_concept')) {
		my $conceptString = '';
		$conceptString = GetString('concept/' . $pageType . '.txt', '', 1);
		if (!$conceptString) {
			$conceptString = GetString('concept/' . substr($pageType, 0, length($pageType) - 1) . '.txt', '', 1);
		}
		if ($conceptString) {
			# sub GetConceptDialog { #TODO, CURRENTLY USED LOOK HERE, #todo: factor out to its own procedure
			my $conceptDialog = GetDialogX('<fieldset>'.ConceptForWeb($conceptString).'</fieldset>', 'Concept');
			#my $conceptDialog = GetDialogX(ConceptForWeb($conceptString), 'Concept: ' . $pageType);
			$conceptDialog = '<span class=advanced>' . $conceptDialog . '</span>';
			# my $conceptDialog = GetDialogX(ConceptForWeb($conceptString), 'Concept: ' . $pageType);
			$txtFooter = str_replace(
				'</body>',
				$conceptDialog . '</body>',
				$txtFooter
			);
		} else {
			WriteLog('GetPageFooter: warning: $conceptString is FALSE; $pageType = ' . $pageType . '; caller = ' . join(',', caller));
			my $noConceptDialog = GetDialogX('<fieldset>Concept for this page is not defined yet.</fieldset>', 'Concept');
			$txtFooter = str_replace(
			    '</body>',
			    $noConceptDialog . '</body>',
			    $txtFooter
			);
		}
	} # if (GetConfig('setting/html/footer_page_concept'))

	if (GetConfig('setting/html/page_map_bottom')) { #todo js and dragging checks #pagemap_bottom
		if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
			require_once('dialog/page_map.pl');
			$txtFooter = str_replace('</body>', GetPageMapDialog() . '</body>', $txtFooter);
		} else {
			#todo

		}
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

sub GetPageFooterWithoutMenu { # $pageType ; returns html for page footer
	my $txtFooter = GetTemplate('html/htmlend.template');
	$txtFooter = FillThemeColors($txtFooter);
	return $txtFooter;
}

1;