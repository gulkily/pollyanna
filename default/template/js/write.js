// == begin write.js

function WriteOnload () { // onload handler for write page
	//alert('DEBUG: WriteOnload() begin');

	if (document.getElementById) {
		//alert('DEBUG: WriteOnload: document.getElementById is true');

		if (0) {
			var comment = document.getElementById('comment');
			if (comment && comment.style) {
				// store current width
				// compare to viewport width
				// if wider than viewport reduce
				// otherwise, leave exactly the same
				var curWidth = comment.clientWidth;
				//alert(curWidth);
				var curHeight = comment.clientHeight;
				//alert(curHeight);
				comment.removeAttribute('cols');
				comment.removeAttribute('rows');
				comment.style.maxWidth = '95%';
				comment.style.width = curWidth + 'px';
				comment.style.height = curHeight + 'px';
			}
		}

		if (window.GetPrefs) {
			//alert('DEBUG: (window.GetPrefs) = TRUE');
			if (GetPrefs('write_enhance')) {
				//alert('DEBUG: write_enhance = TRUE');
				var comment = document.getElementById('comment');
				if (comment) {
					if (window.location.href.indexOf('write') != -1) {
						// write page
						CommentMakeWp(comment);
					} else {
						// not write page
						comment.setAttribute('onfocus', 'CommentMakeWp(this)');
					}
				}
			} else {
				//alert('DEBUG: write_enhance = FALSE');
			}
		} else {
			//alert('DEBUG: (window.GetPrefs) = FALSE');
		}
		var pubKey = '';
		if (window.getPublicKey) {
			//alert('DEBUG: window.getPublicKey exists');
			pubKey = getPublicKey();
		}
		var privKey = '';
		if (window.getPrivateKey) {
			//alert('DEBUG: window.getPrivateKey exists');
			privKey = getPrivateKey();
		}

		var configJsOpenPgp = 0; // this is templated from config/setting/admin/js/openpgp

		if (configJsOpenPgp && privKey) {
			//alert('DEBUG: privKey was true, adding options...');
			if (document.getElementById('spanSignAs')) {
				var gt = unescape('%3E');
				if (window.getAvatar) {

					if (window.solvePuzzle) {
						//alert('DEBUG: window.solvePuzzle was true, adding button...');
						var spanWriteAdvanced = document.getElementById('spanWriteAdvanced');
						if (spanWriteAdvanced && window.solvePuzzle) {
							var btnSolvePuzzle = document.createElement('input');
							btnSolvePuzzle.setAttribute('id', 'btnSolvePuzzle');
							btnSolvePuzzle.setAttribute('type', 'button');
							btnSolvePuzzle.setAttribute('value', 'Solve Puzzle');
							btnSolvePuzzle.setAttribute('onclick',	"if (window.solvePuzzle) { return solvePuzzle(this); } else { return true; }");
							spanWriteAdvanced.appendChild(btnSolvePuzzle);

							var br = document.createElement('br');
							spanWriteAdvanced.appendChild(br);

							var lblSolvePuzzle = document.createElement('span');
							lblSolvePuzzle.setAttribute('class', 'beginner');
							var gt = unescape('%3E');
							lblSolvePuzzle.innerHTML = 'Solving puzzles may improve reputation.';
							spanWriteAdvanced.appendChild(lblSolvePuzzle);
						}
					} // window.solvePuzzle


					var spanSignAs = document.getElementById('spanSignAs');

					var lblSignAs = document.createElement('label');
					lblSignAs.setAttribute('for', 'chkSignAs');

					var chkSignAs = document.createElement('input');
					chkSignAs.setAttribute('name', 'chkSignAs');
					chkSignAs.setAttribute('id', 'chkSignAs');
					chkSignAs.setAttribute('type', 'checkbox');

					if (!(window.GetPrefs) || GetPrefs('sign_by_default')) {
						chkSignAs.setAttribute('checked', 1);
					}

					if (window.solvePuzzle) { // assumes btnSolvePuzzle was created
						chkSignAs.setAttribute('onchange', 'document.getElementById(\'btnSolvePuzzle\').disabled = !this.checked'); // #todo does this need sanity check first?
						chkSignAs.onchange();
					}


					// implied getElementById already been feature checked here
					//chkSignAs.setAttribute('onclick', "if (document.getElementById('btnSolvePuzzle')) { document.getElementById('btnSolvePuzzle').setAttribute('disabled', !chkSignAs.checked); }");
					// this checkbox being checked means signMessage() is called in writeSubmit()

					lblSignAs.innerHTML = 'Sign as ' + getAvatar();
					lblSignAs.appendChild(chkSignAs);
					spanSignAs.appendChild(lblSignAs);
				} // window.getAvatar
			} // document.getElementById('spanSignAs')
		}


		//window.pubKeyForServer = '-----BEGIN PGP PUBLIC KEY BLOCK-----\n\n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\n=Jwcw\n-----END PGP PUBLIC KEY BLOCK-----';

		if (window.pubKeyForServer) {
			var btnEncrypt = document.createElement('button');
			btnEncrypt.setAttribute('title', 'Encrypt');
			btnEncrypt.innerHTML = 'Encrypt'; // todo add text node instead
			btnEncrypt.setAttribute('onclick', 'return EncryptComment()');

			if (document.getElementById('spanEncrypt')) {
				var spanEncrypt = document.getElementById('spanEncrypt')
				spanEncrypt.appendChild(btnEncrypt);
			}
		}

		if (pubKey) {
			//alert('DEBUG: pubKey was true, calling PubKeyPing()');
			if (window.PubKeyPing) {
				PubKeyPing();
			}
		}

		if (window.location.hash) {
			//alert('DEBUG: window.location.hash = ' + window.location.hash);
			if (window.location.hash == '#inspubkey') {
				//alert('DEBUG: #inspubkey found');
				if (pubKey) {
					//alert('DEBUG: pubKey is true, inserting it into comment');
					var comment = document.getElementById('comment');
					if (comment) {
						comment.value = pubKey;
					}
				} else {
					//alert('DEBUG: pubKey was false, this is unexpected. Giving up.');
				}
			}
		}
	} // document.getElementById
	else {
		//alert('DEBUG: WriteOnload: document.getElementById was FALSE');
	}

	return true;
} // WriteOnload()

