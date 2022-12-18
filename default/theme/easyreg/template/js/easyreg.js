/* easyreg.js */

function EasyMember (t) {
	var compose;
	var comment;
	var myFp;

//	if (t && t.value) {
//		t.value = 'Meditate...';
//		setTimeout('EasyMember', 100);
//		return false;
//	}
//
	myFp = getUserFp();
	if (!myFp) {
		var keySuccess = MakeKey();
		myFp = getUserFp();
	}

	//alert('DEBUG: EasyMember: myFp = ' + myFp);

	solvedPuzzle = getSolvedPuzzle(myFp, '1337', 10, 1000000);

	//alert('DEBUG: EasyMember: solvedPuzzle = ' + solvedPuzzle);

	//alert('DEBUG: EasyMember: window.signMessageBasic = ' + window.signMessageBasic);

	var signedPuzzle = signMessageBasic(solvedPuzzle);

	//alert('DEBUG: EasyMember: signedPuzzle = ' + signedPuzzle);

	//comment.value = signedPuzzle;

	//compose.submit();

	return false;
}

/* / easyreg.js */