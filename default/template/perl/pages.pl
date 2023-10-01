#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl -T

# pages.pl
# to do with html page generation

use strict;
use warnings;
use 5.010;
use utf8;

my @foundArgs;
while (my $argFound = shift) {
	push @foundArgs, $argFound;
}

use lib qw(lib);
use URI::Escape qw(uri_escape);
use Digest::MD5 qw(md5_hex);
use POSIX qw(strftime ceil);
use Data::Dumper;
use File::Copy;
use Cwd qw(cwd);

require('./config/template/perl/utils.pl');
require_once('sqlite.pl');
require_once('makepage.pl');

sub GetDialogPage { # $pageName, $pageTitle, $windowContents ; returns html page with dialog
# sub GetDialog()
# this is for getting one page with one dialog, not a /dialog/... page
	my $pageName = shift; # page name: 404
	my $pageTitle = shift; # page title (
	my $windowContents = shift;

	my @allowedPages = qw(401 404);
	if (!in_array($pageName, @allowedPages)) {
		WriteLog('GetDialogPage: warning: $pageName not in @allowedPages; caller = ' . join(',', caller));
		return '';
	}

	if ($pageName) {
		if ($pageName eq '404') { #/404.html
			$windowContents = GetTemplate('html/404.template');

			if (GetConfig('admin/expo_site_mode')) {
				$windowContents = str_replace(
					'<span id=lookingFor></span>',
					'',
					$windowContents
				)
			} else {
				$windowContents = str_replace(
					'<span id=lookingFor></span>',
					'<span id=lookingFor></span>' . GetTemplate('html/form/looking_for.template') . '</span>',
					$windowContents
				)
			}

			my $pageTemplate;
			$pageTemplate = '';

			$pageTemplate .= GetPageHeader('404'); #GetTemplate('html/htmlstart.template');
			$pageTemplate .= GetTemplate('html/maincontent.template');
			$pageTemplate .= GetDialogX($windowContents, $pageTitle);
			#: $windowTitle, $windowMenubar, $columnHeadings, $windowBody, $windowStatus
			$pageTemplate .= GetPageFooter('404');

			# settings.js provides ui consistency with other pages
			$pageTemplate = InjectJs($pageTemplate, qw(settings profile));

			return $pageTemplate;
		}
		if ($pageName eq '401') { #/401.html
			my $message = GetConfig('admin/http_auth/message_401');
			$message =~ s/\n/<br>/g;

			$windowContents = GetTemplate('html/401.template');
			$windowContents = str_replace('<p id=message></p>', '<p id=message>' . $message . '</p>', $windowContents);

			my $pageTemplate;
			$pageTemplate = '';

			$pageTemplate .= GetPageHeader('401'); #GetTemplate('html/htmlstart.template');
			$pageTemplate .= GetTemplate('html/maincontent.template');
			$pageTemplate .= GetDialogX($windowContents, $pageTitle);
			$pageTemplate .= GetPageFooter('401');

			return $pageTemplate;
		}
		if ($pageName eq 'ok') {
		}
	}
} # GetDialogPage()

sub RenderLink {
	my $url = shift;
	my $title = shift;

	WriteLog('RenderLink: $url = ' . $url . '; $title = ' . $title);

	my $link = '<a></a>';
	$link = str_replace('<a></a>', '<a>' . $title . '</a>', $link);
	$link = AddAttributeToTag($link, 'a', 'href', $url);

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
		if ($url =~ m/\/tag\//) {
			$link = AddAttributeToTag($link, 'a ', 'onclick', "if ((window.GetPrefs) && GetPrefs('draggable_spawn') && window.FetchDialogFromUrl) { return FetchDialogFromUrl('/dialog" . $url . "'); }");
			#bughere #todo this is where needs fix for duplicate hashtag listing dialogs #duplicatedialogs
			#todo this may not be the right place for this at all
		}
	}

	return $link;
} # RenderLink()

require_once('render_field.pl');

require_once('dialog/query_as_dialog.pl');

sub LightenColor { # $color ; returns a lightened version of a color
	my $color = shift;
	my @rgb;

	WriteLog('LightenColor: before: $color = ' . $color);

	my $hashPrefix = '';
	if (substr($color, 0, 1) eq '#') {
		$hashPrefix = '#';
		$color = substr($color, 1);
	}

	if ($color =~ m/^([a-fA-F0-9]{6})$/) {
		$color = $1;
		WriteLog('LightenColor: sanity check passed: $color = ' . $color);
	} else {
		WriteLog('LightenColor: warning: sanity check FAILED');
		return '';
	}

	$rgb[0] = hex(substr($color, 0, 2));
	$rgb[1] = hex(substr($color, 2, 2));
	$rgb[2] = hex(substr($color, 4, 2));

	while ($rgb[0] < 128 || $rgb[1] < 228 || $rgb[2] < 228) {
		$rgb[0] = $rgb[0] + 1;
		$rgb[1] = $rgb[1] + 1;
		$rgb[2] = $rgb[2] + 1;

		$color = sprintf("%X", $rgb[0]) . sprintf("%X", $rgb[1]) . sprintf("%X", $rgb[2]);
		WriteLog('LightenColor: after: $color = ' . $color);

	}

	if ($rgb[0] > 255) {
		$rgb[0] = 255;
	}

	if ($rgb[1] > 255) {
		$rgb[1] = 255;
	}

	if ($rgb[2] > 255) {
		$rgb[2] = 255;
	}

	$color = sprintf("%X", $rgb[0]) . sprintf("%X", $rgb[1]) . sprintf("%X", $rgb[2]);
	$color = $hashPrefix . $color;
	WriteLog('LightenColor: after: $color = ' . $color);

	return $color;
} # LightenColor()

require_once('resultset_as_dialog.pl');

require_once('widget/stylesheet.pl');

require_once('widget/author_link.pl');

sub GetPageLink { # returns one pagination link as html, used by GetPageLinks
	my $pageNumber = shift;
	my $itemCount = shift;

	my $pageLimit = GetConfig('html/page_limit');
	if (!$pageLimit) {
		#fallback
		WriteLog('GetPageLink: warning: $pageLimit was FALSE, setting to sane 25');
		$pageLimit = 25;
	}

	my $pageStart = $pageNumber * $pageLimit;
	my $pageEnd = $pageNumber * $pageLimit + $pageLimit;
	if ($pageEnd > $itemCount) {
		$pageEnd = $itemCount - 1;
	}
	my $pageCaption = $pageStart . '-' . $pageEnd;

	state $pageLinkTemplate;
	if (!defined($pageLinkTemplate)) {
		$pageLinkTemplate = GetTemplate('html/widget/pagelink.template');
	}

	my $pageLink = $pageLinkTemplate;
	$pageLink =~ s/\$pageName/$pageCaption/;

	$pageLink =~ s/\$pageNumber/$pageNumber/;

	return $pageLink;
} # GetPageLink()

require_once('dialog.pl');

sub GetPageLinks { # $currentPageNumber ; returns html for pagination links with frame/window
	my $currentPageNumber = shift; #

	state $pageLinks; # stores generated links html in case we need them again

	my $pageLimit = GetConfig('html/page_limit'); # number of items per page

	if (!$pageLimit) {
		WriteLog('GetPageLink: warning: $pageLimit was FALSE, setting to sane 25');
		$pageLimit = 25;
	}

	my $itemCount = DBGetItemCount(); # item count

	if (!$itemCount) {
		WriteLog('GetPageLink: warning: $itemCount was FALSE, sanity check failed');
		return '';
	}

	WriteLog("GetPageLinks($currentPageNumber)");

	# check if we've generated the html already, if so, use it
	if (defined($pageLinks)) {
		WriteLog('GetPageLinks: $pageLinks already exists, doing search and replace');

		my $currentPageTemplate = GetPageLink($currentPageNumber, $itemCount);

		my $currentPageStart = $currentPageNumber * $pageLimit;
		my $currentPageEnd = $currentPageNumber * $pageLimit + $pageLimit;
		if ($currentPageEnd > $itemCount) {
			$currentPageEnd = $itemCount - 1;
		}

		my $currentPageCaption = $currentPageStart . '-' . $currentPageEnd;

		my $pageLinksReturn = $pageLinks; # make a copy of $pageLinks which we'll modify

		$pageLinksReturn =~ s/$currentPageTemplate/<b>$currentPageCaption<\/b> /g;
		# replace current page link with highlighted one

		return $pageLinksReturn;
	} else {
		# we've ended up here because we haven't generated $pageLinks yet

		WriteLog('GetPageLinks: $itemCount = ' . $itemCount);

		$pageLinks = "";

		my $lastPageNum = ceil($itemCount / $pageLimit);

		if ($itemCount > $pageLimit) {
			#		for (my $i = $lastPageNum - 1; $i >= 0; $i--) {
			for (my $i = 0; $i < $lastPageNum; $i++) {
				my $pageLinkTemplate;
				#			if ($i == $currentPageNumber) {
				#				$pageLinkTemplate = "<b>" . $i . "</b>";
				#			} else {
				$pageLinkTemplate = GetPageLink($i, $itemCount);
				#			}

				$pageLinks .= $pageLinkTemplate;
			}
		}

		my $frame = GetTemplate('html/pagination.template');

		$frame =~ s/\$paginationLinks/$pageLinks/;

		$pageLinks = $frame;

		# up to this point, we are building the in-memory template for the pagination links
		# once it is stored in $pageLinks, which is a static ("state") variable,
		# GetPageLinks() returns at the top, and does not reach here.
		return GetPageLinks($currentPageNumber);
	}
} # GetPageLinks()

