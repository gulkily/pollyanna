/* dialog.js */

function CreateDialog (body, title, headings, status, menu) {
	// #todo sanity checks

	var newDialog = document.createElement('div');
	newDialog.setAttribute('class', 'dialog');

	var newTitlebar = document.createElement('div');
	newTitlebar.setAttribute('class', 'titlebar');
	var newTitlebarText = document.createTextNode('titlehere');
	newTitlebar.appendChild(newTitlebarText);
	var newTitlebarExpandLink = document.createElement('a');
	newTitlebarExpandLink.setAttribute('onclick', 'onclick="if (window.ShowAll && window.GetParentDialog) { return !ShowAll(this, GetParentDialog(this)); } return false;"');
	newTitlebarExpandLink.setAttribute('href', '#');
	var newTitlebarExpandLinkText = document.createTextNode('#');
	newTitlebarExpandLink.appendChild(newTitlebarExpandLinkText);

	var newContent = document.createElement('div');
	newContent.setAttribute('class', 'content');
	var newContentText = document.createTextNode('contenthere');
	newContent.appendChild(newContentText);

	var newStatusbar = document.createElement('div');
	newStatusbar.setAttribute('class', 'statusbar');
	var newStatusbarText = document.createTextNode('statusbar here');
	newStatusbar.appendChild(newStatusbarText);

	newDialog.appendChild(newTitlebar);
	newDialog.appendChild(newContent);
	newDialog.appendChild(newStatusbar);

	//newDialog.innerHTML = 'hey';

	document.body.appendChild(newDialog);
} // CreateDialog()

/* / dialog.js */