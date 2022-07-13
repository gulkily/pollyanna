#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

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
}

sub TextartForWeb { # replaces some spaces with &nbsp; to preserve text-based layout for html display; $text
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

#sub FormatMessage { # $message, \%file
#	my $message = shift;
#	my %file = %{shift @_}; #todo should be better formatted
#	#todo sanity checks
#
#	if ($file{'remove_token'}) {
#		my $removeToken = $file{'remove_token'};
#		$message =~ s/$removeToken//g;
#		$message = trim($message);
#	}
#
#	my $isTextart = 0;
#	my $isSurvey = 0;
#	my $isTooLong = 0;
#
#	if ($file{'tags_list'}) {
#		# if there is a list of tags, check to see if there is a 'textart' tag
#
#		# split the tags list into @itemTags array
#		my @itemTags = split(',', $file{'tags_list'});
#
#		# loop through all the tags in @itemTags
#		while (scalar(@itemTags)) {
#			my $thisTag = pop @itemTags;
#			if ($thisTag eq 'textart') {
#				$isTextart = 1; # set isTextart to 1 if 'textart' tag is present
#			}
#			if ($thisTag eq 'survey') {
#				$isSurvey = 1; # set $isSurvey to 1 if 'survey' tag is present
#			}
#		}
#	}
#
#	if ($isTextart) {
#		# if textart, format with extra spacing to preserve character arrangement
#		#$message = TextartForWeb($message);
#		$message = TextartForWeb(GetFile($file{'file_path'}));
#	} else {
#		# if not textart, just escape html characters
#		WriteLog('FormatMessage: calling FormatForWeb');
#		$message = FormatForWeb($message);
#	}
#
#	return $message;
#} # FormatMessage()

1;
