#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetDefault { # $configName
	my $configName = shift;
	chomp $configName;

	$configName = FixConfigName($configName);

	WriteLog('GetDefault: $configName = ' . $configName);
	#todo sanity

	state %defaultLookup;

	if ((exists($defaultLookup{$configName}))) {
		# found in memo
		WriteLog('GetDefault: $defaultLookup already contains value, returning that...');
		WriteLog('GetDefault: $defaultLookup{$configName} is ' . $defaultLookup{$configName});
		return $defaultLookup{$configName};
	}

	if ((-e "default/$configName")) {
		# found a match in default directory
		WriteLog("GetDefault: -e default/$configName returned true, proceeding to GetFile()");
		my $defaultValue = GetFile("default/$configName");
		if (substr($configName, 0, 9) eq 'template/') {
			# do not trim templates
		} else {
			# trim() resulting value (removes whitespace)
			$defaultValue = trim($defaultValue);
		}
		$defaultLookup{$configName} = $defaultValue;
		return $defaultValue;
	} # found in default/
} # GetDefault()

sub FixConfigName { # $configName ; prepend 'setting/' to config paths as appropriate
	my $configName = shift;
	chomp $configName;

	if (!$configName) {
		WriteLog('FixConfigName: warning: $configName was FALSE; caller = ' . join(',', caller));
		return '';
	}

	$configName = trim($configName);

	my @notSetting = qw(query res sqlite3 string setting template theme);
	my $notSettingFlag = 0; # should NOT be prefixed with setting/
	for my $notSettingItem (@notSetting) {
		if ($configName ne 'theme' && substr($configName, 0, length($notSettingItem)) eq $notSettingItem) {
			$notSettingFlag = 1;
		}
	}
	if (!$notSettingFlag && $configName ne 'debug') {
		WriteLog('FixConfigName: (GetConfig) adding setting/ prefix to $configName = ' . $configName);
		$configName = 'setting/' . $configName;
	} else {
		WriteLog('FixConfigName: (GetConfig) NOT adding setting/ prefix to $configName = ' . $configName);
	}

	return $configName;
} # FixConfigName()

