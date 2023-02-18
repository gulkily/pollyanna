// == begin utils.js

// begin html escape hack (credit stacko)
// only works with createElement #backlog
if (document.createElement) {
	var escapeTA = document.createElement('textarea');
}
function escapeHTML (html) {
	if (window.escapeTA) {
		escapeTA.textContent = html;
		return escapeTA.innerHTML;
	}
} // escapeHTML()
function unescapeHTML (html) {
	if (window.escapeTA) {
		escapeTA.innerHTML = html;
		return escapeTA.textContent;
	}
} // unescapeHTML()
// end html escape hack
//#todo above hack seems to be broken, because escapeTA is not global?

function LogWarning (text) {
	if (text.indexOf('warning') != -1) {
		var hasLogger = !!(window.console && window.console.log);
		if (hasLogger) {
			console.log(text);
		} else {
			if (document && document.title) {
				document.title = text;
			}
		}
	}
} // LogWarning()

function OnLoadEverything () { // checks for each onLoad function and calls it
// function OnLoadAll () {
// function BodyOnLoad () {
// body onload body.onload
// function OnLoad {
// typically called from body.onload
	//alert('DEBUG: OnLoadEverything() begins');

	if ((window.addLoadingIndicator) && (!window.loadingIndicator)) {
		//alert('DEBUG: OnLoadEverything: addLoadingIndicator()');
		addLoadingIndicator('Meditate...');
	} else {
		//alert('DEBUG: OnLoadEverything: (window.addLoadingIndicator) is FALSE');
	}

	if (window.setClock) {
		//alert('DEBUG: OnLoadEverything: setClock()');
		window.eventLoopSetClock = 1;
		setClock();
	}
	if (window.ItsYou) {
		//alert('DEBUG: OnLoadEverything: ItsYou()');
		ItsYou();
	}
	if (window.ShowTimestamps) {
		//alert('DEBUG: OnLoadEverything: ShowTimestamps()');
		window.eventLoopShowTimestamps = 1;
		ShowTimestamps();
	}
	if (window.SettingsOnload) {
		//alert('DEBUG: OnLoadEverything: SettingsOnload()');
		SettingsOnload();
	}
	if (window.ProfileOnLoad) {
		//alert('DEBUG: OnLoadEverything: ProfileOnLoad()');
		ProfileOnLoad();
	}
	if (window.WriteOnload) {
		//alert('DEBUG: OnLoadEverything: WriteOnload()');
		WriteOnload();
	}

	if (window.ShowAdvanced) {
		//alert('DEBUG: OnLoadEverything: ShowAdvanced()');
		window.eventLoopShowAdvanced = 1;
		ShowAdvanced(0, 0);
	}
	//alert('DEBUG: OnLoadEverything: ShowAdvanced() finished!');

	if (window.SearchOnload) {
		//alert('DEBUG: OnLoadEverything: SearchOnload()');
		SearchOnload();
	}

	if (window.DesktopOnLoad) {
		//alert('DEBUG: OnLoadEverything: DesktopOnLoad()');
		DesktopOnLoad();
	}

	if (window.UploadAddImagePreviewElement) {
		//alert('DEBUG: OnLoadEverything: UploadAddImagePreviewElement()');
		UploadAddImagePreviewElement();
	}

	//alert('DEBUG: OnLoadEverything: checking for editable field...');

	if (window.location && document.compose && window.location.href.indexOf) {
		if (
			window.location &&
			window.location.href &&
			window.location.href.indexOf('write') != -1 ||
			window.location.hash.indexOf('reply') != -1 ||
			(
				window.location.href.indexOf('message') != -1 &&
				window.GetPrefs &&
				GetPrefs('focus_reply')
			)
				&&
			document.compose &&
			document.compose.comment &&
			document.compose.comment.focus
		) {
			//alert('DEBUG: OnLoadEverything: document.compose.comment.focus()()');
			document.compose.comment.focus();
		}
	}

	if (window.location.href && (window.location.href.indexOf('search') != -1) && document.search.q) {
		//alert('DEBUG: OnLoadEverything: document.search.q.focus()');
		document.search.q.focus();
	}

	if (0 && window.localStorage) { // #todo improve crumbs
		var crumbs1 = localStorage.getItem('crumbs');
		if (crumbs1) {
			crumbs1 = crumbs1 + '\n' + window.location.href;
			localStorage.setItem('crumbs', crumbs1);
		} else {
			localStorage.setItem('crumbs', window.location.href);
		}
	}

	if (window.EventLoop) {
		//alert('DEBUG: OnLoadEverything: EventLoop()');
		if (window.CheckIfFresh) {
			window.eventLoopFresh = 1;
		}
		window.eventLoopEnabled = 1;
		EventLoop();
	}

	// FetchDialog('help');

	if (window.DraggingInit && GetPrefs('draggable')) {
		//alert('DEBUG: OnLoadEverything: DraggingInit()');
		if (window.location.href.indexOf('settings') != -1) {
			// exclude settings page to avoid difficult situations
			// one day, it will no longer be necessary
			DraggingInit(1);
		} else {
			DraggingInit(1);
		}
	} else {
		if (document.getElementById) {
			// this gets rid of the style which hides dialogs on
			// page load so that they can be positioned first
			// dragging_hide_dialogs.js
			// #todo optimize this
			if (document.getElementById('styleHideDialogs')) {
				UnhideHiddenElements();
			}
		}
	}

	if (window.HideLoadingIndicator) {
		//alert('DEBUG: OnLoadEverything: HideLoadingIndicator()');
		HideLoadingIndicator();
	}

	// everything is set now, start event loop
	//
} // OnLoadEverything()

