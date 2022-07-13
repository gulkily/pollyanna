// == begin timestamp.js

function RoundNumber (num) {
	var ret = Math.floor(num);

	//var ret = Math.floor(num * 10) / 10;
	//leave one digit after the decimal point

	////alert('DEBUG: RoundNumber: num = ' + num + '; ret = ' + ret + '');

	return ret;
}

function LongAgo (seconds) { // returns string with time units
// takes seconds as parameter
// returns a string like "3 days ago" or "3 days from now"

	var flip = 0;
	if (seconds < 0) {
		flip = 1;
		seconds = 0 - seconds;
	}

	var unit = '';
	var number = seconds;

	if (number < 60) {
		number = number;

		if (RoundNumber(number) != 1) {
			unit = ' seconds';
		} else {
			unit = ' second';
		}
	} else {
		number = number / 60;

		if (number < 60) {
			if (RoundNumber(number) != 1) {
				unit = ' minutes';
			} else {
				unit = ' minute';
			}
		} else {
			number = number / 60;

			if (number < 24) {
				if (RoundNumber(number) != 1) {
					unit =  ' hours';
				} else {
					unit =  ' hour';
				}
			} else {
				number = number / 24;

				if (number < 7) {
					if (RoundNumber(number) != 1) {
						unit =  ' days';
					} else {
						unit =  ' day';
					}
				} else {
					if (number < 30) {
						number = number / 7;
						if (RoundNumber(number) != 1) {
							unit =  ' weeks';
						} else {
							unit =  ' week';
						}
					} else {
						if (number < 365) {
							number = number / 30;

							if (RoundNumber(number) != 1) {
								unit =  ' months';
							} else {
								unit =  ' month';
							}
						} else {
							number = number / 365;
							if (RoundNumber(number) != 1) {
								unit =  ' years';
							} else {
								unit =  ' year';
							}
						} // years
					} // months
				} // weeks
			} // days
		} // hours
	} // minutes

	//number = RoundNumber(number);

	var returnValue = '';
	if (seconds % 1 == 0) {
		returnValue = RoundNumber(number) + ' ' + unit;
	} else {
		returnValue = number + ' ' + unit;
	}

	if (flip) {
		returnValue = returnValue + ' ago';
	} else {
		returnValue = returnValue + ' from now';
	}

	//alert(returnValue);

	return returnValue;
} // LongAgo()

