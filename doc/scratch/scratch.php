
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