if (!window.performanceOptimization && window.GetPrefs) {
	// if performanceOptimization setting hasn't been initialized yet,
	// and we have a way to do it via GetPrefs() go ahead and do it now
	window.performanceOptimization = GetPrefs('performance_optimization'); // utils.js
}

function EventLoop () { // for calling things which need to happen on a regular basis
// sets another timeout for itself when done
// replaces several independent timeouts
// #backlog add secondary EventLoopWatcher timer which ensures this one runs when needed

	var d = new Date();
	var eventLoopBegin = d.getTime(); // eventLoopStart

	if (!window.eventLoopPrevious) {
		window.eventLoopPrevious = 1;
	}
	window.eventLoopBegin = eventLoopBegin;

	if (window.GetPrefs && GetPrefs('draggable') && window.innerWidth && window.innerHeight) {
		// if viewport size has changed, retile dialogs
		if (!window.rememberInnerWidth) {
			window.rememberInnerWidth = window.innerWidth;
		}
		if (!window.rememberInnerHeight) {
			window.rememberInnerHeight = window.innerHeight;
		}
		if (window.rememberInnerWidth != window.innerWidth || window.rememberInnerHeight != window.innerHeight) {
			//alert('DEBUG: window.innerWidth = ' + window.innerWidth + ', window.innerHeight = ' + window.innerHeight);
			window.rememberInnerWidth = window.innerWidth;
			window.rememberInnerHeight = window.innerHeight;
			if (window.DraggingRetile) {
				DraggingRetile();
			}
		}
	}

	if (window.FetchDialog) {
		// #todo this may not be the best place for this code
		var welcomeSeen = GetPrefs('welcome_seen');
		// try to show this only once
		if (welcomeSeen) {
			if (welcomeSeen == 2) {
				SetPrefs('welcome_seen', 3);
				//FetchDialog('welcome');
				//alert('welcome!');
			} else {
				if (welcomeSeen == 1) {
					SetPrefs('welcome_seen', 2);
				}
				// verify it can be read and updated
			}
		} else {
			SetPrefs('welcome_seen', 1);
			// verify it can be set
		}
	}

	if (window.eventLoopSetClock && window.setClock) {
		// update time displayed in clock
		setClock();
	}

	var m = 500; // multiplier for performance thresholds
	if (window.performanceOptimization) {
		if (window.performanceOptimization == 'quicker') {
			m = 100;
		}
		if (window.performanceOptimization == 'none') {
			// this is the 'None' setting in Settings
			m = 0;
			return '';
		}
	}

	//alert('DEBUG: EventLoop: eventLoopBegin = ' + eventLoopBegin + ' - window.eventLoopPrevious = ' + window.eventLoopPrevious + ' = ' + (eventLoopBegin - window.eventLoopPrevious));

	if (10*m < (eventLoopBegin - window.eventLoopPrevious)) {
		// ACTUAL EVENT LOOP WORK BEGINS
		// ACTUAL EVENT LOOP WORK BEGINS
		// ACTUAL EVENT LOOP WORK BEGINS

		window.eventLoopPrevious = eventLoopBegin; // store begin time

		if (window.flagUnloaded) {
			// show loading indicator if user has started navigating away from page
			// window.flagUnloaded is set by OnUnload event
			if (window.ShowPreNavigateNotification) {
				ShowPreNavigateNotification();
			}
		}

		//return;
		// uncomment to disable event loop
		// makes js debugging easier

		if (window.eventLoopShowTimestamps && window.ShowTimestamps) {
			// update timestamp widgets on page
			if (13*m < (eventLoopBegin - window.eventLoopShowTimestamps)) {
				// only every 13 seconds in regular performance mode
				ShowTimestamps();
				window.eventLoopShowTimestamps = eventLoopBegin;
			} else {
				// do nothing
			}
		}

		if (window.eventLoopDoAutoSave && window.DoAutoSave) {
			// autosave
			if (5*m < (eventLoopBegin - window.eventLoopDoAutoSave)) { // autosave interval
				// autosave every 5 seconds in normal performance mode
				DoAutoSave();
				window.eventLoopDoAutoSave = eventLoopBegin;
			} else {
				// do nothing
			}
		}

		if (window.localStorage && document.getElementById) {
			// update reply cart dialog displayed count
			// #todo move this to separate module
			if (window.ReplyCartUpdateCount) {
				ReplyCartUpdateCount();
			}
		}

		if (window.eventLoopShowAdvanced && window.ShowAdvanced) {
			// update visibility of advanced/beginner layers
			// but only if necessary
			ShowAdvanced(0, 0);
		}

		if (window.eventLoopFresh && window.CheckIfFresh) {
			// check for page changes by sending a HEAD request for current url
			if (10000 < (eventLoopBegin - window.eventLoopFresh)) {
			//if (10*m < (eventLoopBegin - window.eventLoopFresh)) {
			// this is commented because it may hammer the server. uncomment if using localhost

				//window.eventLoopFresh = eventLoopBegin;
				if (
					window.eventLoopFresh &&
					(!window.GetPrefs || GetPrefs('notify_on_change'))
				) {
					// notify_on_change client-side setting needs to be on
					CheckIfFresh();
					window.eventLoopFresh = eventLoopBegin;
				}
			}
		}

		if (
			(window.UpdateDialogList) &&
			(document.getElementById) &&
			(document.getElementsByClassName)
		) {
			// update list of dialogs on page
			UpdateDialogList();
		}

		if (window.GetPrefs) {
			// if performance setting has changed in another window, update it here too
			window.performanceOptimization = GetPrefs('performance_optimization'); // EventLoop()
		}
	} // 10000 < (eventLoopBegin - window.eventLoopPrevious)

	if (window.eventLoopEnabled) {
		// set the next setTimeout for the next "loop" iteration

		// see how long this last iteration took
		var d = new Date();
		var eventLoopEnd = d.getTime();
		var eventLoopDuration = eventLoopEnd - eventLoopBegin;
		//document.title = eventLoopDuration; // for debugging performance

		// unset any timeout if already set
		if (window.timeoutEventLoop) {
			clearTimeout(window.timeoutEventLoop);
		}

		if (30 < eventLoopDuration) {
			// if loop went longer than 100ms, run every 3 seconds or more
			//document.title = eventLoopDuration;
			
			if (GetPrefs('notify_event_loop')) {
				displayNotification('EventLoop: ' + eventLoopDuration + 'ms');
			}
//
//			// #todo make it known to user that hitting performance limit
//			if (document.title.substr(0,3) != '/ ') {
//				// for now we just prepend the title with a slash
//				document.title = '/ ' + document.title;
//			}

			// set performance setting to 'faster'

			//SetPrefs('performance_optimization', 'faster');
			eventLoopDuration = eventLoopDuration * 10;
		} else {
			// otherwise run again after 1 interval time
			eventLoopDuration = 1*m;
		}

		window.timeoutEventLoop = setTimeout('EventLoop()', eventLoopDuration);
	} // window.eventLoopEnabled

	return '';

} // EventLoop()