require_once('widget/get_tag_page_header_links.pl');

require_once('replace_menu.pl');

sub GetQueryPage { # $pageName, $title, $columns ;
# sub GetQueryAsPage {
	my $pageName = shift;
	my $title = shift;
	my $columns = shift;

	if (!$columns) {
		$columns = '';
	}

	WriteLog('GetQueryPage: $pageName = ' . $pageName . '; $title = ' . ($title ? $title : 'FALSE') . '; $columns = ' . $columns);

	if (!$title) {
		$title = ucfirst($pageName);
	}
	if (!$columns) {
		$columns = '';
	}

	#todo sanity

	my $html = '';
	my $query = SqliteGetQueryTemplate($pageName);

	my @result = SqliteQueryHashRef($query);

	if (@result) {
		$html .= GetPageHeader($pageName);
		$html .= GetTemplate('html/maincontent.template');

		###
		$html .= GetResultSetAsDialog(\@result, $title, $columns);
		###

		my $queryWindowContents;

		$queryWindowContents .= '<pre>' . HtmlEscape($query) . '<br></pre>'; #todo templatify

		$html .= '<span class=advanced><form action=/post.html>'; #todo templatify
		$html .= GetDialogX($queryWindowContents, $pageName . '.sql', '', scalar(split("\n", $query)) . ' lines; ' . length($query) . ' bytes');
		$html .= '</form></span>';

		$html .= GetPageFooter($pageName);
		if (GetConfig('admin/js/enable')) {
			$html = InjectJs($html, qw(settings utils timestamp voting avatar));
			#todo only add timestamp if necessary?
		}
		return $html;
	} else {
#		$html .= GetPageHeader($pageName);
#		$html .= GetWindow('No results, please check index');
#		$html .= GetPageFooter($pageName);
		#todo
	}
} # GetQueryPage()

require_once('item_page.pl');

require_once('widget/item_html_link.pl');

sub GetItemTagsSummary { # returns html with list of tags applied to item, and their counts
	my $fileHash = shift;

	if (!IsItem($fileHash)) {
		WriteLog('GetItemTagsSummary: warning: sanity check failed');
		return '';
	}

	WriteLog("GetItemTagsSummary($fileHash)");
	my $voteTotalsRef = DBGetItemLabelTotals2($fileHash);
	my %voteTotals = %{$voteTotalsRef};

	my $votesSummary = '';

	foreach my $voteTag (keys %voteTotals) {
		$votesSummary .= "$voteTag (" . $voteTotals{$voteTag} . ")\n";
	}
	if ($votesSummary) {
		$votesSummary = $votesSummary;
	}

	return $votesSummary;
} # GetItemTagsSummary()

sub GetQuickVoteButtonGroup {
	my $fileHash = shift;
	my $returnTo = shift;

	my $quickVotesButtons = '';
	if ($returnTo) {
		WriteLog('GetQuickVoteButtonGroup: $returnTo = ' . $returnTo);
		$quickVotesButtons = GetItemLabelButtons($fileHash, $returnTo); #todo refactor to take vote totals directly
	} else {
		$quickVotesButtons = GetItemLabelButtons($fileHash); #todo refactor to take vote totals directly
	}

	my $quickVoteButtonGroup = GetTemplate('vote/votequick2.template');
	$quickVoteButtonGroup =~ s/\$quickVotesButtons/$quickVotesButtons/g;

	return $quickVoteButtonGroup;
} # GetQuickVoteButtonGroup()

require_once('format_message.pl');

require_once('image_container.pl');

sub GetTagsListAsHtmlWithLinks { # $tagsListParam ; prints up to 7 tags
	my $tagsListParam = shift;

	if (!$tagsListParam) {
		WriteLog('GetItemTemplate: warning: $tagsListParam is missing. caller: ' . join(',', caller));
		return '';
	}
	my @tagsList = split(',', $tagsListParam);

	my $headings;
	my $comma = '';

	my $safeLimit = 15; # don't print more than this many tags #hardcoded #todo

	foreach my $tag (@tagsList) {
		if (!$tag) {
			# sometimes $tagsListParam begins with a comma
			next;
		}

		if (!--$safeLimit) {
			# check if we've printed more than $safeLimit tags
			$headings .= '[...]';
			last;
		}

		$headings .= $comma;
		$comma = '; ';

		my $tagLink = GetTagLink($tag);

		#$headings .= 'tag='.$tag;
		$headings .= $tagLink;
	}

	return $headings;
} # GetTagsListAsHtmlWithLinks()

require_once('widget/tag_link.pl');

require_once('item_template.pl');

require_once('page_footer.pl');

sub GetSystemMenuList { # writes config/list/menu based on site configuration
	#todo this function is not obvious, overrides obvious list/menu
	my @menu;

	WriteLog('GetSystemMenuList()');

	my $menuList = '';

	if (GetConfig('admin/expo_site_mode')) {
		WriteLog('GetSystemMenuList: expo_site_mode');
		if (!GetConfig('admin/expo_site_edit')) {
			WriteLog('WriteMenuList: returning empty');
		}
	}

	push @menu, 'read';
	push @menu, 'write';

	if (GetConfig('admin/php/quickchat')) {
		push @menu, 'chat';
	}

	#upload
	if (GetConfig('admin/php/enable') && GetConfig('admin/upload/enable')) {
		# push @menu, 'art';
		push @menu, 'upload';
	}

	#profile
	if (GetConfig('admin/js/enable') || GetConfig('admin/php/enable')) {
		# one of these is required for profile to work
		push @menu, 'profile';
	} else {
		#todo hide it or something?
		#perhaps link to informational page on using offline profiles?
		push @menu, 'profile';
	}
	push @menu, 'help';

	return @menu;
} # GetSystemMenuList()

require_once('get_page_header.pl');

require_once('get_item_listing.pl');

