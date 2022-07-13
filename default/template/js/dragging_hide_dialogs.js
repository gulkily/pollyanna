/* dragging_hide_dialogs.js */
if (document.createElement) {
	var styleHideDialogs = document.createElement('style');
	if (styleHideDialogs.innerHTML && styleHideDialogs.setAttribute && document.getElementsByTagName) {
		styleHideDialogs.setAttribute('type', 'text/css');
		styleHideDialogs.setAttribute('id', 'styleHideDialogs');

		styleHideDialogs.innerHTML = '.dialog { display: none !important; }';
		// #todo #bug this breaks ie6, innerHTML is not a given

		var docHead = document.getElementsByTagName('head');
		if (docHead) {
			docHead[0].appendChild(styleHideDialogs);
		}
		// #todo do this without getElementsByTagName()
	}
}
/* / dragging_hide_dialogs.js */