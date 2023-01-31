#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub InjectJs { # $html, @scriptNames ; inject js template(s) before </body> ;
# sub InjectDebug {
# sub JsInject {
	my $html = shift;     # html we're going to inject into

	if (!$html || trim($html) eq '') {
		WriteLog('InjectJs: warning: $html is missing, returning');
		return '';
	}

	if (!GetConfig('admin/js/enable')) {
		# if js is disabled globally, abort
		WriteLog('InjectJs: warning: InjectJs() called when admin/js/enable is false');
		return $html;
	}

	my @scriptNames = @_; # array of names of script templates (minus the .js suffix)
	my $scriptsText = '';  # will contain all the js we want to inject
	my $scriptsComma = ''; # separator between scripts, will be set to \n\n after first script
	my %scriptsDone = ();  # hash to keep track of scripts we've already injected, to avoid duplicates

	if (GetConfig('setting/admin/js/profile_auto_register')) {
		push @scriptNames, 'profile_auto_register';
	}

	WriteLog('InjectJs: @scriptNames = (' . join (' ', @scriptNames) . ') ; caller= ' . join(',', caller));

	if (in_array('settings', @scriptNames)) {
		# some hard-coded script additions
		# these can be more selective in the future

		if (GetConfig('html/clock')) {
			push @scriptNames, 'clock';
		}

		if (GetConfig('admin/js/fresh')) {
			push @scriptNames, 'fresh';
		}

		if (GetConfig('admin/js/dragging')) {
			push @scriptNames, 'dragging'; # InjectJs()
		}

		if (GetConfig('admin/js/table_sort')) {
			push @scriptNames, 'table_sort';
		}
	}
	#

	###############################################
	# NO MORE ADDITIONS TO SCRIPT LIST AFTER HERE #
	###############################################

	WriteLog('InjectJs: after auto-additions, @scriptNames = (' . join (' ', @scriptNames) . ') ; caller= ' . join(',', caller));

	#output list of all the scripts we're about to include
	my $scriptNamesList = join(' ', @scriptNames);

	my $needDraggingHide = 0;
	# inject dragging_hide_dialogs.js after body tag
	# it prevents dialogs from jittering on page load when they need repositioning
	# this is kind of a hack

	foreach my $script (@scriptNames) {
		################################
		# loop through all the scripts #
		################################
		if ($script eq 'clock') {
			my $clockFormat = GetConfig('html/clock_format');
			if ($clockFormat eq 'epoch' || $clockFormat eq 'union' || $clockFormat eq '24hour') {
				$script = 'clock/' . $clockFormat;
			} else {
				next;
			}
		}

		if ($script eq 'translit') {
			if (!GetConfig('admin/js/translit')) {
				WriteLog('InjectJs: warning: translit requested, but admin/js/translit is off');
				next;
			}
		}

		if ($script eq 'dragging') {
			if (GetConfig('admin/js/dragging_initial_hide')) {
				$needDraggingHide = 1;
			}
		}

		if (defined($scriptsDone{$script})) {
			# only inject each script once, otherwise move on
			#todo may want to make this dependent on 'settings' too
			next;
		} else {
		}

		# separate each script with \n\n
		if (!$scriptsComma) {
			$scriptsComma = "\n\n";
		} else {
			$scriptsText .= $scriptsComma;
		}

		my $scriptTemplate = GetScriptTemplate("$script");

		if (trim($scriptTemplate) eq '') {
			WriteLog('InjectJs: warning: $scriptTemplate is FALSE. $script = ' . $script);
		} else {
			# add to the snowball of javascript
			$scriptsText .= $scriptTemplate;
		}

		# remember we've done this script
		$scriptsDone{$script} = 1;
	} # foreach $script (@scriptNames)

	my $needOnload = 0; # remember if we need to add <body onload attribute later
	{
		# if script we are injecting contains "OnLoadEverything",
		# we will need to add it to the <body onload attribute later
		if (index($scriptsText, 'OnLoadEverything') != -1) {
			$needOnload = 1;
		}
	}

	#####################################################
	# NO MORE ADDITIONS TO SCRIPTS TEXT BELOW THIS LINE #
	#####################################################

	# get the wrapper, i.e. <script>$javascript</script>
	my $scriptInject = GetTemplate('html/utils/scriptinject.template');
	# fill in the wrapper with our scripts from above
	$scriptInject =~ s/\$javascript/$scriptsText/g; #todo why is this /g ??

	if (GetConfig('debug')) {
		$scriptInject = str_replace('scriptinject.template -->', 'scriptinject.template (' . join(',', caller) . ') -->', $scriptInject);
	}

	$scriptInject = "\n" . '<!-- InjectJs: ' . $scriptNamesList . ' -->' . "\n\n" . $scriptInject;

	if (index($html, '</body>') > -1) {
		# replace it into html, right before the closing </body> tag
		WriteLog('InjectJs: html contains </body>, inserting before </body>');
		$html = str_ireplace('</body>', $scriptInject . '</body>', $html);
	} else {
		# if there was no </body> tag, just append at the end
		WriteLog('InjectJs: html does not contain </body>, appending');
		$html .= "\n\n" . $scriptInject;
	}

	if ($needOnload) {
		# remember, we need to add <body onload event
		if ($html =~ m/<body.*?onload.*?>/i) {
			# <body already has onload, forget about it
		} else {
			if (index($html, '<body') != -1) {
				# add onload attribute to body tag
				$html = AddAttributeToTag(
					$html,
					'body',
					'onload',
					'if (window.OnLoadEverything) { OnLoadEverything(); }'
				);
				$html = AddAttributeToTag(
					$html,
					'body',
					'onclick',
					"if (window.ShowPreNavigateNotification && event.target && (event.target.tagName == 'A') && !(event.target.onclick)) { ShowPreNavigateNotification(); }"
				);
			} else {
				WriteLog('InjectJs: wanted to  add attribute, but html does not contain body');
			}
		}
	}

	my $needOnUnload = 1;
	if ($needOnUnload) {
		# remember, we need to add <body onunload event
		if ($html =~ m/<body.*?onbeforeunload.*?>/i) {
			# <body already has onunload, forget about it
		} else {
			if (GetConfig('admin/js/loading')) {
				if (index($html, '<body') != -1) {
					# add onload attribute to body tag
					$html = AddAttributeToTag(
						$html,
						'body',
						'onbeforeunload',
						'if (window.ShowPreNavigateNotification){ ShowPreNavigateNotification();}'
						#					'if (window.OnUnloadEverything) { OnUnloadEverything(); }'
					);
				} else {
					WriteLog('InjectJs: warning: $html does not contain <body; caller = ' . join(',', caller));
				}
			}
		}
	}

	if ((index($html, 'dragging.js') == -1) && ($needDraggingHide)) {
		#hack
		$needDraggingHide = 0;
		WriteLog('InjectJs: warning: dragging.js missing, but $needDraggingHide is true');
	}

	if ($needDraggingHide) {
		$html = InjectJs2($html, 'after', '<body.+>', 'dragging_hide_dialogs');
		#sub InjectJs2{ # $html, $injectMode, $htmlTag, @scriptNames, ; inject js template(s) before </body> ;
	}

	return $html;
} # InjectJs()

