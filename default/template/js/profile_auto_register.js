// profile_auto_register.js

// quick and dirty auto-register
// should check for if user previously signed out

function ForceLogin () {
	if (window.MakeKey && window.getPublicKey) {
		if (!getPublicKey()) {
			MakeKey();
			SetPrefs('sign_by_default', 1);
			PubKeyPing();
		} else {
			// already logged in
		}
	}
} // ForceLogin()

setTimeout('ForceLogin()', 5000);

// / profile_auto_register.js
