<?php

/* begin inject_js.php */

function InjectJs ($html, $scriptNames, $injectMode = 'before', $htmlTag = '</body>') { // inject js template(s) into html
// $injectMode: before, after, append (to end of html)
// $htmlTag: e.g. </body>, only used with before/after
// if $htmlTag is not found, does fall back to append

// hi, friend. if you're looking for @validRoutes, you should look in handle_not_found.php instead

	WriteLog('InjectJs() begin...');

	if (!GetConfig('setting/admin/js/enable')) {
		return $html;
	}

	$scriptsText = '';  // will contain all the js we want to inject
	$scriptsComma = ''; // separator between scripts, will be set to \n\n after first script

	$scriptsDone = array();  // array to keep track of scripts we've already injected, to avoid duplicates

	//if (GetConfig('setting/html/clock')) {
	//	// if clock is enabled, automatically add its js
	//	$scriptNames[] = 'clock';
	//}
	//
	//if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/fresh')) {
	//	// if clock is enabled, automatically add it
	//	$scriptNames[] = 'fresh';
	//}

	//output list of all the scripts we're about to include
	$scriptNamesList = implode(' ', $scriptNames);

	// loop through all the scripts
	foreach ($scriptNames as $script) {
		// only inject each script once, otherwise move on
		if (isset($scriptsDone[$script])) {
			next;
		} else {
			$scriptsDone[$script] = 1;
		}

		// separate each script with \n\n
		if (!$scriptsComma) {
			$scriptsComma = "\n\n";
		} else {
			$scriptsText .= $scriptsComma;
		}

		$scriptTemplate = GetTemplate("js/$script.js");

		if (!$scriptTemplate) {
			WriteLog("InjectJs: warning: Missing script contents for $script");
			if (GetConfig('debug')) {
// 				die('InjectJs: Missing script contents');
				$scriptTemplate = "alert('InjectJs: warning: Missing template $script.js');";
			}
		}

		if ($script == 'voting') {
			// for voting.js we need to fill in some theme colors
			$colorSuccessVoteUnsigned = GetThemeColor('success_vote_unsigned');
			$colorSuccessVoteSigned = GetThemeColor('success_vote_signed');

			$scriptTemplate = str_replace('$colorSuccessVoteUnsigned', $colorSuccessVoteUnsigned, $scriptTemplate);
			$scriptTemplate = str_replace('$colorSuccessVoteSigned', $colorSuccessVoteSigned, $scriptTemplate);

			$postUrl = GetConfig('setting/admin/post/post_url'); #my
			if ($postUrl != '/post.html') {
				$scriptTemplate = str_replace('/post.html', $postUrl, $scriptTemplate);
			}
		}
		// #todo finish porting this when GetRootAdminKey() is available in php
		//	if ($script == 'profile') {
		//		# for profile.js we need to fill in current admin id
		//		my $currentAdminId = GetRootAdminKey() || '-';
		//
		//		$scriptTemplate =~ s/\$currentAdminId/$currentAdminId/g;
		//	}

		if ($script == 'settings') {
			// for settings.js we also need to fill in some theme colors
			$colorHighlightAdvanced = GetThemeColor('highlight_advanced');
			$colorHighlightBeginner = GetThemeColor('highlight_beginner');

			$scriptTemplate = str_replace('$colorHighlightAdvanced', $colorHighlightAdvanced, $scriptTemplate);
			$scriptTemplate = str_replace('$colorHighlightBeginner', $colorHighlightBeginner, $scriptTemplate);
		}

		if (index($scriptTemplate, '>') > -1) {
			# warning here if script content contains > character, which is incompatible with mosaic's html comment syntax
			WriteLog('InjectJs: warning: Inject script "' . $script . '" contains > character');
		}

		static $debugType;
		if (!isset($debugType)) {
			$debugType = GetConfig('setting/admin/js/debug');
			$debugType = trim($debugType);
		}

		if ($debugType) {
			#uncomment all javascript debug alert statements
			#and replace them with confirm()'s which stop on no/cancel
			#
			if ($debugType == 'console.log') {
				$scriptTemplate = str_replace("//alert('DEBUG:", "if(!window.dbgoff)console.log('", $scriptTemplate);
			} elseif ($debugType == 'document.title') {
				$scriptTemplate = str_replace("//alert('DEBUG:", "if(!window.dbgoff)document.title = ('", $scriptTemplate);
			} elseif ($debugType == 'LogWarning') {
				#todo this could check the line for 'warning' first?
				$scriptTemplate = str_replace("s/\/\/alert\('DEBUG:", "if(!window.dbgoff&&window.LogWarning)LogWarning('", $scriptTemplate);
			} else {
				$scriptTemplate = str_replace("//alert('DEBUG:", "if(!window.dbgoff)dbgoff=!confirm('DEBUG:", $scriptTemplate);
			}
		}
		// add to the snowball of javascript
		$scriptsText .= $scriptTemplate;
	}

	// get the wrapper, i.e. <script>$javascript</script>
	$scriptInject = GetTemplate('html/utils/scriptinject.template');

	if (GetConfig('setting/admin/php/debug')) {
		$dbt = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS,2);
		$caller = isset($dbt[1]['function']) ? $dbt[1]['function'] : null;
		// <3 https://stackoverflow.com/questions/2110732/how-to-get-name-of-calling-function-method-in-php/28602181#28602181

		$scriptInject = str_replace('scriptinject.template -->', 'scriptinject.template (' . $caller . ') -->', $scriptInject);
	}

	// fill in the wrapper with our scripts from above
	$scriptInject = str_replace('$javascript', $scriptsText, $scriptInject);

	$scriptInject = '<!-- InjectJs: ' . $scriptNamesList . ' -->' . "\n\n" . $scriptInject;

	if ($injectMode != 'append' && index($html, $htmlTag) > -1) {
		// replace it into html, right before the closing </body> tag
		if ($injectMode == 'before') {
			$html = str_replace($htmlTag, $scriptInject . $htmlTag, $html);
		} else {
			$html = str_replace($htmlTag, $htmlTag . $scriptInject, $html);
		}
	} else {
		if ($injectMode != 'append') {
			WriteLog('InjectJs: warning: $html does not contain $htmlTag, falling back to append mode');
		}
		$html .= "\n" . $scriptInject;
	}

	return $html;
} # InjectJs()

/* end inject_js.php */