// == begin voting.js

function PingUrlCallback () {
	var xmlhttp = window.xmlhttp;
	var xmlhttpElement = window.xmlhttpElement;

	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		// alert('DEBUG: PingUrlCallback() found status 200!');

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
		// window.location.replace(xmlhttp.responseURL);
		// document.open();
		// document.write(xmlhttp.responseText);
		// document.close();
		window.xmlhttp = 0;
	} else {
		// alert('DEBUG: PingUrlCallback: warning: unrecognized: xmlhttp.status = ' + xmlhttp.status + '; xmlhttp.readyState = ' + xmlhttp.readyState);
	}
}

function PingUrl (url, ele) { // loads arbitrary url via image or xhr
// compatible with most js
	//alert('DEBUG: PingUrl() begins');

	// another option below
	// var img = document.createElement('img');
	// img.setAttribute("src", url);
	// document.body.appendChild(img);

	if (!ele) {
		ele = 0;
	}

	if (!url) {
		// #todo more sanity here
		//alert('DEBUG: PingUrl: warning: url was FALSE');
		return '';
	}

	//alert('DEBUG: PingUrl: url = ' + url);

	if (window.XMLHttpRequest) {
		//alert('DEBUG: PingUrl: window.XMLHttpRequest was true');

		var xmlhttp;
		if (window.xmlhttp) {
			xmlhttp = window.xmlhttp;
		} else {
			window.xmlhttp = new XMLHttpRequest();
			xmlhttp = window.xmlhttp;
		}

		if (window.GetPrefs && GetPrefs('show_admin')) {
			// skip callback to save resources
		} else {
			xmlhttp.onreadystatechange = window.PingUrlCallback;
		}

		xmlhttp.open("HEAD", url, true);
		//xmlhttp.timeout = 5000; //#xhr.timeout
		xmlhttp.send();

		return false;
	} else {
		//alert('DEBUG: PingUrl: using image method, no xhr here');

		if (document.images) {
			//alert('DEBUG: PingUrl: document.images was true');
			if (document.images.length) {
				// use last image on page, if possible. this should be the special pixel image.
				var img = document.images[document.images.length - 1];

				if (img) {
					img.setAttribute("src", url);
					return false;
				}
			} else {
				var img = document.images[0];

				if (img) {
					img.setAttribute("src", url);
					return false;
				}
			}
		} else {
			//alert('DEBUG: PingUrl: warning: document.images was FALSE');
		}
	}

	return true;
} // PingUrl()

//function OptionsDefault(token, privKeyObj) {
//	this.data = token;
//	this.privateKeys = [privKeyObj];
//}

function signCallback (signed) {
	var url = '/post.html?comment=' + encodeURIComponent(signed.data);

	if (PingUrl(url)) {
		// todo incrememnt counter
	}
}

function IncrementTagLink (t) { // increments number of votes in tag button
// IncrementVoteLink (
// adds a number if there isn't one already
// #todo adapt to accommodate buttons as well

	if (t.innerHTML) {
		// update count in vote link
		//alert('DEBUG: SignVote: t.innerHTML');
		var ih = t.innerHTML;
		if (ih.indexOf('(') == -1) {
			//alert('DEBUG: SignVote: ( not found');
			t.innerHTML = ih + '(1)';
		} else {
			//alert('DEBUG: SignVote: ( found');

			var numVal = ih.substring(ih.indexOf('(') + 1, ih.indexOf(')'));
			var newVal = parseInt(numVal) + 1;
			var hashTag = ih.substring(0, ih.indexOf('('));
			t.innerHTML = hashTag + '(' + newVal + ')';
		}
		//alert('DEBUG: SignVote: finished with t.innerHTML');
	}
}

function SignVote (t, token) { // signs a vote from referenced vote button
// t = reference to calling button's 'this'
// token = full voting token, in the format (gt)(gt)fileHash\n#tag
// where (gt) is a greater-than sign, omitted here
	//alert('DEBUG: SignVote(' + t + ',' + token +')');

	if (
		t.nextSibling &&
		t.nextSibling.tagName &&
		t.nextSibling.getAttribute &&
		t.nextSibling.getAttribute('class') == 'notification'
	) {
		// removes a notification if it is immediately afer this button
		t.nextSibling.remove();
	}

	if (window.xmlhttp) {
		//only allow one vote a time to be happening
		//unless user is operator

		if (GetPrefs('show_admin')) {
			// continue
		} else {
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
		//	    	document.images[0].src = '/post.html?mydomain=' + myUrl;
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
