#!/usr/bin/perl -T

use strict;
use 5.010;
use utf8;

#use Unicode::String qw(utf8); #todo TrimUnicodeString

sub GetString { # $stringKey, $language, $noSubstitutions ; Returns string from config/string/en/
# $stringKey = 'menu/top'
# $language = 'en'
# $noSubstitute = returns empty string if no exact match
	my $defaultLanguage = 'en';

	my $stringKey = shift;
	my $language = shift;
	my $noSubstitute = shift;

	if (!$stringKey) {
		WriteLog('GetString: warning: called without $stringKey, exiting');
		return '';
	}
	if (!$language) {
		$language = GetConfig('language');
	}
	if (!$language) {
		$language = $defaultLanguage;
	}

	# this will store all looked up values so that we don't have to look them up again
	state %strings; #memo
	my $memoKey = $stringKey . '/' . $language . '/' . ($noSubstitute ? 1 : 0);

	if (defined($strings{$memoKey})) {
		#memo match
		return $strings{$memoKey};
	}

	my $string = '';
	if (GetThemeAttribute('string/' . $language . '/' . $stringKey)) {
		WriteLog('GetString: Found GetThemeAttribute: string/' . $language . '/' . $stringKey);
		#if current theme has this string, override default
		$string = GetThemeAttribute('string/' . $language . '/' . $stringKey);
	} else {
		WriteLog('GetString: NOT found in GetThemeAttribute');
		#otherwise use regular string
		$string = GetConfig('string/' . $language . '/' . $stringKey);
	}

	if ($string) {
		# exact match
		chomp ($string);

		$strings{$memoKey} = $string;
	} else {
		# no match, dig deeper...
		if ($noSubstitute) {
			$strings{$memoKey} = '';
			return '';
		} else {
			if ($language ne $defaultLanguage) {
				$string = GetString($stringKey, $defaultLanguage);
			}

			if (!$string) {
				$string = TrimPath($stringKey);

				WriteLog('GetString: warning: string value missing for $stringKey = ' . $stringKey);
				# if string is not found, display string key
				# trin string key's path to make it less confusing
			}

			chomp($string);
			$strings{$memoKey} = $string;
			return $string;
		}
	}
} # GetString()

sub htmlspecialchars { # $text, encodes supplied string for html output
	# port of php built-in
	my $text = shift;
	$text = encode_entities2($text);
	return $text;
}

sub HtmlEscape { # encodes supplied string for html output
	my $text = shift;
	$text = encode_entities2($text);
	return $text;
}

sub GetStringHtmlColor {
# GetColorFromHash {
# GetHashColor {
	my $string = shift;
	#todo dark/light or color(s) to match
	#todo sanity

	if (GetConfig('html/mourn')) { # GetStringHtmlColor()
		return GetThemeColor('text');
	}

	if (!defined($string)) {
		$string = '';
	}

	my $hash = sha1_hex($string);
	my $color = substr($hash, 0, 6);

	$color = '#' . $color;

	return $color;
} # GetStringHtmlColor()

sub str_repeat {
	my $string = shift;
	my $count = shift;
	WriteLog('str_repeat: $string = ' . $string . '; $count = ' . $count);
	WriteLog('str_repeat: ' . $string x $count); #todo performance?
	return $string x $count;
}

#sub TrimUnicodeString {
#	my $string = shift;
#	my $maxLength = shift;
#
#	#todo sanity
#
#	my $unicodeString = utf8($string);
#	if ($unicodeString->length > $maxLength) {
#		$unicodeString = $unicodeString->substr(0, $maxLength);
#	}
#
#	return $unicodeString;
#}

sub GetFirstLine {
	my $text = shift;
	
	$text = trim($text);
	if (index($text, "\n") != -1) {
			$text = trim(substr($text, 0, index($text, "\n")));
	}
	
	return $text;
}

1;
