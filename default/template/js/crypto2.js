// == begin crypto2.js

// these are used to globally store the user's fingerprint and username
var myFingerprint = '';
var myUsername = '';

var configJsOpenPgp = 0; // this is templated from config/setting/admin/js/openpgp

//alert('DEBUG: crypto2.js begins');

function time () { // returns epoch time
	var d = new Date();
	return Math.floor(d.getTime() / 1000);
}

function SimpleBenchmark () { // simple benchmark
	//alert('DEBUG: SimpleBenchmark() begins');

	var i = 0;
	for (i = 0; i <= time() * 1000; i++) {
		i += time();
	}

	//alert('DEBUG: SimpleBenchmark() returning ' + (i/time()));

	return (i / time());
}

function GenerateKey () {
} // GenerateKey()

function MakeKey (t, callback = '') { //makes key using default settings
// returns FALSE for success, TRUE for failure

// also prompts for username, redirects to profile page ...
// calls GenerateKey() #todo
// once key is generated, store it to localStorage

	//alert('DEBUG: MakeKey() begin');
	var openpgp = window.openpgp;

	//var gt = String.fromCharCode(62);
	var gt = unescape('%3E');

	//alert('DEBUG: MakeKey: openpgp: ' + !!openpgp);

	if (window.localStorage && openpgp) {
		// if openpgp is loaded, proceed with client-side key generation

		//alert('DEBUG: MakeKey: SimpleBenchmark() returns ' + SimpleBenchmark());

		// it's a bit convoluted here at the moment
		// bits refers to rsa bits
		// BUT if it is not a number, it refers to the alternative algorithm
		// this is used later to select it with an if statement
		// algoSelectMode, in turn is used to select the value of bits
		// it's ok to just leave it at 2048
		// for dev purposes, it's ok to use 512 for faster keygen
		// 512 is reasonably secure, meaning it would take more than an hour to break it

		var bits = 2048; // decent default. reasonably fast, backwards compatible

		var algoSelectMode = 0; // this is set from template when it's generated
		// 0 means leave it alone at bits = 2048, which is the sanest default

		if (algoSelectMode == '512') { // fast and breakable, good for testing and art projects
			var bits = 512;
		}
		if (algoSelectMode == 'random') { // randomize decent crypto
			var bitsOptions = new Array();
			bitsOptions[0] = 2048;
			bitsOptions[1] = 'curve25519';
			bitsOptions[2] = 'ed25519';
			bitsOptions[3] = 'p256';
			bitsOptions[4] = 'p384';
			bitsOptions[5] = 'p521';
			bitsOptions[6] = 'secp256k1';

			var bits = bitsOptions[Math.floor(Math.random() * bitsOptions.length)];
		}
		if (algoSelectMode == 'max') { // slow, more secure
			var bits = 4096;
			//var bits = bitsOptions[Math.floor(Math.random() * bitsOptions.length)];
		}
		
		//alert('DEBUG: MakeKey: algoSelectMode = ' + algoSelectMode + '; bits = ' + bits);

		// full options list:
		// 512 1024 2048 4096
		// 'curve25519' 'ed25519' 'p256' 'p384' 'p521' 'secp256k1'

		var username = 'Guest'; //#guest...
		//username = prompt('Choose your handle:', username);

		//alert('DEBUG: MakeKey: username: ' + username);

		if (username == null) {
			//alert('DEBUG: MakeKey: username == null is true, skipping keygen!');
		} else {
			//alert('DEBUG: MakeKey: username == null is false');

			if (!username || !username.trim()) {
				username = 'Guest'; //#guest...
			}

			//alert('DEBUG: MakeKey: username: ' + username);

			openpgp.initWorker({path:'openpgp.worker.js'});

			var options;
			if (bits == 512 || bits == 1024 || bits == 2048 || bits == 4096) {
				options = {
					userIds: [{ name: username }],
					numBits: bits,
					passphrase: ''
				};
			} else {
				options = {
					userIds: [{ name: username }],
					curve: bits,
					passphrase: ''
				};
			}

			openpgp.config.show_version = false;
			openpgp.config.show_comment = false;

			openpgp.generateKey(options).then(
				function(key) {
					var privkey = key.privateKeyArmored; // '-----BEGIN PGP PRIVATE KEY BLOCK ... '
					var pubkey = key.publicKeyArmored;   // '-----BEGIN PGP PUBLIC KEY BLOCK ... '
					var revocationCertificate = key.revocationCertificate; // '-----BEGIN PGP PUBLIC KEY BLOCK ... '

					openpgp.key.readArmored(privkey);

					// read it into pgp object
					var privKeyObj = openpgp.key.readArmored(privkey);;

					// get the public key out of it
					var pubKeyObj = privKeyObj.keys[0].toPublic();

					// store the armored version into localStorage
					var pubkey = pubKeyObj.armor();

					// get the fingerprint as uppercase hex and store it
					var myFingerprint = pubKeyObj.primaryKey.keyid.toHex().toUpperCase();

					// get username out of key
					var myUsername = pubKeyObj.users[0].userId.userid;

					//var gt = String.fromCharCode(62);
					var gt = unescape('%3E');

					var avatar = escapeHTML(myUsername);

					AddPrivateKey(privkey);

					window.localStorage.setItem('privatekey', privkey);
					window.localStorage.setItem('publickey', pubkey);
					window.localStorage.setItem('fingerprint', myFingerprint);
					window.localStorage.setItem('avatar', avatar);

					document.cookie = "test=" + myFingerprint;

					if (window.SetPrefs) {
						SetPrefs('sign_by_default', 1);
					}

					//alert('DEBUG: MakeKey: about to share public key');

					//if (window.addLoadingIndicator) {
					//	addLoadingIndicator('Creating profile...');
					//}
					//PubKeyPing();

					// window.location = '/profile.html?' + myFingerprint;
					PingUrl('/profile.html?' + myFingerprint);

					//	if (window.sharePubKey) {
					//		//alert('DEBUG: MakeKey: (window.sharePubKey) exists. calling');
					//		//sharePubKey();
					//
					//		return true;
					//	} else {
					//		//alert('DEBUG: MakeKey: (window.sharePubKey) does NOT exist, using window.location');
					//
					//		window.location = '/write.html#inspubkey';
					//		return true;
					//	}
					//alert('done MakeKey; callback = ' + callback);

					if (callback) {
						setTimeout(callback, 1000);
					}
				}
			);

			return false; // return false, cancel form submit to allow for signing
		}

		return true; // signing wasn't scheduled, allow form to submit

	}

	return true; // signing wasn't scheduled, allow form to submit
} // MakeKey()

