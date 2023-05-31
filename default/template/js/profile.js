// profile.js

var configJsOpenPgp = 0; // this is templated from config/setting/admin/js/openpgp

if (configJsOpenPgp && !window.openpgp && document.head && document.head.appendChild && document.getElementById && window.localStorage) {
	//alert('DEBUG: loading openpgp.js');
	window.openPgpJsLoadBegin = 1;

	var script = document.createElement('script');
	script.src = '/openpgp.js';
	script.async = false; // This is required for synchronous execution
	document.head.appendChild(script);
	//alert('DEBUG: finished loading openpgp.js; window.openpgp: ' + !!window.openpgp);
} else {
	//alert('DEBUG: not loading openpgp.js; window.openpgp: ' + !!window.openpgp + ' document.getElementById: ' + !!document.getElementById + ' window.localStorage: ' + !!window.localStorage + ' window.Promise: ' + !!window.Promise);
}

if (!(window.MakeKey) && document.head && document.head.appendChild && document.getElementById && window.localStorage) {
	//alert('DEBUG: loading crypto2.js');

	var script2 = document.createElement('script');
	script2.src = '/crypto2.js';
	script2.async = false; // This is required for synchronous execution
	document.head.appendChild(script2);

	//alert('DEBUG: finished loading crypto2.js; window.cryptoJs: ' + !!window.cryptoJs + '; document.getPrivateKey: ' + !!document.getPrivateKey + '; window.openpgp: ' + !!window.openpgp);
} else {
	//alert('DEBUG: not loading crypto2.js; ' + ' window.MakeKey = ' + window.MakeKey + '; document.getElementById = ' + document.getElementById + ' window.localStorage = ' + window.localStorage );
}

function btnSignOut_Click (t) { // event for 'Sign Out' button's click
	//alert('DEBUG: btnSignOut_Click() begin');

	if (window.localStorage) {
		//alert('DEBUG: btnSignOut_Click: localStorage is true');

		var ls = window.localStorage;
		ls.removeItem('privatekey');
		ls.removeItem('publickey');
		ls.removeItem('fingerprint');
		ls.removeItem('avatar');
		ls.removeItem('settings');
		ls.removeItem('dialogPosition');
		ls.removeItem('voted');
		ls.removeItem('replyCart');

		SetPrefs('latest_pubkey_ping', 0);
	}

	if (window.SetCookie) {
		SetCookie('cookie', 0);
		SetCookie('checksum', 0);
	}

	if (0) { //#todo
		// postmessage

		var form = document.createElement('form');
		form.setAttribute("action", "/post.html");
		form.setAttribute("method", "get");
		//form.setAttribute("target", "ifrSharePubKey");

		//alert('DEBUG: sharePubKey: creating input');

		var txtComment = document.createElement('input');
		txtComment.setAttribute("type", "hidden");
		txtComment.setAttribute("value", 'exiting... ' + GetTime());
		txtComment.setAttribute("name", "comment");

		//alert('DEBUG: sharePubKey: adding txtComment to form');

		form.appendChild(txtComment);
		//alert('DEBUG: sharePubKey: adding form to body');
		//document.getElementsByTagName('body')[0].appendChild(form);
		document.body.appendChild(form);
		//alert('DEBUG: submitting form');
		signMessage();
		//form.submit();
	}

	return true;
} // btnSignOut_Click()

function btnRegister_Click (t) { // event for 'Register' button's click
// t is clicked button's "this" object
	//alert('DEBUG: btnRegister_Click() begin');
	if (t) {
		if (t.value) {
			t.value = 'Meditate...';
		}
	}

	//if (window.localStorage && window.Promise) { // this extra check is disabled for some reason, I think IE?
	if (window.localStorage && document.getElementById) {
		//alert('DEBUG: btnRegister_Click: localStorage and Promise feature check pass');
		if (window.MakeKey) {
			//alert('DEBUG: btnRegister_Click: window.MakeKey exists, calling MakeKey()');

			var chkEnablePGP = document.getElementById('chkEnablePGP');
			if (chkEnablePGP && chkEnablePGP.checked) {
				//alert('DEBUG: chkEnablePGP is present and checked');
				var intKeyGenResult = MakeKey(t);
				//alert('DEBUG: btnRegister_Click: intKeyGenResult = ' + intKeyGenResult);
				SetPrefs('latest_pubkey_ping', 1);
				//alert('DEBUG: returning intKeyGenResult = ' + intKeyGenResult);
				myFingerprint = window.localStorage.getItem('fingerprint');
				if (myFingerprint) {
					//window.location = '/profile.html?' + myFingerprint;
				} else {
					//window.location = '/profile.html'; // #todo this needs to be fixed to work with relativized urls
				}
				//return intKeyGenResult; // TRUE if failed, FALSE if failed,
				//alert('Registration success.\nYou may need to reload the page.\nPlease forgive us for not being better at JavaScript.');
				setTimeout("window.location.reload()", 1000);
				return false;
				//return true;
				//return false;
				// because it is used to determine whether to submit the form to get a cookie
			}
		}
	} else {
		return true;
	}

	return true;
} // btnRegister_Click()