sub GetItemPrefixPage { # $prefix ; returns page with items matching specified prefix
	WriteLog("GetItemPrefixPage()");

	my $prefix = shift;
	if (!IsItemPrefix($prefix)) {
		WriteLog('GetItemPrefixPage: warning: $prefix sanity check failed');
		return '';
	}

	WriteLog('GetItemPrefixPage: $prefix = ' . $prefix);

	my $htmlOutput = ''; # stores the html

	my $title = 'Items matching ' . $prefix;
	my $titleHtml = 'Items matching ' . $prefix;

	$htmlOutput = GetPageHeader('prefix'); # <html><head>...</head><body>
	$htmlOutput .= GetTemplate('html/maincontent.template'); # where "skip to main content" goes

	my @topItems = DBGetItemsByPrefix($prefix); # get top items from db

	my $itemCount = scalar(@topItems);

	WriteLog('GetItemPrefixPage: $itemCount = ' . $itemCount);

	if ($itemCount) {
	# at least one item returned
		my $itemListingWrapper = GetTemplate('html/item_listing_wrapper2.template'); # GetItemPrefixPage()
		my $itemListings = '';

		my $rowBgColor = ''; # stores current value of alternating row color
		my $colorRow0Bg = GetThemeColor('row_0'); # color 0
		my $colorRow1Bg = GetThemeColor('row_1'); # color 1

		if (scalar(@topItems)) {
			WriteLog('GetItemPrefixPage: scalar(@topItems) was true');
		} else {
			WriteLog('GetItemPrefixPage: warning: scalar(@topItems) was false');
		}

		while (@topItems) {
			my $itemTemplate = GetTemplate('html/item_listing.template'); # GetItemPrefixPage()
			# it's ok to do this every time because GetTemplate() already stores it in a static
			# alternative is to store it in another variable above

			#alternate row color
			if ($rowBgColor eq $colorRow0Bg) {
				$rowBgColor = $colorRow1Bg;
			} else {
				$rowBgColor = $colorRow0Bg;
			}

			my $itemRef = shift @topItems; # reference to hash containing item
			my %item = %{$itemRef}; # hash containing item data

			my $itemKey = $item{'file_hash'};
			my $itemScore = $item{'item_score'};
			my $authorKey = $item{'author_key'};

			my $itemLastTouch = DBGetItemLatestAction($itemKey); #todo add to itemfields

			my $itemTitle = $item{'item_title'};
			if (trim($itemTitle) eq '') {
				# if title is empty, use the item's hash
				# $itemTitle = '(' . $itemKey . ')';
				$itemTitle = 'Untitled';
			}
			$itemTitle = HtmlEscape($itemTitle);

			# my $itemLink = GetHtmlFilename($itemKey); # GetItemPrefixPage()
			my $itemLink = GetItemUrl($itemKey); # GetItemPrefixPage()

			my $authorAvatar;
			if ($authorKey) {
#				$authorAvatar = GetPlainAvatar($authorKey);
				my $authorLink = GetAuthorLink($authorKey, 1);
				if ($authorLink) {
					$authorAvatar = GetAuthorLink($authorKey, 1);
#					$authorAvatar = 'by ' . GetAuthorLink($authorKey, 1);
				} else {
					$authorAvatar = 'Unsigned';
				}
			} else {
				$authorAvatar = 'Unsigned';
			}

			$itemLastTouch = GetTimestampWidget($itemLastTouch);

			# populate item template
			$itemTemplate =~ s/\$link/$itemLink/g;
			$itemTemplate =~ s/\$itemTitle/$itemTitle/g;
			$itemTemplate =~ s/\$itemScore/$itemScore/g;
			$itemTemplate =~ s/\$authorAvatar/$authorAvatar/g;
			$itemTemplate =~ s/\$itemLastTouch/$itemLastTouch/g;
			$itemTemplate =~ s/\$rowBgColor/$rowBgColor/g;

			# add to main html
			$itemListings .= $itemTemplate;
		}

		$itemListingWrapper =~ s/\$itemListings/$itemListings/;

		my $statusText = '';
		if ($itemCount == 0) {
			$statusText = 'No threads found.';
		} elsif ($itemCount == 1) {
			$statusText = '1 thread';
		} elsif ($itemCount > 1) {
			$statusText = $itemCount . ' threads';
		}

#		my $columnHeadings = 'Title,Score,Replied,Author';
		my $columnHeadings = 'title,author,activity';

		$itemListingWrapper = GetDialogX(
			$itemListings,
			'Items prefixed ' . $prefix,
			$columnHeadings,
			$statusText,
			''
		);

		$htmlOutput .= $itemListingWrapper;
	} else {
	# no items returned, use 'no items' template
		$htmlOutput .= GetTemplate('html/item/no_items.template');
	}

	$htmlOutput .= GetPageFooter('prefix'); # </body></html>

	if (GetConfig('admin/js/enable')) {
		# add necessary js
		$htmlOutput = InjectJs($htmlOutput, qw(settings voting timestamp profile avatar utils));
	}

	return $htmlOutput;
} # GetItemPrefixPage()

require_once('dialog/stats_table.pl');
require_once('inject_js.pl');
require_once('dialog/author_info.pl');
require_once('widget/author_friends.pl');

require_once('get_read_page.pl');

require_once('item_list.pl');

sub GetAccessKey { # $caption ; returns access key to use for menu item
#sub AddAccessKey {
	# tries to find non-conflicting one
	WriteLog('GetAccessKey()');

	if (!GetConfig('html/accesskey')) {
		WriteLog('GetAccessKey: warning: sanity check failed');
		return '';
	}

	my $caption = shift;
	#todo sanity checks

	state %captionKey;
	state %keyCaption;
	if ($captionKey{$caption}) {
		return $captionKey{$caption};
	}

	my $newKey = '';
	for (my $i = 0; $i < length($caption) - 1; $i++) {
		my $newKeyPotential = lc(substr($caption, $i, 1));
		if ($newKeyPotential =~ m/^[a-z]$/ && $newKeyPotential ne 'o' && $newKeyPotential ne 'r') { # more/expand and reprint
			if (!$keyCaption{$newKeyPotential}) {
				$newKey = $newKeyPotential;
				last;
			}
		}
	}

	if ($newKey) {
		$captionKey{$caption} = $newKey;
		$keyCaption{$newKey} = $caption;
		return $captionKey{$caption};
	} else {
		#todo pick another letter, add in parentheses like this: File (<u>N</u>)
	}
} # GetAccessKey()

sub MakeJsTestPages {
	my $jsTestPage = GetTemplate('js/test.js');
	PutHtmlFile("jstest.html", $jsTestPage);

	my $jsTest2Page = GetTemplate('js/test2.js');
	#	$jsTest2Page = InjectJs($jsTest2Page, qw(sha512.js));
	PutHtmlFile("jstest2.html", $jsTest2Page);

	my $jsTest3Page = GetTemplate('js/test3.js');
	PutHtmlFile("jstest3.html", $jsTest3Page);

	my $jsTest4Page = GetTemplate('js/test4.js');
	PutHtmlFile("jstest4.html", $jsTest4Page);

	my $jsTest2 = GetTemplate('test/jstest1/jstest2.template');
	$jsTest2 = InjectJs($jsTest2, qw(jstest2));
	PutHtmlFile("jstest2.html", $jsTest2);
} # MakeJsTestPages()

require_once('make_simple_page.pl');

sub MakePhpPages {
	WriteLog('MakePhpPages() begin');

	if (GetConfig('admin/php/enable')) {
		# 'post.php'
		# 'test2.php'
		# 'config.php'
		# 'test.php'
		# 'write.php'
		# 'upload.php'
		# 'search.php'
		# 'cookie.php'
		# 'cookietest.php'
		# 'route.php'
		# 'quick.php'
		my @templatePhpSimple = qw(post test2 config test write upload search cookie cookietest utils route handle_not_found process_new_comment store_new_comment);
		if (GetConfig('admin/php/quickchat')) {
			push @templatePhpSimple, 'quick';
		}
		for my $template (@templatePhpSimple) {
			my $fileContent = GetTemplate("php/$template.php");
			state $PHPDIR = GetDir('php');
			PutFile($PHPDIR . "/$template.php", $fileContent);
		}

		my $utilsPhpTemplate = GetTemplate('php/utils.php');
		state $SCRIPTDIR = GetDir('script');
		state $PHPDIR = GetDir('php');
		$utilsPhpTemplate =~ s/\$scriptDirPlaceholderForTemplating/$SCRIPTDIR/g;
		PutFile($PHPDIR . '/utils.php', $utilsPhpTemplate);

		MakeSimplePage('post'); #post.html, needed by post.php
		GetTemplate('html/item_processing.template'); #to cache it in config/

		if (GetConfig('admin/htaccess/enable')) { #.htaccess
			MakeHtAccessPages();
		} #.htaccess
	} else {
		WriteLog('MakePhpPages: warning: called when admin/php/enable is FALSE');
		return '';
	}
} # MakePhpPages()