function getPrivateKey () { // get private key from local storage
// returns null otherwise
	//alert('DEBUG: getPrivateKey() begins');

	if (window.localStorage) {
		//alert('DEBUG: getPrivateKey: window.localStorage is true, checking for localStorage.getItem(privatekey)');

		var privateKey = localStorage.getItem("privatekey");

		if (privateKey) {
			//alert('DEBUG: getPrivateKey: found something in localStorage: ' + !!privateKey);

			return privateKey;
		} else {
			//alert('DEBUG: getPrivateKey: found nothing in localStorage');

			return null;
		}
	} else {
		return null;
	}
}

function getPublicKey () { // get public key from local storage
// returns null otherwise

	//alert('DEBUG: getPublicKey() begins');

	if (window.localStorage) {
		//alert('DEBUG: getPublicKey: window.localStorage is true, checking for localStorage.getItem(publickey)');

		var publicKey = localStorage.getItem("publickey");

		if (publicKey) {
			//alert('DEBUG: getPublicKey: found in localStorage: ' + publicKey);

			return publicKey;
		} else {
			//alert('DEBUG: getPublicKey: not found in localStorage');

			return null;
		}
	} else {
		return null;
	}
} // getPublicKey()

function AddPrivateKey (keyArmored) {
	//alert('DEBUG: AddPrivateKey()');

	var gt = unescape('%3E');

	//var openpgp = window.openpgp;
	//var privKeyObj = openpgp.key.readArmored(newKey);

	if (window.SetPrefs && window.GetPrefs) {
		var iPrivKey = 0;
		while (GetPrefs('pk' + iPrivKey, 'PrivateKey1')) {
			if (GetPrefs('pk' + iPrivKey, 'PrivateKey1') == keyArmored) {
				return 1; // already stored
			}
			iPrivKey++;
		}
		SetPrefs('pk' + iPrivKey, keyArmored, 'PrivateKey1');
	}
} // AddPrivateKey()