function getUserFp () { // retrieve stored user fingerprint from LocalStorage
	//alert('DEBUG: getUserFp() begin');

	if (window.localStorage) {
		// LocalStorage mode
		var fingerprint = localStorage.getItem('fingerprint');
		if (fingerprint) {
			return fingerprint;
		}
	} else {
		// fallback to cookie mode
		var fingerprint = GetCookie('cookie');

		if (fingerprint) {
			return fingerprint;
		}
	}

	// nothing found, we looked everywhere
	return '';
} // getUserFp()

function sharePubKey (t) { // shares current user's public key via injected form and iframe
	// t is the clicked link's "this", which is used to display a notification next to it

	//alert('DEBUG: profile.js: sharePubKey() begins');

	if (window.getPublicKey) {
		var pubKey = getPublicKey();

		//alert('DEBUG: sharePubKey: pubKey = ' + (pubKey ? pubKey : '(false)'));

		if (pubKey) {
			if (window.displayNotification) {
				if (t) {
					displayNotification('Profile created', t);
				} else {
					// #todo this appears at the bottom of the page
					// probably not visible to most users
					// so the redirect is a surprise
					displayNotification('Profile created');
				}
			}

			if (0) {

				//alert('DEBUG: sharePubKey: creating form');

				var form = document.createElement('form');
				form.setAttribute("action", "/post.html");
				form.setAttribute("method", "GET");
				//form.setAttribute("target", "ifrSharePubKey");

				//alert('DEBUG: sharePubKey: creating input');

				var txtComment = document.createElement('input');
				txtComment.setAttribute("type", "hidden");
				txtComment.setAttribute("value", pubKey);
				txtComment.setAttribute("name", "comment");

				//alert('DEBUG: sharePubKey: adding txtComment to form');

				form.appendChild(txtComment);

				//alert('DEBUG: sharePubKey: adding form to body');

				//document.getElementsByTagName('body')[0].appendChild(form);

				document.body.appendChild(form);

				//alert('DEBUG: submitting form');

				form.submit();

				return false;
			} // if (0)

			if (1) {
				var postPubKeyUrl = '/post.html?comment=' + encodeURIComponent(pubKey);
				PingUrl(postPubKeyUrl);
			}
		} else {
			//alert('DEBUG: sharePubKey: pubKey was FALSE');

			return true;
		}
	}

///// alternative method 1
//	window.open('/write.html#inspubkey', '_self');

///// alternative method 2
//	var iframe = document.createElement("iframe");
//	iframe.src = '/write.html#inspubkey';
//	iframe.name = "inspubkey"
//	iframe.style.display = 'none';
//	document.body.appendChild(iframe);

	return true;
} // sharePubKey()

