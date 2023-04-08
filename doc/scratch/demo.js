/* demo.js */

function DemoAction () { /* performs the next demo action, returns if any more actions left */
	if (window.localStorage && document.getElementById) {
		var aNum = window.localStorage.getItem('demo_position');
		if (aNum) {
			if (aNum == 1) {
				FetchDialog('profile');
				window.localStorage.setItem('demo_position', 2);
			}
		}
	}

}

/* / demo.js */