sub GetScriptTemplate { # $script ; returns script for name
# sub GetScriptText {
# sub GetScriptContent {
	# default/template/js/$script.js
	# config/template/js/$script.js
	# fills in theme colors and server-side settings
	my $script = shift;

	#todo sanity

	WriteLog('GetScriptTemplate: $script = ' . $script);

	my $stringMeditate = GetString('meditate'); # default is 'Meditate...'

	my $scriptTemplate = GetTemplate("js/$script.js");

	if (!$scriptTemplate) {
		WriteLog("InjectJs: WARNING: Missing script contents for $script");
	}

	if ($script eq 'fresh') {
		#todo this should work for all admins, not just root
		# for profile.js we need to fill in current admin id
		if (GetConfig('admin/dev/fresh_reload')) {
			$scriptTemplate =~ s/freshUserWantsReload = 0/freshUserWantsReload = 1/g;
		}
	}

	if ($script eq 'voting') {
		# for voting.js we need to fill in some theme colors
		my $colorSuccessVoteUnsigned = GetThemeColor('success_vote_unsigned');
		my $colorSuccessVoteSigned = GetThemeColor('success_vote_signed');

		$scriptTemplate =~ s/\$colorSuccessVoteUnsigned/$colorSuccessVoteUnsigned/g;
		$scriptTemplate =~ s/\$colorSuccessVoteSigned/$colorSuccessVoteSigned/g;
	}

	if ($script eq 'profile' || $script eq 'write' || $script eq 'crypto2' || $script eq 'avatar') {
		my $configJsOpenPgp = GetConfig('setting/admin/js/openpgp') ? 1 : 0;
		$scriptTemplate = str_replace('var configJsOpenPgp = 0;', 'var configJsOpenPgp = ' . $configJsOpenPgp . ';', $scriptTemplate);
	}

	if ($script eq 'easyreg') {
		my $puzzlePrefix = GetConfig('setting/admin/puzzle/prefix');
		if ($puzzlePrefix) {
			$scriptTemplate = str_replace("var puzzlePrefix = '1337';", "var puzzlePrefix = '" . $puzzlePrefix . "';", $scriptTemplate);
		}
	}

	if ($script eq 'puzzle') {
		# for voting.js we need to fill in some theme colors
		my $puzzlePrefix = GetConfig('puzzle/prefix');;
		my $puzzleCycleLimit = GetConfig('puzzle/cycle_limit');
		my $puzzleSecondsLimit = GetConfig('puzzle/seconds_limit');

		WriteLog('InjectJs: puzzle: $puzzlePrefix = ' . $puzzlePrefix);
		WriteLog('InjectJs: puzzle: $puzzleCycleLimit = ' . $puzzleCycleLimit);
		WriteLog('InjectJs: puzzle: $puzzleSecondsLimit = ' . $puzzleSecondsLimit);

		$scriptTemplate =~ s/var lookingFor = '1337';/var lookingFor = '$puzzlePrefix';/g;
		$scriptTemplate =~ s/var cycleLimit = 1000000;/var cycleLimit = $puzzleCycleLimit;/g;
		$scriptTemplate =~ s/var secondsLimit = 10;/var secondsLimit = $puzzleSecondsLimit;/g;
	}

	if ($script eq 'profile') {
		#todo this should work for all admins, not just root
		# for profile.js we need to fill in current admin id
		my $currentAdminId = '';#GetRootAdminKey() || '-';
		#todo this whole thing should change to include non-root admins
		$scriptTemplate =~ s/\$currentAdminId/$currentAdminId/g;

		my $openPgpChecked = GetConfig('admin/js/openpgp_checked');
		if ($openPgpChecked) {
			$scriptTemplate = str_replace('var chkEnablePgpOn = 0;', 'var chkEnablePgpOn = 1;', $scriptTemplate);
		}
	}

	if ($script eq 'table_sort') {
		# for settings.js we also need to fill in some theme colors
		my $colorRow0 = GetThemeColor('row_0');
		my $colorRow1 = GetThemeColor('row_1');

		$scriptTemplate =~ s/var rowColor0 = '';/var rowColor0 = '$colorRow0';/g;
		$scriptTemplate =~ s/var rowColor1 = '';/var rowColor1 = '$colorRow1';/g;
	}

	if ($script eq 'itsyou') {
		my $itemFp = '00000000000000000'; #todo
		$scriptTemplate =~ s/var itemFp = 0;/var itemFp = '$itemFp';/g;
	}

	#if ($script eq 'settings' || $script eq 'loading_begin') {
	if (
		$script eq 'settings' ||
			$script eq 'timestamp' ||
			$script eq 'loading_end'
	) {
		# for settings.js we also need to fill in some theme colors
		my $colorHighlightAlert = GetThemeColor('highlight_alert');
		my $colorHighlightAdvanced = GetThemeColor('highlight_advanced');
		my $colorHighlightBeginner = GetThemeColor('highlight_beginner');
		my $colorHighlightReady = GetThemeColor('highlight_ready');

		$scriptTemplate =~ s/\$colorHighlightAlert/$colorHighlightAlert/g;
		$scriptTemplate =~ s/\$colorHighlightAdvanced/$colorHighlightAdvanced/g;
		$scriptTemplate =~ s/\$colorHighlightBeginner/$colorHighlightBeginner/g;
		$scriptTemplate =~ s/\$colorHighlightReady/$colorHighlightReady/g;

		my $colorRecentTimestamp = GetThemeColor('recent_timestamp');
		if ($colorRecentTimestamp) {
			$scriptTemplate =~ s/\$colorRecentTimestamp/$colorRecentTimestamp/g;
		} else {
			$colorRecentTimestamp = '#808000';
			$scriptTemplate =~ s/\$colorRecentTimestamp/$colorRecentTimestamp/g;
		}
	}

	if ($script eq 'reply_cart') {
		if (GetConfig('setting/admin/html/ascii_only')) {
			# leave it alone
		} else {
			$scriptTemplate = str_replace('-cart', '–cart', $scriptTemplate);
			# if not ascii-only mode, use an n-dash for the -cart button
			# n-dash should be the same width as + sign and keep the button from changing size

			#$scriptTemplate = str_replace('-cart', '&ndash;cart', $scriptTemplate);
		}
	}

	if ($script eq 'dragging') { # GetScriptTemplate()
		# for dragging.js we also need to fill in some theme colors

		my $colorWindow = GetThemeColor('titlebar_inactive_text');
		my $colorTitlebar = GetThemeColor('titlebar');
		my $colorTitlebarInactive = GetThemeColor('titlebar_inactive');
		my $colorSecondary = GetThemeColor('titlebar_inactive');
		my $colorTitlebarText = GetThemeColor('titlebar_text');

		$scriptTemplate = str_replace("var colorWindow = '';", "var colorWindow = '$colorWindow';", $scriptTemplate);
		$scriptTemplate = str_replace("var colorTitlebarInactive = '';", "var colorTitlebarInactive = '$colorTitlebarInactive';", $scriptTemplate);
		$scriptTemplate = str_replace("var colorTitlebar = '';", "var colorTitlebar = '$colorTitlebar';", $scriptTemplate);
		$scriptTemplate = str_replace("var colorSecondary = '';", "var colorSecondary = '$colorSecondary';", $scriptTemplate);
		$scriptTemplate = str_replace("var colorTitlebarText = '';", "var colorTitlebarText = '$colorTitlebarText';", $scriptTemplate);
	} #dragging

	if ($stringMeditate ne 'Meditate...') {
		WriteLog('GetScriptTemplate: $stringMeditate is not default, replacing');
		$scriptTemplate = str_replace('Meditate...', $stringMeditate, $scriptTemplate);
	}

	if (index($scriptTemplate, '>') > -1) {
		# warning here if script content contains > character, which is incompatible with mosaic's html comment syntax
		WriteLog('GetScriptTemplate: warning: Inject script "' . $script . '" contains > character');
	}

	if (GetConfig('admin/js/debug')) {
		#uncomment all javascript debug alert statements
		#and replace them with confirm()'s which stop on no/cancel
		$scriptTemplate = EnableJsDebug($scriptTemplate);
	}

	if (GetConfig('debug')) {
		# this is broken, #todo
		#$scriptTemplate = "\n" . '/* GetScriptTemplate(' . $script . ")\n" . 'caller = ' . join(',', caller) . "\n" . $scriptTemplate . ' */';
		#$scriptTemplate = $scriptTemplate . "\n" . '/*' . 'GetScriptTemplate(' . $script . ')' . "\n" . 'caller = ' . join(',', caller) . "\n" . ' */' . "\n";
	}

	if (trim($scriptTemplate) eq '') {
		WriteLog('GetScriptTemplate: warning: $scriptTemplate is empty!');
		return '';
	}

	return $scriptTemplate;
} # GetScriptTemplate()

