<?php

function ProcessNewComment ($comment, $replyTo) { // saves new comment to .txt file and calls indexer
# function ProcessNewItem () {
	$hash = ''; // hash of new comment's contents
	$fileUrlPath = ''; // path file should be stored in based on $hash
	$scriptDir = GetScriptDir();

	WriteLog('ProcessNewComment(...)');

	WriteLog('ProcessNewComment: $comment = ' . $comment);

	if ($comment) {
		$fileName = StoreNewComment($comment, $replyTo); // ProcessNewComment()
		WriteLog('ProcessNewComment: StoreNewComment(...) returned $fileName = ' . $fileName);
	}

	if ($fileName) {
		// remember current working directory, we'll need it later
		$pwd = getcwd(); #my
		WriteLog('ProcessNewComment: $pwd = ' . $pwd);

		// script directory is one level up from current directory,
		// which we expect to be called "html"
		$scriptDir = GetScriptDir(); #my
		WriteLog('ProcessNewComment: $scriptDir = ' . $scriptDir);

		// $txtDir is where the text files live, in html/txt
		$txtDir = $pwd . '/txt/'; #my
		WriteLog('ProcessNewComment: $txtDir = ' . $txtDir);

		// $htmlDir is the same as current directory
		$htmlDir = $pwd . '/'; #my
		WriteLog('ProcessNewComment: $htmlDir = ' . $htmlDir);


		// now we can get the "proper" hash,
		// which is for some reason different from sha1($comment), as noted above
		$hash = GetFileHash($fileName);
		// #todo this is wrong
		// #todo this is wrong
		// #todo this is wrong
		// #todo this is wrong
		// #todo this is wrong
		// this $hash is used below to generate things which should be under hte original file's hash which should equal this filename?
		// #debugtheory
		WriteLog('ProcessNewComment: $hash = ' . $hash);

		// hash-named files are stored under /ab/cd/ two-level directory prefix
		{ // create prefix subdirectories under txt/
			if (!file_exists($txtDir . substr($hash, 0, 2))) {
				mkdir($txtDir . substr($hash, 0, 2));
			}

			if (!file_exists($txtDir . substr($hash, 0, 2) . '/' . substr($hash, 2, 2))) {
				mkdir($txtDir . substr($hash, 0, 2) . '/' . substr($hash, 2, 2));
			}
		}
		{ // create prefix subdirectories under ./ (html/)
			if (!file_exists('./' .substr($hash, 0, 2))) {
				mkdir('./' . substr($hash, 0, 2));
			}

			if (!file_exists('./' . substr($hash, 0, 2) . '/' . substr($hash, 2, 2))) {
				mkdir('./' . substr($hash, 0, 2) . '/' . substr($hash, 2, 2));
			}
		}

		// path for new txt file
		$filePathNew =
			$txtDir .
			substr($hash, 0, 2) .
			'/' .
			substr($hash, 2, 2) .
			'/' .
			$hash . '.txt'
		;

		$fileHtmlPath = './' . GetHtmlFilename($hash); // path for new html file
		$fileUrlPath = '/' . GetHtmlFilename($hash); // client's (browser's) path to html file
		// save new post to txt file

		if (!file_exists($filePathNew)) {
			PutFile($filePathNew, GetFile($fileName)); # PutFile()

// 			WriteLog("ProcessNewComment: file_put_contents($filePathNew, $comment); 1465");
// 			file_put_contents($filePathNew, $comment);
// 			// #BUG #todo this is the reason record_cookie doesn't work!
// 			// this could probably just be a rename() #todo
// 			// cookie bug #CookieBug
		} else {
			WriteLog("ProcessNewComment: PutFile() skipped, file already exists");
			//WriteLog("ProcessNewComment: file_put_contents() skipped, file already exists");
		}

		// check if html file already exists. if it does, leave it alone
		if (!file_exists($fileHtmlPath)) {
			$commentHtmlTemplate = GetItemPlaceholderPage($comment, $hash, $fileUrlPath, $filePathNew);

			// store file
			WriteLog("ProcessNewComment: PutFile($fileHtmlPath, $commentHtmlTemplate)");
			PutFile($fileHtmlPath, $commentHtmlTemplate);
//
// 			// store file
// 			WriteLog("ProcessNewComment: file_put_contents($fileHtmlPath, $commentHtmlTemplate)");
// 			file_put_contents($fileHtmlPath, $commentHtmlTemplate);
		}

		if (GetConfig('admin/php/post/index_file_on_post') && isset($filePathNew)) { # ProcessNewComment()
			WriteLog('ProcessNewComment: index_file_on_post TRUE');
			$newFileHash = IndexTextFile($filePathNew);
			if ($newFileHash) {
				MakePage($newFileHash);
			} else {
				WriteLog('ProcessNewComment: warning: $newFileHash is false after IndexTextFile()');
			}
		} # index_file_on_post
		else {
			WriteLog('ProcessNewComment: index_file_on_post FALSE');
		}

		if (isset($_SERVER['HTTP_REFERER']) && $_SERVER['HTTP_REFERER']) {
			$referer = $_SERVER['HTTP_REFERER'];

			// #todo uncomment this once this script is working
			//header('Location: ' . $referer);
		} else {
			// #todo uncomment this once this script is working
			//header('Location: /write.html');
		}

		WriteLog('ProcessNewComment: $fileUrlPath = ' . $fileUrlPath);
	} # isset($comment) && $comment

	WriteLog('ProcessNewComment: return $hash = ' . $hash);

	return $hash;
} // ProcessNewComment()