function setPrivateKeyFromTxt (newKey) { // set the current private key and refresh the pubkey, fingerprint, and avatar too
	var gt = unescape('%3E'); // greater thean symbol, which we hide from mosaic

	//window.localStorage.setItem("privatekey", newKey);

	if (document.head && document.head.appendChild && document.getElementById && window.localStorage) {
		//alert('DEBUG: setPrivateKeyFromTxt: document.head: ' + !!document.head + '; document.head.appendChild = ' + !!document.head.appendChild + '; document.getElementById = ' + !!document.getElementById + '; window.localStorage: ' + !!window.localStorage);

		var configJsOpenPgp = 0; // this is templated from config/setting/admin/js/openpgp
		if (configJsOpenPgp && !window.openpgp) {
			// load openpgp.js if we haven't already and if we have the dependencies

			//alert('DEBUG: setPrivateKeyFromTxt: checks passed, loading openpgp.js');

			window.openPgpJsLoadBegin = 1;

			var script = document.createElement('script');
			script.src = '/openpgp.js';
			script.async = false; // This is required for synchronous execution
			document.head.appendChild(script);

			//alert('DEBUG: setPrivateKeyFromTxt: finished loading openpgp.js');
		} else {
			//alert('DEBUG: setPrivateKeyFromTxt: window.openpgp already exists');
		}
	} else {
		return '';
	}

	var openpgp = window.openpgp;

	// don't display version and comment
	openpgp.config.show_version = false;
	openpgp.config.show_comment = false;

	// read it into pgp object
	var privKeyObj = openpgp.key.readArmored(newKey);

	// get the public key out of it
	var pubKeyObj = privKeyObj.keys[0].toPublic();

	// store the armored version into localstorage
	var pubkey = pubKeyObj.armor();
	window.localStorage.setItem("publickey", pubkey);

	// get the fingerprint as uppercase hex and store it
	var myFingerprint = pubKeyObj.primaryKey.keyid.toHex().toUpperCase();
	// get username out of key

	var myUsername = pubKeyObj.users[0].userId.userid;
	var avatar = escapeHTML(myUsername);
	var privkey = privKeyObj.privateKeyArmored;

	// save to localStorage
	window.localStorage.setItem('privatekey', newKey);
	window.localStorage.setItem('publickey', pubkey);
	window.localStorage.setItem('fingerprint', myFingerprint);
	window.localStorage.setItem('avatar', avatar);

	document.cookie = "test=" + myFingerprint;

	window.location = '/profile.html?' + myFingerprint;

	// this will submit public key as an item to the board
	if (window.PubKeyPing) {
		PubKeyPing();
	} else {
		window.location = '/write.html#inspubkey';
	}
} // setPrivateKeyFromTxt()

function getUsername () { // returns pgp username
	var openpgp = window.openpgp;

	if (window.getUsernameReturn) {
		return window.getUsernameReturn;
	}

	if (openpgp) {
		// read it into pgp object
		var privKeyObj = openpgp.key.readArmored(getPrivateKey());

		// get the public key out of it
		var pubKeyObj = privKeyObj.keys[0].toPublic();
		var myUsername = pubKeyObj.users[0].userId.userid;

		window.getUsernameReturn = myUsername;

		return myUsername;
	}

	return '';
} // getUsername()