sub MakeJsPages {
	state $HTMLDIR = GetDir('html');

	# Zalgo javascript
	PutHtmlFile("zalgo.js", GetTemplate('js/lib/zalgo.js'));

	if (
		GetConfig('admin/js/openpgp')
		&&
			(!-e "$HTMLDIR/openpgp.js")
				||
			(!-e "$HTMLDIR/openpgp.worker.js")
	)
	{
		# OpenPGP javascript
		PutHtmlFile("openpgp.js", GetTemplate('js/lib/openpgp.js'));
		PutHtmlFile("openpgp.worker.js", GetTemplate('js/lib/openpgp.worker.js'));
	}

	if (GetConfig('setting/admin/js/dragging')) {
		PutHtmlFile("dragging.js", GetScriptTemplate('dragging'));
		#PutHtmlFile("dragging.js", GetTemplate('js/dragging.js'));
	}

	PutHtmlFile("sha512.js", GetTemplate('js/sha512.js'));

	if (GetConfig('admin/php/enable')) {
	#if php/enabled, then use post.php instead of post.html
	#todo add rewrites for this
	#rewrites have been added for this, so it's commented out for now, but could still be an option in the future
#		$cryptoJsTemplate =~ s/\/post\.html/\/post.php/;
	}
	#PutHtmlFile("crypto.js", $cryptoJsTemplate);

	my $crypto2JsTemplate = GetTemplate('js/crypto2.js');
	if (GetConfig('admin/js/debug')) {
		#$crypto2JsTemplate =~ s/\/\/alert\('DEBUG:/if(!window.dbgoff)dbgoff=!confirm('DEBUG:/g;
		$crypto2JsTemplate = EnableJsDebug($crypto2JsTemplate);
	}
	my $algoSelectMode = GetConfig('admin/js/openpgp_algo_select_mode');
	if ($algoSelectMode) {
		if ($algoSelectMode eq '512' || $algoSelectMode eq 'random' || $algoSelectMode eq 'max') {
			my $oldValue = $crypto2JsTemplate;
			$crypto2JsTemplate = str_replace('var algoSelectMode = 0;', "var algoSelectMode = '$algoSelectMode'", $crypto2JsTemplate);
			if ($oldValue eq $crypto2JsTemplate) {
				WriteLog('MakeJsPages: warning: crypto2.js algoSelectMode templating failed, value of $crypto2JsTemplate did not change as expected');
			}
		}
	}
	my $promptForUsername = GetConfig('admin/js/openpgp_keygen_prompt_for_username');
	if ($promptForUsername) {
		$crypto2JsTemplate = str_replace('//username = prompt', 'username = prompt', $crypto2JsTemplate);
	}
	PutHtmlFile("crypto2.js", $crypto2JsTemplate);

	# Write avatar javascript
	my $avatarJsTemplate = GetTemplate('js/avatar.js');
	if (GetConfig('admin/js/debug')) {
		# $avatarJsTemplate =~ s/\/\/alert\('DEBUG:/if(!window.dbgoff)dbgoff=!confirm('DEBUG:/g;
		$avatarJsTemplate = EnableJsDebug($avatarJsTemplate);

	}
	PutHtmlFile("avatar.js", $avatarJsTemplate);

	# Write settings javascript
	#PutHtmlFile("settings.js", GetTemplate('js/settings.js'));
	PutHtmlFile("prefstest.html", GetTemplate('js/prefstest.template'));
} # MakeJsPages()

sub MakeSummaryPages { # generates and writes all "summary" and "static" pages StaticPages
# write, add event, stats, profile management, preferences, post ok, action/vote, action/event
# js files,
	WriteLog('MakeSummaryPages() BEGIN');

	state $HTMLDIR = GetDir('html');

	MakeSystemPages();

	# Add Authors page
	MakePage('authors', 0); # authors.html

	MakePage('active', 0); # active.html

	MakePage('scores', 0); # scores.html

	MakePage('read', 0);

	MakePage('image', 0);

	MakePage('picture', 0);

	MakePage('tags', 0);

	MakePage('compost', 0);

	MakePage('deleted', 0);
	#
	# { # clock test page
	# 	my $clockTest = '<form name=frmTopMenu>' . GetTemplate('html/widget/clock.template') . '</form>';
	# 	my $clockTestPage = '<html><body>';
	# 	$clockTestPage .= $clockTest;
	# 	$clockTestPage .= '</body></html>';
	# 	$clockTestPage = InjectJs($clockTestPage, qw(clock));
	# 	PutHtmlFile("clock.html", $clockTestPage);
	# }


	WriteLog('MakeSummaryPages() END');
} # MakeSummaryPages()

sub MakeHtAccessPages {
	my $HTMLDIR = GetDir('html');

	if (GetConfig('admin/htaccess/enable')) { #.htaccess
		# .htaccess file for Apache
		my $HtaccessTemplate = GetTemplate('htaccess/htaccess.template');

		# here, we inject the contents of 401.template into .htaccess
		# this is a kludge until i figure out how to do it properly
		# 401.template should not contain any " characters (will be removed)
		#
		my $message = GetConfig('admin/http_auth/message_401');
		$message =~ s/\n/<br>/g;
		my $text401 = GetTemplate('html/401.template');
		$text401 = str_replace('<p id=message></p>', '<p id=message>' . $message . '</p>', $text401);

		$text401 = str_replace("\n", '', $text401);
		$text401 = str_replace('"', '\\"', $text401);
		$text401 = '"' . $text401 . '"';
		$HtaccessTemplate =~ s/\/error\/error-401\.html/$text401/g;

		if (GetConfig('admin/php/enable')) {
			$HtaccessTemplate .= "\n" . GetTemplate('htaccess/htaccess_php.template');

			my $rewriteSetting = GetConfig('admin/php/rewrite');
			if ($rewriteSetting) {
				if ($rewriteSetting eq 'all') {
					$HtaccessTemplate .= "\n" . GetTemplate('htaccess/htaccess_php_rewrite_all.template');
				}
				if ($rewriteSetting eq 'query') {
					$HtaccessTemplate .= "\n" . GetTemplate('htaccess/htaccess_php_rewrite_query.template');
				}
			}
		}

		if (GetConfig('admin/http_auth/enable')) {
			my $HtpasswdTemplate .= GetConfig('admin/http_auth/htpasswd');
			my $HtaccessHttpAuthTemplate = GetTemplate('htaccess/htaccess_htpasswd.template');

			if ($HtpasswdTemplate & $HtaccessHttpAuthTemplate) {
				PutFile("$HTMLDIR/.htpasswd", $HtpasswdTemplate);
				if ($HTMLDIR =~ m/^([^\s]+)$/) { #todo security less permissive and untaint at top of file #security #taint
					$HTMLDIR = $1;
					chmod 0644, "$HTMLDIR/.htpasswd";
				}

				$HtaccessHttpAuthTemplate =~ s/\.htpasswd/$HTMLDIR\/\.htpasswd/;

				my $errorDocumentRoot = "$HTMLDIR/error/";
				$HtaccessHttpAuthTemplate =~ s/\$errorDocumentRoot/$errorDocumentRoot/g;
				#todo this currently has a one-account template

				$HtaccessTemplate .= "\n" . $HtaccessHttpAuthTemplate;
			}
		}

		if (GetConfig('admin/ssi/enable')) {
			my $ssiConf = GetTemplate('htaccess/htaccess_ssi.template');
			$HtaccessTemplate .= "\n" . $ssiConf;
		}

		if (GetConfig('admin/htaccess_block_list')) {
			my $htaccessBlockList = GetConfig('admin/htaccess_block_list');
			$HtaccessTemplate .= "\n" . $htaccessBlockList;
		}

		PutFile("$HTMLDIR/.htaccess", $HtaccessTemplate);

		# WriteDataPage();
	} #.htaccess
} # MakeHtAccessPages()

sub MakeMenuPages {
# sub MenuPages {
# pre-make all the pages referenced by the menu list
	WriteLog('MakeMenuPages()');
	my @menuPages = split("\n", GetTemplate('list/menu'));
	foreach my $menu (@menuPages) {
		WriteLog('MakeSystemPages: $menu = ' . $menu);
		MakePage($menu);
	}
} # MakeMenuPages()