sub GetConfig { # $configName || 'unmemo', $token, [$parameter] ;  gets configuration value based for $key
# sub GetThemeTemplate {
# sub GetThemeSetting {
# sub GetThemeValue {

	# $token eq 'unmemo'
	#    removes memo entry for $token from %configLookup

	# $token eq 'override'
	# 	instead of regular lookup, overrides value
	#		overridden value is stored in local sub memo
	#			this means all subsequent lookups now return $parameter
	#
	#	this is janky, and doesn't work as expected
	#	this also only works for one value at a time, because it clears
	#	the entire memo when it's done lol
	#
	#	eventually, it will be nice for dev mode to not rewrite
	#	the entire config tree on every rebuild
	#	and also not require a rebuild after a default change
	#		note: this is already possible, there's a config for it:
	#		$CONFIGDIR/admin/dev/skip_putconfig
	#	#todo
	#
	# CONFUSION WARNING there are two separate "unmemo" features,
	# one for the whole thing, another individual keys
	#
	# new "method": get_memo, returns the whole thing for debug output

	my $configName = shift;

	if (!defined($configName)) {
		WriteLog('GetConfig: warning: $configName was undefined; caller = ' . join(',', caller));
		return '';
	}

	chomp $configName;

	if (!$configName) {
		WriteLog('GetConfig: warning: $configName was FALSE; caller = ' . join(',', caller));
		return '';
	}

	my $token = shift;
	if ($token) {
		chomp $token;
	} else {
		$token = '';
	}
	my $parameter = shift;
	if (!defined($parameter)) {
		# otherwise we get a warning below
		$parameter = '';
	}
	if ($parameter) {
		chomp $parameter;
	}

	WriteLog('======================================================================');
	WriteLog("GetConfig($configName); \$token = $token; \$parameter = $parameter; caller: " . join(',', caller));

	state $CONFIGDIR = GetDir('config'); # config/
	state $DEFAULTDIR = GetDir('default'); #default/

	state %configLookup;

	if ($configName && ($configName eq 'unmemo')) {
		WriteLog('GetConfig: FULL UNMEMO requested, removing %configLookup');
		GetThemeAttribute('unmemo');
		GetTemplate('unmemo');
		undef %configLookup;
		return '';
	}

	#WriteLog('GetConfig: $configName BEFORE FixConfigName() is ' . $configName);
	$configName = FixConfigName($configName);
	#WriteLog('GetConfig: $configName AFTER FixConfigName() is ' . $configName);

	if ($token && $token eq 'unmemo') {
		# not sure if this is every called?
		# it could be useful for changing config values during runtime

		WriteLog('GetConfig: unmemo token found');

		my $unmemoCount = 0;
		if (exists($configLookup{'_unmemo_count'})) {
			$unmemoCount = $configLookup{'_unmemo_count'}
		}

		# remove memoized value(s)
		if ($configName) {
			if (exists($configLookup{$configName})) {
				delete($configLookup{$configName});
				$unmemoCount++;
				$configLookup{'_unmemo_count'} = $unmemoCount;
				return '';
				#we return here because otherwise it causes infinite recursion
				#todo this should be fixed in the future when unmemo and no recursion flag can be used together
			} else {
				WriteLog('GetConfig: warning: unmemo requested for unused key. $configName = ' . $configName);
			}
		} # if ($configName)
		else {
			WriteLog('GetConfig: warning: unmemo requested for no key. $configName = ' . $configName);
		}
	} # if ($token && $token eq 'unmemo')

	if ($token && ($token eq 'override')) {
		WriteLog('GetConfig: override token detected');
		if ($parameter || (defined($parameter) && ($parameter eq '' || $parameter == 0))) {
			WriteLog('GetConfig: override: setting $configLookup{' . $configName . '} := ' . $parameter);
			%configLookup = ();
			GetTemplate('unmemo');
			GetThemeAttribute('unmemo');
			WriteLog('GetConfig: override: %configLookup emptied');
			$configLookup{$configName} = $parameter;

			if (0) { #test/debug
				my $testResult = GetConfig($configName);
				WriteLog('GetConfig: override: testResult = ' . $testResult . '; $parameter = ' . $parameter . '; $configLookup{' . $configName . '} = ' . $configLookup{$configName});
				if ($testResult ne $parameter) {
					WriteLog('GetConfig: override: warning: testResult != $parameter');
				}
				else {
					WriteLog('GetConfig: override: sanity check PASSED: testResult == $parameter');
				}
			} # test/debug
		} # if ($parameter || (defined($parameter) && ($parameter eq '' || $parameter == 0)))
		else {
			WriteLog('GetConfig: warning: $token was override, but no parameter. sanity check failed.');
			return '';
		}
	}

	if (exists($configLookup{$configName})) {
		# found in memo
		#WriteLog('GetConfig: ' . $configName . ' $configLookup already contains value, returning: ' . $configLookup{$configName});
		if (index($configName, 'dragging') != -1) {
			WriteLog('GetConfig: $configLookup{' . $configName . '} is ' . $configLookup{$configName});
		}
		#todo WriteLog() should skip multiline output unless config/debug > 1
		return $configLookup{$configName};
	}

	if ($token ne 'no_theme_lookup') {
		WriteLog("GetConfig: no_theme_lookup: Trying GetThemeAttribute() first...");
		if (
			$configName ne "setting/theme" &&
			substr($configName, 0, 6) ne 'theme/'
		) {
			my $themeAttributeValue = '';
			#$themeAttributeValue = GetThemeAttribute($configName);
			if ($themeAttributeValue) {
				$configLookup{$configName} = $themeAttributeValue;
				return $configLookup{$configName};
			}
		}
	}

	WriteLog("GetConfig: Looking for config value in $CONFIGDIR/$configName ...");

	my $acceptableValues;
	if ($configName eq 'setting/html/clock_format') {
		if (substr($configName, -5) ne '.list') {
			#todo i don't think this ever happens?
			my $configList = GetConfig("$configName.list"); # should this be GetDefault()? arguable
			if ($configList) {
				$acceptableValues = $configList;
			}
		}
	} else {
		$acceptableValues = 0;
	}

	if (-d "$CONFIGDIR/$configName") {
		WriteLog('GetConfig: warning: $configName was a directory, returning');
		return;
	}

	if (-e "$CONFIGDIR/$configName") {
		# found in $CONFIGDIR/
		# found a match in config directory
		WriteLog("GetConfig: -e $CONFIGDIR/$configName returned true, proceeding to GetFile(), set \$configLookup{}, and return \$configValue");

		if (-e "$CONFIGDIR/debug") {
			my @statDefault = stat("$DEFAULTDIR/$configName");
			my @statConfig = stat("$CONFIGDIR/$configName");

			my $timeDefault = $statDefault[9];

			if ($timeDefault) {
				my $timeConfig = $statConfig[9];

				if ($timeDefault > $timeConfig) {
					WriteLog('GetConfig: warning: default is newer than config: ' . $configName);
				}
			}
		}

		my $configValue = GetFile("$CONFIGDIR/$configName");
		if (substr($configName, 0, 9) eq 'template/') {
			# do not trim templates
		} else {
			# trim() resulting value (removes whitespace)
			$configValue = trim($configValue);
		}
		
		if ($acceptableValues) {
			# there is a list of acceptable values
			# check to see if value is in that list
			# if not, issue warning and return 0
			if (index($configValue, $acceptableValues)) {
				$configLookup{$configName} = $configValue;
				return $configValue;
			} else {
				WriteLog('GetConfig: warning: $configValue was not in $acceptableValues');
				return 0; #todo should return default, perhaps via $param='default'
			}
		} else {
			$configLookup{$configName} = $configValue;
			return $configValue;
		}
	} # if (-e "$CONFIGDIR/$configName")
	else { # not found in $CONFIGDIR/
		WriteLog("GetConfig: -e $CONFIGDIR/$configName returned false, looking in defaults...");

		if (-e "$DEFAULTDIR/$configName") {
			# found default, return that
			WriteLog("GetConfig: -e $DEFAULTDIR/$configName returned true, proceeding to GetFile(), etc...");
			my $configValue = GetFile("$DEFAULTDIR/$configName");
			$configValue = trim($configValue);
			$configLookup{$configName} = $configValue;

			if (!GetConfig('admin/dev/skip_putconfig')) {
				# this preserves default settings, so that even if defaults change in the future
				# the same value will remain for current instance
				# this also saves much time not having to run ./clean_dev when developing
				WriteLog('GetConfig: calling PutConfig($configName = ' . $configName . ', $configValue = ' . length($configValue) .'b);');

				#PutConfig($configName, $configValue);
				if (GetConfig('setting/admin/config_add_newline') && index($configValue, "\n") == -1) {
					PutConfig($configName, $configValue . "\n");
					# this is done to make the configs look nicer in the term
					# #todo add a feature flag for this
				}
				else {
					PutConfig($configName, $configValue);
				}
			} else {
				WriteLog('GetConfig: skip_putconfig= TRUE, not calling PutConfig()');
			}

			return $configValue;
		} # return $DEFAULTDIR/
		else {
			if (substr($configName, 0, 16) eq 'template/js/lib/') {
				WriteLog('GetConfig: found a missing js library, inflating all');

				my $jsLibSourcePath = $DEFAULTDIR . '/template/js/lib/jslib.tar.gz';
				my $jsLibTargetPath = $CONFIGDIR . '/template/js/lib/';

				EnsureSubdirs($jsLibTargetPath);

				WriteLog('GetConfig: $jsLibSourcePath = ' . $jsLibSourcePath . '; $jsLibTargetPath = ' . $jsLibTargetPath);
				my $tarCommand = "tar -vzxf $jsLibSourcePath -C $jsLibTargetPath";
				WriteLog('GetConfig: $tarCommand = ' . $tarCommand);
				my $tarCommandResult = `$tarCommand`;
				WriteLog('GetConfig: $tarCommandResult = ' . $tarCommandResult);

				return GetConfig($configName);
			} # if (substr($configName, 0, 16) eq 'template/js/lib/')

			if (substr($configName, 0, 6) eq 'theme/' || substr($configName, 0, 7) eq 'string/') {
				WriteLog('GetConfig: no default; $configName = ' . $configName);
				return '';
			} else {
				if ($configName =~ m/\.list$/ || $configName =~ m/debug/) {
					# cool
					return '';
				} else {
					WriteLog('GetConfig: warning: Tried to get undefined config with no default; $configName = ' . $configName . '; caller = ' . join (',', caller));
					return '';
				}
			}
		} # not found in $DEFAULTDIR/
	} # not found in $CONFIGDIR/

	WriteLog('GetConfig: warning: reached end of function, which should not happen');
	return '';
} # GetConfig()

