// == begin voting.js

function PingUrlCallback () {
	var xmlhttp = window.xmlhttp;
	var xmlhttpElement = window.xmlhttpElement;

	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		//alert('DEBUG: PingUrlCallback() found status 200!');

		if (xmlhttpElement) {
			var elemOK = document.createElement('span');
			//elemOK.setAttribute('disabled', true);
			elemOK.innerHTML = '&check;'; // checkmark
			//#todo: get rect, and check if it is too wide,
			//   which means escaped char didn't work
			//   and should be replaced (ff 3.x, camino)
			//elemOK.innerHTML = 'OK';
			xmlhttpElement.setAttribute('disabled', true);
			xmlhttpElement.appendChild(elemOK);
		}

		//if (xmlhttp.responseURL.indexOf('message') != -1) {
			// this works, but is not always desirable.
			// it should happen from a page reprint request #todo
			//window.location.replace(xmlhttp.responseURL);
		//}

		//if (xmlhttp.responseUrl.indexOf('message') != -1) {
			//window.location.replace(xmlhttp.responseURL);
		//}

		// this is very janky but has potential
		// document.open();
		// document.write(xmlhttp.responseText);
		// document.close();

		window.xmlhttp = 0;
	}
	//else if (xmlhttp.readyState == 4 && xmlhttp.status == 303) {
	//} // could be useful in the future
	else if (xmlhttp.readyState == 4 && xmlhttp.status == 401) {
		// server returned 401, which most likely means that we need a cookie
		// redirect user to profile.html page so that they can register
		// this is very basic, jarring, and unfriendly, but it is better than failing silently
		// relative links setting should also be taken into account
		// #todo
		window.location = '/session.html'; // #todo relativize
	}
	else {
		//alert('DEBUG: PingUrlCallback: warning: unrecognized: xmlhttp.status = ' + xmlhttp.status + '; xmlhttp.readyState = ' + xmlhttp.readyState);
	}
}

//function OptionsDefault(token, privKeyObj) {
//	this.data = token;
//	this.privateKeys = [privKeyObj];
//}

function signCallback (signed) {
	var postUrl = '/post.html';
	var url = postUrl + '?comment=' + encodeURIComponent(signed.data);

	if (PingUrl(url)) {
		// todo incrememnt counter
	}
}

function IncrementTagLink (t) { // increments number of votes in tag button
// function IncrementVoteLink () {
// function AddVote () {
// adds a number if there isn't one already
// #todo adapt to accommodate buttons as well

	if (!t) {
		// if t is missing, return true, so that click event can go through
		//alert('DEBUG: IncrementTagLink: warning: t is missing');
		return true;
	}

	if (t.innerHTML) {
		// update count in vote link
		//alert('DEBUG: IncrementTagLink: t.innerHTML');
		var ih = t.innerHTML;
		if (ih.indexOf('(') == -1) {
			// there is no count yet, add a 1
			//alert('DEBUG: IncrementTagLink: ( not found');
			t.innerHTML = ih + '(1)';
		} else {
			// there is a count already, increment it
			//alert('DEBUG: IncrementTagLink: ( found');

			var numVal = ih.substring(ih.indexOf('(') + 1, ih.indexOf(')'));
			var newVal = parseInt(numVal) + 1;
			var hashTag = ih.substring(0, ih.indexOf('('));
			t.innerHTML = hashTag + '(' + newVal + ')';
		}

		var voteValue = t.innerHTML.substring(0, t.innerHTML.indexOf('('));

		//alert('DEBUG: IncrementTagLink: voteValue = "' + voteValue + '"');

		//alert('DEBUG: IncrementTagLink: finished with t.innerHTML');

		return false;
	} // if (t.innerHTML)

	return true;
} // IncrementTagLink()

function SignVote (t, token) { // signs a vote from referenced vote button
// t = reference to calling button's 'this'
// token = full voting token, in the format (gt)(gt)fileHash\n#tag
// where (gt) is a greater-than sign, omitted here

// function SendVote () {
// function StoreVote () {
// function SaveVote () {

	//alert('DEBUG: SignVote(' + t + ',' + token +')');

	if (
		t.nextSibling &&
		t.nextSibling.tagName &&
		t.nextSibling.getAttribute &&
		t.nextSibling.getAttribute('class') == 'notification'
	) {
		// removes a notification if it is immediately afer this button
		if (t.nextSibling.remove) {
			// #todo there is a bug here, somehow remove() isn't always there
			t.nextSibling.remove();
		}
	}

	if (window.xmlhttp) {
		//only allow one vote a time to be happening
		//unless user is operator

		if (GetPrefs('show_admin')) {
			// user has assumed operator role, continue without check
		} else {
			// user has not assumed operator role,
			// show notification and cancel vote
			if (window.displayNotificationWithTimeout) {
				displayNotificationWithTimeout('Too fast', t);
			}
			return false;
		}
	}


	if (document.getElementById) {
	// basic dumb feature check #todo make smarter feature check ;
	// needs better compatibility for older browsers
		// get private key

		if (!GetPrefs('show_admin') && GetPrefs(token)) {
			// don't let user vote twice -- basic version
			// the token we'd send to vote is stored as the key to a preference setting
			// #todo this could be nicer?
			// doesn't apply if user is showing operator controls
			if (window.displayNotificationWithTimeout) {
				window.duplicateVoteTries ? window.duplicateVoteTries++ : window.duplicateVoteTries = 1;
				if (3 <= window.duplicateVoteTries) {
					// display alternative message if user has tried to duplicate-vote 3 or more times
					displayNotificationWithTimeout('Hey!', t);
				} else {
					displayNotificationWithTimeout('Already voted', t);
				}
			} else {
				//alert('DEBUG: window.displayNotificationWithTimeout() was missing');
			}

			// returning false will keep the link from navigating to non-js fallback
			return false;
		}

		IncrementTagLink(t);

		var privkey = 0; //also serves as feature check flag, sorry
		if (window.getPrivateKey && window.openpgp) {
			var privkey = getPrivateKey();
		}

		//alert('DEBUG: SignVote: privkey: ' + !!privkey);

		window.xmlhttpElement = t;
		
		if (GetPrefs('show_admin') || !privkey) {
			//alert('DEBUG: !privkey');
			// if there is no private key, just do a basic unsigned vote;

			// if user is operator, they also do this for faster voting

			if (PingUrl(t.href)) {
				return false;
			}
		} else {
			// there is a private key
			//alert('DEBUG: privkey is true');

			// load the private key into openpgp
			var privKeyObj = openpgp.key.readArmored(privkey).keys[0];
			var options;
			options = new Object();
			options.data = token;
			options.privateKeys = privKeyObj;
			openpgp.config.show_version = false;
			openpgp.config.show_comment = false;

			// sign the voting token and send to post.html when finished
			openpgp.sign(options).then(signCallback);
		}

		// remember that we voted for this already
		SetPrefs(token, 1);

		if (window.displayNotification) {
			// displayNotification('Success!', t);
		} else {
			//alert('DEBUG: window.displayNotification() was missing');
		}

		return false; // cancel link click-through
	} else {
		//	    if (document.images) {
		//	        var myUrl = window.location;
		//	        var postUrl = '/post.html';
		//	    	document.images[0].src = postUrl + '?mydomain=' + myUrl;
		//
		//	    	//alert('DEBUG: t = ' + t);
		//
		//	    	return false;
		//	    }
	}

	//alert('DEBUG: SignVote: warning: fall-through');

	return true; // allow link click to happen
} // SignVote()

// == end voting.js