function UrlExists (url) { // checks if url exists
// #todo use async
// #todo Q: how to do pre-xhr browsers? A: use img.src = and check the resulting image url

	//alert('DEBUG: UrlExists(' + url + ')');

	if (window.XMLHttpRequest) {
		//alert('DEBUG: UrlExists: window.XMLHttpRequest check passed');

		var http = new XMLHttpRequest();
		http.open('HEAD', url, false);
		//http.timeout = 5000; //#xhr.timeout
		http.send();
		var httpStatusReturned = http.status;

		//alert('DEBUG: UrlExists: httpStatusReturned = ' + httpStatusReturned);

		return (httpStatusReturned == 200);
	}
} // UrlExists()

function DisplayStatus (status) {
// #todo this doesn't seem to be used anywhere yet
	if (document.getElementById) {
		var statusBar = document.getElementById('status');
		// #todo finish this
	}
} // DisplayStatus()

function DownloadAsTxt (filename, text) {
	var element = document.createElement('a');

	element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
	element.setAttribute('download', filename);

	element.style.display = 'none';
	document.body.appendChild(element);

	element.click();

	document.body.removeChild(element);
} // DownloadAsTxt()

function displayNotificationWithTimeout (strMessage, thisButton) {
	var spanNotification = displayNotification(strMessage, thisButton);

	if (spanNotification) {
		var d = new Date();
		var spanId = d.getTime();
		spanNotification.setAttribute('id', spanId);
		setTimeout('document.getElementById(' + spanId + ').remove()', 5000);

		return spanNotification;
	}
} // displayNotificationWithTimeout()

