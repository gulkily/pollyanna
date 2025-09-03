/* dialog.js */

function CreateDialog (body, title, status) {
	// #todo sanity checks

	var newDialog = document.createElement('div');
	newDialog.setAttribute('class', 'dialog');

	var newTitlebar = document.createElement('div');
	newTitlebar.setAttribute('class', 'titlebar');
	var newTitlebarText = document.createTextNode(title + ' ');
	newTitlebar.appendChild(newTitlebarText);
	var newTitlebarExpandLink = document.createElement('a');
	newTitlebarExpandLink.setAttribute('onclick', 'onclick="if ((window.ShowAll) && window.GetParentDialog) { return !ShowAll(this, GetParentDialog(this)); } return false;"');
	newTitlebarExpandLink.setAttribute('href', '#');
	var newTitlebarExpandLinkText = document.createTextNode('#');
	newTitlebarExpandLink.appendChild(newTitlebarExpandLinkText);
	newTitlebar.appendChild(newTitlebarExpandLink);

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

function GetTimestampWidget (time) {
	/* timestamp_time.template */

	var gt = unescape('%3E');
	return '<time class=timestamp datetime=' + time + ' title="' + 'todo' + '"' + gt + 'todo' + '</time' + gt;
}

function CreateItemDialog (file) {

	/*
	# %file(hash for each file)
	# file_path = file path including filename
	# file_hash = git's hash of the file's contents
	# author_key = gpg key of author (if any)
	# add_timestamp = time file was added as unix_time
	# child_count = number of replies
	# display_full_hash = display full hash for file
	# template_name = item/item.template by default
	# remove_token = token to remove (for reply tokens)
	# show_vote_summary = shows item's list and count of tags
	# show_quick_vote = displays quick vote buttons
	# item_title = override title
	# item_statusbar = override statusbar
	# labels_list = comma-separated list of tags the item has
	# is_textart = set <tt <code  tags for the message itself
	# no_permalink = do not link to item's permalink page
	*/

	/* #todo sanity checks */

	var status = GetTimestampWidget(testItem.add_timestamp);

	var body = escapeHTML(file.body);
	var gt = unescape('%3E');
	body = body.replace("\n", ("<br" + gt));

	var title = escapeHTML(file.item_title);

	return CreateDialog(body, title, status);
} // CreateItemDialog()

/*
var testItem = {};
testItem.item_title = 'this is a test item, thanks';
testItem.labels_list = 'hastext,hastitle';
testItem.hash = 'abcdef012346789abcdef012346789abcdef012346789abcd';
testItem.path = '/txt/ab/cd/abcdef012346789abcdef012346789abcdef012346789abcd.txt';
testItem.body = 'asdfasdfd' + "\n" + "\n" + "\n" + 'tefasdfads';
testItem.add_timestamp = 1716921560;

CreateItemDialog(testItem);
*/

/* / dialog.js */