sub InjectJs2 { # $html, $injectMode, $htmlTag, @scriptNames, ; inject js template(s) before </body> ;
	#todo, once i figure out how to pass an array and/or need this in perl:
	# to copy php version
	# $injectMode: before, after, append
	# $htmlTag: e.g. </body>, only used with before/after
	# if $htmlTag is not found, does fall back to append
	my $html = shift;     # html we're going to inject into

	if (!GetConfig('admin/js/enable')) {
		return $html;
	}

	my $injectMode = shift;
	my $htmlTag = shift;

	if ($injectMode eq 'before' || $injectMode eq 'after' || $injectMode eq 'append') {
		#do nothing, leave it alone
	} else {
		if (!$injectMode) {
			$injectMode = '';
		} else {
			WriteLog('InjectJs2: warning: $injectMode sanity check failed');
			$injectMode = '';
		}
	}

	my @scriptNames = @_; # array of names of script templates (minus the .js suffix)

	my $scriptsText = '';  # will contain all the js we want to inject
	my $scriptsComma = ''; # separator between scripts, will be set to \n\n after first script

	my %scriptsDone = ();  # hash to keep track of scripts we've already injected, to avoid duplicates

	if (in_array('settings', @scriptNames)) {
		if (GetConfig('html/clock')) {
			# if clock is enabled, automatically add its js
			push @scriptNames, 'clock';
		}
		if (GetConfig('admin/js/fresh')) {
			# if clock is enabled, automatically add it
			push @scriptNames, 'fresh';
		}
	}

	#output list of all the scripts we're about to include
	my $scriptNamesList = join(' ', @scriptNames);

	# loop through all the scripts
	foreach my $script (@scriptNames) {
		if ($script eq 'clock') {
			my $clockFormat = GetConfig('html/clock_format');
			if ($clockFormat eq 'epoch' || $clockFormat eq 'union' || $clockFormat eq '24hour') {
				$script = 'clock/' . $clockFormat;
			}
		}

		# only inject each script once, otherwise move on
		if (defined($scriptsDone{$script})) {
			next;
		} else {
			$scriptsDone{$script} = 1;
		}

		# separate each script with \n\n
		if (!$scriptsComma) {
			$scriptsComma = "\n\n";
		} else {
			$scriptsText .= $scriptsComma;
		}

		my $scriptTemplate = GetScriptTemplate($script);

		# add to the snowball of javascript
		$scriptsText .= $scriptTemplate;
	}

	# get the wrapper, i.e. <script>$javascript</script>
	my $scriptInject = GetTemplate('html/utils/scriptinject.template');
	# fill in the wrapper with our scripts from above
	$scriptInject =~ s/\$javascript/$scriptsText/g; #todo why is this /g ??

	if (GetConfig('debug')) {
		$scriptInject = str_replace('scriptinject.template -->', 'scriptinject.template (' . join(',', caller) . ') -->', $scriptInject);
	}

	$scriptInject = "\n" . '<!-- InjectJs2: ' . $scriptNamesList . ' -->' . "\n\n" . $scriptInject;

	if (
		$injectMode ne 'append'
	) {
		# replace it into html, right before the closing </body> tag
		if ($injectMode eq 'before') {
			WriteLog('InjectJs2: before $htmlTag = ' . $htmlTag);
			#$html = str_replace($htmlTag, $scriptInject . $htmlTag, $html);
			$html =~ s/($htmlTag)/$scriptInject$1/;
		} elsif ($injectMode eq 'after') { # after
			WriteLog('InjectJs2: after $htmlTag = ' . $htmlTag);
			#$html = str_replace($htmlTag, $htmlTag . $scriptInject, $html);
			my $htmlLengthBefore = length($html);
			$html =~ s/($htmlTag)/$1$scriptInject/;
			if ($htmlLengthBefore == length($html)) {
				WriteLog('InjectJs2: warning: xxxxxxx');
			}
		} else {
			WriteLog('InjectJs2: warning: inject mode fallthrough');
		}
	} else {
		# if there was no </body> tag, just append at the end
		if ($injectMode ne 'append') {
			WriteLog('InjectJs: warning: $html does not contain $htmlTag, falling back to append mode');
		}
		$html .= "\n" . $scriptInject;
	}

	return $html;
}

