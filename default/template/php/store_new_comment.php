<?php

function StoreNewComment ($comment, $replyTo, $recordFingerprint = 1) { // returns filename
// function StoreComment () {}
// function StoreItem () {}
// function AddItem () {}
// function InsertItem () {}
// function StoreNewItem () {}
// function CreateItem () {}
// function CreateTextFile () {}
	$hash = ''; // hash of new comment's contents
	$scriptDir = GetScriptDir();

	#todo more sanity

	if (!file_exists($scriptDir) || !is_dir($scriptDir)) {
		WriteLog('StoreNewComment: warning: $scriptDir is not a directory');
		return '';
	}

	if (isset($comment) && $comment) {
		WriteLog('StoreNewComment: $comment exists');

		// remember current working directory, we'll need it later
		$pwd = getcwd(); #my
		WriteLog('StoreNewComment: $pwd = ' . $pwd);

		// script directory is one level up from current directory,
		// which we expect to be called "html"
		$scriptDir = GetScriptDir(); #my
		WriteLog('StoreNewComment: $scriptDir = ' . $scriptDir);

		// $txtDir is where the text files live, in html/txt
		$txtDir = $pwd . '/txt/'; #my
		WriteLog('StoreNewComment: $txtDir = ' . $txtDir);

		// $htmlDir is the same as current directory
		$htmlDir = $pwd . '/'; #my
		WriteLog('StoreNewComment: $htmlDir = ' . $htmlDir);


		// find hash of the comment text
		// it will not be the same as sha1 of the file for some mysterious reason, #todo
		// but we will use it for now.
		$hash = sha1($comment);
		WriteLog('StoreNewComment: $comment = ' . $comment);
		WriteLog('StoreNewComment: $hash = ' . $hash);

		// generate a temporary filename based on the temporary hash
		$fileName = $txtDir . $hash . '.txt';
		WriteLog('StoreNewComment: $fileName = ' . $fileName);

		// standard signature separator
		$signatureSeparator = "\n--- \n"; #\n--
		$signatureContent = '';

		if (GetConfig('admin/logging/record_http_auth_username')) {
			if (isset($_SERVER['PHP_AUTH_USER']) && $_SERVER['PHP_AUTH_USER']) {
				WriteLog('StoreNewComment: Recording http auth username... $_SERVER[PHP_AUTH_USER]: ' . $_SERVER['PHP_AUTH_USER']);
				// record user's http-auth username if we're doing that and it exists
				// #todo sanity check on $_SERVER['PHP_AUTH_USER']

				$signatureContent .= 'Authorization: ' . $_SERVER['PHP_AUTH_USER'];
				$signatureContent .= "\n";
			}
		} else {
			WriteLog('StoreNewComment: NOT recording http auth username...');
		}

		WriteLog('StoreNewComment: $comment before cookie check: ' . $comment);

		if (GetConfig('admin/logging/record_cookie')) {
			WriteLog('StoreNewComment: record_cookie is TRUE');

			if (isset($_COOKIE['cookie']) && $_COOKIE['cookie']) {
				WriteLog('StoreNewComment: cookie: cookie was found! $_COOKIE[cookie] = ' . $_COOKIE['cookie']);

				// if there's a cookie variable and cookie logging is enabled
				if (index($comment, 'PGP SIGNED MESSAGE') == -1 || GetConfig('admin/logging/record_cookie_when_signed')) {
					// don't add cookie if message appears signed. this is a temporary measure to mitigate duplicate messages
					// because access.pl doesn't know how to save cookies yet. record_cookie_when_signed=0 by default

					WriteLog('StoreNewComment: cookie: adding cookie to $comment!');

					$signatureContent .= 'Cookie: ' . $_COOKIE['cookie'];
					$signatureContent .= "\n";
				}
			} else {
				WriteLog('StoreNewComment: cookie: cookie was NOT found');
			}
		}

		if (GetConfig('admin/logging/record_server_time')) {
			WriteLog('StoreNewComment: record_server_time is TRUE');
			$serverTime = time(); #my

			if (isset($serverTime) && $serverTime) {
				WriteLog('StoreNewComment: record_server_time: $serverTime $serverTime = ' . $serverTime);
				#WriteLog('StoreNewComment: cookie: adding server time to $comment!');

				$signatureContent .= 'Received: ' . $serverTime;
				$signatureContent .= "\n";
			}
		}

		if ($recordFingerprint) {
			if (GetConfig('admin/logging/record_client')) {
				WriteLog('StoreNewComment: admin/logging/record_client && $recordFingerprint');

				#my
				$clientHostname = (array_key_exists('REMOTE_HOST', $_SERVER) ? $_SERVER['REMOTE_HOST'] : $_SERVER['REMOTE_ADDR']);
				$userAgent = $_SERVER['HTTP_USER_AGENT'];

				$clientFingerprint = uc(substr(md5($clientHostname . $userAgent), 0, 16));

				#$signatureContent .= 'Client: ' . $clientFingerprint;
				$signatureContent .= 'Client: ' . $clientFingerprint;
				$signatureContent .= "\n";

				WriteLog('StoreNewComment: $recordFingerprint: $clientFingerprint = ' . $clientFingerprint);
			} else {
				WriteLog('StoreNewComment: warning: $recordFingerprint was requested, but admin/logging/record_client is off');
			}
		}

		if (GetConfig('admin/logging/record_http_host')) {
			if (isset($_SERVER['HTTP_HOST']) && $_SERVER['HTTP_HOST']) {
				// record host if it's enabled

				$signatureContent .= 'Host: ' . $_SERVER['HTTP_HOST'];
				$signatureContent .= "\n";
			}
		}

		if (strpos($comment, 'PUBLIC KEY BLOCK') && GetConfig('setting/admin/php/post/skip_footer_when_pubkey')) {
			// skip adding footer
		} else {
			if (trim($signatureContent)) {
				$comment .= $signatureSeparator;
				$comment .= $signatureContent;
			}
		}

		WriteLog('StoreNewComment: $comment = ' . htmlspecialchars($comment));

		WriteLog('StoreNewComment: PutFile(' . $fileName . ', $comment)');
		// save the file as ".tmp" and then rename
		PutFile($fileName, $comment); # PutFile()

// 		WriteLog('StoreNewComment: file_put_contents(' . $fileName . '.tmp, ' . htmlspecialchars($comment) . ') 1373');
// 		// save the file as ".tmp" and then rename
// 		file_put_contents($fileName . '.tmp', $comment); # PutFile()
		#WriteLog('StoreNewComment: rename(' . $fileName . '.tmp, ' . $fileName . ')');
		#rename($fileName . '.tmp', $fileName);

		//WriteLog('StoreNewComment: file_get_contents(' . $fileName . '):');
		//WriteLog(file_get_contents($fileName));
		// this can be  used for a test to verify that the content is there #todo
		// #todo more sanity

		return $fileName;
	} # if (isset($comment) && $comment)

	WriteLog('StoreNewComment: warning: returning without filename');
	return '';
} # StoreNewComment()
