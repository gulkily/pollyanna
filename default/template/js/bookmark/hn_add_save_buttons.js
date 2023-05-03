/* puts all comments into one post request and ships it off to localhost */
/* hn_add_reply_buttons.js */

var d=document;
var ct = d.getElementsByClassName('commtext');

function getForm () {
	var frm = document.frmReply;
	if (frm) {
		return frm;
	}

	/* todo */
}

function sendToHC (eventP) {
	var commtext = eventP.target.parentElement.querySelector('.commtext').innerHTML;
	if (document.frmReply && document.frmReply.comment) {
		document.frmReply.comment.value = commtext;
		document.frmReply.submit();
	}
}

var oldButton = document.getElementsByClassName('reply');
if (oldButton) {
	for (i = 0; i < oldButton.length; i++) {
		oldButton[i].remove();
	}
}

if (ct && ct.length) {
	if (1 || confirm(ct.length + ' items found. continue?')) {
		var frm = document.createElement('form');
		frm.setAttribute('action', 'http://localhost:2784/post.html');
		frm.setAttribute('method', 'GET');
		frm.setAttribute('target', 'http://www.hypercode.com/post.html');
		frm.setAttribute('name', 'frmReply');

		var commentField = document.createElement('input');
		commentField.setAttribute('type', 'hidden');
		commentField.setAttribute('name', 'comment');

		var sourceField = document.createElement('input');
		sourceField.setAttribute('type', 'hidden');
		sourceField.setAttribute('name', 's');
		sourceField.setAttribute('value', window.location.href);

		frm.appendChild(commentField);
		document.body.appendChild(frm);

		for (i = 0; i < ct.length; i++) {
			var newButton = document.createElement('button');
			newButton.innerHTML = 'reply';
			newButton.onclick = window.sendToHC;
			ct[i].parentElement.appendChild(newButton);

			if (ct[i].parentElement.querySelector('.reply')) {
				ct[i].parentElement.querySelector('.reply').remove();
			}
		}
	}
}
