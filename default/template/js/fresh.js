// == begin fresh.js
var freshClient;

function freshCallback() { // callback for requesting HEAD for current page
	//alert('DEBUG: freshCallback() this.readyState = ' + this.readyState);

	if (
		document.getElementById &&
		this.readyState == this.HEADERS_RECEIVED ||
		this.status == 200
	) { // headers received -- what we've been waiting for
		//alert('DEBUG: freshCallback() this.readyState == this.HEADERS_RECEIVED');

		var eTag = freshClient.getResponseHeader("ETag"); // etag header contains page 'fingerprint'

		if (!eTag) {
			if (window.myOwnETag) {
				//alert('DEBUG: fresh.js: freshCallback: warning: eTag is FALSE; setting to equal myOwnETag');
				eTag = window.myOwnETag;
			} else {
				//alert('DEBUG: fresh.js: freshCallback: warning: eTag is FALSE; and myOwnETag is also FALSE');
			}
		}

		//alert('DEBUG: fresh.js: freshCallback: eTag = ' + eTag);

		if (eTag) { // if ETag header has a value
			if (window.myOwnETag) {
				//alert('DEBUG: fresh.js: freshCallback: eTag = ' + eTag + '; window.myOwnETag = ' + window.myOwnETag);
				if (eTag != window.myOwnETag) {
					if (eTag == window.lastEtag) { // if it's equal to the one we saved last time
						// no new change change
					} else {
						var freshUserWantsReload = 0;  // templated

						if (freshUserWantsReload) {
							// user wants reload
							//alert('DEBUG: fresh.js: freshCallback: user wants automatic page reload');
							location.reload();
						} else {
							// user doesn't want reload, just show notification
							//alert('DEBUG: fresh.js: freshCallback: user does not want automatic page reload, notify');
							window.lastEtag = eTag;

							var ariaAlert;
							ariaAlert = document.getElementById('ariaAlert');

							if (!ariaAlert) {
								//alert('DEBUG: fresh.js: freshCallback: ariaAlert created successfully');
								ariaAlert = document.createElement('p');
								ariaAlert.setAttribute('role', 'alert');
								ariaAlert.setAttribute('id', 'ariaAlert');
								ariaAlert.style.zIndex = '1337'; //#todo

								var txtUpdated = document.createTextNode('Page updated ');
								ariaAlert.appendChild(txtUpdated);

								//document.body.appendChild(ariaAlert);
								document.body.insertBefore(ariaAlert, document.body.firstChild);
								//window.newPageContent =
								//FetchNewPageContent(window.mypath + '?' + new Date().getTime());

								//ariaAlert.innerHTML = ariaAlert.innerHTML + '+';
								var d = new Date();
								var n = d.getTime();
								n = Math.ceil(n / 1000);

								var space = document.createElement('span');
								space.innerHTML = ' ';
								ariaAlert.appendChild(space);

								var a = document.createElement('a');
								a.setAttribute('id', 'freshAria');
								a.setAttribute('href', '#');
								a.setAttribute('onclick', 'location.reload()');
								ariaAlert.appendChild(a);

								var newTs = document.createElement('span');
								newTs.setAttribute('class', 'timestamp');
								newTs.setAttribute('epoch', n);
								newTs.setAttribute('id', 'freshTimestamp');
								newTs.innerHTML = 'just now!';
								a.appendChild(newTs);
							} // !ariaAlert

							if (window.freshTimeoutId) {
								clearTimeout(window.freshTimeoutId);
							}
							//window.eventLoopFresh = 0; // stop checking for updates

							if (document.title.substring(0, 2) != '! ') {
								document.title = '! ' + document.title;
							}
						} // NOT freshUserWantsReload
					} // lastEtag also didn't match
				} // eTag != window.myOwnETag
				else {
					//document.title = 'freshCallback: x ' + window.myOwnETag + ';' + new Date().getTime();
					if (window.freshTimeoutId) {
						clearTimeout(window.freshTimeoutId);
					}
					window.freshTimeoutId = setTimeout('CheckIfFresh()', 15000);
				}
			} // if (window.myOwnETag)
			else {
				window.myOwnETag = eTag;
			}
		} // if (eTag) // ETag header has value
	} // status == 200
	if (this.status == 404 && document.getElementById) {
		//alert('DEBUG: fresh.js: freshCallback: page has gone away on server (404)');
		var ariaAlert;
		ariaAlert = document.getElementById('ariaAlert');
		if (!ariaAlert) {
			//alert('DEBUG: fresh.js: freshCallback: ariaAlert not found on page, creating...');
			ariaAlert = document.createElement('p');
			ariaAlert.setAttribute('role', 'alert');
			ariaAlert.setAttribute('id', 'ariaAlert');
			ariaAlert.style.zIndex = '1337'; //#todo
			ariaAlert.innerHTML = 'Page was deleted from server.';

			//document.body.appendChild(ariaAlert);
			document.body.insertBefore(ariaAlert, document.body.firstChild);
		}
		// window.eventLoopFresh = 0; // stop checking for updates
	} // status == 404

	return true;
} // freshCallback()

function CheckIfFresh () {
	var d = new Date();
	//alert('DEBUG: CheckIfFresh: ' + d.getTime());

	var freshCheckRecent = window.freshCheckRecent;
	if (freshCheckRecent) {
		//alert('DEBUG: CheckIfFresh: freshCheckRecent = ' + freshCheckRecent);
		var d = new Date();
		var curTime = d.getTime();
		if (curTime < freshCheckRecent + 3000) {
			return true;
		}
	}
	//alert('DEBUG: CheckIfFresh: checkpoint passed');

	var d = new Date();
	window.freshCheckRecent = d.getTime();

	var xhr = null;
	if (window.XMLHttpRequest){
		xhr = new XMLHttpRequest();
	}
	else {
		if (window.ActiveXObject) {
			xhr = new ActiveXObject("Microsoft.XMLHTTP");
		}
	}

	if (xhr) {
		var mypath = window.mypath;

		if (!mypath) {
			mypath = window.location;
			window.mypath = mypath;
		}


		freshClient = xhr;

		if (0 && mypath.toString().indexOf('?') == -1) {
			// NO question mark (or params)
			// cachebuster
			// this ensures no caching, but may cause other problems
			// q: what problems?
			freshClient.open("HEAD", mypath + '?' + d.getTime(), true);
		} else {
			// below we strip the page arguments if they begin with ?message=

			if (mypath.toString().indexOf('?message=') == -1) {
				// leave it
				freshClient.open("HEAD", mypath, true);
			} else {
				// remove the parameters
				mypath = mypath.toString().substr(0, mypath.toString().indexOf('?message='));
				freshClient.open("HEAD", mypath, true);
			}
		}

		//freshClient.timeout = 5000; //#xhr.timeout
		freshClient.setRequestHeader('Cache-Control', 'no-cache');
		freshClient.onreadystatechange = freshCallback;

		freshClient.send();
	}

	return true;
} // CheckIfFresh()

//alert('DEBUG: fresh.js');

if (window.EventLoop) {
	if (!window.GetPrefs) {
		// if no prefs, enable it
		window.eventLoopEnabled = 1;
		window.eventLoopFresh = 1;
	}
	
	EventLoop();
} else {
	CheckIfFresh();
}

// == end fresh.js
