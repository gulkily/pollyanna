<?php

function HandleNotFound ($path, $pathRel) { // handles 404 error by regrowing the missing page
// Handle404 (  #todo #DRY
// $pathRel?? relative path of $path (to current directory, which should be html/)

// for searching:
// thanks.html welcome.html help.html settings.html profile.html

	WriteLog("HandleNotFound($path, $pathRel) BEGIN");

	if (GetConfig('admin/php/regrow_404_pages')) {
		WriteLog('HandleNotFound: admin/php/regrow_404_pages was true');
		$SCRIPTDIR = GetScriptDir();
		WriteLog('HandleNotFound: $SCRIPTDIR = ' . $SCRIPTDIR);
		WriteLog('HandleNotFound: about to do lookup and call pages.pl. $path = ' . $path);

		/* my */ $canPlaceholder = 0;

		### aliases begin
		if (GetConfig('admin/php/url_alias_friendly')) {
			if (IsItem(substr($path, 1))) {
				$path = '/' . GetHtmlFilename(substr($path, 1));
				WriteLog('HandleNotFound: found item hash in path. path is now $path = ' . $path);
			}
		}
		### aliases end

		if (preg_match('/^\/[a-f0-9]{2}\/[a-f0-9]{2}\/([a-f0-9]{8})/', $path, $itemHashMatch)) {
			# Item URL in the form: /ab/01/ab01cd23.html
			WriteLog('HandleNotFound: found item hash');
			$itemHash = $itemHashMatch[1];
			$pagesPlArgument = $itemHash;
			$canPlaceholder = 1;
		}
		if (preg_match('/^\/author\/([A-F0-9]{16})/', $path, $itemHashMatch)) {
			WriteLog('HandleNotFound: found author fingerprint');
			$authorFingerprint = $itemHashMatch[1];
			$pagesPlArgument = $authorFingerprint;
			$canPlaceholder = 1;
		}
		if (preg_match('/^\/person\/([A-Za-z0-9]+)/', $path, $itemHashMatch)) {
			WriteLog('HandleNotFound: found person name');
			$personName = $itemHashMatch[1];
			$pagesPlArgument = "-M person $personName";
			$canPlaceholder = 1;
		}
		if (preg_match('/^\/tag\/([a-zA-Z0-9_]+)\.html/', $path, $hashTagMatch)) { #tagName
			# Item URL in the form: /tag/nice.html
			WriteLog('HandleNotFound: found hashtag');
			$hashTag = $hashTagMatch[1];
			$pagesPlArgument = '\#' . $hashTag;
			$canPlaceholder = 1;
		}
		if (preg_match('/^\/label\/([a-zA-Z0-9_]+)\.html/', $path, $labelMatch)) { #labelName
			# Item URL in the form: /label/nice.html
			WriteLog('HandleNotFound: found label');
			$hashTag = $labelMatch[1];
			$pagesPlArgument = '\#' . $hashTag;
			$canPlaceholder = 1;
		}
		if (preg_match('/^\/date\/([0-9]{4}-[0-9]{2}-[0-9]{2})\.html/', $path, $dateMatch)) { #date
			WriteLog('HandleNotFound: found date');
			$pageDate = $dateMatch[1];
			$pagesPlArgument = $pageDate;
			$canPlaceholder = 1;
		}
		#todo
		#		if (
		#			preg_match('/^\/goto\/([a-zA-Z0-9]+)/', $path, $hashTagMatch)
		#		) {
		#			WriteLog('HandleNotFound: found goto');
		#			$gotoArgument = $hashTagMatch[1];
		#			$pagesPlArgument = 'goto/' . $gotoArgument;
		#		}
		if (
			$path == '/upload_multi.html' ||
			$path == '/etc.html' ||
			$path == '/events.html' ||
			$path == '/search.html' ||
			$path == '/manual.html' ||
			$path == '/manual_advanced.html' ||
			$path == '/frame.html' ||
			$path == '/frame2.html' ||
			$path == '/frame3.html' ||
			$path == '/media.html' ||
			$path == '/post.html' ||
			$path == '/jstest1.html' ||
			$path == '/keyboard.html' ||
			$path == '/keyboard_netscape.html' ||
			$path == '/keyboard_android.html'
		) {
			WriteLog('HandleNotFound: warning: found a --listing page, this may cause slowness');
			$pagesPlArgument = '--listing';
			$canPlaceholder = 1;
		}

		if (
			$path == '/bookmark.html'
		) {
			$pagesPlArgument = '-M bookmark';
			$canPlaceholder = 1;
		}

		if (
			$path == '/' ||
			$path == '/index.html'
		) {
			WriteLog('HandleNotFound: found index page');
			$pagesPlArgument = '-M welcome';
			$canPlaceholder = 1;
		}

		if (
			$path == '/cookie.html'
		) {
			WriteLog('HandleNotFound: found cookie page');
			$pagesPlArgument = '-M cookie';
			$canPlaceholder = 1;
		}

		if ($path == '/stats.html' || $path == '/engine.html') {
			WriteLog('HandleNotFound: found stats page');
			$pagesPlArgument = '-M stats';
			$canPlaceholder = 1;
		}

		if ($path == '/cloud.html') {
			WriteLog('HandleNotFound: found cloud page');
			$pagesPlArgument = '-M cloud';
			$canPlaceholder = 1;
		}

		if ($path == '/random.html') {
			WriteLog('HandleNotFound: found random page');
			$pagesPlArgument = '-M random';
			$canPlaceholder = 1;
		}

		if ($path == '/desktop.html') {
			WriteLog('HandleNotFound: found desktop page');
			$pagesPlArgument = '--desktop';
			$canPlaceholder = 1;
		}

		# @validRoutes = # $validRoutes = # handle_not_found.php = # $validRoutes = # @validRoutes = # handle_not_found.php
		# $validMakePageNames # $validMakePageNames # $validMakePageNames # $validMakePageNames # $validMakePageNames

		$validMakePageNames = array(
			'/history.html',
			'/calendar.html',
			'/upload.html',
			'/help.html',
			'/sponsors.html', #expo
			'/committee.html', #expo
			'/speakers.html', #expo
			'/academic.html', #expo
			'/schedule.html', #expo
			'/profile.html',
			'/child.html',
			'/example.html',
			'/chat.html',
			'/welcome.html',
			'/thanks.html',
			'/faq.html',
			'/documentation.html',
			'/about.html',
			'/examples.html',
			'/biography.html', # shadowme
			'/interests.html', # shadowme
			'/messages.html', # shadowme
			'/network.html', # ilyag
			'/people.html', #ilyag
			'/menu.html',
			'/queue.html',
			'/session.html',
			'/paint.html'
		);

		if (in_array($path, $validMakePageNames)) {
			WriteLog('HandleNotFound: found ' . $path);
			$pagesPlArgument = '-M ' . substr($path, 1, length($path) - 6);
			$canPlaceholder = 1;
		}

		$validViews = array(
			'deleted', # deleted.html
			'compost', # compost.html
			'new', # new.html
			'raw', # raw.html
			'picture', # picture.html
			'image', # image.html
			'read', # read.html
			'chain', # chain.html
			'url', # url.html
			'authors', # authors.html
			'active', # active.html
			'scores', # scores.html
			'threads', # threads.html
			'boxes', #banana #todo
			'tasks', #dev tasks.html
			'browse', #shadowme browse.html
			'donate', #donate donate.html
			'topics', #topics topics.html
			'judge', #judge judge.html
			'random', #random random.html
		); # $validViews
		#todo make this nicer and configurable etc
		# validRoutes

		if (preg_match('/^\/([a-z]+)([0-9]+)?\.html$/', $path, $pathMatches)) {
			WriteLog('HandleNotFound: $pathMatches = ' . print_r($pathMatches, 1));

			$pathView = $pathMatches[1];
			$pathViewPageNumber = 0;
			if (array_key_exists(2, $pathMatches)) {
				$pathViewPageNumber = $pathMatches[2];
			}

			if (in_array($pathView, $validViews)) {
				WriteLog('HandleNotFound: found view: $pathView = ' . $pathView . '; $pathViewPageNumber = ' . $pathViewPageNumber);
				$pagesPlArgument = '-M ' . $pathView;
			} else {
				WriteLog('HandleNotFound: warning: view NOT FOUND in $validViews: $pathView = ' . $pathView);
				// #todo should be possible to recover if in dev mode
			}
			$canPlaceholder = 1;
		} else {
			WriteLog('HandleNotFound: warning: no match in $validViews for $path = ' . $path);
		}

		$validJsPage = array(
			'/sha512.js',
			'/crypto.js',
			'/crypto2.js',
			'/openpgp.js'
		);
		if (in_array($path, $validJsPage)) {
			WriteLog('HandleNotFound: found js: ' . $path);
			$pagesPlArgument = '--js';
			$canPlaceholder = 0;
		}


		if (
			$path == '/settings.html'
		) {
			WriteLog('HandleNotFound: found settings page');
			$pagesPlArgument = '--settings';
			$canPlaceholder = 1;
		}

########### DIALOGS BEGIN
		if (substr($path, 0, 8) == '/dialog/') {
			# $validDialogs handle_not_found.php
			# validDialog
			$basicDialogs = array(
				'threads',
				'stats',
				'settings',
				'help',
				'donate',
				'image',
				'url',
				'search',
				'data',
				'chain',
				'new',
				'tags',
				'scores',
				'active',
				'authors', # /dialog/authors.html
				'people', # /dialog/people.html
				'welcome',
				'profile',
				'read',
				'upload',
				'write',
				'access',
				'float', # /dialog/float.html
				'labels',
				'topics',
				'session',
				'about',
				'judge',
				'calendar',
				'random',
				'menu'
			); # /dialog/ # $basicDialogs

			foreach ($basicDialogs as $basicDialog) {
				if (
					$path == '/dialog/' . $basicDialog . '.html'
				) {
					WriteLog('HandleNotFound: found ' . $basicDialog . ' dialog');
					$pagesPlArgument = '-D ' . $basicDialog;
					$canPlaceholder = 0;
					break;
				}
			}

			if (!isset($pagesPlArgument) || !$pagesPlArgument) {
				# simple dialogs not matched, try some other strategies
				if (preg_match('/^\/dialog\/[a-f0-9]{2}\/[a-f0-9]{2}\/([a-f0-9]{8})/', $path, $itemHashMatch)) {
					# Item URL in the form: /ab/01/ab01cd23.html
					WriteLog('HandleNotFound: found dialog / item hash');
					$itemHash = $itemHashMatch[1];
					$pagesPlArgument = '-D ' . $itemHash;
					$canPlaceholder = 0;
				}

				if (preg_match('/^\/dialog\/tag\/([a-zA-Z0-9_-]+)\.html/', $path, $itemTagMatch)) {
					# Item URL in the form: /tag/nice.html
					WriteLog('HandleNotFound: found dialog / tag');
					$tagName = $itemTagMatch[1];
					$pagesPlArgument = '-D \#' . $tagName;
					$canPlaceholder = 0;
				}
				if (preg_match('/^\/dialog\/label\/([a-zA-Z0-9_-]+)\.html/', $path, $itemLabelMatch)) {
					# Item URL in the form: /label/nice.html
					WriteLog('HandleNotFound: found dialog / label');
					$labelName = $itemLabelMatch[1];
					$pagesPlArgument = '-D \#' . $labelName;
					$canPlaceholder = 0;
				}
			}
		} # /dialog/...

############################ DIALOGS END
		if (
			$path == '/data.html' ||
			$path == '/txt.zip' ||
			$path == '/tree.zip' ||
			$path == '/index.sqlite3' ||
			$path == '/index.sqlite3.zip'
		) {
			WriteLog('HandleNotFound: found data page');
			$pagesPlArgument = '--data';
			$canPlaceholder = 0;
		}

		if (
			$path == '/write.html' ||
			$path == '/write_post.html'
		) {
			WriteLog('HandleNotFound: found write page');
			$pagesPlArgument = '--write';
			$canPlaceholder = 1;
		}

		if (
			$path == '/tags.html' ||
			$path == '/votes.html'
		) {
			#todo this may not be needed?
			WriteLog('HandleNotFound: found tags page');
			$pagesPlArgument = '--tags';
			#$canPlaceholder = 1;
		}

		if ($path == '/labels.html') {
			#todo this may not be needed?
			WriteLog('HandleNotFound: found labels page');
			$pagesPlArgument = '--labels';
			$canPlaceholder = 1;
		}

		if (isset($pagesPlArgument) && $pagesPlArgument) {
			# here we will issue a pages.pl call but first
			# we will check if it's been done in last 60s because
			# we want to keep from calling it too often, for example
			# in a case when the call does not result in
			# the page being built for whatever reason

			$mostRecentCacheName = 'pages/' . md5($pagesPlArgument);
			$mostRecentCall = intval(GetCache($mostRecentCacheName));

			#my
			$refreshWindowInterval = GetConfig('admin/php/route_pages_pl_sane_limit');
				#todo still a bug here; cache should be used if pages.pl sanity check fails

			WriteLog('HandleNotFound: $mostRecentCacheName = ' . $mostRecentCacheName . '; $mostRecentCall = ' . $mostRecentCall . '; $refreshWindowInterval = ' . $refreshWindowInterval);

			if (time() - $mostRecentCall > $refreshWindowInterval) {
				WriteLog('HandleNotFound: interval check passed, trying to grow page');
				# call pages.pl to generate the page
				$pwd = getcwd();
				WriteLog('HandleNotFound: $pwd = ' . $pwd);

				WriteLog("HandleNotFound: cd $SCRIPTDIR ; perl -T ./pages.pl $pagesPlArgument");
				/* my */ $pagesPlTimeout = 0;
				if ($pagesPlTimeout) {
					#use timeout to give up on html generation after 5 seconds
					#todo use GetDir() and not ./pages.pl
					/* my */ $pagesPlCommand = 'cd "' . $SCRIPTDIR . '" ; timeout ' . $pagesPlTimeout . 's ' . 'perl -T ./pages.pl ' . $pagesPlArgument;
					WriteLog('HandleNotFound: $pagesPlCommand = ' . $pagesPlCommand);
					/*my*/ $exitCode = exec($pagesPlCommand);
					WriteLog('HandleNotFound: $exitCode = ' . $exitCode);

					if ($exitCode) {
						# there was an error, probably timed out
						WriteLog('HandleNotFound: $exitCode was TRUE, writing placeholder page');
						#todo:
						#	/*my*/ $pathLocal = './' . $path;
						#	PutFile($pathLocal, 'hi');
					} else {
						# ok
					}
				} else {
					if (GetConfig('setting/admin/php/regrow_404_fork')) { # create placeholder page and fork
						if ($canPlaceholder) {
							WriteLog('HandleNotFound: $canPlaceholder was TRUE, calling ForkWithLoadingPage(); $path = ' . $path . '; $pagesPlArgument = ' . $pagesPlArgument);
							ForkWithLoadingPage($path);
						} else {
							if (0) { // for debugging
								print($path);
								print('<br>');
								print($pagesPlArgument);
								exit;
							}
						}
					}

					/* my */ $pagesPlCommand = 'cd "' . $SCRIPTDIR . '" ; perl -T ./pages.pl ' . $pagesPlArgument;
					WriteLog('HandleNotFound: $pagesPlCommand = ' . $pagesPlCommand);
					WriteLog('HandleNotFound: ' . `$pagesPlCommand`);
				}

				/* #todo
				$command = 'timeout 5 ls';
				$output = exec($command);
				$return_code = $output[0];

				if ($return_code == 124) {
				  echo 'The command timed out.';
				} else {
				  echo 'The command completed successfully.';
				}
				*/

				WriteLog("HandleNotFound: cd $pwd");
				WriteLog('HandleNotFound: cd $pwd = ' . `cd $pwd`);

				PutCache($mostRecentCacheName, time());
			} else {
				WriteLog('HandleNotFound: warning: pages.pl was called LESS THAN $refreshWindowInterval seconds ago, NOT trying to grow page');
				#fallthrough to showing 404 page
				#return 0;
			}
		} # $pagesPlArgument = true
		else {
			WriteLog('HandleNotFound: warning: $pagesPlArgument is FALSE');
			return 0;
		}

		$pathRel = '.' . $path; // relative path of $path (to current directory, which should be html/)

		if ($pathRel && file_exists($pathRel)) {
			WriteLog('HandleNotFound: $pathRel exist: ' . $pathRel);
			$html = file_get_contents($pathRel);
		}
	} # if (GetConfig('admin/php/regrow_404_pages'))

	if (!isset($html) || !$html) {
		// don't know how to handle this request, default to 404
		WriteLog('HandleNotFound: warning: $html is FALSE, returning 404');
		if (file_exists('404.html')) {
			$html = file_get_contents('404.html');
			header("HTTP/1.0 404 Not Found");
		}
	}

	if (!isset($html) || !$html) {
		// something strange happened, and $html is still blank
		// evidently, 404.html didn't work, just use some hard-coded html
		WriteLog('HandleNotFound: warning: 404.html missing, fallback');
		$html = '<html>'.
			'<head><title>404</title></head>'.
			'<body><h1>404 Message Received</h1><p>Page not found, please try again later. <a href=/ accesskey=t title=Thank><u>T</u>hank you.</a><hr></body>'.
			'</html>';
	}

	return $html;
} # HandleNotFound()