function displayNotification (strMessage, thisButton) { // adds notification to page
// function progressIndicator () { // progress indicator
// function showNotification () (
// used for loading indicator bar (to top of page, depending on style)
// also used for "creating profile" and "already voted" notifications
	var spanNotification = document.createElement('span');
	spanNotification.setAttribute('class', 'notification');
	spanNotification.setAttribute('role', 'alert');
	spanNotification.setAttribute('onclick', 'this.remove(); return false;');
	spanNotification.innerHTML = strMessage;
	spanNotification.style.zIndex = GetFineTime();

	if (window.GetPrefs && GetPrefs('draggable')) {
		thisButton = 0;
		// #todo this is a workaround for floating notification being messed up in draggable mode
	}

	if (thisButton) {
		thisButton.parentNode.appendChild(spanNotification);
		if (thisButton.after) {
			thisButton.after(spanNotification);
		}

		// set element's position based on its initial box model position
		var rect = spanNotification.getBoundingClientRect();
		spanNotification.style.top = (rect.top) + "px";
		spanNotification.style.left = (rect.left) + "px";
		spanNotification.style.position = 'absolute';

		return spanNotification;
	} else {
		// #todo this should be in stylesheet; floating notification should have different class
		spanNotification.style.position = 'fixed';
		spanNotification.style.top = '0';
		spanNotification.style.right = '0';
		spanNotification.style.margin = '0';

		document.body.appendChild(spanNotification);

		return spanNotification;
	}
} // displayNotification()

function newA (href, target, innerHTML, parent) { // makes new a element and appends to parent
	var newLink = document.createElement('a');
	if (href) { newLink.setAttribute('href', href); }
	if (target) { newLink.setAttribute('target', target); }
	if (innerHTML) { innernewLink.setAttribute('innerHTML', innerHTML); }
	parent.appendChild(newLink);
	return newLink;
} // newA()

function SetCookie (cname, cvalue, exdays) { // set cookie
	//alert('DEBUG: SetCookie(' + cname + ', ' + cvalue + ', ' + exdays + ')');
	var d = new Date();
	if (!exdays) {
		exdays = 1;
	}
	d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
	var expires = "expires=" + d.toUTCString();
	document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	var testSetCookie = GetCookie(cname);
	if (cvalue == testSetCookie) {
		return 1;
	} else {
		return 0;
	}
} // SetCookie()

function GetCookie (cname) { // get cookie value
	// in js, cookies are accessed via one long string of the form
	// key1=value1; key2=value2;
	// so we make an array, splitting the string using the ; separator
	if (document.cookie && document.cookie.split) {
		//todo add support for ie3, which does not have a split() method on strings
		var dc = document.cookie;
		var ca = dc.split(';');

		// the value we are looking for will be prefixed with cname=
		var name = cname + "=";

		for(var i = 0; i < ca.length; i++) {
			// loop through ca array until we find prefix we are looking for
			var c = ca[i];
			while (c.charAt(0) == ' ') {
				// remove any spaces at beginning of string
				c = c.substring(1);
			}
			if (c.indexOf(name) == 0) {
				// if prefix matches, return value
				return c.substring(name.length, c.length);
			}
		}
	}

	// at this point, nothing left to do but return empty string
	return "";
} // GetCookie()