function AddPrivateKeyLinks () { // adds save/load links to profile page if features are available
// #todo make it so that this can be called repeatedly and hide/show appropriate links
// this will allow to avoid having to reload profile page on status change

	//alert('DEBUG: AddPrivateKeyLinks() begin');
	if (document.getElementById && window.getPrivateKey) {
		//alert('DEBUG: AddPrivateKeyLinks: document.getElementById && window.getPrivateKey');
		var privateKey = getPrivateKey();
		var fieldset = document.getElementById('fldRegistration');

		if (fieldset && document.createElement) {
			//alert('DEBUG: AddPrivateKeyLinks: fieldset && document.createElement');

			if (privateKey) {
				//alert('DEBUG: AddPrivateKeyLinks: privateKey: true');


				// [go to profile]
				var pProfileLink = document.getElementById('spanProfileLink');
				if (!pProfileLink) {
					// profile link not there or the p is empty
					pProfileLink = document.createElement('p');
					pProfileLink.setAttribute('id', 'spanProfileLink');
					fieldset.appendChild(pProfileLink);
				}

				if (pProfileLink && !pProfileLink.innerHTML) {
					// ATTENTION!
					// THERE IS A GOTCHA HERE: THIS LINK MAY ALSO BE
					// ADDED BY PHP; THEN THIS CODE WILL NOT EXECUTE!
					// BECAUSE pProfileLink WILL ALREADY BE TRUE ABOVE

					// "Go to profile" link
					var aProfile = document.createElement('a');
					aProfile.setAttribute('href', '/author/' + getUserFp() + '/index.html');
					aProfile.setAttribute('onclick', 'if (window.sharePubKey) { return sharePubKey(this); }');
					aProfile.setAttribute('id', 'linkGoToProfile');
					aProfile.innerHTML = 'Go to profile';
					// 'Go to profile' "Go to profile"

					// Append both to fieldset
					pProfileLink.appendChild(aProfile);
				}

				if (0) {

					// [save as file]
					var pSaveKeyAsTxt = document.createElement('p');
					var aSaveKeyAsTxt = document.createElement('a');
					aSaveKeyAsTxt.setAttribute('href', '#');
					aSaveKeyAsTxt.setAttribute('id', 'linkSavePrivateKey');
					aSaveKeyAsTxt.setAttribute('onclick', 'if (window.SavePrivateKeyAsTxt) { return SavePrivateKeyAsTxt(); }');
					aSaveKeyAsTxt.innerHTML = 'Save as file';

					// hint for [save as file]
					var hintSaveKeyAsTxt = document.createElement('span');
					hintSaveKeyAsTxt.setAttribute('class', 'beginner');
					hintSaveKeyAsTxt.innerHTML = 'Save key to use again later';

					// insert [save as file] link into dom
					pSaveKeyAsTxt.appendChild(aSaveKeyAsTxt);
					var brSaveKeyAs = document.createElement('br');
					pSaveKeyAsTxt.appendChild(brSaveKeyAs);
					pSaveKeyAsTxt.appendChild(hintSaveKeyAsTxt);
					fieldset.appendChild(pSaveKeyAsTxt);
				}

				// [show private key]
				var linkShowPrivateKey = document.getElementById('linkShowPrivateKey');
				if (!linkShowPrivateKey) {
					var pShowPrivateKey = document.createElement('p');
					var aShowPrivateKey = document.createElement('a');
					pShowPrivateKey.setAttribute('class', 'advanced');

					aShowPrivateKey.setAttribute('href', '#');
					aShowPrivateKey.setAttribute('id', 'linkShowPrivateKey');
					aShowPrivateKey.setAttribute('onclick', 'if (window.ShowPrivateKey) { return ShowPrivateKey(); }');
					aShowPrivateKey.innerHTML = 'Show private key';

					// hint for [show private key]
					var hintShowPrivateKey = document.createElement('span');
					hintShowPrivateKey.setAttribute('class', 'beginner');
					hintShowPrivateKey.innerHTML = 'Display as text you can copy';

					pShowPrivateKey.appendChild(aShowPrivateKey);
					brElement = document.createElement('br');
					pShowPrivateKey.appendChild(brElement);
					pShowPrivateKey.appendChild(hintShowPrivateKey);
					fieldset.appendChild(pShowPrivateKey);
				}
			} // privateKey is true
			else {
				//alert('DEBUG: AddPrivateKeyLinks: privateKey: false');

				var pLoadKeyFromTxt = document.createElement('p');

				//alert('DEBUG: AddPrivateKeyLinks: creating file input...');

			} // privateKey is FALSE

			if (window.ShowAdvanced) {
				ShowAdvanced(1, 0);
			}
		} // if (fieldset && document.createElement)
		else {
			//alert('DEBUG: AddPrivateKeyLinks: checks FAILED (fieldset && document.createElement)');
		}
	} else {
		//alert('DEBUG: AddPrivateKeyLinks: checks FAILED (document.getElementById && window.getPrivateKey)');
	}

	return true;
} // AddPrivateKeyLinks()

