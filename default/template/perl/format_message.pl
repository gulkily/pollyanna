#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub SurveyForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	my $text = shift;

	if (!$text) {
		return '';
	}

	my $i = 0;

	$text = HtmlEscape($text);
	# $text =~ s/\n /<br>&nbsp;/g;
	$text =~ s/^ /&nbsp;/g;
	$text =~ s/  / &nbsp;/g;
	# $text =~ s/\n/<br>\n/g;
	# $text =~ s/<br>/'<br><input type=text size=80 name=txt'.$i++.'><br>'/ge;
	# $text =~ s/<br>/<br><br>/g;
	$text = '<textarea wrap=wrap cols=80 rows=24>'.$text.'</textarea>';
	$text = '<form action=/post.html>'.$text.'<br><input type=submit value=Send></form>';

	#htmlspecialchars(
	## nl2br(
	## str_replace(
	## '  ', ' &nbsp;',
	# htmlspecialchars(
	## $quote->quote))))?><? if ($quote->comment) echo(htmlspecialchars('<br><i>Comment:</i> '.htmlspecialchars($quote->comment)
	#));?><?=$tt_c?></description>

	return $text;
} # SurveyForWeb()

sub AddressForWeb {
	my $text = shift;

	if (!$text) {
		return '';
	}

	my $urlText = $text;
	$urlText = UriEscape($urlText);
	my $url = "http://maps.google.com/maps/?q=$urlText";

	my $formattedAddress =
		'<a href="' .
		$url .
		'">' .
		$text .
		'</a>'
	;

	return $formattedAddress;
	#return $urlText;
	#return $text;
} # AddressForWeb();

sub PhoneForWeb {
	my $text = shift;

	if (!$text) {
		return '';
	}

	my $html = '<a href="tel:' . $text . '">' . $text . '</a>';

	#rough draft

	return $html;
} # PhoneForWeb()

sub CppForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text);
	#$text =~ s/\n /<br>&nbsp;/g;
	#$text =~ s/^ /&nbsp;/g;
	#$text =~ s/  / &nbsp;/g;
	#$text =~ s/\n/<br>\n/g;

	#htmlspecialchars(
	## nl2br(
	## str_replace(
	## '  ', ' &nbsp;',
	# htmlspecialchars(
	## $quote->quote))))?><? if ($quote->comment) echo(htmlspecialchars('<br><i>Comment:</i> '.htmlspecialchars($quote->comment)
	#));?><?=$tt_c?></description>

	my $container = GetTemplate('html/item/container/cpp.template');
	$container = str_replace('$text', $text, $container);

	return $container;
} # CppForWeb()

sub PyForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text);
	#$text =~ s/\n /<br>&nbsp;/g;
	#$text =~ s/^ /&nbsp;/g;
	#$text =~ s/  / &nbsp;/g;
	#$text =~ s/\n/<br>\n/g;

	#htmlspecialchars(
	## nl2br(
	## str_replace(
	## '  ', ' &nbsp;',
	# htmlspecialchars(
	## $quote->quote))))?><? if ($quote->comment) echo(htmlspecialchars('<br><i>Comment:</i> '.htmlspecialchars($quote->comment)
	#));?><?=$tt_c?></description>

	my $container = GetTemplate('html/item/container/py.template');
	$container = str_replace('$text', $text, $container);

	return $container;
} # PyForWeb()

sub PerlForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text);

	my $container = GetTemplate('html/item/container/perl.template');
	$container = str_replace('$text', $text, $container);

	return $container;
} # PerlForWeb()

sub ZipForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text);

	my $container = GetTemplate('html/item/container/zip.template');
	$container = str_replace('$text', $text, $container);

	return $container;
} # ZipForWeb()

sub SqlForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text);

	my @sqlKeywords = qw(SELECT FROM SELECT COUNT AS MAX AS SUM AS SUM AS FROM WHERE JOIN DISTINCT IN SELECT FROM GROUP BY WHERE AND LIKE ORDER BY DESC LIMIT SUBSTR DATETIME UNION ON ALL LOWER UPPER);
	for my $sqlKeyword (@sqlKeywords) {
		$text =~ s/$sqlKeyword/<b>$sqlKeyword<\/b>/g;
	}

	my $container = GetTemplate('html/item/container/sql.template');
	$container = str_replace('$text', $text, $container);

	return $container;
} # SqlForWeb()

