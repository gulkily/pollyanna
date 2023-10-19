<?php

/* route.php BEGIN */

/*
	ATTENTION
	The actual routes are defined in handle_not_found.php
	ATTENTION
	This should be fixed at some point...
*/

{
	// this fixes a crash bug in mosaic. it should not cause a problem anywhere else
	// <_<     >_>      o_O      -_-     ^_^
	header('Content-Type: text/html');
}

include_once('utils.php');

#`find config/setting -type f | sort | xargs md5sum | md5sum | cut -d ' ' -f 1 > config/hash_setting`;

$hashSetting = trim(GetFile(GetDir('config') . '/hash_setting')); #my
$hashSettingSuccinct = substr($hashSetting, 0, 8); #my
#todo make this nicer

WriteLog('route.php begins');

if (GetConfig('setting/admin/php/route_random_update') && rand(1, 17) == 1) {
# randomly call DoUpdate() on page load
# may slow down user's experience, but site is more likely to be up to date
	if (function_exists('DoUpdate')) {
		DoUpdate();
	}
} # if (GetConfig('setting/admin/php/route_random_update') && rand(1, 17) == 1)

function SetHtmlClock ($html) { // sets html clock on page if present
	WriteLog('SetHtmlClock()');
	$html = preg_replace('/id=txtClock value=\".+\"/', 'id=txtClock value="' . GetClockFormattedTime() . '"', $html);
	return $html;
} # SetHtmlClock()

function TrimPath ($string) { // Trims the directories AND THE FILE EXTENSION from a file path
# Should really be called GetFileNameWithoutPathAndExtension()
#todo implement rtrim() and fix it to match perl version
	while (index($string, "/") >= 0) {
		$string = substr($string, index($string, "/") + 1);
	}

	if (index($string, '.') >= 0) {
		$string = substr($string, 0, index($string, ".") + 0);
	}

	return $string;
} # TrimPath()

function TranslateEmoji ($html) { // replaces emoji with respective text
	WriteLog('TranslateEmoji()');

	return $html; # needs improvement before it can be allowed to run

	// this could be optimized a lot. A LOT.

	$scriptDir = GetScriptDir();
	if ($scriptDir && file_exists("$scriptDir/config/string/emoji")) {
		$emojiList = `find $scriptDir/config/string/emoji`;
		if ($emojiList) {
			$emojiList = explode("\n", `find $scriptDir/config/string/emoji`);
			foreach ($emojiList as $emojiFile) {
				$emojiName = TrimPath($emojiFile);
				$emojiEmoji = GetFile($emojiFile);
				$html = str_replace($emojiEmoji, '[' . $emojiName . ']', $html);
			}
		}
	}

//	$html = preg_replace('/id=txtClock value=\".+\"/', 'id=txtClock value="' . GetClockFormattedTime() . '"', $html);

	return $html;
} # TranslateEmoji()

function StripHeavyTags ($html) { // strips heavy tags from page replaces with basic ones
	WriteLog('StripHeavyTags()');

	$tags = array(
		'table', 'tbody', 'tr', 'td', 'th',
#		'span',
		'fieldset', 'legend',
		'font',
		'script', 'style',
		'big'
	);

	{
		// #todo strip only table attributes, not the tables themselves

		// this would be necessary if the br tags were not already there
		// may be useful in the future to do automated fixing-up of existing templates
		// then we can remove all those <br> tags from the templates and make them look neater

		// the substitutions below provide some reasonable replacements for the tags
		// each replacement, for debugging purposes, has an extra attribute like id1 or id5
		// these can be removed later once debugging is mostly finished

		{
			// not sure what this does anymore,
			// but the id1 and id2 bits are for identifying which replacement took place
			$html = preg_replace('/\<\/a\>\<b\>/', '</a>; <b id1>', $html);
			$html = preg_replace('/\<\/b\>\<a\ /', '</b>; <a id2 ', $html);
		}

		$html = preg_replace('/\<\/th\>/', '; ', $html);
		$html = preg_replace('/\<br\>\<\/td\>/', '; ', $html);
		$html = preg_replace('/\<\/td\>\<\/tr\>/', '<br>', $html);
		$html = preg_replace('/:\<\/td\>\<td\>/', ': ', $html);
		$html = preg_replace('/\<\/td\>/', '; ', $html);
		$html = preg_replace('/\<\/tr\>\<\/table\>/', '<br><hr>', $html);
		$html = preg_replace('/\<\/table\>/', '<br><hr>', $html);
		$html = preg_replace('/\<\/tr\>/', '<br>', $html);
		$html = preg_replace('/\<\/fieldset\>\<\/td\>/', '<br>', $html);
		$html = preg_replace('/\<\/fieldset\>/', '<br>', $html);
		$html = preg_replace('/\<\/legend\>/', '<br>', $html);
		$html = preg_replace('/\<\/a\>\<a/', '</a>; <a', $html);
		$html = preg_replace('/; ;/', '; ', $html);
		$html = preg_replace('/\<br\>; \<br\>/', '<br>', $html);
		$html = preg_replace('/\<\/form\>\<br\>\<\/tbody\>\<br\>/', '<br></form></tbody>', $html);

		$html = str_ireplace('</p><br>', '</p>', $html);
		$html = str_ireplace('<br><br><hr>', '<br><br><hr>', $html);
		$html = str_ireplace('<br><br></p>', '</p>', $html);

	}

	foreach ($tags as $tag) {
		$html = preg_replace('/\<'.$tag.'[^>]+\>/', '', $html);
		//$html = preg_replace('/\<\/'.$tag.'\>/', '', $html);
		$html = str_replace('<'.$tag.'>', '', $html);
		$html = str_replace('</'.$tag.'>', '', $html);
	}

	return $html;
} # StripHeavyTags()

function StripComments ($html) { // strips html comments from html
	$html = preg_replace('/\<\!--[^>]+\>/', '', $html);

	return $html;
} # StripComments()

function CleanBodyTag ($html) { // removes all attributes from body tag in given html
	$html = preg_replace('/\<body[^>]+\>/', '<body>', $html);

	return $html;
} # CleanBodyTag()

function StripWhitespace ($html) { // strips extra whitespace from given html
//	while (preg_match('/[\t\n ]{2}'
	$html = str_replace("\t", ' ', $html);

	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);
	$html = str_replace("\n ", "\n", $html);

//
	$html = str_replace("\n", ' ', $html);

	$html = str_replace('  ', ' ', $html);
	$html = str_replace('  ', ' ', $html);
	$html = str_replace('  ', ' ', $html);
	$html = str_replace('  ', ' ', $html);
	$html = str_replace('  ', ' ', $html);
//
//	while (! (strpos($html, '  ') === false)) {
//		$html = str_replace('  ', ' ', $html);
//	}
//
	$html = str_replace('> <', '><', $html);
////	$html = str_replace('> ', '>', $html);
////	$html = str_replace(' <', '<', $html);
//	$html = str_replace('<br><br>', '<br>', $html);
//	$html = str_replace('<br> <br>', '<br>', $html);

	return $html;
} # StripWhitespace()

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

//	if (GetConfig('html/clock')) {
//		// if clock is enabled, automatically add its js
//		$scriptNames[] = 'clock';
//	}
//
//	if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/fresh')) {
//		// if clock is enabled, automatically add it
//		$scriptNames[] = 'fresh';
//	}
//
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
		//		if ($script == 'profile') {
		//			# for profile.js we need to fill in current admin id
		//			my $currentAdminId = GetRootAdminKey() || '-';
		//
		//			$scriptTemplate =~ s/\$currentAdminId/$currentAdminId/g;
		//		}

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