sub MakeSystemPages {
# pre-make all the "system" pages:
# welcome.html - the welcome page (also index.html by default)
# cookie.html - page which tells users they need a cookie
# index.php, utils.php, post.php, write.php, upload.php, search.php, cookie.php, cookietest.php, route.php, quick.php
# (if php module is enabled)
# 404.html - the 404, page not found page
# write.html - the write / compose / create thread page
# #todo add others
	state $HTMLDIR = GetDir('html');

	WriteLog('MakeSystemPages: $HTMLDIR = ' . $HTMLDIR . '; caller = ' . join(',', caller));

	#MakeSimplePage('calculator'); # calculator.html calculator.template
	MakeSimplePage('welcome'); # welcome.html welcome.template index.html

	MakeSimplePage('cookie'); # welcome.html welcome.template index.html

	if (GetConfig('admin/php/enable')) {
		MakePhpPages();
	}

	{
		my $fourOhFourPage = GetDialogPage('404'); #GetTemplate('html/404.template');
		if (GetConfig('html/clock')) {
			$fourOhFourPage = InjectJs($fourOhFourPage, qw(clock fresh utils)); #todo this causes duplicate clock script
		}
		PutHtmlFile("404.html", $fourOhFourPage);
		PutHtmlFile("error/error-404.html", $fourOhFourPage);
	}
	# Submit page
	require_once('page/write.pl');
	my $submitPage = GetWritePage();
	PutHtmlFile("write.html", $submitPage);
	#MakeSimplePage('write');

	{
		my $accessDeniedPage = GetDialogPage('401'); #GetTemplate('html/401.template');
		PutHtmlFile("error/error-401.html", $accessDeniedPage);
	}

	if (GetConfig('admin/offline/enable')) {
		PutHtmlFile("cache.manifest", GetTemplate('js/cache.manifest.template') . "#" . time()); # setting/admin/offline/enable
	}

	if (GetConfig('admin/dev/make_js_test_pages')) {
		MakeJsTestPages();
	}

	my $jsTest1 = GetTemplate('test/jstest1/jstest1.template'); # Browser Test
	$jsTest1 = InjectJs($jsTest1, qw(jstest1));
	PutHtmlFile("jstest1.html", $jsTest1);

	if (GetConfig('admin/php/enable')) {
		# create write_post.html for longer messages if admin/php/enable
		$submitPage =~ s/method=get/method=post/g;
		if (index(lc($submitPage), 'method=post') == -1) {
			$submitPage =~ s/\<form /<form method=post /g;
		}
		if (index(lc($submitPage), 'method=post') == -1) {
			$submitPage =~ s/\<form/<form method=post /g;
		}
		$submitPage =~ s/cols=32/cols=50/g;
		$submitPage =~ s/rows=9/rows=15/g;
		$submitPage =~ s/please click here/you're in the right place/g;
		PutHtmlFile("write_post.html", $submitPage);
	}

	MakePage('upload');

	# Upload page
	my $uploadMultiPage = GetUploadPage('html/form/upload_multi.template');
	PutHtmlFile("upload_multi.html", $uploadMultiPage);

	MakeSimplePage('post');

	# Blank page
	PutHtmlFile("blank.html", "");

	if (GetConfig('admin/js/enable')) {
		MakeJsPages();
	}

	if (GetConfig('admin/htaccess/enable')) { #.htaccess
		MakeHtAccessPages();
	} #.htaccess

	PutHtmlFile("favicon.ico", '');

	{
		# p.gif
		WriteLog('making p.gif');

		if (!-e './config/template/html/p.gif.template') {
			if (-e 'default/template/html/p.gif.template') {
				copy('default/template/html/p.gif.template', 'config/template/html/p.gif.template');
			}
		}

		if (-e 'config/template/html/p.gif.template') {
			copy('config/template/html/p.gif.template', $HTMLDIR . '/p.gif');
		}
	}

	#MakePage('read');
} # MakeSystemPages()

sub MakeListingPages {
	WriteLog('MakeListingPages()');

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
		my $dialog;

		$dialog = GetQueryAsDialog('read', 'Top Threads');
		PutHtmlFile('dialog/read.html', $dialog);

		require_once('page/upload.pl');
		$dialog = GetUploadDialog();
		PutHtmlFile('dialog/upload.html', $dialog);

		$dialog = GetPasteDialog();
		$dialog = InjectJs($dialog, qw(paste));
		PutHtmlFile('dialog/paste.html', $dialog);

		$dialog = GetWriteDialog();
		PutHtmlFile('dialog/write.html', $dialog);

		$dialog = GetSettingsDialog();
		PutHtmlFile('dialog/settings.html', $dialog);

		$dialog = GetAnnoyancesDialog();
		PutHtmlFile('dialog/annoyances.html', $dialog);

		$dialog = GetStatsTable();
		PutHtmlFile('dialog/stats.html', $dialog);

		$dialog = GetSimpleDialog('help');
		PutHtmlFile('dialog/help.html', $dialog);
	}

	my @makePages = qw(profile chain deleted compost authors scores data);
	for my $page (@makePages) {
		WriteLog('MakeListingPages: calling MakePage(' . $page . ')');
		MakePage($page);
	}

	# MakePage('profile');
	# MakePage('chain');
	# MakePage('deleted');
	# MakePage('compost');
	# MakePage('authors');
	# MakePage('data');

	#PutHtmlFile('desktop.html', GetDesktopPage());
	MakeSimplePage('desktop');

	if (1) {
		# Ok page
		# this page is for responding to user actions on a static mode server
		# it just says ok, and then redirects after 10 seconds
		my $okPage;
		$okPage .= GetPageHeader('default', 'OK');
		my $windowContents = GetTemplate('html/action_ok.template');
		$okPage .= GetDialogX($windowContents, 'Data Received', '', 'Ready');
		$okPage .= GetPageFooter('default');
		$okPage =~ s/<\/head>/<meta http-equiv="refresh" content="10; url=\/"><\/head>/;
		$okPage = InjectJs($okPage, qw(settings));
		PutHtmlFile("action/event.html", $okPage);
	}

	# Search page
	MakeSimplePage('search');

	MakeSimplePage('access');

	MakeSimplePage('etc');

	# Add Event page
	my $eventAddPage = GetEventAddPage();
	PutHtmlFile("event.html", $eventAddPage);


	PutHtmlFile("test.html", GetTemplate('html/test.template'));
	PutHtmlFile("keyboard.html", GetTemplate('html/keyboard/keyboard.template'));
	PutHtmlFile("keyboard_netscape.html", GetTemplate('html/keyboard/keyboard_netscape.template'));
	PutHtmlFile("keyboard_android.html", GetTemplate('html/keyboard/keyboard_a.template'));

	PutHtmlFile("frame.html", GetTemplate('html/keyboard/keyboard_frame.template'));
	PutHtmlFile("frame2.html", GetTemplate('html/keyboard/keyboard_frame2.template'));
	PutHtmlFile("frame3.html", GetTemplate('html/keyboard/keyboard_frame3.template'));


	MakeSimplePage('manual'); # manual.html manual.template
	MakeSimplePage('help'); # 'help.html' 'help.template' GetHelpPage {
	MakeSimplePage('bookmark'); # welcome.html welcome.template
	# MakeSimplePage('desktop'); # desktop.html desktop.template
	MakeSimplePage('manual_advanced'); # manual_advanced.html manual_advanced.template
	MakeSimplePage('manual_tokens'); # manual_tokens.html manual_tokens.template


	MakeSimplePage('settings');
	MakeSimplePage('post');
	PutStatsPages();
	# Settings page
	#my $settingsPage = GetSettingsPage();
	#PutHtmlFile("settings.html", $settingsPage);

} # MakeListingPages()

sub GetEventAddPage { # get html for /event.html
	# $txtIndex stores html page output
	my $txtIndex = "";

	my $title = "Add Event";
	my $titleHtml = "Add Event";

	$txtIndex = GetPageHeader('event_add');

	$txtIndex .= GetTemplate('html/maincontent.template');


	my $eventAddForm = GetTemplate('html/form/event_add.template');

	#	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
#		localtime(time);
#
#	my $amPm = 0;
#	if ($hour > 12) {
#		$hour -= 12;
#		$amPm = 1;
#	}
#
	$txtIndex .= $eventAddForm;

	$txtIndex .= GetPageFooter('event_add');

	$txtIndex = InjectJs($txtIndex, qw(settings avatar event_add profile));

	my $colorRow0Bg = GetThemeColor('row_0');
	my $colorRow1Bg = GetThemeColor('row_1');

	$txtIndex =~ s/\$colorRow0Bg/$colorRow0Bg/g;
	$txtIndex =~ s/\$colorRow1Bg/$colorRow1Bg/g;

	return $txtIndex;
}