function ShowPrivateKey () { // displays private key in textarea
	//alert('DEBUG: ShowPrivateKey() begin');
	if (document.getElementById) {
		//alert('DEBUG: ShowPrivateKey: document.getElementById is true');

		var txtPrivateKey = document.getElementById('txtPrivateKey');
		if (txtPrivateKey) {
			//alert('DEBUG: ShowPrivateKey: txtPrivateKey is true');

			if (txtPrivateKey.style.display == 'none') {
				//alert('DEBUG: style is none, set to block');
				txtPrivateKey.style.display = 'block';
			} else {
				//alert('DEBUG: style is block, set to none');
				txtPrivateKey.style.display = 'none';
			}

			var linkShowPrivateKey = document.getElementById('linkShowPrivateKey');
			if (linkShowPrivateKey) {
				if (txtPrivateKey.style.display == 'none') {
					linkShowPrivateKey.innerHTML = 'Show private key';
				} else {
					linkShowPrivateKey.innerHTML = 'Hide private key';
				}
			}

			return false;
		}
	}

	if (window.getPrivateKey) {
		var privateKey = getPrivateKey();
		if (privateKey && document.createElement) {
			var txtPrivKey = document.createElement('textarea');
			txtPrivKey.setAttribute('cols', 80);
			txtPrivKey.setAttribute('rows', 24);
			txtPrivKey.setAttribute('id', 'txtPrivateKey');
			txtPrivKey.innerHTML = privateKey;

			var fldRegistration = document.getElementById('fldRegistration');
			if (fldRegistration) {
				fldRegistration.appendChild(txtPrivKey);
			} else {
				document.body.appendChild(txtPrivKey);
			}

			var linkShowPrivateKey = document.getElementById('linkShowPrivateKey');
			if (linkShowPrivateKey) {
				linkShowPrivateKey.innerHTML = 'Hide private key';
			}

			txtPrivKey.focus();

			return false;
		}
	}

	return true;
} // ShowPrivateKey()

function openFile (event) {
	//alert('DEBUG: openFile() begin');

	var input = event.target;

	if (window.FileReader) {
		reader = new FileReader();

		// this eval is for hiding the "=function(){}" syntax from incompatible browsers
		// they shouldn't try to execute it because they don't make it here due to other tests
		eval('reader.onload = function() { var text = reader.result; LoadPrivateKeyFromTxt(text); }');
		reader.readAsText(input.files[0]);
	}

	return true;
} // openFile()

function LoadPrivateKeyFromTxt (text) {
	if (window.setPrivateKeyFromTxt) {
		setPrivateKeyFromTxt(text);
	}

	return true;
} // LoadPrivateKeyFromTxt()

function StripToFilename (text) { // strips provided text to only filename-valid characters
	if (!text) return '';

	text = text.trim();

	if (!text) return '';

	var charsAllowed = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';

	for (var i = 0; i < text.length; i++) {
		if (-1 < charsAllowed.indexOf(text.substr(i, 1))) {
			// ok
		} else {
			text = text.substr(0, i) + '' + text.substr(i + 1);
			i = i - 1;
		}
	}

	return text;
} // StripToFilename()

function getUsername2 () { // returns pgp username
// can be optimized with caching, but would also need to be
// un-cached when it changes. at this time, caching seems
// like over-optimization here
	var openpgp = window.openpgp;
	if (openpgp) {
		// read it into pgp object
		var privKeyObj = openpgp.key.readArmored(getPrivateKey());
		// get the public key out of it
		var pubKeyObj = privKeyObj.keys[0].toPublic();
		var myUsername = pubKeyObj.users[0].userId.userid;
		return myUsername;
	}
	return '';
} // getUsername2()

function SavePrivateKeyAsTxt () { // initiates "download" of private key as text file
	var myFp = getUserFp();
	var myUsername = getUsername2();
	var text = getPrivateKey();

	myUsername = StripToFilename(myUsername);

	window.blockPreNavigateNotification = 1;

	return DownloadAsTxt(myUsername + '_' + myFp + '.txt', text);
} // SavePrivateKeyAsTxt()

// override cookie if we have a profile in LocalStorage
//if (document.cookie) {
if (window.GetCookie) {
	if (GetCookie('cookie')) {
		//alert('DEBUG: cookie=' + document.cookie);
	} else {
		//alert('DEBUG: document.cookie missing');
		if (window.localStorage) {
			//alert('DEBUG: window.localStorage exists');
			var fp = localStorage.getItem('fingerprint');
			if (fp) {
				//alert('DEBUG: fp exists, setting cookie via js');
				document.cookie = 'test=' + fp;
			}
		}
	}
} else {
	//alert('DEBUG: profile.js: warning: GetCookie() is missing');
}

