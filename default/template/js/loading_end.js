// begin loading_end.js

function HideLoadingIndicator () {
	var loadingIndicator = window.loadingIndicator;

	if (!loadingIndicator) {
		if (document.getElementById) {
			loadingIndicator = document.getElementById('loadingIndicator');
			if (!loadingIndicator && document.getElementsByClassName) {
				var allNotificationElements = document.getElementsByClassName('notification');
				if (allNotificationElements) {
					loadingIndicator = allNotificationElementsp[0];
				}
			}
		} else {
		    // #todo forms fallback
		}
	}

	if (!loadingIndicator) {
	    //alert('DEBUG: HideLoadingIndicator: warning: loadingIndicator is FALSE');
	    return '';
	}

	if (window.loadingIndicatorShowTimeout) {
		clearTimeout(loadingIndicatorShowTimeout);
	}

	loadingIndicator.innerHTML = 'Ready.';
	loadingIndicator.style.backgroundColor = '$colorHighlightReady';

	//setTimeout('window.loadingIndicator.style.backgroundColor = "#00ffa0"', 500);
	//setTimeout('window.loadingIndicator.style.backgroundColor = "#e0ffa0"', 800);
	//setTimeout('window.loadingIndicator.style.backgroundColor = "#00ffa0"', 1100);
	//setTimeout('window.loadingIndicator.style.backgroundColor = "#e0ffa0"', 1400);

	window.loadingIndicator = loadingIndicator;
	//loadingIndicator.setAttribute('onclick', 'this.remove()');
	setTimeout('if (window.loadingIndicator && window.loadingIndicator.remove) { window.loadingIndicator.remove(); } else { if (window.loadingIndicator.style) { window.loadingIndicator.style.display = "none"; } }', 5000); //#todo fix this long line
	// #todo this causes a page shift in ie4 and ie6

	// } else {
	// 	if (loadingIndicator) { loadingIndicator.style.display = 'none' }
	// }
	return '';
} // HideLoadingIndicator()

function WaitForOpenPgp () {
	//alert('debug: WaitForOpenPgp()');
	var d = new Date();
	if (window.openPgpJsLoadBegin && window.openpgp) {
		HideLoadingIndicator();
	} else {
		setTimeout('if (window.WaitForOpenPgp) { WaitForOpenPgp() }', 500);
	}
} // WaitForOpenPgp()

// #todo see if this is still necessary
//if (!window.OnLoadEverything && window.HideLoadingIndicator) {
//	HideLoadingIndicator();
//}

// end loading_end.js