sub PutStatsPages { # stores template for footer stats dialog
	WriteLog('PutStatsPage()');

	MakeSimplePage('stats');

	if (GetConfig('debug')) {
		WriteLog('PutStatsPage: debug mode is ON');

		#my $statsPage = GetStatsPage();
		if (file_exists('log/log.log')) {
			WriteLog('PutStatsPage: log/log.log EXISTS');

			my $warningsLog = `grep -i warning log/log.log > html/warning.txt`;
			my $warningsSummary = `cat html/warning.txt | cut -d ' ' -f 3 | cut -d ':' -f 1 | cut -d '(' -f 1 | sort | uniq -c | sort -bnr > html/warnsumm.txt`;
			$warningsSummary = "\n" . GetFile('html/warnsumm.txt') . "\n";

			my $warningsSummaryHtml = '';
			my @warningsSummaryArray = split("\n", $warningsSummary);
			for my $warningSub ( @warningsSummaryArray ) {
				if ($warningSub =~ m/^([a-zA-Z0-9_\-])$/) {
					$warningSub = $1;
					$warningsSummaryHtml .= '<a href="/warning_' . $warningSub . '.txt">' . $warningSub . '</a>';
					$warningsSummaryHtml .= "\n";
				} else {
					$warningsSummaryHtml .= $warningSub;
					$warningsSummaryHtml .= "\n";
				}
			}

			my $warningsSummaryCommandResult = `find html | cut -d '/' -f 2-`;
			if ($warningsSummaryCommandResult =~ m/^([\x00-\x7F]+)$/) {
				$warningsSummaryCommandResult = $1;
			} else {
				WriteLog('PutStatsPage: warning: sanity check failed on $warningsSummaryCommandResult');
				$warningsSummaryCommandResult = '';
			}

			# THIS IS HARD-CODED BECAUSE it is a system-debugging feature,
			# and should have as few dependencies as possible
			# and maybe a little bit to save time
			my $warningsHtml =
				'<html><head><title>engine</title></head><body>' .
				'<center><table height=95% width=98%>' .
				'<tr><td align=center valign=middle>' .
				'<p>technical users:<br><a href="/warning.txt">warning list</a> can help fix bugs<br>or just <a href="/help.html">confuse more</a></p>' .
				'<p><tt>' .
				"cat html/warning.txt | cut -d ' ' -f 3 | cut -d ':' -f 1 | cut -d '(' -f 1 | sort | uniq -c | sort -bnr > html/warnsumm.txt" .
				'</tt></p>' .
				'</td>' .
				'<td><pre>' .
				$warningsSummaryHtml .
				'</pre></td>' .
				'</tr></table></center>' .
				'<hr>' .
				'<pre>' .
				$warningsSummaryCommandResult .
				'</pre>' .
				'</body></html>'
			;
			#$warningsHtml = InjectJs($warningsHtml, qw(utils fresh)); #shouldn't be any javascript on this page
			#todo warning if there is javascript in the html
			PutHtmlFile("engine.html", $warningsHtml); # engine.html
		} # if (-e 'log/log.log')
	} # if (GetConfig('debug'))
	else {
		WriteLog('PutStatsPage: debug mode is OFF');
	}

	my $statsFooter = GetDialogX(
		GetStatsTable('stats-horizontal.template'),
		'Site Statistics*'
	);
	$statsFooter = '<span class=advanced>' . $statsFooter . '</span>';
	PutHtmlFile("stats-footer.html", $statsFooter);
} # PutStatsPages()

sub GetPagePath { # $pageType, $pageParam ; returns path to item's html path
# $pageType, $pageParam match parameters for MakePage()
	my $pageType = shift;
	my $pageParam = shift;

	chomp $pageType;
	chomp $pageParam;

	if (!$pageType) {
		WriteLog('GetPagePath: warning: called without $pageType; caller = ' . join(',', caller));
		return '';
	}

	my $htmlPath = '';

	if ($pageType eq 'author') {
		# /author/ABCDEF1234567890/index.html
		$htmlPath = $pageType . '/' . $pageParam . '/index.html';
	}
	elsif ($pageType eq 'rss') {
		# /rss.xml
		$htmlPath = 'rss.xml';
	}
	else {
		if ($pageParam) {
			# e.g. /tag/approve.html
			$htmlPath = $pageType . '/' . $pageParam . '.html';
		} else {
			# e.g. /profile.html
			$htmlPath = $pageType . '.html';
		}
	}

	return $htmlPath;
} # GetPagePath()

sub BuildTouchedPages { # $timeLimit, $startTime ; builds pages returned by DBGetTouchedPages();
	WriteLog("BuildTouchedPages: warning: is broken, exiting");

	# DBGetTouchedPages() means select * from task where priority > 0

#	my $timeLimit = shift;
#	if (!$timeLimit) {
#		$timeLimit = 0;
#	}
#	my $startTime = shift;
#	if (!$startTime) {
#		$startTime = 0;
#	}

#	WriteLog("BuildTouchedPages($timeLimit, $startTime)");

#	my $pagesLimit = GetConfig('admin/update/limit_page');
#	if (!$pagesLimit) {
#		WriteLog("WARNING: setting/admin/update/limit_page missing!");
#		$pagesLimit = 1000;
#	}

	my $pagesProcessed = 0;

	# get a list of pages that have been touched since touch git_flow
	# this is from the task table
	my @pages = SqliteQueryHashRef("SELECT task_name, task_param FROM task WHERE priority > 0 AND task_type = 'page' ORDER BY priority DESC;");
	#todo templatize

	shift @pages; #remove header row

	if (@pages) {
		# write number of touched pages to log
		WriteLog('BuildTouchedPages: scalar(@pages) = ' . scalar(@pages));

		# this part will refresh any pages that have been "touched"
		# in this case, 'touch' means when an item that affects the page
		# is updated or added

		my $isLazy = 0;
#		if (GetConfig('admin/pages/lazy_page_generation')) {
#			if (GetConfig('admin/php/enable')) {
#				# at this time, php is the only module which can support regrowing
#				# 404 pages and thsu lazy page gen
#				if (GetConfig('admin/php/rewrite')) {
#					# rewrite is also required for this to work
#					if (GetConfig('admin/php/regrow_404_pages')) {
#						WriteLog('BuildTouchedPages: $isLazy conditions met, setting $isLazy = 1');
#						$isLazy = 1;
#					}
#				}
#			}
#		}
		WriteLog('BuildTouchedPages: $isLazy = ' . $isLazy);

		foreach my $pageHashRef (@pages) {
			my %page = %{$pageHashRef};
#			if ($timeLimit && $startTime && ((time() - $startTime) > $timeLimit)) {
#				WriteMessage("BuildTouchedPages: Time limit reached, exiting loop");
#				WriteMessage("BuildTouchedPages: " . time() . " - $startTime > $timeLimit");
#				last;
#			}

#			$pagesProcessed++;
			#	if ($pagesProcessed > $pagesLimit) {
			#		WriteLog("Will not finish processing pages, as limit of $pagesLimit has been reached");
			#		last;
			#	}
			#	if ((GetTime2() - $startTime) > $timeLimit) {
			#		WriteLog("Time limit reached, exiting loop");
			#		last;
			#	}

			# dereference @pageArray and get the 3 items in it

			my $pageType = $page{'task_name'};
			my $pageParam = $page{'task_param'};
#			my $touchTime = shift @pageArray;

			# output to log
#			WriteLog('BuildTouchedPages: $pageType = ' . $pageType . '; $pageParam = ' . $pageParam . ';');
#			WriteLog('BuildTouchedPages: $pageType = ' . $pageType . '; $pageParam = ' . $pageParam . '; $touchTime = ' . $touchTime);

			if ($isLazy) {
				my $pagePath = GetPagePath($pageType, $pageParam);
				RemoveHtmlFile($pagePath);
			} else {
				MakePage($pageType, $pageParam);
			}
			DBDeletePageTouch($pageType, $pageParam);
		}
	} # $touchedPages
	else {
		WriteLog('BuildTouchedPages: warning: $touchedPages was false, and thus not an array reference.');
		return 0;
	}

	return $pagesProcessed;
} # BuildTouchedPages()

sub BuildStaticExportPages { #
	my $pagesProcessed = 0;
	my $allPages = DBGetAllPages();

	if ($allPages) { #todo actually check it's an array reference or something?
		# de-reference array of touched pages
		my @pagesArray = @$allPages;

		# write number of touched pages to log
		WriteLog('BuildTouchedPages: scalar(@pagesArray) = ' . scalar(@pagesArray));

		# this part will refresh any pages that have been "touched"
		# in this case, 'touch' means when an item that affects the page
		# is updated or added

		foreach my $page (@pagesArray) {
			$pagesProcessed++;

			# dereference @pageArray and get the 3 items in it
			my @pageArray = @$page;
			my $pageType = shift @pageArray;
			my $pageParam = shift @pageArray;
			my $touchTime = shift @pageArray;

			# output to log
			WriteLog('BuildStaticExportPages: $pageType = ' . $pageType . '; $pageParam = ' . $pageParam . '; $touchTime = ' . $touchTime);

			MakePage($pageType, $pageParam, './export');
		}
	} # $allPages
	else {
		WriteLog('BuildStaticExportPages: warning: $allPages was false, and thus not an array reference.');
		return 0;
	}

	return $pagesProcessed;
} # BuildStaticExportPages()