function PubkeyCheckProfileExists (fp) { // check if profile exists on server
	//alert('DEBUG: PubkeyCheckProfileExists() begin');

	//alert('DEBUG: PubkeyCheckProfileExists: fp = ' + fp);

	//var profileUrl = '/author/' + fp + '/';
	var profileUrl = '/author/' + fp + '.zip';

	//alert('DEBUG: profileUrl = ' + profileUrl);

	if (UrlExists(profileUrl)) {
		//alert('DEBUG: lastPubKeyPing: profile exists');
		return true;
	} else {
		//alert('DEBUG: lastPubKeyPing: profile NOT FOUND');
		return false;
	}

	return true;
} // PubkeyCheckProfileExists()

function GetTime () {
	var d = new Date();
	var n = d.getTime();
	n = Math.ceil(n / 1000);
	return n;
} // GetTime()

function GetFineTime () { // returns epoch in 10th of seconds
	var d = new Date();
	var n = d.getTime();
	n = Math.ceil(n / 100);
	return n;
} // GetFineTime()

function PubKeyPing () { // checks if user's public key is on server
// function PingProfile ()
// function PingPubKey ()
// function PingPublicKey ()
// uploads it to server if it is missing
//
	//alert('DEBUG: PubKeyPing() begin');

	var latestPing = GetPrefs('latest_pubkey_ping');

	if (latestPing && (GetTime() < (latestPing + 3600))) {
		//alert('DEBUG: PubKeyPing: latestPing+10 = ' + (latestPing+10) + ' < time() = ' + time());
	} else {
		//alert('DEBUG: PubKeyPing: latestPing was false or stale, doing a check at ' + time());

		if (window.location.href.indexOf('profile') != -1 && window.getUserFp) {
			//alert('DEBUG; PubKeyPing: window.getUserFp check passed');

			var myFingerprint = getUserFp();

			//alert('DEBUG: PubKeyPing: myFingerprint = ' + myFingerprint);

			if (myFingerprint) {
				if (PubkeyCheckProfileExists(myFingerprint)) {
					//alert('DEBUG: PubKeyPing: profile already exists');
				} else {
					if (window.sharePubKey) {
						//alert('DEBUG: PubKeyPing: latestPing: (window.sharePubKey) check passed, doing it...');
						sharePubKey();

						latestPing = GetTime();
						SetPrefs('latest_pubkey_ping', latestPing);
					} else {
						//alert('DEBUG: PubKeyPing: latestPing: (window.sharePubKey) check FAILED');
					}
				}
			} else {
				//alert('DEBUG: PubKeyPing: myFingerprint: false');
			}

			//alert('DEBUG: PubKeyPing: latestPing check complete, saving time');
		} else {
			//alert('DEBUG: PubKeyPing: window.getUserFp check FAILED');
		}
	}

	return true;
} // PubKeyPing()

function selectKeyPopulate () {
	if (document.formSelectKey && document.formSelectKey.selectKey) {
		if (1 < document.formSelectKey.selectKey.length) {
			// already populated
		} else { // #todo put this in event loop?
			if ((window.SetPrefs) && (window.GetPrefs)) {
				var iPrivKey = 0;
				while (GetPrefs('pk' + iPrivKey, 'PrivateKey1')) {
					//if (GetPrefs('pk' + iPrivKey, 'PrivateKey1') == keyArmored) {
					//	return 1; // already stored
					//}
					var o = new Option('pk' + iPrivKey, 'pk' + iPrivKey);
					document.formSelectKey.selectKey.add(o);
					iPrivKey++;
				}
				//SetPrefs('pk' + iPrivKey, keyArmored, 'PrivateKey1');
			}
		}
	}

	//alert(document.formSelectKey.selectKey.value);
}

function selectLoadKey (keyName) {
	var newKey = GetPrefs(keyName, 'PrivateKey1');
	if (newKey) {
		 setPrivateKeyFromTxt(newKey);
	}
}

