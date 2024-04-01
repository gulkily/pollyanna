		// from GetDialogX() utils.php
		//
		// 		if ($showButtons && GetConfig('admin/js/dragging')) {
		// 			WriteLog('GetDialogX: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('admin/js/dragging'));
		//
		// 			$btnCloseCaption = '{-}'; # needs to match one other place in dragging.js #collapseButton
		// 			$windowTitlebar = GetTemplate('html/window/titlebar_with_button.template'); #window_titlebar_buttons
		//
		// 			$windowTitlebar = InjectJs($windowTitlebar, array('titlebar_with_button'));
		//
		// 			$windowTitlebar = str_replace('$windowTitle', $windowTitle, $windowTitlebar);
		// 			#$windowTitlebar = str_replace('$dialogAnchor', $dialogAnchor, $windowTitlebar);
		// 			$windowTemplate = str_replace('$windowTitlebar', $windowTitlebar, $windowTitlebar);
		// 			$windowTemplate = str_replace('$btnCloseCaption', $btnCloseCaption, $windowTitlebar);
		// 			#$contentColumnCount = 2;
		// 		} else {
		// 			$windowTitlebar = GetTemplate('html/window/titlebar.template');
		// 			#
		// 			#			if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
		// 			#				$windowTitlebar = AddAttributeToTag($windowTemplate, 'a href=#$dialogAnchor', 'onfocus', 'document.title=this.innerHTML;');
		// 			#				$windowTitlebar = AddAttributeToTag($windowTemplate, 'a href=#$dialogAnchor', 'onclick', 'document.title=this.innerHTML;');
		// 			#			}
		// 			#
		// 			$windowTitlebar = str_replace('$windowTitle', $windowTitle, $windowTitlebar);
		// 			$windowTitlebar = str_replace('$dialogAnchor', $dialogAnchor, $windowTitlebar);
		// 			$windowTemplate = str_replace('$windowTitlebar', $windowTitlebar, $windowTitlebar);
		// 		}



// function GetNeighborDialog($pageName, $pageArgument) {
//     // todo sanity checks
//
//     WriteLog('GetNeighborDialog: $pageName = ' . $pageName . '; $pageArgument = ' . $pageArgument . '; caller = ' . implode(',', debug_backtrace()));
//
//     $neighbors = GetConfigListAsArray('neighbor');
//     $linkTemplate = '<a href="http://$host/$pageName.html">$host</a>';
//
//     $dialog = '';
//     foreach ($neighbors as $neighbor) {
//         $neighbor = trim($neighbor);
//         if (preg_match('/^([0-9a-z:\.]+)$/', $neighbor, $matches)) {
//             $neighbor = $matches[1];
//         } else {
//             // todo
//             continue;
//         }
//
//         $link = str_replace('$host', $neighbor, $linkTemplate);
//         $link = str_replace('$pageName', $pageName, $link);
//         $dialog .= $link . '<br/>';
//     }
//
//     $dialog = GetDialogX($dialog, 'Neighbors');
//     return $dialog;
// }



//for route.php:

			<p id=insPubKey onclick="
				if (window.PubKeyShare && window.getUserFp) {
					var authorKey = getUserFp();
					if (authorKey) {
						PubKeyShare();
						window.location = '/author/' + authorKey + '/index.html';
						return false;
					}
					/* else go to /write.html#inspubkey */
					else {
						return true;
					}
				}
				else {
					return true;
				}
			"><a href="/write.html#inspubkey">Join session</a></p>
<!-- #todo verify that relativize_links works in above line -->




$pid = pcntl_fork();
if ($pid == -1) {
	// something went wrong
} elseif ($pid == 0) {
	// continue
} else {
	// print placeholder page and also return it
	/* my */ $htmlPlaceholder = '<html><head><meta http-equiv="refresh" content="1"></head><body>Meditate...</body></html>';
	PutFile($path, $htmlPlaceholder);
	header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");
	print($htmlPlaceholder);
	exit;
}



// this was in route.php, but i am not sure why
// it returns a 404 error for a.gif and p.gif with a 50% probability
			// 			if ( $path == '/a.gif' || $path == '/p.gif' ) {
			// 				if (time() % 2) {
			// 					$html = file_get_contents('404.html');
			// 					header("HTTP/1.0 404 Not Found");
			// 					exit;
			// 				}
			// 			}

===



				if (GetConfig('setting/admin/js/enable')) {
					$html = AddAttributeToTag($html, 'a href=#maincontent', 'onclick', "if (window.displayNotification) { displayNotification('You are welcome!') }");
				}



{
	if (GetConfig('setting/admin/php/force_profile')) {
		if (!isset($_COOKIE['cookie']) || !isset($_COOKIE['checksum'])) {
			setcookie2('test', '1');
			RedirectWithResponse('/welcome.html', 'Welcome!');
		}
	}
}


						if (!GetConfig('config/hash_setting')) {
							WriteLog(`find config/setting -type f | sort | xargs md5sum | md5sum | cut -d ' ' -f 1 > config/hash_setting`);
						}



						if ($path == '/write.html') {
							if (file_exists('write.php')) {
								include('write.php');

								if (isset($_GET['name']) && $_GET['name']) {
									WriteLog('name request found');

									$nameValue = $_GET['name'];

									WriteLog('$nameValue = ' . $nameValue);

									// #todo validate $vouchValue
									$nameToken =
										'my name is ' . htmlspecialchars($nameValue) .
										"\n" .
										"\n" .
										"I like to ...\n\n"
									;

									WriteLog('$nameToken = ' . $nameToken);

									$html = str_ireplace('</textarea>', $nameToken . '</textarea>' , $html);
								} else {
									WriteLog('my name is request not found');
								}
							}
						}



								if ($hnMode && length(c) > 6) {
			$c = trim($c);
			if (substr($c, length($c) - 6) == 'reply') {
				$c = substr($c, 0, length($c) - 5);
				$c = trim($c);
			}
		}
