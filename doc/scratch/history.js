// history.js

//function UpdateHistoryList () {
//	var lstHistory = document.getElementById('lstHistory');
//	if (lstHistory) {
//		//var allOpenDialogs = document.getElementsByClassName('dialog');
//
//		if (allOpenDialogs.length) {
//			var listContent = '';
//			for (var iDialog = 0; iDialog < allOpenDialogs.length; iDialog++) {
//				var dialogTitle = GetDialogTitle(allOpenDialogs[iDialog]);
//				var dialogId = GetDialogId(allOpenDialogs[iDialog]);
//				var gt = unescape('%3E');
//
//				if (dialogTitle.length > 24) {
//					dialogTitle = dialogTitle.substr(0, 24);
//				}
//
//				listContent = listContent + '<a href="#' + dialogId + '" onclick="if (window.SpotlightDialog) { SpotlightDialog(' + dialogId + '); }"' + gt + dialogTitle + '</a' + gt + '<br' + gt;
//				lstDialog.innerHTML = lstDialog.innerHTML + iDialog;
//
//				/* #todo
//				var newLink = document.createElement('a');
//				newLink.setAttribute('href', '#');
//				newLink.setAttribute('onclick', "if (window.SpotlightDialog) { SpotlightDialog(' + dialogId + '); }");
//				//newLink.innerHTML = dialogTitle;
//				var newText = document.createTextNode(dialogTitle);
//				var newBr = document.createElement('br');
//
//				newLink.appendChild(newText);
//				lstDialog.appendChild(newLink);
//				lstDialog.appendChild(newBr);
//				*/
//			}
//
//			if (lstDialog.innerHTML != listContent) {
//				lstDialog.innerHTML = listContent;
//			}
//		}
//	}
//} // UpdateDialogList()

// / history.js
