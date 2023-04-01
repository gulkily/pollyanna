#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub UriEscape {
# sub UrlEncode {
# sub EscapeUrl {

	my $string = shift;

	#todo sanity

	my $escapedString = $string;

	$escapedString = uri_escape($escapedString);
	$escapedString = str_replace(' ', '+', $escapedString);
	$escapedString = str_replace('+', '%2b', $escapedString);
	$escapedString = str_replace('#', '%23', $escapedString);

	return $escapedString;
} # UriEscape()

sub GetHtmlAvatar { # $key ; Returns HTML avatar from cache
	state %avatarMemo;

	# returns avatar suitable for comments
	my $key = shift;
	if (!$key) {
		WriteLog('GetHtmlAvatar: warning: $key was FALSE; caller = ' . join(',', caller));
		return '';
	}

	if (!IsFingerprint($key)) {
		WriteLog('GetHtmlAvatar: warning: $key failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	if ($avatarMemo{$key}) {
		WriteLog("GetHtmlAvatar: found in hash");
		return $avatarMemo{$key};
	}

	my $avatar = GetAvatar($key);
	if ($avatar) {
		if (-e 'html/author/' . $key) {
			my $avatarLink = GetAuthorLink($key);
			$avatarMemo{$key} = $avatar;
			return $avatarLink;
		}
	} else {
		return $key;
		#		return 'unregistered';
	}

	return $key;
	#	return 'unregistered';
} # GetHtmlAvatar()

sub GetItemUrl {
	#todo
	my $hash = shift;
	#todo sanity
	return GetHtmlFilename($hash);
}

sub GetHtmlFilename { # get the HTML filename for specified item hash
# sub GetItemUrl {
# sub GetItemHtmlLink {
# sub GetHtmlFilePath {
# sub GetItemHtmlFilePath {
# sub GetHtmlFile {
	# Returns 'ab/cd/abcdef01234567890[...].html'
	# -or- Slug-From-Item-Name.html
	#
	my $hash = shift;

	WriteLog("GetHtmlFilename()");

	if (!defined($hash) || !$hash) {
		if (WriteLog("GetHtmlFilename: warning: called without parameter; caller = " . join(',', caller))) {

			#my $trace = Devel::StackTrace->new;
			#print $trace->as_string; # like carp
		}

		return '';
	}

	WriteLog('GetHtmlFilename: $hash = ' . $hash);

	if (!IsItem($hash)) {
		WriteLog("GetHtmlFilename: warning: called with parameter that isn't a SHA-1. Returning.");
		#WriteLog("$hash");
		#
		# my $trace = Devel::StackTrace->new;
		# print $trace->as_string; # like carp

		return '';
	}

	#	my $htmlFilename =
	#		substr($hash, 0, 2) .
	#		'/' .
	#		substr($hash, 2, 8) .
	#		'.html';
	#


	# my $htmlFilename =
	# 	substr($hash, 0, 2) .
	# 	'/' .
	# 	substr($hash, 2, 2) .
	# 	'/' .
	# 	$hash .
	# 	'.html';
	#
	#
	my $htmlFilename = '';

	if (GetConfig('html/item_name_slug')) {
		my $itemName = DBGetItemAttribute($hash, 'name');

		WriteLog('GetHtmlFilename: item_name_slug: $itemName = ' . $itemName);

		if ($itemName) {
			my $slug = $itemName;
			$slug = str_replace(' ', '-', $slug);
			$slug =~ s/[^a-zA-Z0-9\-]//g;

			#todo sanity

			if ($slug) {
				$htmlFilename = $slug . '.html';
			}
		} # if ($itemName)
	} # if (GetConfig('html/item_name_slug'))

	if (!$htmlFilename) {
		# fallback and default in one
		$htmlFilename =
			substr($hash, 0, 2) .
				'/' .
				substr($hash, 2, 2) .
				'/' .
				substr($hash, 0, 8) .
				'.html';
	}

	WriteLog('GetHtmlFilename: returning: $htmlFilename = ' . $htmlFilename);

	return $htmlFilename;
} # GetHtmlFilename()

sub AddAttributeToTag { # $html, $tag, $attributeName, $attributeValue; adds attr=value to html tag;
# sub AddTagAttribute {
	my $html = shift; # chunk of html to work with
	my $tag = shift; # tag we'll be modifying
	my $attributeName = shift; # name of attribute
	my $attributeValue = shift; # value of attribute

	my $lengthBefore = length($html);

	WriteLog("AddAttributeToTag(\$html, $tag, $attributeName, $attributeValue)");
	WriteLog('AddAttributeToTag: length($html) $lengthBefore: ' . $lengthBefore);

	my $tagAttribute = '';
	if ($attributeValue eq '') {
		$tagAttribute = $attributeName;
	}
	elsif ($attributeValue =~ m/\s/ || index($attributeValue, "'") != -1 || index($attributeValue, '(') != -1 || index($attributeValue, ')') != -1) {
		# attribute value contains whitespace, must be enclosed in double quotes
		$tagAttribute = $attributeName . '="' . $attributeValue . '"';
	}
	else {
		$tagAttribute = $attributeName . '=' . $attributeValue . '';
	}

	my $htmlBefore = $html;
	$html = str_ireplace('<' . $tag . ' ', '<' . $tag . ' ' . $tagAttribute . ' ', $html);
	if ($html eq $htmlBefore) {
		$html = str_ireplace('<' . $tag . '', '<' . $tag . ' ' . $tagAttribute . ' ', $html);
	}
	if ($html eq $htmlBefore) {
		$html = str_ireplace('<' . $tag . '>', '<' . $tag . ' ' . $tagAttribute . '>', $html);
	}
	if ($html eq $htmlBefore) {
		WriteLog('AddAttributeToTag: warning: nothing was changed; $tag = ' . $tag . '; $attributeName = ' . $attributeName . '; caller = ' . join (',', caller));
	}

	my $lengthAfter = length($html);

	if ($lengthBefore == $lengthAfter) {
		WriteLog('AddAttributeToTag: warning: $lengthBefore == $lengthAfter = ' . $lengthAfter . '; caller = ' . join (',', caller));
	}

	return $html;
} # AddAttributeToTag()

sub RemoveHtmlFile { # $file ; removes existing html file
# sub RemoveHtmlPage {
# sub DeleteHtml {
# sub DeleteHtmlFile {
# sub DeleteItemPage {

# returns 1 if file was removed
	my $file = shift;
	if (!$file) {
		return 0;
	}
	if ($file eq 'index.html') {
		# do not remove index.html
		# temporary measure until caching is fixed
		# also needs a fix for lazy html, because htaccess rewrite rule doesn't catch it
		return 0;
	}

	my $HTMLDIR = GetDir('html');

	my $fileProvided = $file;
	$file = "$HTMLDIR/$file";

	if (
		$file =~ m/^([0-9A-Za-z\/.]+)$/
			&&
		index($file, '..') == -1
	) {
		# sanity check passed
		WriteLog('RemoveHtmlFile: sanity check passed for $file = ' . $file);
		$file = $1;
		if (-e $file) {
			unlink($file);
		}
		return 1;
	} else {
		WriteLog('RemoveHtmlFile: warning: sanity check failed, $file = ' . $file);
		return '';
	}
} # RemoveHtmlFile()

sub GetTargetPath { # $target ; gets the target url for an action
# for example, GetTargetPath('post') may return /post.html or /post.php or /cgi-bin/post depending on configuration
# sub GetUrl {
# sub GetTargetUrl {
# sub GetEndpointPath {
# sub GetRoutePath {
# sub GetPostUrl {
	my $target = shift;
	if ($target =~ m/([a-z]+)/) {
		$target = $1;
	} else {
		WriteLog('GetTargetPath: warning: sanity check failed on $target; caller = ' . join(',', caller));
		return '';
	}

	state %returnValue;

	my @validTargets = qw(post);

	if (in_array($target, @validTargets)) {
		if ($returnValue{$target}) {
			return $returnValue{$target};
		}

		if ($target eq 'post') {
			if (GetConfig('setting/admin/python3_server/enable')) {
				if (GetConfig('setting/admin/cgi/enable')) {
					$returnValue{$target} = '/cgi-bin/post.py';
				} else {
					$returnValue{$target} = '/post.html';
				}
			}
			if (GetConfig('setting/admin/lighttpd/enable')) {
				if (GetConfig('setting/admin/php/enable')) {
					if (GetConfig('setting/admin/php/rewrite')) {
						$returnValue{$target} = '/post.html';
					} else {
						$returnValue{$target} = '/post.php';
					}
				} else {
					$returnValue{$target} = '/post.html';
				}
			}
		}
	} else {
		WriteLog('GetTargetPath: warning: $target was not in @validTargets; caller = ' . join(',', caller));
		return '';
	}

	#todo sanity check on $returnValue;

	WriteLog('GetTargetPath: $target = ' . $target . '; $returnValue{$target} = ' . $returnValue{$target});

	return $returnValue{$target};
} # GetTargetPath()

1;