function ProfileOnLoad () { // onload event for profile page
	//alert('DEBUG: ProfileOnLoad() begin');
	if (document.getElementById) {
		//alert('DEBUG: ProfileOnLoad: document.getElementById check passed');

		var lblSigningIndicator = document.getElementById('lblSigningIndicator');

		selectKeyPopulate();

		if (window.getPrivateKey) {
			//alert('DEBUG: ProfileOnLoad: window.getPrivateKey check passed');

			if (window.localStorage) {
				//alert('DEBUG: ProfileOnLoad: window.localStorage check passed, calling getPrivateKey()...');

				var configJsOpenPgp = 0; // this is templated from config/setting/admin/js/openpgp

				var pk = getPrivateKey();

				if (configJsOpenPgp && pk) {
					//alert('DEBUG: ProfileOnLoad: pk = GetPrivateKey() = ' + !!pk);
					// span used to indicate whether openpgp signing is available
					if (lblSigningIndicator) {
						//alert('DEBUG: lblSigningIndicator TRUE');
						// display value of "algorithm" which openpgp gives us
						// in reality, this only give us rsa/not-rsa, and formatted poorly
						// there's the bit count and the actual algo for non-rsa which needs
						// to be displayed more nicely here
						var privKeyObj = openpgp.key.readArmored(pk);
						var pubKeyObj = privKeyObj.keys[0].toPublic();

						var myAlgo = pubKeyObj.primaryKey.algorithm.toString();
						if (myAlgo) {
							//lblSigningIndicator.innerHTML = myAlgo;
							var gt = unescape('%3E');
							lblSigningIndicator.innerHTML = 'Signed in with private key.';
							//lblSigningIndicator.innerHTML = 'Signed in with private key. <a href="/profile.html" onclick="return btnSignOut_Click()"' + gt + 'Delete</a' + gt;
							//#todo this is a hack, make it less hacky
						} else {
							lblSigningIndicator.innerHTML = 'Signed in.';
						}
						AddPrivateKeyLinks(); // ProfileOnLoad()

						var pRegButton = document.getElementById('pRegButton');
						if (pRegButton) {
							pRegButton.style.display = 'none';
						}
					} else {
						//alert('DEBUG: lblSigningIndicator FALSE');
					}


					lblHandle = document.getElementById('lblHandle');

					if (lblHandle) {
						var strHandle = localStorage.getItem('avatar');
						if (strHandle) {
							lblHandle.innerHTML = strHandle;
						}
					}

					lblFingerprint = document.getElementById('lblFingerprint');

					if (lblFingerprint) {
						var strFingerprint = localStorage.getItem('fingerprint');
						if (strFingerprint) {
							lblFingerprint.innerHTML = strFingerprint;
						}
					}

					//alert('DEBUG: ProfileOnLoad: calling PubKeyPing()');
					PubKeyPing();
				} // pk is true
				else {
					//alert('DEBUG: pk = false')
					if (configJsOpenPgp && lblSigningIndicator) {
						//alert('DEBUG: lblSigningIndicator check passed');
						if (window.openpgp) {
							var lblFingerprint = document.getElementById('lblFingerprint');
							////alert('DEBUG: lblFingerprint = ' + lblFingerprint.innerHTML);
							if (lblFingerprint && lblFingerprint.innerHTML && (lblFingerprint.innerHTML != '')) { //#todo ...
								//pgp is available, but we're already logged in via cookies

								lblSigningIndicator.innerHTML = 'Signed in with cookie.';
							} else {
								// #todo why is window.openpgp false here??
								//alert('DEBUG: window.openpgp check passed, setting no (available)');

								var pExitButton = document.getElementById('pExitButton');
								if (pExitButton) {
									pExitButton.style.display = 'none';
								}

								lblSigningIndicator.innerHTML = '';

								var lblEnablePGP = document.createElement('label');
								var chkEnablePGP = document.createElement('input');
								var txtEnablePGP = document.createTextNode('Create private key (PGP)');

								var chkEnablePgpOn = 0;
								// this flag is set based on config setting/admin/js/openpgp_checked

								chkEnablePGP.setAttribute('type', 'checkbox');
								chkEnablePGP.setAttribute('name', 'chkEnablePGP');
								chkEnablePGP.setAttribute('id', 'chkEnablePGP');

								if (chkEnablePgpOn) {
									chkEnablePGP.setAttribute('checked', '1');
								}

								lblEnablePGP.setAttribute('for', 'chkEnablePGP');

								lblEnablePGP.appendChild(chkEnablePGP);
								lblEnablePGP.appendChild(txtEnablePGP);
								lblSigningIndicator.appendChild(lblEnablePGP);

								AddPrivateKeyLinks(); // ProfileOnLoad()
							}
						} else {
							//alert('DEBUG: warning: window.openpgp check FAILED');
							lblSigningIndicator.innerHTML = 'Unavailable';
						}
					} else {
						//alert('DEBUG: lblSigningIndicator check FAILED');
					}
					//AddPrivateKeyLinks();
				}
			} else {
				//alert('DEBUG: ProfileOnLoad: window.localStorage check FAILED');
			}
		} else {
			//alert('debug: ProfileOnLoad: window.getPrivateKey check FAILED');
		}
	} else {
		//alert('DEBUG: ProfileOnLoad: document.getElementById check FAILED');
	}

	return true;
} // ProfileOnLoad()

// / profile.js
