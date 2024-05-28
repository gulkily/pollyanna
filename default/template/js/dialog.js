/* dialog.js */

function CreateDialog (body, title, status) {
	// #todo sanity checks

	var newDialog = document.createElement('div');
	newDialog.setAttribute('class', 'dialog');

	var newTitlebar = document.createElement('div');
	newTitlebar.setAttribute('class', 'titlebar');
	var newTitlebarText = document.createTextNode(title);
	newTitlebar.appendChild(newTitlebarText);
	var newTitlebarExpandLink = document.createElement('a');
	newTitlebarExpandLink.setAttribute('onclick', 'onclick="if (window.ShowAll && window.GetParentDialog) { return !ShowAll(this, GetParentDialog(this)); } return false;"');
	newTitlebarExpandLink.setAttribute('href', '#');
	var newTitlebarExpandLinkText = document.createTextNode('#');
	newTitlebarExpandLink.appendChild(newTitlebarExpandLinkText);

	var newContent = document.createElement('div');
	newContent.setAttribute('class', 'content');
	newContent.innerHTML = body;

	var newStatusbar = document.createElement('div');
	newStatusbar.setAttribute('class', 'statusbar');
	newStatusbar.innerHTML = status;
	//var newStatusbarText = document.createTextNode('statusbar here');
	//newStatusbar.appendChild(newStatusbarText);

	newDialog.appendChild(newTitlebar);
	newDialog.appendChild(newContent);
	newDialog.appendChild(newStatusbar);

	document.body.appendChild(newDialog);
} // CreateDialog()

/* / dialog.js */