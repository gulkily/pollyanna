<?php

$cookie = 0;
include_once('utils.php');

WriteLog('cookie.php: begin');

function GetSessionFingerprint () { # returns logged in user's fingerprint based on cookie
	if (isset($_COOKIE['test']) && $_COOKIE['test']) {
		WriteLog('GetSessionFingerprint: test cookie found');
		if (isset($_COOKIE['cookie']) && $_COOKIE['cookie']) {
			$cookie = $_COOKIE['cookie'];
		}
		if (isset($_COOKIE['checksum']) && $_COOKIE['checksum']) {
			$checksum = $_COOKIE['checksum'];
		}
		WriteLog('GetSessionFingerprint: $cookie = ' . (isset($cookie) ? $cookie : '(unset)') . '; $checksum= ' . (isset($checksum) ? $checksum : '(unset)'));
		$secret = GetConfig('admin/secret');
		if (md5($cookie . '/' . $secret) == $checksum) {
			return $cookie;
		} else {
			return '';
		}
	} else {
		return '';
	}
} # GetSessionFingerprint()

// #technically all the commands stuff should be in profile.php

//	WriteLog(htmlspecialchars(nl2br(print_r($_GET))));

$responseSignedIn = 0;

if (isset($_GET['btnSignOut'])) {
	$_GET['request'] = 'Sign Out';
}

if (isset($_GET['btnBegin'])) {
	$_GET['request'] = 'Begin';
}

if (isset($_GET['btnSignOut']) && $_GET['btnSignOut']) {
	WriteLog('cookie.php: btnSignOut activated');
	// user requested to sign out

	// unset relevant cookies
	unsetcookie2('test');
	unsetcookie2('cookie');
	unsetcookie2('checksum');

	// redirect with signed out message
	RedirectWithResponse('/session.html', 'Goodbye! You have signed out!');

	WriteLog('cookie.php: all cookies unset');
} # btnSignOut handler
else {
	WriteLog('cookie.php: btnSignOut not found');
	if (isset($_COOKIE['test']) && $_COOKIE['test']) {
		WriteLog('cookie.php: test cookie found');

		$validCookies = array('cookie', 'checksum', 'test', 'light', 'show_advanced', 'beginner', 'show_admin', 'opened_dialogs');
		foreach ($_COOKIE as $cookieKey => $cookieValue) {
			if (in_array($cookieKey, $validCookies)) {
				// is ok
			} else {
				WriteLog('cookie.php: warning: cookie not in validCookies was found and unset: ' . $cookieKey . ' = ' . $cookieValue);
				unsetcookie2($cookieKey);
			}
		}

		if (preg_match('/^[0-9A-F]{16}$/', $_COOKIE['test'])) { // #todo actual auth #knownCookieAuth
		    # set cookie to match public key fingerprint

			WriteLog('cookie.php: test cookie override!');

			$cookie = $_COOKIE['test'];
			setcookie2('cookie', $cookie);

			$secret = GetConfig('admin/secret');
			if (!$secret) {
				WriteLog('cookie.php: cookie.php: warning: $secret was false, making a new one');
				$secret = md5(time()); #todo #security
				PutConfig('admin/secret', $secret);
			} else {
				WriteLog('cookie.php: $secret was true');
			}

			$checksum = md5($cookie . '/' . $secret);
			setcookie2('checksum', $checksum);
			setcookie2('test', 1);

			$responseSignedIn = 1;
		} else {
			if (isset($_COOKIE['cookie']) && $_COOKIE['cookie']) {
				$cookie = $_COOKIE['cookie'];
			}

			if (isset($_COOKIE['checksum']) && $_COOKIE['checksum']) {
				$checksum = $_COOKIE['checksum'];
			}
		}

		WriteLog('cookie.php: $cookie = ' . (isset($cookie) ? $cookie : '(unset)') . '; $checksum= ' . (isset($checksum) ? $checksum : '(unset)'));
		$secret = GetConfig('admin/secret');

		if (!$cookie) {
			$cookie = strtoupper(substr(md5(rand()), 16));
			$checksum = md5($cookie . '/' . $secret);

			setcookie2('cookie', $cookie);
			setcookie2('checksum', $checksum);

			$responseSignedIn = 1;
		}

		if (md5($cookie . '/' . $secret) != $checksum) {
			WriteLog('cookie.php: Checksum mis-match! Expected ' . md5($cookie . '/' . $secret) . ', found ' . $checksum);

			unset($cookie);
			unsetcookie2('cookie');
			unsetcookie2('checksum');
			unsetcookie2('test');

			RedirectWithResponse('/session.html', 'You have been signed out! Press Begin button to start a new session. <span class=advanced>Technical: Checksum mismatch detected. Please notify operator.</span>');
			#todo write a nicer version of this
		}

		if ($responseSignedIn) {
			#todo more sanity on origin value
			$redirectPath = '/profile.html';
			$originValue = '';
			if (isset($_GET['origin']) && $_GET['origin']) {
				$originValue = $_GET['origin'];
			}
			if (isset($_POST['origin']) && $_POST['origin']) {
				$originValue = $_POST['origin'];
			}
			if ($originValue) {
				$redirectPath = $originValue;
			}
			WriteLog('cookie.php: $originValue = ' . $originValue . '; $redirectPath = ' . $redirectPath);

			# this caused a bug, where some pages were replaced with the write page. #todo fix
			#RedirectWithResponse($redirectPath, 'Success! You have signed in.');
		}
	} // if (isset($_COOKIE['test']) && $_COOKIE['test'])
	else {
		WriteLog('cookie.php: test cookie not found');
		if (isset($_GET['request']) && ($_GET['request'] == 'Begin')) { // ATTENTION: $_GET['request'] may be set by code above
			setcookie2('test', '1');
			header('Location: /profile.html?' . time());
		}
	}
} # not btnSignout
