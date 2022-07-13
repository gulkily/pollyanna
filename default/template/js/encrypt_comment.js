// encrypt_comment.js

function EncryptComment () { // todo move to crypto2.js
	//alert(window.pubKeyForServer);
	// still broken
	if (window.openpgp) {
		//var pubKey = window.pubKeyForServer
		var pubKey = getPublicKey();

		//alert(pubKey);

		var openpgp = window.openpgp;
		var message = document.compose.comment.value;
		var textbox = document.compose.comment;

		var pubKeyObj = openpgp.key.readArmored(pubKey.trim());

		options = {
			data: message,
			publicKeys: [pubKeyObj]
		};

		openpgp.config.show_version = false; // don't add openpgp version message to output
		openpgp.config.show_comment = false; // don't add comment to output

		var stringA = openpgp.encrypt(options);

//		openpgp.encrypt(options).then(function(signed) {
//			textbox.value = signed.data;
//		});
	}

	return '';
} // EncryptComment()

// / encrypt_comment.js
