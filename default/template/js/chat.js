// chat.js

var chatTimeout;
var chatClient;
var chatState;
var chatEtag;

function ChatCallback () {
	//alert('DEBUG: ChatCallback()');
	if (
		document.getElementById &&
		this.readyState == this.HEADERS_RECEIVED ||
		this.status == 200
	) { // headers received -- what we've been waiting for
		//var eTag = this.getResponseHeader("ETag"); // etag header contains page 'fingerprint'
		//if (eTag != window.chatEtag) {
		//	window.chatEtag = eTag;
		//	ChatUpdate('GET');
		//}

		if (this.responseText) {
			if (window.chatState != this.responseText) {
				window.chatState = this.responseText;
				//alert(window.chatState);
				ChatInject(window.chatState);
			}
			if (window.chatTimeout) {
				clearTimeout(window.chatTimeout);
			}
			window.chatTimeout = setTimeout('ChatUpdate()', 1000);
		}
	}

	return '';
} // ChatCallback()

function ChatInject (chatState) {
	//alert('DEBUG: ChatInject()');
	var items = chatState.split('\n');
	for (var i = 0; i < items.length; i++) {
		var itemThings = items[i].split('|');
		if (itemThings.length == 2) {
			var itemHash = itemThings[0];
			var itemTime = itemThings[1];

			var itemUrl = '/dialog/' + itemHash.substr(0,2) + '/' + itemHash.substr(2, 2) + '/' + itemHash.substr(0, 8) + '.html'; // #todo GetHtmlFilename()
			var dialogId = itemHash.substr(0, 8);

			if (!document.getElementById(dialogId)) {
				window.chatState = ''; // reset chatState so that we update again; in the future, this should be a queue
				return FetchDialogFromUrl(itemUrl);
			}
		}
	}

	return '';
} // ChatInject()

function ChatUpdate () {
	//alert('DEBUG: ChatUpdate()');
	if (window.XMLHttpRequest){
		xhr = new XMLHttpRequest();
	}
	else {
		if (window.ActiveXObject) {
			xhr = new ActiveXObject("Microsoft.XMLHTTP");
		} else {
			return '';
		}
	}

	if (xhr) {
		var chatClient = xhr;

		//chatClient.open(method, '/new.txt', true);
		chatClient.open("GET", '/new.txt', true);
		//chatClient.open("HEAD", '/new.txt', true);

		chatClient.setRequestHeader('Cache-Control', 'no-cache');
		chatClient.onreadystatechange = ChatCallback;
		chatClient.send();

		return '';
	} else {
		return '';
	}
} // ChatUpdate()

//window.setTimeout('ChatUpdate', 1000);
//ChatUpdate('GET');
setTimeout('ChatUpdate()', 1000);

// / chat.js