sub ConceptForWeb { # $text ; for formatting software concept definitions
	my $text = shift;

	if (!$text) {
		return '';
	}

	my @conceptKeywords = qw(concept actions where state where purpose references state actions);
	push @conceptKeywords, "operational principle";

	$text = HtmlEscape($text);

	for my $conceptKeyword (@conceptKeywords) {
		$text =~ s/^$conceptKeyword/<b>$conceptKeyword<\/b>/gm;
		$text =~ s/^(\s+)$conceptKeyword/$1<b>$conceptKeyword<\/b>/gm;
	}

	$text =~ s/^(\s+?)([a-zA-Z]+)\(/$1<b class=function>$2<\/b>(/gm;
	$text =~ s/^(\s+?)([a-z_]+):/$1<b class=variable>$2<\/b>:/gm;
	#$text =~ s/a/b/g;

	$text =~ s/\n /<br>&nbsp;/g;
	$text =~ s/^ /&nbsp;/g;
	$text =~ s/  / &nbsp;/g;
	$text =~ s/\n/<br>\n/g;

	my $container = GetTemplate('html/item/container/sql.template');
	$container = str_replace('$text', str_replace('^', '', $text), $container);

	return $container;
} # ConceptForWeb()

sub TextartForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	# sub EscapeHtml { # TextartForWeb()
	# sub FormatHtml {
	# sub FormatAsHtml {
	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text);
	$text =~ s/\n /<br>&nbsp;/g;
	$text =~ s/^ /&nbsp;/g;
	$text =~ s/  / &nbsp;/g;
	$text =~ s/\n/<br>\n/g;

	#htmlspecialchars(
	## nl2br(
	## str_replace(
	## '  ', ' &nbsp;',
	# htmlspecialchars(
	## $quote->quote))))?><? if ($quote->comment) echo(htmlspecialchars('<br><i>Comment:</i> '.htmlspecialchars($quote->comment)
	#));?><?=$tt_c?></description>

	my $container = GetTemplate('html/item/container/textart.template');
	$container = str_replace('$text', $text, $container);

	return $container;
} # TextartForWeb()

sub FormatForWeb { # $text ; replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	# sub GetItemText {
	# sub GetItemFormattedText {

	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text); #todo this needs some improvement

	if (0) {
		#format wiki-like links, still needs some work

		#$file{'format_wiki'} = 1;
		#if ($file{'format_wiki'}) {

		#$text =~ s/\[\[(?!.+?:)([^\]\[]+)\|([^\]\[]+)\]\]
		#$text =~ s/([A-Z][a-z]+[A-Z][A-Za-z]+)/GetTagLink($1)/eg;
		$text =~ s/\[\[#([A-Z][a-z]+[A-Z][A-Za-z]+)\]\]/GetTagLink($1)/eg
		#$text =~ s/\[\[#([A-Z][a-z]+[A-Z][A-Za-z]+)\]\]/GetTagLink($1)/eg todo make it add the [[]] to the output
		#$itemText =~ s/a/b/g;
		#basic
	}

	# these have been moved to format for textart
	#	$text =~ s/\n /<br>&nbsp;/g;
	#	$text =~ s/^ /&nbsp;/g;
	#	$text =~ s/  / &nbsp;/g;

	#$text =~ s/\n\n/<p>/g; #todo reinstate this when the stylesheet problem is fixed
	$text =~ s/\n/<br>/g;

	# this is more flexible than \n but may cause problems with unicode
	# for example, it recognizes second half of russian "x" as \R
	# #regexbugX
	# $text =~ s/\R\R/<p>/g;
	# $text =~ s/\R/<br>/g;

	if (GetConfig('admin/html/allow_tag/code')) {
		$text =~ s/&lt;code&gt;(.*?)&lt;\/code&gt;/<code>$1<\/code>/msgi;
		# /s = single-line (changes behavior of . metacharacter to match newlines)
		# /m = multi-line (changes behavior of ^ and $ to work on lines instead of entire file)
		# /g = global (all instances)
		# /i = case-insensitive
	}

	return $text;
} # FormatForWeb()

sub FormatForRss { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
	my $text = shift;

	if (!$text) {
		return '';
	}

	$text = HtmlEscape($text);
	$text =~ s/\n/<br \/>\n/g;

	return $text;
} # FormatForRss()

1;
