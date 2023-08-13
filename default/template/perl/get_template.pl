#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetTemplate { # $templateName ; returns specified template from template directory
# returns empty string if template not found
# here is how the template file is chosen:
# 1. template's existence is checked in config/template/ or default/template/
#    a. if it is found, it is THEN looked up in the config/theme/template/ and default/theme/template/
#    b. if it is not found in the theme directory, then it is looked up in config/template/, and then default/template/
# this allows themes to override existing templates, but not create new ones
#
	my $filename = shift;
	chomp $filename;
	#	$filename = "$SCRIPTDIR/template/$filename";

	#todo if more than one argument, raise warning
	#if (scalar(@_)) {
	#	WriteLog('GetTemplate: warning: was called with more than one argument; caller = ' . join(',', caller));
	#}

	my $isHtmlTemplate = 0;
	if ($filename =~ m/^html/) {
		$isHtmlTemplate = 1;
	}

	state $CONFIGDIR = GetDir('config');
	state $DEFAULTDIR = GetDir('default');

	WriteLog("GetTemplate($filename) get_template.pl caller: " . join(', ', caller));
	state %templateMemo; #stores local memo cache of template
	if ($templateMemo{$filename}) {
		#if already been looked up, return memo version
		WriteLog('GetTemplate: returning from memo for ' . $filename);
		if (trim($templateMemo{$filename}) eq '') {
			WriteLog('GetTemplate: warning: returning empty string for ' . $filename);
		}
		return $templateMemo{$filename};
	}

	if (!-e ($CONFIGDIR . '/template/' . $filename) && !-e ($DEFAULTDIR . '/template/' . $filename)) {
		#todo this should not fail if there is a template in the current theme
		#shim for rename
		if (-e ($CONFIGDIR . '/html/' . $filename) || -e ($DEFAULTDIR . '/html/' . $filename)) {
			WriteLog('GetTemplate: warning: template reference needs to be prepended with html: ' . $filename);
			return GetTemplate('html/' . $filename);
		}

		# if template doesn't exist
		# and we are in debug mode
		# report the issue
		WriteLog('GetTemplate: warning: template missing; $filename = ' . $filename . '; $DEFAULTDIR = ' . $DEFAULTDIR . '; $CONFIGDIR = ' . $CONFIGDIR);
		WriteLog('GetTemplate: warning: template missing; $filename = ' . $filename . '; caller = ' . join(',', caller));
		#WriteLog('GetTemplate: warning: template missing; ' . ($CONFIGDIR . '/template/' . $filename));
		#WriteLog('GetTemplate: warning: template missing; ' . ($DEFAULTDIR . '/template/' . $filename));
	}

	#information about theme
#	my $themeName = GetConfig('theme');
#	my $themePath = 'theme/' . $themeName . '/template/' . $filename;

	my $template = '';
	if (GetThemeAttribute('template/' . $filename)) {
		WriteLog('GetTemplate: Found GetThemeAttribute(template/' . $filename . ')');
		#if current theme has this template, override default
		$template = GetThemeAttribute('template/' . $filename);
	} elsif (GetConfig('template/' . $filename)) {
		WriteLog('GetTemplate: found GetConfig(template/' . $filename . ')');
		#otherwise use regular template
		$template = GetConfig('template/' . $filename);
	} else {
		WriteLog('GetTemplate: warning: found neither GetThemeAttribute(template/' . $filename . ') nor GetConfig(template/' . $filename . '); caller = ' . join(',', caller));
		$template = '';
	}

	# add \n to the end because it makes the resulting html look nicer
	# and doesn't seem to hurt anything else
	$template .= "\n";

	if ($isHtmlTemplate && GetConfig('debug')) {
		#todo this is buggy
		#$template .= '<!-- ' . join(', ', caller) . '-->' . "\n";
	}

	if ($isHtmlTemplate) {
		if (substr($template, 0, 4) eq '<!--') {
			# add newline to make it look nicer in the html source
			$template = "\n" . $template;
		}
	}

	if ($template) {
		#if template contains something, cache it
		$templateMemo{$filename} = $template;
		return $template;
	} else {
		#if result is blank, report it
		WriteLog("GetTemplate: warning: GetTemplate() returning empty string for $filename.");
		return '';
	}
} # GetTemplate()

1;