require_once('widget/avatar.pl');
require_once('format_message.pl');
require_once('widget.pl');

require_once('dialog.pl');

require_once('dialog/chain_log.pl');
require_once('dialog/access.pl');
require_once('dialog/tos.pl');
require_once('dialog/write.pl');
require_once('dialog/puzzle.pl');
require_once('dialog/annoyances.pl');
require_once('dialog/operator.pl');
require_once('dialog/search.pl');
require_once('dialog/simple.pl');
require_once('dialog/settings.pl');

require_once('dialog/reply.pl');

sub GetQuerySqlDialog { # $pageQuery ; displays query for user to see
# sub DisplayQueryDialog {
# sub GetSqlDialog {
# sub QuerySqlDialog {
# sub GetSqlQueryDialog {
# sub GetQueryDialog { #GetQuerySqlDialog()
# sub GetQueryForDisplay {
# sub GetDisplayQuery {
	# display query used to generate the listing
	#my $displayQuery = TextartForWeb(SqliteGetQueryTemplate($pageQuery));
	my $pageQuery = shift;
	#todo sanity checks

	my $queryDisplayName = $pageQuery . '.sql';

	my $displayQuery = '<pre class=sql contenteditable>' . HtmlEscape(SqliteGetQueryTemplate($pageQuery)) . '</pre>'; #todo templatify
	my $dialog = '<span class=advanced>' . GetDialogX($displayQuery, $queryDisplayName) . '</span>';

	return $dialog;
}

sub PrintBanner {
	my $string = shift; #todo sanity checks
	my $width = length($string);

	my $edge = "=" x $width;

	print $edge;
	print $string;
	print $edge;
} # PrintBanner()

sub MakeWritePage {
	WriteLog('MakeWritePage()');

	require_once('page/write.pl');
	my $submitPage = GetWritePage();
	PutHtmlFile("write.html", $submitPage);

	if (GetConfig('admin/php/enable')) {
		# create write_post.html for longer messages if admin/php/enable
		# this is a bit hacky, but it works for now
		# the template used here is html/form/write/write.template

		$submitPage =~ s/method=get/method=post/g;
		if (index(lc($submitPage), 'method=post') == -1) {
			$submitPage =~ s/\<form /<form method=post /g;
		}
		if (index(lc($submitPage), 'method=post') == -1) {
			$submitPage =~ s/\<form/<form method=post /g;
		}

		$submitPage =~ s/cols=32/cols=50/g;
		$submitPage =~ s/rows=9/rows=15/g;
		$submitPage =~ s/please click here/you're in the right place/g;

		PutHtmlFile("write_post.html", $submitPage);
	}
} # MakeWritePage()

sub GetIntroDialog { # $pageName
	my $pageName = shift;
	chomp $pageName;

	#todo sanity

	my $introText = GetString('page_intro/' . $pageName);
	my $introDialogContents = '<fieldset><p>' . FormatForWeb($introText) . '</p></fieldset>';
	my $introDialog = GetDialogX($introDialogContents, 'Welcome to ' . ucfirst($pageName));

	return $introDialog;
} # GetIntroDialog()

