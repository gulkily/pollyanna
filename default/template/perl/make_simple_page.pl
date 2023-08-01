#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

require_once('dialog.pl');

sub MakeSimplePage { # given page name, makes page
# sub GetSimplePage {
# sub WriteSimplePage {
# sub PutSimplePage {

# i think it is better to
# make a "sub GetFooPage"
# than to use this sub

# help.html
	my $pageName = shift;
	if (!$pageName) {
		return;
	}
	chomp $pageName;
	if (!$pageName =~ m/^[a-z]+$/) {
		WriteLog('MakeSimplePage: warning: $pageName failed sanity check');
		return '';
	}

	WriteLog('MakeSimplePage(' . $pageName . '); caller = ' . join(',', caller));

	my $html = '';
	my $subFound = 0;

	my $perlTemplate = GetTemplate('perl/page/' . $pageName . '.pl');

	if ($perlTemplate && trim($perlTemplate)) {
		#todo this is a hack, it shouldn't patch it into config but instead use the actual theme path
		#it's ok for now though, except when we change the theme, which requires a recompile

		WriteLog('MakeSimplePage: $pageName.pl found!');

		PutConfig('template/perl/page/'. $pageName . '.pl', $perlTemplate);
		ensure_module('page/' . $pageName . '.pl');
		require_once('page/' . $pageName . '.pl');

		{
			# start a new scope to keep the effect of "no strict"
			#todo maybe there is a better way to do this?
			# i read something about dispatch tables:
			# Dispatch Table
			#
			# 	A typical dispatch table is an array of subroutine references. The following example shows %options as a dispatch table that maps a set of command-line options to different subroutines:
			#
			# %options = (       # For each option, call appropriate subroutine.
			# 	"-h"         => \&help,
			# 	"-f"         => sub {$askNoQuestions = 1},
			# 	"-r"         => sub {$recursive = 1},
			# 	"_default_"  => \&default,
			# );
			#
			# ProcessArgs (\@ARGV, \%options); # Pass both as references
			#
			# #
			no strict 'refs';
			my $subName = 'Get' . ucfirst($pageName) . 'Page';
			if (exists &{$subName}) {
				WriteLog('MakeSimplePage: ' . $subName . '() exists! calling it...');
				$html = &{$subName}();
				$subFound = 1;
			} else {
				WriteLog('MakeSimplePage: warning: ' . $subName . '() was not found!');
			}
		}
	}

	if (!$subFound) {
		WriteLog('MakeSimplePage: $subFound = FALSE');

		my $title = ucfirst($pageName);

		if (GetConfig('admin/expo_site_mode')) {
			if (lc($pageName) eq 'media') {
				$title = 'Media Partners';
			}

			if (lc($pageName) eq 'academic') {
				$title = 'Academic Partners';
			}
		}

		$html .= GetPageHeader($pageName);
		$html .= GetTemplate('html/maincontent.template');

		my $pageContent = GetTemplate("html/page/$pageName.template");
		if (trim($pageContent) eq '') {
			$pageContent = 'Coming Soon...';
		}
		my $contentWindow = GetDialogX(
			$pageContent,
			$title
		);

		my $itemListPlaceholder = '<span id=itemList></span>';
		if (GetConfig('html/simple_page_list_items')) {
			if (GetTemplate('query/'.$pageName)) {
				$contentWindow .= GetQueryAsDialog($pageName, 'Discussions About ' . $title);
				# not sure the reason for $contentWindow
			}

			if (GetConfig('debug')) {
				$contentWindow .= GetQueryAsDialog('gtd');
			}

			#if (GetConfig('admin/js/enable')) {
			#	$html = AddAttributeToTag($html, 'input name=comment', onpaste, "window.inputToChange=this; setTimeout('ChangeInputToTextarea(window.inputToChange); return true;', 100);");
			#} #input_expand_into_textarea

			if (index($html, $itemListPlaceholder) != -1) {
				my %queryParams;
				$queryParams{'where_clause'} = "WHERE ','||item_flat.tags_list||',' LIKE '%," . $pageName . ",%' AND item_flat.item_score > 0"; #loose match #todo
				$queryParams{'order_clause'} = "ORDER BY item_flat.add_timestamp DESC"; #order by timestamp desc
				$queryParams{'limit_clause'} = "LIMIT 100";
				my @files = DBGetItemList(\%queryParams);
				if (@files) {
					my $itemListHtml = GetItemListHtml(\@files);
					$contentWindow = $itemListHtml;
				}
			}
		}

		if (trim($pageContent) eq '') {
			$pageContent = 'Coming Soon...';
		}

		$html .= $contentWindow;

		$html .= GetPageFooter($pageName);
		#$html .= GetPageFooter($pageType);

		if (GetConfig('admin/js/enable')) {
			my @scripts = qw(avatar settings profile utils timestamp clock);
			if (GetConfig('admin/js/dragging')) {
				push @scripts, 'dragging'; # MakeSimplePage()
			}
			$html = InjectJs($html, @scripts);
		}
	} else {
		WriteLog('MakeSimplePage: $subFound = FALSE');
	}

	PutHtmlFile("$pageName.html", $html);

	# my $defaultHomePage = 'welcome';
	# if (GetConfig('html/home_page')) {
	# 	$defaultHomePage = GetConfig('html/home_page');
	# 	if ($defaultHomePage =~ m/^([0-9a-z]+)/) {
	# 		$defaultHomePage = $1;
	# 	}
	# }

	if ($pageName eq 'welcome') {
		WriteLog('MakeSimplePage: welcome page, writing index.html; caller = ' . join(',', caller));
		PutHtmlFile("index.html", $html);
	}
} # MakeSimplePage()

1;