sub ConfigKeyValid { #checks whether a config key is valid
	# valid means passes character sanitize
	# and exists in default/
	my $configName = shift;

	if (!$configName) {
		WriteLog('ConfigKeyValid: warning: $configName parameter missing');
		return 0;
	}

	$configName = FixConfigName($configName);

	WriteLog("ConfigKeyValid($configName)");

	if (! ($configName =~ /^[a-z0-9_\/]{1,64}$/) ) {
		WriteLog("ConfigKeyValid: warning: sanity check failed! caller = " . join(',', caller));
		return 0;
	}

	WriteLog('ConfigKeyValid: $configName sanity check passed:');

	#my $CONFIGDIR = GetDir('config');
	my $DEFAULTDIR = GetDir('default');

	if (-e "$DEFAULTDIR/$configName") {
		WriteLog("ConfigKeyValid: $DEFAULTDIR/$configName exists, return 1");
		return 1;
	} else {
		WriteLog("ConfigKeyValid: $DEFAULTDIR/$configName NOT exist, return 0");
		return 0;
	}
} # ConfigKeyValid()

sub ResetConfig { # Resets $configName to default by removing the config/* file
	# Does a ConfigKeyValid() sanity check first
	my $configName = shift;

	my $CONFIGDIR = GetDir('config');

	if (ConfigKeyValid($configName)) {
		WriteLog('ResetConfig: removing stored config; $configName = ' . $configName . '; caller = ' .join(',', caller));
		unlink("$CONFIGDIR/$configName");
	}
} # ResetConfig()

