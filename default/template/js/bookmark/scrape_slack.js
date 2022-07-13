document.addEventListener('scroll', function(e) {
	var aa = document.getElementsByTagName('a');
	if (aa) {
		for (i = 0; i < aa.length; i++) {
			document.title = i;
			var href = aa[i].getAttribute('href');
			if (href) {
				if (
					href.indexOf('slack.com') == -1 &&
					href.indexOf('zoom.us') == -1 &&
					href.indexOf('forms.gle') == -1 &&
					href.indexOf('drive.google.com') == -1 &&
					href.indexOf('/') != 0
				) {
					window.localStorage.setItem(href, 1);
				}
			}
		}
	}
}, true);

