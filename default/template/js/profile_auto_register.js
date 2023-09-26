// profile_auto_register.js

// quick and dirty auto-register
// should check for if user previously signed out

function ForceLogin () { // attempts to create a registration
	if (window.ForceLoginTried) {
		return '';
		// already tried it once
	}
	window.ForceLoginTried = 1;
	if (window.MakeKey && window.getPublicKey) {
		if (!getPublicKey()) {
			MakeKey(); // #todo this should not prompt for a username
			SetPrefs('sign_by_default', 1);
			PubKeyPing();
		} else {
			// already logged in
		}
	}
} // ForceLogin()

setTimeout('ForceLogin()', 1000);

// / profile_auto_register.js