sub PutConfig { # $configName, $configValue ; writes config value to config storage
#sub SetString {
	# $configName = config name/key (file path)
	# $configValue = value to write for key
	# Uses PutFile()

	my $configName = shift;
	my $configValue = shift;

	my $CONFIGDIR = GetDir('config');

	$configName = FixConfigName($configName);

	if (index($configName, '..') != -1) {
		WriteLog('PutConfig: warning: sanity check failed: $configName contains ".."');
		WriteLog('PutConfig: warning: sanity check failed: $configName contains ".."');
		return '';
	}

	#chomp $configValue;

	#todo there needs to be a sanity check here to see if $configValue was not provided

	WriteLog('PutConfig: $configName = ' . $configName . ', $configValue = ' . length($configValue) . 'b)');

	my $putFileResult = PutFile("$CONFIGDIR/$configName", $configValue);

	# ask GetConfig() to remove memo-ized value it stores inside
	GetConfig($configName, 'unmemo');

	return $putFileResult;
} # PutConfig()

sub GetConfigListAsArray { # $listName ; returns an array from a config list template treated as a whitespace-separated list
# sub GetConfigAsArray {
# sub GetList {
	my $listName = shift;
	chomp $listName;

	#todo sanity checks

	my @listRaw = split("\n", trim(GetTemplate('list/' . $listName)));
	WriteLog('GetConfigListAsArray: $listName = ' . $listName . '; scalar(@listRaw) = ' . scalar(@listRaw));

	return @listRaw;

	#todo sanity checks and etc
	#	my @listClean;
	#	for(my $i = 0; $i < scalar(@listRaw); $i++) {
	#		if (trim($listRaw[$i]) eq '') {
	#			# nothing, it's blank
	#		} else {
	#			if ($listRaw[$i] =~ m/^([0-9a-zA-Z_])$/) {
	#				my $newItem = $1;
	#				push @listClean, $newItem;
	#			} else {
	#				# nothing, it fails sanity check
	#			}
	#		}
	#	}
	#
	#	return @listClean;
} # GetConfigListAsArray()