function ShowTimestamps () { // finds any class=timestamp, updates its displayed time as needed
// currently requires getElementsByClassName()
// in the future, ie4+, nn4+, and others compat can be improved
	//alert('DEBUG: ShowTimestamps()');
// function FormatTimestamps () {

	var restAfter = 100; // stop after this many changes to avoid slowing things down
	if (
		window.GetPrefs &&
		(GetPrefs('performance_optimization') == 'faster')
	) {
		restAfter = 30;
	}
	//alert('DEBUG: ShowTimestamps() BEGIN');

	if (document.getElementsByClassName) {
		//alert('DEBUG: ShowTimestamps: document.getElementsByClassName feature check passed');
		var d = new Date();
		var curTime = d.getTime() / 1000;
		//var curTime = Math.floor(d.getTime() / 1000);
		var changeLogged = 0;
		var showTimestampsFormat = 0;

		if (window.GetPrefs) {
			if (GetPrefs('timestamps_format')) {
				showTimestampsFormat = GetPrefs('timestamps_format');
			} else {
				showTimestampsFormat = 0;
			}
		}

		// find elements with class=timestamp
		var te = document.getElementsByClassName("timestamp"); //#timestampTagFormat
		//var te = document.getElementsByTagName("time"); //#timestampTagFormat

		//alert('DEBUG: ShowTimestamps: class=timestamp elements found: ' + te.length);
		for (var i = 0; i < te.length; i++) {
			// loop through all the timestamp elements on the page

			var timeValue = te[i].getAttribute('datetime');  //#timestampTagFormat
			if (!timeValue) {
				var timeValue = te[i].getAttribute('epoch');  //#timestampTagFormat
			}

			if (!isNaN(timeValue)) {
			//if (!isNaN(te[i].getAttribute('epoch'))) { //#timestampTagFormat
				// element also has an attribute called 'epoch', and it is
				// a number, which would represent epoch seconds
				var secs = 0 - (curTime - timeValue); // number of seconds since epoch begin
				var longAgo = '';
				if (timeValue % 1 == 0) {
					secs = RoundNumber(secs);
				}

				//alert(showTimestampsFormat);

				//if (te[i].getAttribute('format')) {
					//showTimestampsFormat = te[i].getAttribute('format');
				//}


				if (showTimestampsFormat) {
					if (showTimestampsFormat == 'exact') { //#todo
						longAgo = te[i].getAttribute('title');
					}
					if (showTimestampsFormat == 'exact_full') {
						var date = new Date(timeValue * 1000);

						var year = date.getFullYear();
						var month = date.getMonth() + 1;
						var day = date.getDate();
						var hours = date.getHours();
						var minutes = date.getMinutes();

						if (month < 10) { month = '0' + month; }
						if (day < 10) { day = '0' + day; }
						if (hours < 10) { hours = '0' + hours; }
						if (minutes < 10) { minutes = '0' + minutes; }

						longAgo = year + "-" + month + "-" + day + " " + hours + ":" + minutes;
					}
					if (showTimestampsFormat == 'adjusted') {
						longAgo = LongAgo(RoundNumber(secs)); // what the element's displayed value should be
					}
					if (showTimestampsFormat == 'seconds') {
						longAgo = secs; // what the element's displayed value should be
					}
					if (showTimestampsFormat == 'epoch') {
						longAgo = RoundNumber(timeValue);
					}
					if (showTimestampsFormat == 'iso') {
						if (d.toISOString) {
							var dd = new Date(timeValue * 1000);
							longAgo = dd.toISOString();
							var gt = unescape('%3E');
							longAgo = longAgo.substr(0,10) + '<wbr' + gt + longAgo.substr(10); // wrapping hint
						}
					}
					if (!longAgo) {
						showTimestampsFormat = 'adjusted';
						longAgo = LongAgo(RoundNumber(secs));
					}
				} else {
					longAgo = secs;
				}

				//longAgo = secs;

				if (te[i].innerHTML != longAgo) {
					// element's content does not already equal what it should equal
					te[i].innerHTML = longAgo;
					if ((secs * (-1)) < 3600) {
						// less than an hour ago = bold
						te[i].style.fontWeight = 'bold';
					} else {
						te[i].style.fontWeight = '';
					}
					if ((secs * (-1)) < 86400) {
						// less than a day ago = highlight
						te[i].style.backgroundColor = '$colorHighlightAlert';
					} else {
						te[i].style.backgroundColor = '';
					}
					
					//var rect = te[i].getBoundingClientRect();
					//if (!te[i].getAttribute('maxw') || (te[i].getAttribute('maxw') < rect.width)) {
					//	te[i].setAttribute('maxw', rect.width);
					//	te[i].style.width = (rect.width) + 'px';
					//	document.title = te[i].getAttribute('maxw') + ',' + te[i].style.width;
					//}
					changeLogged++; // count change logged
				}
			}
			if (restAfter < changeLogged) {
				setTimeout('ShowTimestamps()', 500);
				i = te.length;
				
				return changeLogged;
			}
		} // for (var i = 0; i < te.length; i++)

		if (window.EventLoop) {
			// do nothing, EventLoop() will call us when needed
		} else {
			// allow ShowTimestamps() to run decoupled from EventLoop()
			if (changeLogged) {
				setTimeout('ShowTimestamps()', 5000);
			} else {
				setTimeout('ShowTimestamps()', 15000);
			}
		}
		
		return changeLogged;
	}
} // ShowTimestamps()
//
//if (window.EventLoop) {
//	// do nothing, EventLoop() will take care of us
//} else {
//	// if no EventLoop(), we do it ourselves
//	ShowTimestamps();
//}

// == end timestamp.js