require_once('handle_not_found.php');

function ReadGetParams ($GET) { // does what's needed with $_GET, takes $_GET as parameter
	#todo
}

if (GetConfig('setting/admin/php/route_enable')) {
// admin/php/route_enable is true
	$redirectUrl = '';
	$cacheOverrideFlag = 0;
	$cacheTimeLimit = GetConfig('setting/admin/php/route_cache_time_limit'); // seconds page cache is good for

	$cacheWasUsed = 0;
	$skipPrintedNotice = 0;
	$stalePageNotice = 0;
	#$html = '';

	if (GetConfig('setting/admin/php/debug_do_not_use_cache')) {
		$cacheOverrideFlag = 1;
	}

	if ($_GET) {
		// there is a get request
		WriteLog('route.php: $_GET = ' . print_r($_GET, 1));

		if (isset($_GET['q'])) {
			if (GetConfig('setting/admin/php/root_search_query_redirect')) {
				# redirects ?q= to search engine of choice
				$queryString = urlencode($_GET['q']);
				Header('Location: http://www.google.com/search?q=' . $queryString);
				exit;
			}
		}

		# look for user-provided fingerprint
		foreach ($_GET as $keyGet => $valueGet) {
			if (preg_match( '/([0-9A-F]{16})/', $keyGet, $matches)) {
				/* my */ $getFp = $matches[0];
				WriteLog('route.php: found user-provided fingerprint: ' . $keyGet . ' => ' . $valueGet . '; $getFp = ' . $getFp);
				RedirectWithResponse('/profile.html', 'Welcome, human. Please, create a profile.');
				# #todo actually make note of client id by storing a new item
				# /* my */ $fileName = StoreNewComment($getFp, 0, 1);
			}
		}


		if (isset($_GET['path'])) {
			WriteLog('route.php: cool: $_GET[path] confirmed!');

			$serverResponse = '';

			// get request includes path argument
			$path = $_GET['path'];

			if (index($path, '?') != -1) {
				# ATTENTION THIS IS A WORKAROUND SHIM
				# DO NOT ADD CONDITIONS INSIDE THIS IF STATEMENT

				# EXPLANATION
				# sometimes we get one argument in $path
				# i don't know why, but this sort of fixes it,
				# by splitting off the extra parameter

				WriteLog('route.php: warning: found qm in $path');

				# ATTENTION THIS IS A WORKAROUND SHIM
				# DO NOT ADD CONDITIONS INSIDE THIS IF STATEMENT
				# SEE EXPLANATION ABOVE

				# weird php bug, i think... or is it my lighttpd config?
				$pathWithoutArg = substr($path, 0, index($path, '?'));
				$pathFirstArg = substr($path, index($path, '?') + 1);

				# ATTENTION THIS IS A WORKAROUND SHIM
				# DO NOT ADD CONDITIONS INSIDE THIS IF STATEMENT
				# SEE EXPLANATION ABOVE

				if ($pathFirstArg) {
					WriteLog('route.php: $pathFirstArg = ' . $pathFirstArg);
					#todo sanity check
					if (index($pathFirstArg, '=') != -1) {
						#todo sanity check
						list($pathFirstArgKey, $pathFirstArgValue) = explode("=", $pathFirstArg, 2);
						$_GET[$pathFirstArgKey] = $pathFirstArgValue;
					}
					$_GET['path'] = $pathWithoutArg;
					$path = $pathWithoutArg;
					WriteLog('route.php: $_GET = ' . print_r($_GET, 1));
				}

				# ATTENTION THIS IS A WORKAROUND SHIM
				# DO NOT ADD CONDITIONS INSIDE THIS IF STATEMENT
				# SEE EXPLANATION ABOVE
			} else {
				WriteLog('route.php: cool: did NOT find question mark in $path');
			}

			if (GetConfig('setting/admin/php/url_alias_friendly')) {
				if (preg_match('/^\/([a-f0-9]+)$/', $path, $matches)) {
					$matchedItem = $matches[1];
					$path = '/' . GetHtmlFilename($matchedItem);

					WriteLog('route.php: url_alias_friendly MATCH! $matchedItem = ' . $matchedItem . '; $path = ' . $path);
					//$path = '/' . substr($matchedItem, 0, 2) . '/' . substr($matchedItem, 2, 2) . '/' . $matchedItem . '.html'; #todo GetHtmlFilename()
				} else {
					WriteLog('route.php: url_alias_friendly NO match; $path = ' . $path);
				}
			} # if (GetConfig('setting/admin/php/url_alias_friendly'))

			if ($path == '/welcome.html') {
				if (GetConfig('setting/admin/php/route_welcome_desktop_logged_in')) {
					// if logged in, replace welcome with desktop page
					include_once('cookie.php');

					if (isset($cookie) && $cookie) {
						$path = '/desktop.html';
					}
				}
			} # if ($path == '/welcome.html')

			WriteLog('route.php: $path = ' . $path); // e.g. ab/cd/abcdef01.html
			$pathFull = realpath('.' . $path); // e.g. /ab/cd/abcdef01.html

			WriteLog('route.php: $pathFull = ' . $pathFull);

			$hostRequestLimit = GetConfig('setting/admin/php/route_per_host_request_limit'); #my
			/* my */ $hostAccessCount = 0;

			if ($hostRequestLimit) {
				$hostHash = md5($_SERVER['REMOTE_ADDR']); #my
				$hostAccessCount = GetCache('access_count/' . $hostHash);
				$hostAccessCount++;
				PutCache('access_count/' . $hostHash, $hostAccessCount);
			} # if ($hostRequestLimit)

			if ($path == '/upload.html') {
				if (GetConfig('setting/admin/php/restrict_upload')) {
					include_once('cookie.php');

					if (isset($cookie) && $cookie) {
						#ok
					} else {
						$path = '/profile.html';
					}
				}
			} # if ($path == '/upload.html')

			if (GetConfig('setting/admin/php/force_profile')) {
			#if (GetConfig('setting/admin/php/force_profile') || ($hostAccessCount > $hostRequestLimit)) { #todo add feature flag and uncomment
				$redirectPath = GetConfig('setting/admin/php/force_profile_redirect_path');
				if (!$redirectPath) {
					$redirectPath = '/profile.html'; # is often /welcome.html
				}

				$pathWithoutArgs = $path;
				if (index($pathWithoutArgs, '?') != -1) {
					$pathWithoutArgs = substr($pathWithoutArgs, 0, index($pathWithoutArgs, '?'));
				}

				$redirectExceptions = array(
					'/rss.xml'
				);

				// if registration is required, redirect user to profile.html
				if (
					$pathWithoutArgs == $redirectPath
					||
					in_array($pathWithoutArgs, $redirectExceptions)
				) { # usually /profile.html or /welcome.html
					// if profile, leave it alone
					// otherwise, below is for forcing login
				} # if ($path == $redirectPath)
				else {
					// redirect

					$clientHasCookie = 0;
					if (isset($_COOKIE)) {
						if (isset($_COOKIE['cookie'])) {
							$clientHasCookie = 1;
						}
					}

					WriteLog('route.php: $clientHasCookie = ' . $clientHasCookie);

					if (!$clientHasCookie) {
						# these headers help the original request not be cached, so that user can return to it after registration
						header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
						header("Cache-Control: post-check=0, pre-check=0", false);
						header("Pragma: no-cache");

						if (GetConfig('setting/admin/php/force_profile_include_origin')) {
							$redirectPath = $redirectPath . '?origin=' . urlencode($path);
						}

						RedirectWithResponse($redirectPath, 'Please create profile to continue.'); # /profile.html /welcome.html
						if (! GetConfig('setting/admin/php/force_profile_fallthrough')) {
							exit; // #todo this is bad to have here
						}
					} # if ($clientHasCookie)
				} # else (NOT $path == '/profile.html')
			} # GetConfig('setting/admin/php/force_profile'))

			$pathSelf = $_SERVER['PHP_SELF'];
			$pathSelfReal = realpath('.'.$pathSelf);
			$pathValidRoot = substr($pathSelfReal, 0, strlen($pathSelfReal) - strlen($pathSelf));

			WriteLog('route.php: $pathValidRoot = ' . $pathValidRoot);
			WriteLog('route.php: $pathFull = ' . $pathFull . ';');
			WriteLog('route.php: substr($pathFull, 0, strlen($pathValidRoot)) = ' . substr($pathFull, 0, strlen($pathValidRoot)) . ';');


			########################################################
			########################################################
			########################################################
			########################################################
			########################################################

            // 			if ( $path == '/a.gif' || $path == '/p.gif' ) {
            // 				if (time() % 2) {
            // 					$html = file_get_contents('404.html');
            // 					header("HTTP/1.0 404 Not Found");
            // 					exit;
            // 				}
            // 			}


			if (
				$path == '/404.html' ||
				(
					// mitigate directory traversal? could be
					$pathFull &&
					substr($pathFull, 0, strlen($pathValidRoot)) == $pathValidRoot
				)
			) {
				WriteLog('route.php: cool: root sanity check passed for $path = "' . $path . '"');
				if ($path) {
					// there's a $path
					$pathRel = '.' . $path; // relative path of $path (to current directory, which should be html/)

					if (isset($_GET['time']) && $_GET['time']) { # client is requesting reprint via time= argument
						WriteLog('route.php: $_GET[time] = ' . $_GET['time']);
						if (intval($_GET['time'])) {
							if ((intval($_GET['time']) + 3600) > time()) {
								#timeout
								$cacheOverrideFlag = 1;
							}
						}
					} else {
						WriteLog('route.php: $_GET[time] = FALSE');
					}

					$fileCacheTime = 0;
					if (file_exists($pathRel)) {
						$fileCacheTime = time() - filemtime($pathRel);

						#todo
						# what should happen here:
						# 1) immediately return a message to the user
						# 2) if possible, start generating fresh page in the background, via some queue
						# 3) offer the user the option of a fresh page
						# 4) possibly do an archive.is-style self-reloading status page
						# 5) done?

						#timeout
					}

					if ($cacheOverrideFlag) {
						if ($path) {
							$refStart = time();
							#timeout
							$html = HandleNotFound($path, $pathRel); # cacheOverrideFlag

							if ($html) {
								$refFinish = time();
								$messagePageReprinted = 'OK, I reprinted the page for you.';
								RedirectWithResponse($path, $messagePageReprinted . ' ' . '<small class=advanced>in ' . ($refFinish - $refStart) . 's</small>');
								#todo the time display should be refactored out
							} else {
								WriteLog('route.php: cacheOverrideFlag: warning: $html was FALSE');
							}
							#todo templatize
						}
					}

					if (isset($_GET['message'])) {
						WriteLog('route.php: $_GET[message] exists');
						$messageId = $_GET['message'];

						if ($messageId == 'test') {
							# easter egg

							WriteLog('route.php: $messageId = test');

							$testMessage = '
								Over the firewall,
								out the antenna,
								into the router,
								shot to the modem,
								out the transponder,
								bounce into space,
								off the satellite,
								over their firewall,
								into the forums ....
								nothing but NET
							';

							RedirectWithResponse($path, $testMessage);
						}
					}

					if (
						!$cacheOverrideFlag &&
						$path != '/404.html' &&
						file_exists($pathRel) &&
						($fileCacheTime < $cacheTimeLimit)
					) {
						# ok to use cache
						if (GetConfig('setting/admin/php/route_stale_page_notice') && $fileCacheTime > 360) {
							# 10 minutes = stale page
							#todo make this a configurable setting
							$stalePageNotice = 1;
						}

						WriteLog('route.php: $fileCacheTime = ' . $fileCacheTime . '; $cacheTimeLimit = ' . $cacheTimeLimit);
						WriteLog('route.php: time() = ' . time() . '; time() - $fileCacheTime = ' . (time() - $fileCacheTime));
						#timeout

						// file exists and is new enough
						WriteLog("route.php: file_exists($pathRel) was true");
						WriteLog("route.php: route.php: cool: conditions for cache use met");

						if (isset($_GET['txtClock'])) {
							# this is part of easter egg
							$_GET['message'] = 'test';
							WriteLog('route.php: setting message = test');
						}

						if (isset($_GET['message'])) {
							WriteLog('route.php: $_GET[message] exists');
							$messageId = $_GET['message'];

							if (preg_match('/^[a-f0-9]{8}$/', $messageId)) {
								WriteLog('route.php: Found $messageId which is [a-f0-9]{8}');

								$serverResponse = RetrieveServerResponse($messageId);
								$serverResponse = trim($serverResponse);
							} else {
								WriteLog('route.php: NOT Found $messageId which is [a-f0-9]{8}');
							}

							if (!$serverResponse && !$redirectUrl) {
								if ($messageId != 'test' && GetConfig('setting/admin/php/route_redirect_when_missing_message')) {
									# if there is a message ticket provided,
									# but nothing under that ticket,
									# remove it from the url
									$redirectUrl = $path;
								}
							}
						} # isset($_GET['message'])
						else {
							WriteLog('route.php: $_GET[message] NOT set');
						}

						//						if (!isset($_SERVER['PHP_AUTH_USER'])) {
						////							header('WWW-Authenticate: Basic realm="My Realm"');
						////							header('HTTP/1.0 401 Unauthorized');
						//							echo 'Text to send if user hits Cancel button';
						//							exit;
						//						} else {
						//							echo "<p>Hello {$_SERVER['PHP_AUTH_USER']}.</p>";
						//							echo "<p>You entered {$_SERVER['PHP_AUTH_PW']} as your password.</p>";
						//						}


						if (
							isset($_GET['chkRefreshFrontend']) &&
							isset($_GET['btnRefreshFrontend'])
						) {
                            $refreshFrontendStartTime = time();
                            $refreshFrontendLog = DoRefreshFrontend();
                            $refreshFrontendFinishTime = time();
                            $refreshFrontendDuration = $reindexFinishTime - $reindexStartTime;

                            WriteLog('route.php: refreshFrontendLog = ' . $refreshFrontendLog);

                            /* my */ $refreshFrontendLogSaved = ProcessNewComment($refreshFrontendLog, '');
                            ProcessNewComment("Rebuild Frontend log metadata\n-- \n>>$reindexLogSaved\n#textart\ntitle: Rebuild Frontend finished at $refreshFrontendFinishTime", '');
                            RedirectWithResponse(GetHtmlFilename($refreshFrontendLogSaved), "Rebuild Frontend finished! <small>in $refreshFrontendDuration"."s</small>");
						}

						if (
							isset($_GET['chkConfigDump']) &&
							isset($_GET['btnConfigDump'])
						) {
							$updateStartTime = time();
							$configDumpPath = DoConfigDump();
							$fileUrlPath = ''; #todo why?
							$updateFinishTime = time();
							$updateDuration = $updateFinishTime - $updateStartTime;

							WriteLog('route.php: $configDumpPath = ' . $configDumpPath);

							IndexTextFile("./html/" . substr($configDumpPath, 1)); #todo get output and redirect to correct page

							RedirectWithResponse('/stats.html', "Config dump finished! <small>in $updateDuration"."s</small>");
						}

						if ( isset($_GET['btnReindex']) ) {
							if ( isset($_GET['chkReindex']) ) {
								$reindexStartTime = time();
								$reindexLog = DoReindex();
								$reindexFinishTime = time();
								$reindexDuration = $reindexFinishTime - $reindexStartTime;

								WriteLog('route.php: reindexLog = ' . $reindexLog);

								$reindexLogSaved = ProcessNewComment($reindexLog, ''); # my
								ProcessNewComment("Reindex log metadata\n-- \n>>$reindexLogSaved\n#textart\ntitle: Reindex log finished at $reindexFinishTime", '');
								RedirectWithResponse(GetHtmlFilename($reindexLogSaved), "Reindex finished! <small>in $reindexDuration"."s</small>");
							} else {
								RedirectWithResponse('/settings.html', 'You pressed the Reindex button, but did not check the checkbox. Please try again!');
							}
						}

						if ( isset($_GET['btnFlush']) ) {
							if (isset($_GET['chkFlush'])) {
								WriteLog('route.php: Flush requested (chkFlush && btnFlush)');
								# can't let this happen yet #todo #improve
								//DoFlush();
								//DoUpdate();
								RedirectWithResponse('/settings.html', 'Previous content has been archived.');
							} else {
								RedirectWithResponse('/settings.html', 'You pressed the Flush button, but did not check the checkbox. Please try again!');
							}
						}

						if ( isset($_GET['ui']) ) {
							$uiNew = strtolower($_GET['ui']);
							if ($uiNew == 'beginner') {
								setcookie2('show_advanced', 0, 1);
								setcookie2('beginner', 1, 1);
								RedirectWithResponse($path, 'Switched to Beginner Mode');
							}
							if ($uiNew == 'intermediate') {
								setcookie2('show_advanced', 1, 1);
								setcookie2('beginner', 1, 1);
								RedirectWithResponse($path, 'Switched to Intermediate Mode');
							}
							if ($uiNew == 'advanced') {
								setcookie2('show_advanced', 1, 1);
								setcookie2('beginner', 0, 1);
								RedirectWithResponse($path, 'Switched to Advanced Mode');
							}
						} # if ( isset($_GET['ui']) )

						if (substr($pathRel, -1) == '/') {
							# if it ends with /, add index.html
							$pathRel .= 'index.html';
						} # if (substr($pathRel, -1) == '/')

						// user asked for a particular file, and that's what we'll give them
						if (file_exists($pathRel) && is_file($pathRel)) {
							WriteLog('route.php: $html = GetFile($pathRel)');
							$html = GetFile($pathRel);
							#$html = GetFile($pathRel);

							if ($hashSetting) {
								if (index($html, $hashSetting) != -1) {
									// cool
									#$html = 'hi' . $html;
								} else {
									#$html = 'bye' . $html;
									// file is probably old, needs a rebuild
								}
							} else {
								// $html = 'no configChecksumHash?';
							}
						} # if (file_exists($pathRel) && is_file($pathRel))
						else {
							WriteLog('route.php: file_exists($pathRel) was false, trying alternative');
							$html = '';
						}

						if (index($html, 'You are seeing this placeholder page') != -1) {
                            // this special string appears in placeholder file generated by post.php
                            // if string is found, try to call pages.pl to generate file again
                            // the file is removed first... this is sub-optimal, but works for now
							WriteLog('route.php: found placeholder page, trying to replace it. $path = .' . $path);

							#unlink('.' . $path); #todo

							$newHtml = HandleNotFound($path, $pathRel); # 'formatter is catching up' page
								// could be better done by rebuilding the page directly?
							if ($newHtml) {
								$html = $newHtml;
							}
						}

						if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/fresh')) {
							// because javascript cannot access the page's headers
							// we will put the ETag value at the end of the page
							// as window.myOwnETag
							// this allows the script to compare it to the ETag value
							// returned by the server when requesting HEAD for current page
							// fresh_js fresh.js
							if (index($html, 'CheckIfFresh()') > -1) {
								// only need to do it if the script is included in page
								$md5 = md5_file($pathRel);
								header('ETag: ' . $md5);
								$html .= "<script><!-- window.myOwnETag = '$md5'; // --></script>";
								// #todo this should probably be templated and added using InjectJs()
							}
						} # GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/fresh')

						$cacheWasUsed = 1;
					} # it's reasonable to use cache (file exists, is not too old)
					else { # do not use cache
						WriteLog('route.php: cache was not used, mis-using HandleNotFound()');
						$html = HandleNotFound($path, ''); # fallback if cache not available

						if ($html) {
							WriteLog('route.php: cache was not used, setting $cacheWasUsed = 0');
							$cacheWasUsed = 0;
						} else {
							if (file_exists($pathRel) && is_file($pathRel)) {
								// cache is stale, but we have nothing better, so use stale cache
								WriteLog('route.php $html = file_get_contents($pathRel)');
								$html = file_get_contents($pathRel);
							} else {
								WriteLog('route.php: sorry, something went wrong!');
								$html = '';
							}
						}
						if (file_exists($fileCacheTime)) {
							$fileCacheTime = time() - filemtime($pathRel); # file was made again, refresh this time
						} else {
							WriteLog('route.php: warning: no file at $pathRel = ' . $pathRel);
							$fileCacheTime = 0;
						}
					} # else, do not use cache

					//if ($path == '/settings.html') {
					if (GetConfig('setting/admin/php/form_add_timestamp_input')) {
						// adds a 'timestamp' input element to all forms on the page to help avoid
						// submitting the same exact request another time and getting a cached response
						// it used to be only used on the settings page, but i found it useful on all pages
						$timestampFormElement = '<input type=hidden name=timestamp value=' . time() . '>';
						$html = str_ireplace('</form>', $timestampFormElement . '</form>' , $html);
					} # if (GetConfig('setting/admin/php/form_add_timestamp_input'))

					if (GetConfig('setting/admin/php/force_profile_include_origin')) {
						// adds an 'origin' input element to forms on the page so that user can return to the page
						// after submitting the form? #todo verify this works
						$originValue = $path;
						if (isset($_GET['origin']) && $_GET['origin']) {
							$originValue = $_GET['origin'];
						}
						if (isset($_POST['origin']) && $_POST['origin']) {
							$originValue = $_POST['origin'];
						}
						WriteLog('route.php: $originValue = ' . $originValue);

						$originPathFormElement = '<input type=hidden name=origin value="' . htmlspecialchars($originValue) . '">';
						$html = str_ireplace('</form>', $originPathFormElement . '</form>' , $html);
					} # if (GetConfig('setting/admin/php/force_profile_include_origin'))

					if (
						$path == '/404.html' ||
						$path == '/keyboard.html' ||
						$path == '/keyboard_netscape.html' ||
						$path == '/keyboard_android.html' ||
						$path == '/index.html' ||
						$path == '/' ||
						substr($path, 0, 11) == '/pollyanna/' ||
						(index($html, 'Message received, and scheduled to be posted.') != -1)
					) {
						$skipPrintedNotice = 1;
					}

					if (GetConfig('setting/admin/php/route_notify_printed_time') && !$skipPrintedNotice) { # route.php -- page printed time notice
						# this should be in a template,
						# but it would be very awkward to make at this time
						# why is it awkward?
						#date("F d Y H:i:s.", filemtime($pathRel)) .
						#($fileCacheTime == 1 ? 's' : 's') .
						#(time() + 10) .
						# Printed:

						#my
						$printedEpoch = file_exists($pathRel) ? filemtime($pathRel) : '';
						$printedHuman = file_exists($pathRel) ? date("F d Y H:i:s.", filemtime($pathRel)) : ''; #todo it's sometimes blank

						if ($fileCacheTime == 0) {
							$printedAgeSeconds = 'Fresh!';
						} else {
							$printedAgeSeconds = $fileCacheTime . ($fileCacheTime == 1 ? ' second' : ' seconds');
							if (!$printedEpoch || !$printedHuman || !$printedAgeSeconds) {
								#sanity check
								WriteLog('route.php: warning: tried to make printed notice with missing timestamp value');
							}
						}
						$selfPath = $path . '?time=' . (time() + 10);
						#todo refactor above

						$printedNotice = GetTemplate('html/printed_notice.template');

						#todo this should fail gracefully if git or backtick-exec is not available
						$versionFull = `git rev-parse HEAD`; #todo fix this
						$versionSuccinct = substr($versionFull, 0, 8);
						#$versionSequence = '775'; #my
						#$versionFull = 'abcdef01'; #my

						$printedNotice = str_replace('$selfPath', $selfPath, $printedNotice);
						$printedNotice = str_replace('$printedAgeSeconds', $printedAgeSeconds, $printedNotice);
						$printedNotice = str_replace('$printedHuman', $printedHuman, $printedNotice);
						$printedNotice = str_replace('$printedEpoch', $printedEpoch, $printedNotice);
						#$printedNotice = str_replace('<span id=versionSequence></span>', '<span id=versionSequence>' . $versionSequence . '</span>', $printedNotice);
						$printedNotice = str_replace('$versionSuccinct', $versionSuccinct, $printedNotice);
						$printedNotice = str_replace('$versionFull', $versionFull, $printedNotice);
						$printedNotice = str_replace('$hashSettingSuccinct', $hashSettingSuccinct, $printedNotice);
						$printedNotice = str_replace('$hashSetting', $hashSetting, $printedNotice);
						#$printedNotice

						$printedNotice = '<span class=advanced>' . GetDialogX($printedNotice, 'PageInformation', '', '', '') . '</span>';

						if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
							#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmousedown', 'this.style.zIndex = ++window.draggingZ;');
							$printedNotice = AddAttributeToTag($printedNotice, 'table', 'onmouseenter', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() route.php
							$printedNotice = AddAttributeToTag($printedNotice, 'table', 'onmousedown', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() route.php
						}

						#todo this dialog needs to be added to advanced layer
						#$printedNotice = '<span class=advanced>' . $printedNotice . '</span>';

						if (index($html, '<img src="/p.gif" alt="" height=1 width=1>') != -1) {
							$html = str_ireplace(
								'<img src="/p.gif" alt="" height=1 width=1>',
								$printedNotice . '<img src="/p.gif" alt="" height=1 width=1>',
								$html
							);
						} else {
							$html = str_ireplace('</body>', $printedNotice . '</body>', $html);
						}

						// if (GetConfig('debug')) {
						// # for debug mode, print cached page notice at the top
						// $html = str_ireplace('</body>', $printedNotice . '</body>', $html);
						// #$html = $htmlCacheNotice . $html; #todo ...
						// } else {
						// $html = str_ireplace('</body>', $printedNotice . '</body>', $html);
						// }
					} // if (route_notify_printed_time)
				} # $path
				else {
					// no $path
					WriteLog('route.php: $path not specified, using HandleNotFound()');
					$html = HandleNotFound($path, ''); // no $path
				}
			// if ($path == '/404.html' || $pathFull && substr($pathFull, 0, strlen($pathValidRoot)) == $pathValidRoot)
			} else {
				// #todo when does this actually happen?
				// smarter 404 handler
				WriteLog('route.php: smarter 404 handler... activate!');
				WriteLog('route.php: $path not found, using HandleNotFound()');
				$html = HandleNotFound($path, ''); // not sure
			}
		} else {
			WriteLog('route.php: no $path specified in GET');
			$html = HandleNotFound($path, $pathRel); // no $path specified in GET
		}

		if (GetConfig('html/clock')) {
			WriteLog('route.php: calling SetHtmlClock()');
			$html = SetHtmlClock($html);
		} # if (GetConfig('html/clock'))

		if ($path == '/jstest1.html' && GetConfig('setting/admin/js/enable')) {
			WriteLog('route.php: jstest1.html: inject $userAgentValue into /jstest1.html');
			$userAgentValue = $_SERVER['HTTP_USER_AGENT'];
			$userAgentValue = htmlspecialchars($userAgentValue);
			$html = AddAttributeToTag($html, 'input name=txtNetworkUserAgent', 'value', $userAgentValue);
		} else {
			WriteLog('route.php: NOT jstest1.html: $path = ' . $path . '; admin/js/enable = ' . GetConfig('setting/admin/js/enable'));
		}

		if (isset($_GET['mode'])) {
			if ($_GET['mode'] == 'light') {
				$_GET['light'] = 1;
			}
		}

		$lightMode = 0;
		if (isset($_COOKIE['light']) && $_COOKIE['light']) {
			$lightMode = 1;
		}
		if (isset($_GET['light'])) {
			$lightMode = $_GET['light'] ? 1 : 0;
		}
		if (isset($_GET['btnLightOn'])) {
			$lightMode = 1;
		}
		if (isset($_GET['btnLightOff'])) {
			$lightMode = 0;
		}

		if (isset($_COOKIE['light'])) {
			// if there is a cookie, change its value if it's necessary

			if ($_COOKIE['light'] != $lightMode) {
				setcookie2('light', $lightMode);
				if ($lightMode) {
					$messageLM = 'Light mode set.';
				} else {
					$messageLM = 'Modern mode set.';
				}
				RedirectWithResponse($path, $messageLM);
			}
		} # if (isset($_COOKIE['light']))
		else {
			// if there is no cookie set, set it
			setcookie2('light', $lightMode);
		} # else !(isset($_COOKIE['light']))

		if (GetConfig('setting/admin/php/light_mode_always_on')) {
			$lightMode = 1;
		} # if (GetConfig('setting/admin/php/light_mode_always_on'))

		if ($_GET && isset($_GET['theme'])) {
			$themeMode = $_GET['theme']; // normalize the request
			if ($themeMode != 'chicago') {
				$themeMode = '';
			}
			if (isset($_COOKIE['theme'])) {
				// if there is a cookie, change its value if it's necessary
				if ($_COOKIE['theme'] != $themeMode) {
					setcookie2('theme', $themeMode);
					//$lightModeSetMessage = StoreServerResponse('Light mode has been set to ' . $lightMode);
					//$redirectUrl = '';
				}
			} else {
				// if there is no cookie set, set it
				setcookie2('theme', $themeMode);
			}
		}

		if ($serverResponse) {
			WriteLog('route.php: $serverResponse IS SET');
		}

		if ($serverResponse && GetConfig('setting/admin/php/server_response_display_to_client')) {
			// inject server message into html

			// base template for server message, not including js
			$serverResponseTemplate = GetTemplate('html/server_response.template');

			if (GetConfig('setting/admin/js/enable')) {
				// add javascript call to close server response message
				// for the entire server response message table
				$serverResponseTemplate = AddAttributeToTag(
					$serverResponseTemplate,
					'table',
					'onclick',
					"if (window.serverResponseOk) { return serverResponseOk(this); }"
				);
				$serverResponseTemplate = AddAttributeToTag(
					$serverResponseTemplate,
					'a href=#maincontent',
					'onclick',
					"if (window.serverResponseOk) { return serverResponseOk(this); }"
				);
			}

			// fill in the theme color for $colorHighlightAlert
			$colorHighlightAlert = GetThemeColor('highlight_alert');
			$serverResponseTemplate = str_replace('$colorHighlightAlert', $colorHighlightAlert, $serverResponseTemplate);

			// inject the message text itself.
			// no escaping, because it can contain html formatting
			$serverResponseTemplate = str_replace('$serverResponse', $serverResponse, $serverResponseTemplate);

			$messageInjected = 0;

			if (isset($_GET['anchorto']) && $_GET['anchorto']) {
				// anchorto means we can add a # to the "Thanks" link which goes straight to the relevant item

				$anchorTo = $_GET['anchorto'];

				if (index($html, "<a name=$anchorTo>") > -1) {
					// same as below, same message applies

					if (GetConfig('setting/admin/js/enable')) {
						// add javascript call to close server response message for the 'thanks' link
						$serverResponseTemplate = AddAttributeToTag(
							$serverResponseTemplate,
							'a href=#maincontent',
							'onclick',
							"if (window.serverResponseOk) { return serverResponseOk(this); } else { return true; }"
						);
					}

					$serverResponseTemplate = str_replace(
						'<a href=#maincontent',
						'<a href="' . $path . '#' . $anchorTo . '"',
						$serverResponseTemplate
					);

					if (!$lightMode && GetConfig('setting/admin/php/server_response_attach_to_anchor')) {
						WriteLog('route.php: server_response_attach_to_anchor');
						// if server_response_attach_to_anchor, we will put the server message next to the anchor
						// unless we are in light mode, because then we want the message at the top of the page

						$replaceWhat = "<a name=$anchorTo>";
						$replaceWith = "<a name=$anchorTo>" . $serverResponseTemplate;
						$html = str_replace($replaceWhat, $replaceWith, $html);

						$messageInjected = 1;
					}
				}
			}

			if (!$messageInjected) {
				// put the current file's path in the "OK" link for nojs browsers
				// this is a compromise, because it causes a page reload, which may be slow
				// the other option is to leave it as is, but the message will remain on
				// the page instead of disappearing, which doesn't look nearly as cool
				// perhaps to be conditional under html/cool_effects?

				$serverResponseTemplate = str_replace('<a href=#maincontent', '<a href="' . $path . '?"', $serverResponseTemplate);
				// here we add a question mark to reduce caching problems

				// inject server message right after the body tag
				$replaceWhat = '(<body\s[^>]*>|<body>)'; // both with attributes or without
				$replaceWith = '$0' . $serverResponseTemplate; // the $0 is the original body tag, which we want to retain
				$html = preg_replace($replaceWhat, $replaceWith, $html, 1);

				$messageInjected = 1;
			}

			if (GetConfig('setting/admin/js/enable')) {
				//javascript stuff, if javascript is enabled

				// inject server_response.js for hiding the server message popup
				$html = InjectJs($html, array('server_response'), 'before', '</head>');

				// add onkeydown event to body tag, which responds to escape key
				// known issue: if there's a non-chr(32) whitespace character directly after "<body", this may not work right
				$replaceWith = '<body onkeydown="if (event.keyCode && event.keyCode == 27) { if (window.bodyEscPress) { return bodyEscPress(); } }"';
				$replaceWhat = '<body ';
				$html = str_replace($replaceWhat, $replaceWith . ' ', $html);
				$replaceWhat = '<body>';
				$html = str_replace($replaceWhat, $replaceWith . '>', $html);
			}

			if ($messageInjected) {
				// ask browser to not cache page if it contains server response message
				header('Pragma: no-cache');
			}
		} # if ($serverResponse)
		else {
			if ($stalePageNotice) {
				$notice = 'Notice: Cached page served to save server effort. ';
				$selfPath = $path . '?time=' . (time() + 10);
				$notice .= '<a href="' . $selfPath . '">Reprint</a>';
				$notice = '<p class=advanced><small><small>' . $notice . '</small></small></p>';
				#$html = preg_replace('/(<body[^>]+>)/', '$1' . $notice, $html);
				$html = str_replace('</body>', $notice . '</body>', $html);
			}
		}

		if ($redirectUrl) {
			// if we've come up with a place to redirect to, do it now

			// todo this should be a feature flag, because some browsers do not like redirects

			header('Location: ' . $redirectUrl);
		}

		WriteLog('route.php: before check for profile.html: $path = ' . $path);

		if (index($html, '<a id=btnReprint href=#')) {
			$reprintPath = $path . '?time=' . (time() + 10);
			$html = str_replace('<a id=btnReprint href=#', '<a id=btnReprint href="' . $reprintPath . '"', $html);
		}

		if (index($html, '<a id=btnAdvanced href=#')) {
			$expandPath = $path . '?ui=Advanced&timestamp=' . (time() + 10);
			$html = str_replace('<a id=btnAdvanced href=#', '<a id=btnAdvanced href="' . $expandPath . '"', $html);
		}

		if (index($html, '<a id=btnMinimal href=#')) {
			$beginnerPath = $path . '?ui=Beginner&timestamp=' . (time() + 10);
			$html = str_replace('<a id=btnMinimal href=#', '<a id=btnMinimal href="' . $beginnerPath . '"', $html);
		}

		#if ($path == '/profile.html' || $path == '/welcome.html' || $path == '/desktop.html') {
		#if ($path) { #todo #bug
		if (index($html, 'frmProfile') != -1) {
			// special handling for frmProfile (usually in /profile.html, /welcome.html, or /desktop.html
			WriteLog('route.php: frmProfile handler activated');

			// we need cookies
			include_once('cookie.php');

			$handle = ''; // will store our handle
			$fingerprint = ''; // will store our fingerprint

			if (isset($cookie) && $cookie) {
				$fingerprint = $cookie;

				if (!$handle && GetConfig('setting/admin/php/alias_lookup')) {
					$handle = GetAlias($fingerprint);
				} else {
					$handle = 'Guest'; #todo #guest...
				}

				// $html = str_replace('<span id=spanSignedInStatus></span>', '<span id=spanSignedInStatus class=beginner><p><b>Status: You are signed in</b></p></span>', $html);
				// #todo get this from template
				// #todo add the same logic to javascript frontend
				#$html = preg_replace('/pRegButton/', 'asdfadfd', $html);
				$html = preg_replace('/<p id=pRegButton>.*?<\/p>/s', '', $html);
			} else {
				$handle = '';
				$fingerprint = '';
				// this is a mis-use of the spans... oh well

				$html = preg_replace('/<p id=pExitButton>.*?<\/p>/s', '', $html);
				$html = preg_replace('/<p id=pCurrentProfileIndicator>.*?<\/p>/s', '', $html);
				$html = str_replace('<hr id=pCurrentProfileIndicatorSeparator>', '', $html);
			}

			if ($fingerprint) {
				$html = str_replace('<span id=lblHandle></span>', "<span id=lblHandle>$handle</span>", $html);
				$html = str_replace('<span id=lblFingerprint></span>', "<span id=lblFingerprint>$fingerprint</span>", $html);

				$html = str_replace(
					'<span id=spanUsernameProfileLink></span>',
					'<span id=spanUsernameProfileLink><a href="/author/' .
						$cookie .
						'/index.html" onclick="if (window.sharePubKey) { return sharePubKey(this); }">' .
						$handle .
						'</a></span>',
					$html
				);

				if (isset($cookie) && $cookie) {
					if (GetConfig('setting/admin/js/enable')) {
						#$html = str_replace('<span id=spanProfileLink></span>', '<span id=spanProfileLink><p><a href="/author/' . $cookie . '/index.html" onclick="if (window.sharePubKey) { return sharePubKey(this); }">Check in</a></p></span>', $html);
						#$html = str_replace('<p id=spanProfileLink></p>', '<p id=spanProfileLink><a href="/author/' . $cookie . '/index.html" onclick="if (window.sharePubKey) { return sharePubKey(this); }">Check in</a></p>', $html);

						$html = str_replace('<span id=spanProfileLink></span>', '<span id=spanProfileLink><p><a href="/author/' . $cookie . '/index.html" onclick="if (window.sharePubKey) { return sharePubKey(this); }">Profile</a></p></span>', $html);
						$html = str_replace('<p id=spanProfileLink></p>', '<p id=spanProfileLink><a href="/author/' . $cookie . '/index.html" onclick="if (window.sharePubKey) { return sharePubKey(this); }">Go to profile</a></p>', $html);
						# 'Go to profile' "Go to profile"
					} else {
						#$html = str_replace('<span id=spanProfileLink></span>', '<span id=spanProfileLink><p><a href="/author/' . $cookie . '/index.html">Check in</a></p></span>', $html);
						$html = str_replace('<span id=spanProfileLink></span>', '<span id=spanProfileLink><p><a href="/author/' . $cookie . '/index.html">Go to profile</a></p></span>', $html);
						# 'Go to profile' "Go to profile"
					}
				}
			} else {

				$html = str_replace(
					'<span id=spanUsernameProfileLink></span>',
					'<span><a href="/profile.html">Register or Sign In</a></span>',
					$html
				);
			}
		} # /profile.html

		if (GetConfig('setting/admin/php/route_insert_cookie_fingerprint')) {
			if (index($html, '1337133713371337') != -1) { # shadowme
				$currentCookie = GetSessionFingerprint();
				if ($currentCookie) {
					#todo if IsFingerprint() sanity check
					# this is a hack, needs improvement #todo
					$html = str_replace('1337133713371337', $currentCookie, $html);
				}
			}
		}

		if (GetConfig('setting/admin/php/cookie_inbox')) {
			WriteLog('route.php: cookie_inbox is TRUE');
			if (index($html, '</body>') != -1) {
				#if (isset($cookie) && $cookie) {
				if (isset($_COOKIE['cookie']) && $_COOKIE['cookie']) {
					WriteLog('route.php: cookie_inbox: $_COOKIE[cookie] is TRUE');
					if (IsFingerprint($_COOKIE['cookie'])) {
						WriteLog('route.php: cookie_inbox: IsFingerprint($_COOKIE[cookie]) is TRUE');
						$authorCookie = $_COOKIE['cookie'];
						$htmlDir = GetDir('html');
						$cookieInboxDialogPath = $htmlDir . '/dialog/replies/' . $authorCookie . '.html';
						WriteLog('route.php: cookie_inbox: $cookieInboxDialogPath = ' . $cookieInboxDialogPath);
						if (file_exists($cookieInboxDialogPath)) {
							WriteLog('route.php: cookie_inbox: file_exists($cookieInboxDialogPath) is TRUE');
							$cookieInboxDialog = GetFile($cookieInboxDialogPath);

							if ($cookieInboxDialog) {
								WriteLog('route.php: cookie_inbox: $cookieInboxDialog is TRUE');
							} else {
								WriteLog('route.php: cookie_inbox: warning: $cookieInboxDialog is FALSE');
							}
							#$html = str_ireplace('</body>', $cookieInboxDialog . '</body>', $html);

							if (index($html, '<span id=messages></span>') != -1) {
								$html = str_ireplace('<span id=messages></span>', '<span id=messages>' . $cookieInboxDialog . '</span>', $html); # shadowme
							} else {
								WriteLog('route.php: cookie_inbox: warning: $html lacks placeholder');
							}
						} else {
							# shadowme
							WriteLog('route.php: cookie_inbox: file_exists($cookieInboxDialogPath) is FALSE');
							$cookieInboxDialog = GetDialogX('<fieldset><p>No messages at this time.</p></fieldset>', 'Inbox');
							$html = str_ireplace('<span id=messages></span>', '<span id=messages>' . $cookieInboxDialog . '</span>', $html);
						}
					} else {
						WriteLog('route.php: cookie_inbox: warning: cookie did not pass fingerprint sanity check');
					}
				} else {
					WriteLog('route.php: cookie_inbox: user has no cookie');
				}
			} else {
				WriteLog('route.php: cookie_inbox: warning: could not find closing body tag');
			}
		}

		if ($path == '/bookmark.html') { #bookmarklets replace server name with host name
			$hostName = 'localhost:2784';
			if (isset($_SERVER['HTTP_HOST'])) {
				if ($_SERVER['HTTP_HOST']) {
					$hostName = $_SERVER['HTTP_HOST'];

					//if (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT']) {
					//	$hostName .= ':' . $_SERVER['SERVER_PORT'];
					//}

					#todo sanity check here

					$html = str_replace('localhost:2784', $hostName, $html);
				} else {
					WriteLog('route.php: warning: serving bookmarklets page without host'); #todo lookup in config
				}
			} else {
				WriteLog('route.php: warning: serving bookmarklets page without host'); #todo lookup in config
			}
		}

		if (GetConfig('html/clock')) {
			//$html = preg_replace('/id=txtClock value=\".+\"/', 'id=txtClock value="' . GetClockFormattedTime() . '"', $html);
			$html = SetHtmlClock($html);
		}

		if (GetConfig('setting/admin/php/footer_stats') && file_exists('stats-footer.html')) { # Site Statistics*
			# footer stats
			if ($path == '/keyboard.html' || $path == '/keyboard_netscape.html' || $path == '/keyboard_android.html') {
				# no footer for the keyboard pages, because they are displayed in a thin frame at bottom of page
			} else {
				// footer stats
				#my
				$footerStats = file_get_contents('stats-footer.html');

				#todo this dialog needs to be added to advanced layer
				#$footerStats = '<span class=advanced>' . $footerStats . '</span>';

				$html = str_replace(
					'</body>',
					'<br>' . $footerStats . '</body>',
					$html
				);
			}

		} // footer stats

		if ($lightMode) {
			// light mode #lightmode
			WriteLog('route.php: $lightMode is true!');

			// #lightmode options
			$html = StripComments($html);
			$html = StripWhitespace($html);
			$html = CleanBodyTag($html);
			$html = StripHeavyTags($html);
			$html = TranslateEmoji($html);

			// this is a hack
			$html = preg_replace('/<span class=titlebarButtons>.+?<\/span>/', '', $html);

			if (function_exists('mb_convert_encoding')) {
				$html = mb_convert_encoding($html, 'UTF-8', 'US-ASCII');
			} else {
				WriteLog('route.php: warning: mb_convert_encoding was missing');
			}

			$pathSelf = $_SERVER['REQUEST_URI'];
			if (! (strpos($pathSelf, '?') === false)) {
				$pathSelf = substr($pathSelf, 0, strpos($pathSelf, '?'));
			}

			// $html = str_replace(
			//  '</body>',
			//  '<p>(Using site in lightweight mode. If you want, <a href="' . $pathSelf . '?light=0">switch to full mode</a>.)</p></body>',
			// 	$html
			// );
			$html = str_replace(
				'>Accessibility mode<',
				'><font color=orange>Light Mode is ON</font><',
				$html
			);
			$html = str_replace(
				'>Turn On<',
				'>Is ON<',
				$html
			);
			//
			//	$html = str_replace(
			//		'<main id=maincontent>',
			//		'<p>(Using site in lightweight mode. If you want, <a href="' . $pathSelf . '?light=0">switch to full mode</a>.)</p><main id=maincontent>',
			//		$html
			//	);

			//#todo perhaps strip onclick, onkeypress, etc., and style
		} else {
			$html = str_replace(
				'>Turn Off<',
				'>Is OFF<',
				$html
			);
		} // light mode

		if (GetConfig('setting/admin/php/assist_show_advanced')) {
			WriteLog('route.php: admin/php/assist_show_advanced is true');

			#todo the defaults are hard-coded

			#if ($GET['ui']) {
			#	if ($GET['ui'] == 'Intermediate') {
			#		setcookie2('show_advanced', 1);
			#		setcookie2('beginner', 1);
			#	}
			#}

			WriteLog('route.php: ShowAdvanced() assist activated');
			$assistCss = ''; #my $assistCss = '';

			$colorHighlightBeginner = GetThemeColor('highlight_beginner'); #my
			$colorHighlightAdvanced = GetThemeColor('highlight_advanced'); #my

			if (!isset($_COOKIE['show_advanced']) || $_COOKIE['show_advanced'] == '0') {
				# this defaults to true
				# hides advanced elements
				
				WriteLog('route.php: $_COOKIE[show_advanced] = ' . ( isset( $_COOKIE['show_advanced']) ? $_COOKIE['show_advanced'] : 'UNDEFINED' ) ) ;

				$assistCss .= ".advanced, .admin { display:none }\n";
                // $assistCss .= ".advanced, .admin, .heading, .menubar { display:none }\n";
				#$assistCss .= ".advanced, .admin{ display: none; background-color: $colorHighlightAdvanced }\n";
				// #todo templatify
			}
			if (isset($_COOKIE['beginner']) && $_COOKIE['beginner'] == '0') { # this defaults to false


				WriteLog('route.php: $_COOKIE[beginner] = ' . $_COOKIE['beginner']);
				$assistCss .= ".beginner { display:none }\n";
				#$assistCss .= ".beginner { display:none; background-color: $colorHighlightBeginner }\n";
				// #todo templatify
			}

			#todo add something here
			#$assistCss .= ".advanced, .admin{ background-color: $colorHighlightAdvanced }\n";
			#$assistCss .= ".beginner { background-color: $colorHighlightBeginner }\n";


			if ($assistCss) {
				#todo templatize
				$html = str_replace(
						'</head>'
					,
						"<!-- php/assist_show_advanced -->\n".
						"<style id=styleAssistShowAdvanced><!--" .
						"\n" .
						$assistCss .
						"\n" .
						"/* assist ShowAdvanced() in pre-hiding elements with class=advanced and/or class=beginner */" .
						"\n" .
						"--></style>" .
						"</head>"
					,
						$html
				);
			} else {
				// do nothing
			}
		} # assist_show_advanced

		{ # assist_sequence_counter
			if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/php/assist_sequence_counter')) {
				
				// this allows clients to see the sequence counter
				// and thus know how many posts they haven't seen yet
				#$html .= '<script><!-- window.sequenceServerValue = 0; // --></script>';
				#todo make neater
			}
		} # assist_sequence_counter

		if (0 && GetConfig('setting/admin/php/remove_post_links_when_no_cookie')) {
			#todo
			#2022-05-31 13:26:34: (mod_fastcgi.c.451) FastCGI-stderr:PHP Warning:  Undefined variable $cookie in /home/manjaro/diary/html/route.php on line 1230

			$html = str_ireplace('post.html', 'cookie.html', $html);
		}

		if (!$html) {
			$html = GetFile('help.html');
			if ($path != '/help.html') {
				#RedirectWithResponse('/help.html', 'Redirected to Help page because of missing page template.');
			}
		}


		if (1) { # multiple dialogs requested allowed
			if (substr($path, 0, 8) == '/dialog/') {
				/* my */ $dialogList = substr($path, 8);
				if (index($dialogList, ',') != -1) {
					/* my */ $dialogsTogether = '';
					if (substr($dialogList, -5) == '.html') {
						$dialogList = substr($dialogList, 0, strlen($dialogList) - 5);
						#print($dialogList);
						$dialogListArray = explode(',', $dialogList);
						for (/* my */ $i = 0; $i < count($dialogListArray); $i++) {
							/* my */ $htmlDir = GetDir('html');
							/* my */ $dialogName = $dialogListArray[$i];
							if ($dialogName == 'undefined') {
								continue;
							}
							if (file_exists("$htmlDir/dialog/" . $dialogName . '.html')) {
								# cool
							} else {
								HandleNotFound("/dialog/" . $dialogName . ".html", '');
							}
							$dialogsTogether .= GetFile("$htmlDir/dialog/" . $dialogName . '.html');
						}
					}
					$html = $dialogsTogether;
				}
			}
		}


		////////////////////////////
		if (!$html) {
			// MISSING HTML ERROR PAGE
			#todo other sanity checks, like "no html tags" or "nothing but html tags"
			WriteLog('route.php: warning: $html was empty; $path = ' . $path);

			$html = '<html>';
			$html = '<head>';
			$html = '<title>System Message: Engine requires attention. Please remain calm.</title>';
			$html = '<meta http-equiv=refresh content=5>';
			$html = '</head>';
			$html = '<body bgcolor="#808080" text="#000000" onclick="if (this.style && this.style.display) { this.style.display=\'none\'; }">';
			$html .= '<center><table bgcolor="#808080" border=10 bordercolor="#c0c0c0" width=99%><tr><td align=center valign=middle>';
			$html .= '<h2>System Message: <br>Engine requires attention.</h2>';
			$html .= '<h1>Please forgive inconvenience. <br>Remain calm.</h1>';
			$html .= '<hr>';
			$html .= '<p>';
			$html .= '<h3>Try one of these links:<br>';
			$html .= '<a href="/">Home</a> | ';
			$html .= '<a href="/help.html">Help</a> | ';
			$html .= '<a href="/settings.html">Settings</a>';
			$html .= '</h3>';
			$html .= '<p>';
			$html .= '<hr>';
			$html .= '<form action=/post.html><label>Send Message:</label><br><input type=text size=30 name=comment value="Status?"><input type=submit value=Send></form>';
			$html .= '</td></tr></table></center>';
			$html .= '</body>';
			$html .= '</html>';
		}

		if (function_exists('WriteLog') && GetConfig('setting/admin/php/debug')) {
			// DEBUG LOG
			// inject at the bottom of page
			if ($foo = stripos($html, '</body>')) {
				$debugOutput = WriteLog(0); #my
				$debugOutput = str_replace('warning', '<font color=red>warning</font>', $debugOutput);
				$html = str_replace('</body>', '<p class=advanced>' . $debugOutput . '</p></body>', $html);
			} else {
				$html .= WriteLog(0);
			}
		}

		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		// output html /////////////
		////////////////////////////
		print($html); // final output
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
		////////////////////////////
	}
} # if (GetConfig('setting/admin/php/route_enable'))
else {
	WriteLog('route.php: config/setting/admin/php/route_enable = false');

	// this is a fallback, and shouldn't really be here
	// but it helps compensate for another bug

	//print "oh no! route_enable is false, but route.php was called!";
	if ($_GET['path']) {
		if (file_exists($path)) {
			$html = get_file_contents($path);
		}
		else if (file_exists($path . '.html')) {
			$html = get_file_contents($path . '.html');
		}

		if ($html) {
			print($html);
		} else {
			$pageHelp = get_file_contents('help.html');
			if ($pageHelp) {
				print($pageHelp);
			} else {
				$defaultBanner = '<a href="/">Continue to home page</a>';
				print('<h1>' . $defaultBanner . '</h1>');
			}
		}
	}
} # NOT GetConfig('setting/admin/php/route_enable')
