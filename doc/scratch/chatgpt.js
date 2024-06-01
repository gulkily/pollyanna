function GetParentDialog(el) {
	if (el) {
		var parentDialog = el;
		while (parentDialog && !parentDialog.classList.contains('dialog')) {
			parentDialog = parentDialog.parentElement;
		}
		if (parentDialog) {
			return parentDialog;
		}
	}
	return '';
} // GetParentDialog()



function GetParentDialog(el) {
	if (el) {
		var parentDialog = el;
		var dialogClassRegex = new RegExp('(^|\\s)dialog(\\s|$)');
		while (parentDialog && !dialogClassRegex.test(parentDialog.className)) {
			parentDialog = parentDialog.parentElement;
		}
		if (parentDialog) {
			return parentDialog;
		}
	}
	return '';
} // GetParentDialog()