sub GetConfigValueAsArray { # $listName ; returns an array from a config value treated as a whitespace-separated list
# this should probably be merged with GetConfigListAsArray(), but i'm not sure how yet
	my $listName = shift;
	chomp $listName;

	#todo sanity checks

	my @listRaw = split("\n", trim(GetConfig($listName)));
	WriteLog('GetConfigValueAsArray: $listName = ' . $listName . '; scalar(@listRaw) = ' . scalar(@listRaw));

	return @listRaw;

	#todo sanity checks and etc
	#	my @listClean;
	#	for(my $i = 0; $i < scalar(@listRaw); $i++) {
	#		if (trim($listRaw[$i]) eq '') {
	#			# nothing, it's blank
	#		} else {
	#			if ($listRaw[$i] =~ m/^([0-9a-zA-Z_])$/) {
	#				my $newItem = $1;
	#				push @listClean, $newItem;
	#			} else {
	#				# nothing, it fails sanity check
	#			}
	#		}
	#	}
	#
	#	return @listClean;
} # GetConfigValueAsArray()

sub GetActiveThemes { # return list of active themes (config/setting/theme)
# sub GetThemes {
# sub ListThemes {
# sub GetThemeList {
# sub GetThemesList {
# sub GetActiveThemesList {
	WriteLog('GetActiveThemes: caller = ' . join(',', caller));
	#GetConfig('setting/theme', 'override', 'dark'); # used during testing/dev
	my $themesValue = GetConfig('setting/theme');
	if ($themesValue) {
		$themesValue =~ s/[\s]+/ /g; # strip extra whitespace and convert to spaces
		my @activeThemes = split(' ', $themesValue); # split by spaces
		foreach my $themeName (@activeThemes) {
			#todo some validation
		}
		WriteLog('GetActiveThemes: returning @activeThemes = ' . join(' ', @activeThemes));
		return @activeThemes;
	} else {
		WriteLog('GetActiveThemes: warning: $themesValue is FALSE; caller = ' . join(',', caller));
		return '';
	}
} # GetActiveThemes()

sub GetThemeAttribute { # returns theme color from $CONFIGDIR/theme/
# sub GetThemeStyle {

# ATTENTION: this may be CONFUSING at first:
# * additional.css special case:
#   values will be concatenated instead of returning first one
# * #todo template/list/menu special case: #todo
#   values will be concatenated instead of returning first one
	my $attributeName = shift;
	chomp $attributeName;

	WriteLog('GetThemeAttribute(' . $attributeName . ')');

	my $returnValue = '';

	#my $themesValue = GetConfig('theme');
	#$themesValue =~ s/[\s]+/ /g;
	#my @activeThemes = split(' ', $themesValue);
	state @activeThemes;

	if (!@activeThemes || $attributeName eq 'unmemo') {
		WriteLog('GetThemeAttribute: @activeThemes is empty or $attributeName = unmemo; calling GetActiveThemes()' . '; caller = ' . join(',', caller));
		@activeThemes = GetActiveThemes();
		if (!@activeThemes) {
			WriteLog('GetThemeAttribute: warning: @activeThemes was FALSE');
		} else {
			WriteLog('GetThemeAttribute: @activeThemes = ' . join(' ', @activeThemes));
		}
	}

	foreach my $themeName (@activeThemes) {
		my $attributePath = 'theme/' . $themeName . '/' . $attributeName;

		#todo sanity checks
		my $attributeValue = GetConfig($attributePath, 'no_theme_lookup');

		WriteLog('GetThemeAttribute: $attributeName = ' . $attributeName . '; $themeName = ' . $themeName . '; $attributePath = ' . $attributePath);

		if ($attributeValue && trim($attributeValue) ne '') {
			WriteLog('GetThemeAttribute: ' . $attributeName . ' + ' . $themeName . ' -> ' . $attributePath . ' -> length($attributeValue) = ' . length($attributeValue));
			if ($attributeName eq 'additional.css') {
				$returnValue .= $attributeValue || '';
				$returnValue .= "\n";
				if (GetConfig('html/css/theme_concat')) { # css_combine css_concat
					# nothing
					# concatenate all the selected themes' css together
				} else {
					last;
				}
			}
			else {
				$returnValue = $attributeValue || '';
				last;
			}
		} # if ($attributeValue && trim($attributeValue) ne '')
	} # foreach $themeName (@activeThemes)

	if (trim($returnValue) eq '') {
		if ($attributeName =~ m/^template/ || $attributeName =~ m/^string/) {
			# this is ok
		} else {
			# not ok
			WriteLog('GetThemeAttribute: warning: $returnValue is empty for $attributeName = ' . $attributeName . '; caller = ' . join(',', caller));
		}
	}

	WriteLog('GetThemeAttribute: length($returnValue) = ' . length($returnValue) . '; $attributeName = ' . $attributeName);
	#WriteLog('GetThemeAttribute: $returnValue = ' . $returnValue . '; $attributeName = ' . $attributeName);

	return trim($returnValue);

#
#	if (!ConfigKeyValid("theme/$themeName")) {
#		WriteLog('GetThemeAttribute: warning: ConfigKeyValid("theme/$themeName") was false');
#		$themeName = 'chicago';
#	}
#
#	return trim($attributeValue);
} # GetThemeAttribute()