function signMessageBasic (message) {
	var openpgp = window.openpgp;

	//alert('DEBUG: signMessageBasic: openpgp = ' + openpgp);

	var privkey = getPrivateKey();
	var privKeyObj = openpgp.key.readArmored(privkey).keys[0];
	var signedMessage = '';

	//alert('DEBUG: signMessageBasic: privkey = ' + privkey);
	//alert('DEBUG: signMessageBasic: privKeyObj = ' + privKeyObj);

	// set basic options for signing the message
	options = {
		data: message,                             // input as String (or Uint8Array)
		privateKeys: [privKeyObj]                  // for signing
	};

	//alert('DEBUG: signMessageBasic: options = ' + options);

	openpgp.config.show_version = false; // don't add openpgp version message to output
	openpgp.config.show_comment = false; // don't add comment to output
	openpgp.sign(options).then(function(signed) {
		//alert('DEBUG: signMessageBasic: signed = ' + signed);
		//signedMessage = signed.data;

		document.compose.comment.value = signed.data;
		// #todo figure out how to do sync return in javascript with this

		//alert(signed.data);
	});

	//alert('DEBUG: signMessageBasic: signedMessage = ' + signedMessage);

	return signedMessage;
} // signMessageBasic()

function signMessage () { // find the compose textbox and sign whatever is in it
// if message is already signed or is a public key, exit
// relies on getElementById and localStorage
// submits the form when finished

	//alert('DEBUG: signMessage() begin');

	var privkey = getPrivateKey();
	if (document.getElementById && privkey) {
		// private key exists, can proceed
		//alert('DEBUG: signMessage: privkey is true');

		var textbox = document.getElementById('comment');
		var composeForm = document.getElementById('compose');

		if (textbox && composeForm && window.openpgp) {
			//alert('DEBUG: signMessage: textbox && composeForm is true');

			// this would change textbox appearance to indicate something happened
			// textbox.style.color = '#00ff00';
			// textbox.style.backgroundColor = '#c0c000';

			var message = textbox.value;

			// if the message already has the header,
			//    assume it's already signed and return
			// #todo make it also verify that it's signed before returning
			// #todo some kind of *unobtrusive* indicator/confirmation/option
			// #todo change color of textbox when message is properly signed

			if (message.trim().substring(0, 34) == ('-----BEGIN PGP SIGNED MESSAGE-----')) {
				//alert('DEBUG: signMessage: message is already signed, returning');
				return true;
			}

			if (message.trim().substring(0, 36) == ('-----BEGIN PGP PUBLIC KEY BLOCK-----')) {
				//alert('DEBUG: signMessage: message contains public key, returning');
				return true;
			}

			var replyTo = document.getElementById('replyto');
			// look for a replyto field

			if (replyTo) {
				// if replyto exists, prepend it contents to the message as a (gtgt) token
				var replyToId = replyTo.value;
				if (replyToId) {
					var gt = unescape('%3E');
					if (-1 < message.indexOf(gt + gt + replyToId)) {
					} else {
						message = gt + gt + replyToId + '\n\n' + message;
					}
				}
			}

			var privKeyObj = openpgp.key.readArmored(privkey).keys[0];
			//
			// privateKey.decrypt('hello');
			// var privKeyObj = (await openpgp.key.readArmored(privkey)).keys[0];
			// await privKeyObj.decrypt(passphrase);

			// set basic options for signing the message
			options = {
				data: message,                             // input as String (or Uint8Array)
				privateKeys: [privKeyObj]                  // for signing
			};

			openpgp.config.show_version = false; // don't add openpgp version message to output
			openpgp.config.show_comment = false; // don't add comment to output
			openpgp.sign(options).then(function(signed) {
				// begin signing process

				// put the signed data into th textbox when it's done
				textbox.value = signed.data;
				// submit the form
				composeForm.submit();
			});
			return false; // don't submit the form yet, will submit after signed
		}
		return true; // let the form submit
	} else {
		// this is an edge case
		// user signed out in another window, but wants to sign in this one
		// signing is no longer possible, so just submit to be on safe side
		return true;
	}

	return true;
} // signMessage()

function cryptoJs () { // used for checking if crypto2.js has been loaded
	return 1;
} // cryptoJs()

//alert('DEBUG: crypto2.js ends');

// == end crypto2.js
