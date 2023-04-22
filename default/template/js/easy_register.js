/* easy_register.js */

function EasyRegister (t) {
	MakeKey(t);
	SetPrefs('sign_by_default', 1);
	PubKeyPing();
	doSolvePuzzle(t);
	return false;
}

/* / easy_register.js */