function CommentMakeWp (comment) { // makes editor textarea larger and gives it wp color scheme
// called when write_enhance is on
	if (comment) {
		comment.style.backgroundColor = '#102080';
		comment.style.color = 'ffffff';
		comment.style.fontWeight = 'bold';
		comment.style.width = '95%';
		comment.style.height = '50%';
		comment.style.padding = '1em';
		comment.setAttribute('cols', 80);
		comment.setAttribute('rows', 24);
	}

	return '';
} // CommentMakeWp()

function writeSubmit (t) { // called when user submits write form //signMessage (
	//alert('DEBUG: writeSubmit() begin');
	if (window.localStorage) {
		//alert('DEBUG: window.localStorage');
		if (window.ClearAutoSave) {
			ClearAutoSave();
		}
	} else {
		//alert('DEBUG: no window.localStorage');
	}

	var configJsOpenPgp = 0; // this is templated from config/setting/admin/js/openpgp
	if (configJsOpenPgp && window.getPrivateKey && window.signMessage) {
		//alert('DEBUG: window.getPrivateKey && window.signMessage test passed');
		if (getPrivateKey()) {
			//alert('DEBUG: getPrivateKey() is true, writeSubmit() Calling signMessage()');

			if (document.getElementById) {
				var chkSignAs = document.getElementById('chkSignAs');
				if (!chkSignAs || (chkSignAs && chkSignAs.checked)) {
					// if there's a "sign as" checkbox, it should be checked
					if (window.signMessage) {
						var signMessageResult = signMessage();
						if (!signMessageResult) {
							signMessageResult = 0;
						}
						// once the message is signed, callback will submit the form
						if (signMessageResult) {
							return false; // uncomment this for duplicate unsigned messages feature
						} else {
							return true;
						}
					}
				} else {
					// user choose not to sign
					return true;
				}
			}
		} else {
			// no private key
			//alert('DEBUG: no private key, basic submit');
		}
	} else {
		//alert('DEBUG: Test Failed: window.getPrivateKey: ' + !!window.getPrivateKey + '; window.signMessage: ' + !!window.signMessage);
	}

	window.eventLoopFresh = 0; // disables fresh.js. may not be a wise move here.

	//alert('DEBUG: writeSubmit: about to return true');

	return true;
} // writeSubmit()

function DoAutoSave() {
	var initDone = window.autoSaveInitDone;
	if (!initDone) {
		window.autoSaveInitDone = 1;

		var ls = window.localStorage;
		if (window.localStorage && ls) {
			var storedValue = ls.getItem('autosave');

			if (storedValue) {
				var comment = document.getElementById('comment');
				if (comment) {
					comment.value += storedValue;
				}
			}
		}

		return 0;
	}

	if (document.getElementById) {
		//alert('DEBUG: DoAutoSave: document.getElementById is true');

		if (window.GetPrefs) {
			//alert('DEBUG: DoAutoSave: (window.GetPrefs) = TRUE');

			if (GetPrefs('write_autosave')) { // #todo this can't be right
				//alert('DEBUG: DoAutoSave: write_autosave = TRUE');

				var comment = document.getElementById('comment');
				if (comment) {
					if (window.localStorage) {
						var ls = window.localStorage;
						if (window.localStorage && ls) {
							ls.setItem('autosave', comment.value);
						}
					}
				}
			} else {
				//alert('DEBUG: write_autosave = FALSE');
			}
		} else {
			//alert('DEBUG: (window.GetPrefs) = FALSE');
		}
	}

	return '';
} // DoAutoSave()

function ClearAutoSave () {
	var ls = window.localStorage;
	if (window.localStorage && ls) {
		window.eventLoopDoAutoSave = 0;
		ls.removeItem('autosave');
	}
} // ClearAutoSave()

function writeAddTag (tag) {
	if (document.compose && document.compose.comment) {
		document.compose.comment.value = tag + ' ' + document.compose.comment.value;
	}
} // writeAddTag()


window.eventLoopDoAutoSave = 1;

// == end write.js