sub GetThemeColor { # returns theme color based on setting/theme
# sub GetColor {
	my $colorName = shift;
	chomp $colorName;

	if ($colorName eq 'link' || $colorName eq 'vlink') {
		WriteLog('GetThemeColor: $colorName = ' . $colorName . ' changed to ' . ($colorName . '_text') . '; caller = ' . join(',', caller));
		$colorName .= '_text';
	}

	if (GetConfig('html/monochrome')) { # GetThemeColor()
		#todo in hypercode theme + monochrome, the page background color should be #e9caad, to match hypercode_bg.jpg
		if (index(lc($colorName), 'text') != -1 || index(lc($colorName), 'link') != -1) {
			if (index(lc($colorName), 'back') != -1) {
				return GetConfig('html/color/background'); # #BackgroundColor
			} else {
				return GetConfig('html/color/text'); # #TextColor
			}
		} else {
			return GetConfig('html/color/background'); # #BackgroundColor
		}
	}

	if (GetConfig('html/mourn')) { # GetThemeColor()
		if (index(lc($colorName), 'text') != -1 || index(lc($colorName), 'link') != -1) {
			if (index(lc($colorName), 'back') != -1) {
				return '#000000'; # #BackgroundColor
			} else {
				return '#c0c0c0'; # #TextColor
			}
		} else {
			return '#000000'; # #BackgroundColor
		}
	}

	$colorName = 'color/' . $colorName;
	my $color = GetThemeAttribute($colorName);

	if (!defined($color) || $color eq '') {
		# we didn't find a color using GetThemeAttribute() so let's try to find a fallback
		# if the color we're looking up is called "..text" or "..background", use text or background color
		# otherwise, use green
		if (0) {}
		elsif ($color =~ m/text$/ && $color ne 'text') {
			WriteLog('GetThemeColor: warning: substituting $colorName = text for ' . $colorName . '; caller = ' . join(',', caller));
			$color = GetThemeColor('text');
		}
		elsif ($color =~ m/background$/ && $color ne 'background') {
			WriteLog('GetThemeColor: warning: substituting $colorName = background for ' . $colorName . '; caller = ' . join(',', caller));
			$color = GetThemeColor('background');
		}
		elsif ($color eq 'text' || $color eq 'background') {
			if (GetConfig('html/mourn')) { # GetThemeColor()
				$color = '#000000';
			} else {
				$color = '#00ff00';
			}
		}
		WriteLog('GetThemeColor: warning: value not found, $colorName = ' . $colorName . '; caller = ' . join(',', caller));
	}

	if ($color =~ m/^[0-9a-fA-F]{6}$/) {
		# if it looks like a hex color without '#' prefix, add the prefix
		$color = '#' . $color;
	}

	return $color;
} # GetThemeColor()

