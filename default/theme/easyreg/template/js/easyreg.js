/* easyreg.js */

function EasyMember (t) {

	//alert('EasyMember()');

	var myFp;    // stores current user's fingerprint

//	if (t && t.value) {
//		t.value = 'Meditate...';
//		setTimeout('EasyMember', 100);
//		return false;
//	}
//
	if (window.getUserFp && window.MakeKey) {
		myFp = getUserFp();
		if (!myFp) {
			var keySuccess = MakeKey(t, 'afterKeygen()');
			myFp = getUserFp();
		} else {
			afterKeygen();
		}

		return false;
	}
}

function afterKeygen () {

	//alert('afterKeygen()');

	//alert('DEBUG: EasyMember: myFp = ' + myFp);

	var myFp = getUserFp();

	var puzzlePrefix = '1337'; // note: this line is used for templating

	var solvedPuzzle = getSolvedPuzzle(myFp, puzzlePrefix, 10, 1000000);

	var myMessage =
		'Welcome, New Member!' + "\n\n" +
		'A new member has completed registration.' + "\n\n" +
		'Feel free to introduce yourself below.' + "\n\n" +
		solvedPuzzle
	;

	//alert('DEBUG: EasyMember: solvedPuzzle = ' + solvedPuzzle);

	//alert('DEBUG: EasyMember: window.signMessageBasic= ' + window.signMessageBasic);

	PubKeyShare();

	if (document.compose && document.compose.comment) {
		// we already have a compose form with a comment field, everything is cool
	} else {
		// we need to create a form
		var newForm = document.createElement('form');
		newForm.setAttribute('method', 'GET');
		newForm.setAttribute('action', '/post.html');
		newForm.setAttribute('name', 'compose');
		var newComment = document.createElement('input');
		newComment.setAttribute('name', 'comment');
		newComment.setAttribute('type', 'hidden');
		newForm.appendChild(newComment);
		document.body.appendChild(newForm);
	}

	if (document.compose && document.compose.comment) {
		var signedPuzzle = signMessageBasic(myMessage, document.compose.comment, 'sendSignedMessage()');
		//alert('DEBUG: EasyMember: signedPuzzle = ' + signedPuzzle);
		//comment.value = signedPuzzle;
		//compose.submit();
	} else {
		//alert('DEBUG: EasyMember: warning: form was missing');
		return '';
	}

	return ''; // #todo is this right?
} // afterKeygen()

function sendSignedMessage () {

	//alert('sendSignedMessage()');

	document.compose.submit();
}

/* / easyreg.js */