sub EnableJsDebug { # $scriptTemplate ; enables javascript debug mode
# sub InjectDebug {
	# works by uncommenting any lines which begin with //alert('DEBUG:
	state $debugType;
	if (!$debugType) {
		$debugType = GetConfig('admin/js/debug');
		chomp $debugType;
		$debugType = trim($debugType);
	}

	my $scriptTemplate = shift;

	WriteLog('EnableJsDebug: $debugType = ' . $debugType);

	if ($debugType eq 'console.log') {
		$scriptTemplate =~ s/\/\/alert\('DEBUG:/if(!window.dbgoff)console.log('/gi;
	}
	elsif ($debugType eq 'document.title') {
		$scriptTemplate =~ s/\/\/alert\('DEBUG:/if(!window.dbgoff)document.title=('DEBwUG:/gi;
	}
	elsif ($debugType eq 'LogWarning') {
		# todo this could check the line for 'warning' first?
		$scriptTemplate =~ s/\/\/alert\('DEBUG:/if(!window.dbgoff&&window.LogWarning)LogWarning('/gi;
	}
	else {
		#$scriptTemplate =~ s/\/\/alert\('DEBUG:/if(!window.dbgoff)dbgoff=!confirm('DEBUG:/gi;
		#		$scriptTemplate =~ s/(function\ )([a-zA-Z0-9_]+)( \))(.+?)\)( \{)/$1$2$3$4$5\n\/\/alert('DEBUG: $2: caller: ' + $2.caller);/gi
		#$scriptTemplate =~ s/(function\ )([a-zA-Z0-9_]+)( \))(.+?)\)( \{)/$1$2$3$4$5\n\/\/hi/gi
		#todo ..

		$scriptTemplate =~ s/\/\/alert\('DEBUG:/if(!window.dbgoff)dbgoff=!confirm('DEBUG:/gi;
	}

	return $scriptTemplate;
} # EnableJsDebug()

1;
