// profile_auto_register.js

// #autoreg
// quick and dirty auto-register
// should check for if user previously signed out
//
// if OpenPGP.js is available, and there is no kaypair already
// generate a pair, store it, and publish the public key

function AutoRegister () { // attempts to create a registration
	if (window.AutoRegisterTried) {
		return '';
		// already tried it once
	}
	window.AutoRegisterTried = 1;

	// should not trigger on session or profile page
	if (window.location.href.indexOf('session.html') != -1 || window.location.href.indexOf('profile.html') != -1) {
		return '';
	}

	// we should also set a cookie so that we don't keep prompting the user every session
	// this just shouldn't be used with openpgp_keygen_prompt_for_username
	if ((window.MakeKey) && (window.getPublicKey)) {
		if (!getPublicKey()) {
			MakeKey(); // # this may prompt for a username
			SetPrefs('sign_by_default', 1);
			PubKeyPing();
			// todo: should reload page and/or update dialog
		} else {
			// already logged in
		}
	}
} // AutoRegister()

// / profile_auto_register.js
