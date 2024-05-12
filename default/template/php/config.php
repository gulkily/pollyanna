<?php
/* php/config.php */

include_once('utils.php');

//
//echo(time());
//
//echo "<br><hr><br>";
//echo "<br>Below is set of local config which differs from defaults<br>";
//echo "<br>You can copy and paste this into Write form of your own site, sign it, and post as Operator.";
//echo "<br><hr><br>";

function WriteConfigDump () {
	$TXT = GetDir('txt');
	$CONF = GetDir('config');
	$DEF = GetDir('default');

	WriteLog('WriteConfigDump: $TXT = ' . $TXT . '; $CONF = ' . $CONF . '; $DEF = ' . $DEF);

	$default = explode("\n", `find $DEF`);
	$config = explode("\n", `find $CONF`);

	$text = "";
	$text = time() . " #config #example\n\n";
	$configLookup = array();

	foreach ($config as $c) {
		#WriteLog('WriteConfigDump: $c = ' . $c);
		$c = str_replace($CONF, '', $c);
		$configLookup[$c] = 1;

		#avoid checking directories with file_exists(), causes warning
		if (file_exists($CONF . $c)) {
			if (is_dir($CONF . $c)) {
				$configValue[$c] = '';
			} else {
				$configValue[$c] = file_exists($CONF . $c) ? trim(file_get_contents($CONF . $c)) : '';
			}
		}
		if (file_exists($DEF . $c)) {
			if (is_dir($DEF . $c)) {
				$defaultValue[$c] = '';
			} else {
				$defaultValue[$c] = file_exists($DEF . $c) ? trim(file_get_contents($DEF . $c)) : '';
			}
		}
	} # foreach ($config as $c)

	#WriteLog('WriteConfigDump: $configLookup = ' . print_r($configLookup, 1));

	foreach ($default as $d) {
		if (index($d, 'secret') == -1) {
			//WriteLog('WriteConfigDump: $d before replace = ' . $d);
			$d = str_replace($DEF, '', $d);
			//WriteLog('WriteConfigDump: $d after replace = ' . $d);

			// print(isset($configLookup[$d]) ? $configLookup[$d] : '');

			if (isset($configLookup[$d])) {
				//print('<b>+</b>');
				if ($configValue[$d] == $defaultValue[$d]) {
					//print 'default';
				} else {
					$text .= "config";
					$text .=  $d;
					$text .=  '=';
					$text .=  $configValue[$d];

					//print htmlspecialchars(trim($configValue[$d]));
					//print "<br>";
					$text .= "\n";
				}
			}
		}
	}

	$targetFileName = $TXT . "/config_dump_" . time() . ".txt";

	PutFile($targetFileName, $text);
	WriteLog('WriteConfigDump: $text = ' . $text);
	#file_put_contents($targetFileName, $text);

	WriteLog('WriteConfigDump: wrote $targetFileName = ' . $targetFileName);

	return $targetFileName;
} # WriteConfigDump()

/* / php/config.php */