function GetParentElement (el, parentTagName) {
// #todo maybe make this more flexible?
	if (el) {
		var parentElement = el;
		while (parentElement && (parentElement.tagName != parentTagName)) {
			parentElement = parentElement.parentElement;
		}
		if (parentElement) {
			return parentElement;
		}
	}
	return '';
} // GetParentElement()

function UnmaskBlurredImages () {
	var im = document.images;
	if (im) {
		var i = 0;
		for (i = 0; i < im.length; i++) {
			if (im[i].getAttribute('src')) {
				var src = im[i].getAttribute('src');
				var gPos = src.indexOf('_g_');
				if (gPos != -1 && 0 < gPos) {
					im[i].setAttribute('src', src.substr(0, gPos) + '' + src.substr(gPos + 2));
				}
			}
		}
	}
	return '';
} // UnmaskBlurredImages()


//https://stackoverflow.com/questions/123999/how-can-i-tell-if-a-dom-element-is-visible-in-the-current-viewport

function elementInViewport (el) {
	var top = el.offsetTop;
	var left=el.offsetLeft;
	var width = el.offsetWidth;
	var height = el.offsetHeight;

	while (el.offsetParent) {
		el = el.offsetParent;
		top += el.offsetTop;
		left+=el.offsetLeft;
	}

	return (
		window.pageYOffset <= top &&
		window.pageXOffset <= left &&
		(top + height) <= (window.pageYOffset + window.innerHeight) &&
		(left + width) <= (window.pageXOffset + window.innerWidth)
	);
} // elementInViewport()
//You could modify this simply to determine if any part of the element is visible in the viewport:

function elementInViewport2 (el) {
	var top = el.offsetTop;
	var left=el.offsetLeft;
	var width = el.offsetWidth;
	var height = el.offsetHeight;

	while (el.offsetParent) {
		el = el.offsetParent;
		top += el.offsetTop;
		left+=el.offsetLeft;
	}

	return (
		top < (window.pageYOffset + window.innerHeight) &&
		left < (window.pageXOffset + window.innerWidth) &&
		window.pageYOffset < (top + height) &&
		window.pageXOffset < (left + width)
	);
} // elementInViewport2()


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

// function EscapeUrl () {
// function UriEscape () {
// USE encodeURIComponent()


//function ChangeInputToTextarea (input) { // called by onpaste
////#input_expand_into_textarea
//	//#todo more sanity
//	if (!input) {
//		return '';
//	}
//
//	if (document.createElement) {
//		var parent = input.parentElement;
//		var textarea = document.createElement('textarea');
//		var cols = input.getAttribute('cols');
//		var name = input.getAttribute('name');
//		var id = input.getAttribute('id');
//		var rows = 5;
//		var width = cols + 'em';
//
//		textarea.setAttribute('name', name);
//		textarea.setAttribute('id', id);
//		textarea.setAttribute('cols', cols);
//		textarea.setAttribute('rows', rows);
//		//textarea.style.width = width;
//		textarea.innerHTML = input.value;
//
//		//parent.appendChild(t);
//		parent.insertBefore(textarea, input.nextSibling);
//		input.style.display = 'none';
//
//		textarea.focus();
//		textarea.selectionStart = textarea.innerHTML.length;
//		textarea.selectionEnd = textarea.innerHTML.length;
//
//		if (window.inputToChange) {
//			window.inputToChange = '';
//		}
//	}
//
//	return true;
//}

//
//function ConvertSubmitsToButtonsWithAccessKey (parent) {
//	if (!parent) {
//		//alert('DEBUG: ConvertSubmitsToButtons: warning: sanity check failed');
//		return '';
//	}
//
//	if (parent.getElementsByClassName) {
//		var buttons = parent.getElementsByClassName('btnSubmit');
//		// convert each submit to button with accesskey
//	} else {
//		//todo
//	}
//	return ''
//} // ConvertSubmitsToButtonsWithAccessKey()


// developer
// SetPrefs('notify_event_loop', 1);
// SetPrefs('notify_event_loop', 0);


// == end utils.js