while (my $arg1 = shift @foundArgs) {
	# evaluate each argument, fuzzy matching it, and generate requested pages

	# go through all the arguments one at a time
	if ($arg1) {
		if (-e $arg1 && -f $arg1) {
			# if filename was supplied, use its filehash
			$arg1 = GetFileHash($arg1);
		}

		#this cool feature also had undesired effects, which should be corrected
		#		if ($arg1 =! m/\/([0-9A-F]{16})\//) {
		#			# if it looks like a profile url, use the profile identifier
		#			$arg1 = $1;
		#		}
		#
		if ($arg1 eq '--theme') {
			#todo this is broken, fix it
			# override the theme for remaining pages
			WriteMessage("recognized token --theme");
			my $themeArg = shift @foundArgs;
			chomp $themeArg;
			GetConfig('theme', 'override', $themeArg);
		}
		elsif (IsItem($arg1)) {
			WriteLog('pages.pl; recognized item identifier; $arg1 = ' . $arg1 . '; caller = ' . join(',', caller));
			WriteMessage("recognized item identifier\n");
			MakePage('item', $arg1, 1);
		}
		elsif (IsItemPrefix($arg1)) {
			WriteMessage("recognized item prefix\n");
			MakePage('prefix', $arg1, 1);
		}
		elsif (IsFingerprint($arg1)) {
			WriteMessage("recognized author fingerprint\n");
			MakePage('author', $arg1, 1);
		}
		elsif (IsDate($arg1)) {
			WriteMessage("recognized date\n");
			MakePage('date', $arg1, 1);
		}
		elsif (substr($arg1, 0, 1) eq '#') {
			#todo sanity checks here
			WriteMessage("recognized hash tag $arg1\n");
			MakePage('tag', substr($arg1, 1), 1);
		}
		elsif ($arg1 eq '--summary' || $arg1 eq '-s') {
			WriteMessage("recognized --summary\n");
			MakeSummaryPages();
		}
		elsif ($arg1 eq '--system' || $arg1 eq '-S') { #--system #system pages
			WriteMessage("recognized --system\n");
			MakeSystemPages();
		}
		elsif ($arg1 eq '--listing' || $arg1 eq '-L') { #--listing #listing pages
			WriteMessage("recognized --listing\n");
			MakeListingPages();
		}
		elsif ($arg1 eq '--php') {
			WriteMessage("recognized --php\n");
			if (!GetConfig('admin/php/enable')) {
				print("warning: --php was used, but admin/php/enable is false\n");
			}
			MakePhpPages();
		}
		elsif ($arg1 eq '--js') {
			WriteMessage("recognized --js\n");
			MakeJsPages();
		}
		elsif ($arg1 eq '--settings') {
			WriteMessage("recognized --settings\n");
			#my $settingsPage = GetSettingsPage();
			#PutHtmlFile('settings.html', $settingsPage);
			MakeSimplePage('settings');
			PutStatsPages();
		}
		elsif ($arg1 eq '--tags') {
			WriteMessage("recognized --tags\n");
			MakePage('tags');
		}
		elsif ($arg1 eq '--labels') {
			WriteMessage("recognized --labels\n");
			MakePage('labels');
		}
		elsif ($arg1 eq '--write') {
			WriteMessage("recognized --write, you can use -M write now\n");
			MakePage('write');
		}
		elsif ($arg1 eq '--data' || $arg1 eq '-i') {
			WriteMessage("recognized --data\n");
			MakePage('data');
		}
		elsif ($arg1 eq '--desktop' || $arg1 eq '-i') {
			WriteMessage("recognized --desktop\n");
			#PutHtmlFile('desktop.html', GetDesktopPage());
			MakeSimplePage('desktop');
		}
		elsif ($arg1 eq '--queue' || $arg1 eq '-Q') {
			WriteMessage("recognized --queue\n");
			BuildTouchedPages(); # -queue or -Q
		}
		elsif ($arg1 eq '--all' || $arg1 eq '-a') {
			WriteMessage("recognized --all\n");
			SqliteQuery("UPDATE task SET priority = priority + 1 WHERE task_type = 'page'");
			MakeSystemPages();
			MakeMenuPages();
			MakeListingPages();
			MakeSummaryPages();
			BuildTouchedPages(); # --all
		}
		elsif ($arg1 eq '--export') {
			GetConfig('admin/php/enable', 'override', 0);
			GetConfig('admin/js/enable', 'override', 0);
			GetConfig('admin/pages/lazy_page_generation', 'override', 0);
			GetConfig('admin/expo_mode_edit', 'override', 0);
			WriteMessage("recognized --export\n");
			BuildStaticExportPages();
		}
		elsif ($arg1 eq '-M' || $arg1 eq '-m') { # makepage
			WriteMessage("recognized -M or -m\n");
			my $makePageArg = shift @foundArgs;
			#todo sanity check of $makePageArg
			if ($makePageArg) {
				if ($makePageArg eq 'compare') {
					require_once('page/compare.pl');

					my $itemA = shift @foundArgs;
					my $itemB = shift @foundArgs;

					if ($itemA && $itemB && IsItem($itemA) && IsItem($itemB)) {
						my $comparePage = GetComparePage($itemA, $itemB);
						WriteMessage("calling GetComparePage($itemA, $itemB)\n");
						PutHtmlFile('compare1.html', $comparePage);
					} else {
						WriteMessage("compare needs 2 items\n");
						#todo ...
					}
				} else {
				    if ($makePageArg eq 'person') {
				        my $personArg = shift @foundArgs;
				        #todo sanity check
				        MakePage('person', $personArg);
				    } else {
                        WriteMessage("calling MakePage($makePageArg)\n");
                        MakePage($makePageArg);
                        # /new.html
                    }
				}
			} else {
				print("missing argument for -M\n");
			}
		}
		elsif ($arg1 eq '-D') { # dialog
			##### DIALOGS ######################
			##### DIALOGS ######################
			##### DIALOGS ######################
			##### DIALOGS ######################
			WriteMessage("pages.pl: recognized -D\n");
			my $makeDialogArg = shift @foundArgs;
			#todo sanity check of $makeDialogArg
			if ($makeDialogArg) {
				my @validDialogs = qw(settings access upload data search profile);
				my @needRequire = qw(profile upload);
				my @queryDialogs = qw(read image url chain new tags scores active authors people threads labels);
				my @simpleDialogs = qw(help );

				if (0) { }
				elsif (in_array($makeDialogArg, @validDialogs)) {
					# basically this accomplishes the following:
					#
					# my $dialog = GetSettingsDialog();
					# WriteMessage("-D $makeDialogArg\n");
					# PutHtmlFile('dialog/settings.html', $dialog);
					#
					# /dialog/settings.html
					# /dialog/access.html
					# /dialog/upload.html
					# /dialog/data.html
					# /dialog/search.html

					WriteLog('pages.pl: $makeDialogArg found in @validDialogs');
					if (in_array($makeDialogArg, @needRequire)) {
						my $requirePath = 'page/' . $makeDialogArg . '.pl';
						require_once($requirePath);
					}
					no strict 'refs';
					my $subName = 'Get' . ucfirst($makeDialogArg) . 'Dialog';
					if (exists &{$subName}) {
						WriteLog('pages.pl: ' . $subName . '() exists! calling it...');
						WriteMessage('-D ' . $makeDialogArg);
						my $dialogContent = &{$subName}();
						my $dialogOutputPath = 'dialog/' . $makeDialogArg . '.html';
						PutHtmlFile($dialogOutputPath, $dialogContent);
					} else {
						WriteLog('pages.pl: warning: ' . $subName . '() was not found!');
					}
				} # @validDialogs

				elsif (in_array($makeDialogArg, @queryDialogs)) {
					# /dialog/read.html
					# /dialog/image.html
					# /dialog/url.html
					# /dialog/chain.html
					# /dialog/new.html
					# /dialog/tags.html
					# /dialog/labels.html
					# /dialog/scores.html
					# /dialog/active.html
					# /dialog/authors.html
					# /dialog/people.html
					# /dialog/threads.html

					my $dialogTitle = $makeDialogArg; #todo make nicer
					my $dialog = GetQueryAsDialog($makeDialogArg, $dialogTitle);
					WriteMessage("-D $makeDialogArg\n");
					my $dialogOutputPath = 'dialog/' . $makeDialogArg . '.html';
					PutHtmlFile($dialogOutputPath, $dialog);
				} # @queryDialogs

				elsif ($makeDialogArg eq 'stats') {
					my $dialog = GetStatsTable();
					PutHtmlFile('dialog/stats.html', $dialog);
					WriteMessage("-D $makeDialogArg\n");
				}
				elsif ($makeDialogArg eq 'write') {
					my $dialog = GetWriteDialog();
					WriteMessage("-D $makeDialogArg\n");
					PutHtmlFile('dialog/write.html', $dialog);
				}
				elsif ($makeDialogArg eq 'help') {
					my $dialog = GetSimpleDialog('help');
					WriteMessage("-D $makeDialogArg\n");
					PutHtmlFile('dialog/help.html', $dialog);
				}
				elsif ($makeDialogArg eq 'welcome') {
					my $dialog = GetSimpleDialog('welcome');
					WriteMessage("-D $makeDialogArg\n");
					PutHtmlFile('dialog/welcome.html', $dialog);
				}
				elsif ($makeDialogArg =~ m/([0-9a-f]{8})/) {
					WriteMessage("-D (item_prefix)\n");
					my $dialog = GetItemTemplateFromHash($makeDialogArg);
					my $dialogPath = GetHtmlFilename($makeDialogArg); # pages.pl #todo

					if ($dialog && $dialogPath) {
						PutHtmlFile('dialog/' . $dialogPath, $dialog);
					} else {
						WriteLog('pages.pl: warning: $dialog or $dialogPath is FALSE');
					}
				}
				# elsif (IsFingerprint($arg1)) {
				# 	WriteMessage("recognized author fingerprint\n");
				# 	MakePage('author', $arg1, 1);
				# }
				elsif (substr($makeDialogArg, 0, 1) eq '#') { #hashtag tag/like.html
					#todo sanity checks here
					WriteMessage("-D hashtag $makeDialogArg\n");
					my $hashTag = substr($makeDialogArg, 1);

					if ($hashTag =~ m/^([a-zA-Z_\-0-9]+)$/) { #todo non-latin characters #hashtag
						$hashTag = $1;

						my $query = GetTemplate('query/tag_dozen.sql');
						my $queryLikeString = "'%,$hashTag,%'";
						$query =~ s/\?/$queryLikeString/;

						WriteLog('pages.pl: $query = ' . $query . '; caller = ' . join(',', caller)); #todo removeme
						my $queryDialogTitle = '#' . $hashTag;

						my $dialog = GetQueryAsDialog(
							$query,
							$queryDialogTitle
						); #todo sanity
						my $dialogPath = 'tag/' . $hashTag . '.html';

						$dialog = AddAttributeToTag($dialog, 'table', 'id', 'top_' . $hashTag);

						if ($dialog && $dialogPath) {
							PutHtmlFile('dialog/' . $dialogPath, $dialog);
						} else {
							WriteLog('pages.pl: warning: dialog: nothing returned for #' . $makeDialogArg);
						}
					} # $hashTag sanity check
					else {
						WriteLog('pages.pl: warning: sanity check failed on $hashTag (-D)');
						return '';
					}
				} # -D #foo
				else {
					print 'pages: did not recognize dialog type: ' . $makeDialogArg;
					print "\n";
				}

				#WriteMessage("calling MakePage($makePageArg)\n");
				#MakePage($makePageArg);
			} else {
				print("pages: missing argument for -D\n");
			}
			##### DIALOGS ######################
			##### DIALOGS ######################
			##### DIALOGS ######################
			##### DIALOGS ######################
			##### DIALOGS ######################

		}
		else {
			print("Available arguments:\n");
			print("--summary or -s for all summary or system pages\n");
			print("--system or -S for basic system pages\n");
			print("--php for all php pages\n");
			print("--queue or -Q for all pages in queue\n");
			print("-M [page] to call MakePage\n");
			print("-D [dialog] to make dialog page\n");
			print("item id for one item's page\n");
			print("author fingerprint for one item's page\n");
			print("#tag for one tag's page\n");
			print("YYYY-MM-DD for a date page\n");
		}
	}

	print("-------");
	print("\n");
	my @filesWrittenHtml = PutHtmlFile('report_files_written');
	for my $fileWritten (@filesWrittenHtml) {
		print $fileWritten;
		print "\n";
	}
	my @filesWritten = PutFile('report_files_written');
	for my $fileWritten (@filesWritten) {
		print $fileWritten;
		print "\n";
	}
	print "-------";
	print "\n";
	print "Total files written: ";
	print scalar(@filesWritten) + scalar(@filesWrittenHtml);
	print "\n";
}

##buggy
#my %configLookupList = GetConfig('get_memo'); #this gets a memo of all the lookups done with GetConfig() so far
##i know it is confusing to have a "method call" in the function's argument
#if (%configLookupList) {
#	print Dumper(keys(%configLookupList));
#}
#print "\n";

1;
