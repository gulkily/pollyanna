/* dragging_spotlight_dialog.js */

function SpotlightDialog (dialogId, t) { // t is 'this' of the element which was clicked
// pagemap, page map,
// <!-- dialoglist.js
// should actually be called ToggleDialog()
	//alert(dialogId);
	var dialog = document.getElementById(dialogId);
	//alert('DEBUG: SpotlightDialog(' + dialogId + ',' + dialog + ')');

	/* #todo
			titlebarHeight = 30;

							curTop += titlebarHeight;
							curLeft += titlebarHeight;

		var curTop = 55;
		var curLeft = 5;
	*/

	if (dialog) {
		//alert('DEBUG: DialogIsVisible(dialog):' + DialogIsVisible(dialog));

		if (0 && DialogIsVisible(dialog)) {
			//alert('DEBUG: SpotlightDialog: DialogIsVisible(dialog) was TRUE');

			// SpotlightDialog() should never hide the dialog

			dialog.style.display = 'none';
			t.style.opacity = "100%"; // #todo classes
		} else {
			// #todo if dialog itself has class=advanced, remove it
			//alert('DEBUG: SpotlightDialog: dialog.className = ' + dialog.className);
			// but also, move upwards, and check that any spans it's inside of have class=advanced, remove advanced from the class names of those spans
			var element = dialog;
			while (element.parentElement) {
				//alert('DEBUG: SpotlightDialog: element.tagName + element.className = ' + element.tagName + ',' + element.className);
				if (element.className == 'advanced' || element.className == 'beginner' || element.className == 'admin') {
					//alert('advanced found');
					element.className = '';
					if (element.style.display == 'none') {
						element.style.display = '';
					}
					ShowAdvanced(1);
					// #todo multiple class names
				}
				if (element.style && element.style.display && element.style.display == 'none') {
					element.style.display = '';
					ShowAdvanced(1);
				}
				element = element.parentElement;
			}

			//if (event && event.clientX && event.clientY) {
			//	//alert(event.clientX);
			//	//alert(event.clientY);
			//	dialog.style.left = clientX + 'px';
			//	dialog.style.top = clientY + 'px';
			//} else {
			//	//alert();
			//}

			SetActiveDialog(dialog);

			//console.log(dialog.style);
			// dialog.style.top = event.clientX;
			// dialog.style.left = event.clientY;
			// there is an issue with this for some reason
			var dialogPageMap = GetParentDialog(t);
			var dialogTop = (event.clientY - 35) + 'px';
			var dialogLeft = (event.clientX + 100) + 'px';

			DraggingInitDialog(dialog, 0);
			
			var dialogPageMap = GetParentDialog(t);
			var dialogTop, dialogLeft;
			
			if (dialogPageMap.getAttribute('id') == 'PageMap') {
				// Get the position of PageMap
				var pageMapRect = dialogPageMap.getBoundingClientRect();
			
				// Calculate the available space on both sides
				var spaceRight = window.innerWidth - pageMapRect.right;
				var spaceLeft = pageMapRect.left;
			
				// Set the dialog position based on available space, preferring the right side
				if (spaceRight >= spaceLeft) {
					// Prefer the right side
					dialogLeft = (pageMapRect.right) + 'px'; // You can adjust the offset (10) based on your design
				} else {
					// Use the left side
					dialogLeft = (pageMapRect.left) + 'px'; // You can adjust the offset (10) based on your design
				}
			
				//dialogTop = (pageMapRect.top) + 'px'; // Adjust the offset (35) based on your design
				dialogTop = (event.clientY - 20) + 'px';
			} else {
				// Position near the mouse cursor (as in the previous example)
				var offsetTop = 20;
				var offsetLeft = 50;
				dialogTop = (event.clientY - offsetTop) + 'px';
				dialogLeft = (event.clientX - offsetLeft) + 'px';
			}
			
			dialog.style.top = dialogTop;
			dialog.style.left = dialogLeft;

			t.style.opacity = "80%"; // #todo classes
		}

	} else {
		//alert('DEBUG: SpotlightDialog: warning: dialog not found');

	}

//	var dialog = document.getElementById('d' + dialogId);
//	if (dialog) {
//		var dialogDisplay = dialog.style.display;
//		if (dialogDisplay == 'none') {
//			dialog.style.display = 'inline';
//		} else {
//			dialog.style.display = 'none';
//		}
//	} else {
//		//alert('DEBUG: SpotlightDialog: warning: dialog not found');
//	}
	return false;
} // SpotlightDialog()

/* / dragging_spotlight_dialog.js */
