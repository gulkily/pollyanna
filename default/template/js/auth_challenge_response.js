// auth_challenge_response.js

// sent by the server when it needs the client to request a new cookie
// server provides a challenge string, and client is to sign it with pgp and return it

var challengeString = '1234567890';

if (challengeString) {
	if (window.signMessageBasic) {
		alert();
	}
}

// / auth_challenge_response.js