sub FillThemeColors { # $html ; fills in templated theme colors in provided html
# sub FillHtmlColors {
# sub FillColors {
# sub ReplaceColors {
#todo think about whether this should be in html.pl? it just does so much more config stuff than html stuff... and it may be used for something other than html
	my $html = shift;
	chomp($html);

	my $colorTagNegativeText = GetThemeColor('tag_negative_text');
	$html =~ s/\$colorTagNegativeText/$colorTagNegativeText/g;

	my $colorTagPositiveText = GetThemeColor('tag_positive_text');
	$html =~ s/\$colorTagPositiveText/$colorTagPositiveText/g;

	my $colorInputBackground = GetThemeColor('input_background');
	$html =~ s/\$colorInputBackground/$colorInputBackground/g;

	my $colorInputText = GetThemeColor('input_text');
	$html =~ s/\$colorInputText/$colorInputText/g;

	my $colorRow0Bg = GetThemeColor('row_0');
	$html =~ s/\$colorRow0Bg/$colorRow0Bg/g;

	my $colorRow1Bg = GetThemeColor('row_1');
	$html =~ s/\$colorRow1Bg/$colorRow1Bg/g;

	my $colorHighlightAlert = GetThemeColor('highlight_alert');
	$html =~ s/\$colorHighlightAlert/$colorHighlightAlert/g;

	my $colorHighlightBeginner = GetThemeColor('highlight_beginner');
	$html =~ s/\$colorHighlightBeginner/$colorHighlightBeginner/g;

	my $colorHighlightAdvanced = GetThemeColor('highlight_advanced');
	$html =~ s/\$colorHighlightAdvanced/$colorHighlightAdvanced/g;

	my $colorTopMenuTitlebarText = GetThemeColor('top_menu_titlebar_text');
	$html =~ s/\$colorTopMenuTitlebarText/$colorTopMenuTitlebarText/g;

	my $colorTopMenuTitlebar = GetThemeColor('top_menu_titlebar');
	$html =~ s/\$colorTopMenuTitlebar/$colorTopMenuTitlebar/g;

	my $colorTitlebarText = GetThemeColor('titlebar_text');
	$html =~ s/\$colorTitlebarText/$colorTitlebarText/g;

	my $colorTitlebar = GetThemeColor('titlebar');
	$html =~ s/\$colorTitlebar/$colorTitlebar/g;

	my $colorHighlightReady = GetThemeColor('highlight_ready');
	$html =~ s/\$colorHighlightReady/$colorHighlightReady/g;
	#
	# my $colorWindow = GetThemeColor('window');
	# $html =~ s/\$colorWindow/$colorWindow/g;

	my $colorDialogHeading = GetThemeColor('dialog_heading');
	$html =~ s/\$colorDialogHeading/$colorDialogHeading/g;

	my @colors = qw(primary secondary background text link vlink window);
	for my $color (@colors) {
		#todo my @array1 = map ucfirst, @array;
		my $templateToken = '$color' . ucfirst($color);
		$html = str_replace($templateToken, GetThemeColor($color), $html);
	}
	# there are two issues with replacing below with above
	# a) searching for template token in code wouldn't find this section
	# b)
	# my $colorPrimary = GetThemeColor('primary');
	# $html =~ s/\$colorPrimary/$colorPrimary/g;
	#
	# my $colorSecondary = GetThemeColor('secondary');
	# $html =~ s/\$colorSecondary/$colorSecondary/g;
	#
	# my $colorBackground = GetThemeColor('background');
	# $html =~ s/\$colorBackground/$colorBackground/g;
	#
	# my $colorText = GetThemeColor('text');
	# $html =~ s/\$colorText/$colorText/g;
	#
	# my $colorLink = GetThemeColor('link');
	# $html =~ s/\$colorLink/$colorLink/g;
	#
	# my $colorVlink = GetThemeColor('vlink');
	# $html =~ s/\$colorVlink/$colorVlink/g;

	return $html;
} # FillThemeColors()

if (0) { #tests
	require('./utils.pl');
	require_once('sqlite.pl');
	print "GetConfig('current_version') = " . GetConfig('current_version') . "\n";
	print "GetTemplate('query/related') = " . GetTemplate('query/related') . "\n";
	print "SqliteGetQueryTemplate('related') = " . SqliteGetQueryTemplate('related') . "\n";
	print "GetConfig('setting/html/page_limit') = " . GetConfig('setting/html/page_limit') . "\n";
	print "GetThemeAttribute('setting/html/page_limit') = " . GetThemeAttribute('setting/html/page_limit') . "\n";
}

1;
