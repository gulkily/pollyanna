// puzzle.js

if (document.createElement && document.head) {
// include sha512.js library instead of embedding it in page
// because it's big and contains (gt) characters
// and because it is large
	var script = document.createElement('script');
	script.src = '/sha512.js';
	script.async = false; // This is required for synchronous execution
	document.head.appendChild(script);
}

function getSolvedPuzzle (userFp, desiredPrefix, timeLimit, iterationLimit) {

	// userFp example: ABCDEF0123456789
	// desiredPrefix example: 1337
	// timeLimit example: 15
	// iterationLimit example: 1000000

	var i = 0; // counts iterations
	var done = 0; // done status

	var r = 0 + ''; // stores random number as string
	var lookingFor = desiredPrefix; // required hash prefix
	var lookingForLength = lookingFor.length;
	var cycleLimit = iterationLimit; // give up after this many tries
	var secondsLimit = time; // give up after this many seconds
	var puzzle = ''; // finished puzzle
	var fp = userFp;

	var hash = ''; // starting salt provided by server

	var puzzleResult = '';

	var d = new Date();
	var epochStart = d.getTime();
	epochStart = Math.ceil(epochStart / 1000); // current time in epoch format

	while(done < 1) {
		var d = new Date();
		var epoch = d.getTime();
		epoch = Math.ceil(epoch / 1000); // current time in epoch format

		// look for a puzzle which fits criteria
		i = i + 1; // counter
		r = Math.random() + '';

		puzzle = fp + ' ' + epochStart + ' ' + r;
		hash = hex_sha512(puzzle);

		if (hash.substring(0, lookingForLength) == lookingFor) {
			// match found
			puzzleResult = puzzleResult + puzzle + "\n";
			done++;
		}
		if (cycleLimit < i) {
			// give up
			done = 100;
		}
		if (epochStart + secondsLimit < epoch) {
			done = 100;
		}
	} // while(!done) -- solving puzzle

	if (puzzleResult) {
		return puzzleResult;
	} else {
		return '';
	}
}

function doSolvePuzzle () { // solves puzzle
	// called from a timeout set by solvePuzzle()
	/*
	depends on the following:
	=========================
	window.WriteSubmit() is called after
	document.getElementById('btnSolvePuzzle') caption is changed
	document.compose is a form
		if it is not found, looks for frmSession
	document.compose.comment is a textarea that's appended to
	window.getUserFp() is used to get user's fingerprint
	*/

	if (!window.WriteSubmit) {
		//alert('DEBUG: warning: missing window.WriteSubmit');
	}
	if (!document.getElementById('btnSolvePuzle')) {
		//alert('DEBUG: warning: btnSolvePuzzle missing');
	}
	if (!document.compose) {
		//alert('DEBUG: warning: document.compose missing');
	}
	if (!document.compose.comment) {
		//alert('DEBUG: warning: document.compose.comment missing');
	}
	if (!window.getUserFp) {
		//alert('DEBUG: warning: window.getUserFp missing');
	}

	var fp = '0000000000000000';
	if (window.getUserFp) {
		fp = getUserFp();
	}
	// user's fp or default to 000

	var d = new Date();
	var epochStart = d.getTime();
	epochStart = Math.ceil(epochStart / 1000); // current time in epoch format

	var txtComment = '';
	if (document && document.compose && document.compose.comment) {
		txtComment = document.compose.comment;
	}

	var lookingFor = '1337'; // this line is updated by InjectJs()
	var cycleLimit = 1000000; // this line is updated by InjectJs()
	var secondsLimit = 10; // this line is updated by in InjectJs()
	var promptForPrefix = 0; // this line is templated by InjectJs()

	if (promptForPrefix) {
		var userPrefix = prompt('Prefix:', (lookingFor ? lookingFor : ''));
	} else {
		var userPrefix = lookingFor;
	}
	if (userPrefix) { // #todo sanity check
		lookingFor = userPrefix;
	}

	var puzzleResult = getSolvedPuzzle(fp, lookingFor, secondsLimit, cycleLimit); // #todo this should be templated?

	// add to compose form, sign, and submit
	//var txtComment = document.compose.comment; // dupe from above
	if (txtComment && window.solvePuzzle) {
		if (puzzleResult) {
			//
			if (txtComment.value.substr(txtComment.value.length - 2, 2) == "\n\n") {
				txtComment.value += puzzleResult;
			} else {
				if (txtComment.value.substr(txtComment.value.length - 1, 1) == "\n") {
					txtComment.value += "\n" + puzzleResult;
				} else {
					txtComment.value += "\n\n" + puzzleResult;
				}
			}
		}
	}

	var btnSolvePuzzle = document.getElementById('btnSolvePuzzle');
	if (window.signMessage) {
		if (btnSolvePuzzle) {
			btnSolvePuzzle.value = 'Signing...';
		}
		signMessage();
	}
	if (window.WriteSubmit) {
		WriteSubmit();
		if (btnSolvePuzzle) {
			btnSolvePuzzle.value = 'Sending...';
		}
	}
} // doSolvePuzzle()

function solvePuzzle (t) { // t = button pressed ; begins puzzle solving process and indicates to user
// done with timeout to give button a chance to change caption before pegging cpu

	if (!window.hex_sha512 || !window.doSolvePuzzle) {
		// required function is missing
		return true;
	}
	if (t) {
		// update button caption
		t.value = 'Solving...';
	}

	// set timeout to solve puzzle... i forget why it has to be done this way, but this should be documented #todo
	var timeoutSolvePuzzle = setTimeout('doSolvePuzzle()', 500);

	return false; // do not let the calling form submit, doSolvePuzzle() will do it
} // solvePuzzle()

// / puzzle.js
