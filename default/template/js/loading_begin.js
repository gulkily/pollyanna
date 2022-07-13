// begin loading_begin.js

//var loadingIndicatorWaitToShowMin = 1500;
//var loadingIndicatorWaitToHideMin = 500;

function addLoadingIndicator (strMessage) { // adds loading indicator bar (to top of page, depending on style)
// function ShowLoadingIndicator ()
	//alert('DEBUG: addLoadingIndicator(' + strMessage + ')');
	if (!strMessage) {
		//alert('DEBUG: strMessage = ' + strMessage);
		strMessage = 'Meditate...';
	}
	//alert('DEBUG: addLoadingIndicator: strMessage = ' + strMessage);

	if (!document.createElement) {
		//alert('DEBUG: addLoadingIndicator: warning: no document.createElement');
		return '';
		// #todo improve compatibility here
	}

	if (window.loadingIndicator) {
	    //alert('DEBUG: addLoadingIndicator: warning: loading indicator already exists');
	    return '';
	}
	window.loadingIndicator = 1;

	//alert('DEBUG: addLoadingIndicator: sanity checks passed!');
	var spanLoadingIndicator = document.createElement('span');
	if (spanLoadingIndicator) {
		spanLoadingIndicator.setAttribute('id', 'loadingIndicator');
		spanLoadingIndicator.innerHTML = strMessage;
		spanLoadingIndicator.zIndex = 1337;
		document.body.appendChild(spanLoadingIndicator);
		window.loadingIndicator = spanLoadingIndicator;
	}

	return '';

} // addLoadingIndicator()

function ShowPreNavigateNotification () { // displays 'Meditate...' message
	// OnUnload ()
	//alert('DEBUG: ShowPreNavigateNotification() begin');

	if (window.blockPreNavigateNotification) {
		//alert('DEBUG: ShowPreNavigateNotification() blocked by window.blockPreNavigateNotification');
		window.blockPreNavigateNotification = 0;
		return '';
	}

	if (document.title.indexOf('...') == -1) {
		document.title = document.title + '...';
	}

	//document.body.style.opacity="0.8";
	if (event.target == location.href) {
	} else {
		if (document.getElementById) {
			var ariaAlert;
			ariaAlert = document.getElementById('ariaAlert');

			if (!ariaAlert) {
				ariaAlert = document.createElement('p');
				ariaAlert.setAttribute('role', 'alert');
				ariaAlert.setAttribute('id', 'ariaAlert');
				ariaAlert.innerHTML = 'Meditate...';
				ariaAlert.style.opacity = '1';
				ariaAlert.style.zIndex = '1337';
				//document.body.appendChild(ariaAlert);
				document.body.insertBefore(ariaAlert, document.body.firstChild);
			}
		} else {
			//#todo
		}
	}

	return ''; // true would show a confirmation
} // ShowPreNavigateNotification()

if (document.createElement) {
	//alert('DEBUG: loading_begin.js: createElement feature check PASSED!');
	var d = new Date();
	var loadingIndicatorStart = d.getTime() * 1;

	addLoadingIndicator('Meditate...');
} else {
	//alert('DEBUG: loading_begin.js: createElement feature check FAILED!');
}
// end loading_begin.js
