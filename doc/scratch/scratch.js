
		window.injectMouseX = mouseX;
		window.injectMouseY = mouseY;
===
					// position the dialog below the menubar
					// #todo this should be done via css
					// #todo this should be done via a separate function
					var menu = document.getElementById('topmenu');
					var menuHeight = 0;
					if (menu) {
						menuHeight = menu.offsetHeight;
					}
					var menuTop = 0;
					if (menu) {
						menuTop = menu.offsetTop;
					}
					var dialogTop = menuTop + menuHeight;
					newDialog[iDialog].style.top = dialogTop + 'px';
					//var dialogLeft = 0;
					var dialogLeft = (document.documentElement.clientWidth / 2) - (newDialog[iDialog].offsetWidth / 2);
					// half of the viewport width minus half of the dialog width
					newDialog[iDialog].style.left = dialogLeft + 'px';

===

function TileDialogs4() {
    var pageWidth = document.documentElement.clientWidth; // Fixed width of the page
    var placedDialogs = [];

    var elements = document.getElementsByClassName('dialog');

    // Function to check if a dialog overlaps with any already placed dialog
    function doesOverlap(newDialog, newX, newY, newWidth, newHeight) {
        return placedDialogs.some(dialog => {
            return !(newX + newWidth + 5 <= dialog.x ||
                     newX >= dialog.x + dialog.width + 5 ||
                     newY + newHeight + 5 <= dialog.y ||
                     newY >= dialog.y + dialog.height + 5);
        });
    }

    // Function to find a place for the dialog
    function findSpotForDialog(dialogWidth, dialogHeight) {
        for (let y = 5; y < document.documentElement.clientHeight; y += 5) {
            for (let x = 5; x <= pageWidth - dialogWidth; x += 5) {
                if (!doesOverlap(dialog, x, y, dialogWidth, dialogHeight)) {
                    return { x: x, y: y };
                }
            }
        }
        return null; // If no spot is found
    }

    Array.from(elements).forEach(function(dialog) {
        if (dialog.style.display === 'none' ||
            dialog.parentElement.style.display === 'none' ||
            dialog.parentElement.parentElement.style.display === 'none') {
            return; // Skip hidden dialogs
        }

        var dialogWidth = dialog.offsetWidth;
        var dialogHeight = dialog.offsetHeight;

        // Find a spot for the dialog
        var spot = findSpotForDialog(dialogWidth, dialogHeight);
        if (spot) {
            // Place the dialog
            dialog.style.top = spot.y + 'px';
            dialog.style.left = spot.x + 'px';
            dialog.style.zIndex = 100; // Arbitrary z-index

            // Save the placement for future overlap checks
            placedDialogs.push({
                x: spot.x,
                y: spot.y,
                width: dialogWidth,
                height: dialogHeight
            });
        }
    });
}



function TileDialogs() {
    var pageWidth = document.documentElement.clientWidth; // Fixed width of the page
    var curTop = 5;
    var curLeft = 5;
    var rowHeight = 0;

    var elements = document.getElementsByClassName('dialog');
    var positionedDialogs = [];

    // First, sort elements by height to place larger ones first (if needed)
    var sortedElements = Array.from(elements).sort((a, b) => b.offsetHeight - a.offsetHeight);

    sortedElements.forEach(function(dialog) {
        if (dialog.style.display === 'none' ||
            dialog.parentElement.style.display === 'none' ||
            dialog.parentElement.parentElement.style.display === 'none') {
            return; // Skip hidden dialogs
        }

        var dialogWidth = dialog.offsetWidth;
        var dialogHeight = dialog.offsetHeight;

        // Check if the dialog fits in the current row, or if a new row is needed
        if (curLeft + dialogWidth > pageWidth) {
            // Start a new row
            curTop += rowHeight + 5; // Add a small margin between rows
            curLeft = 5; // Reset left position
            rowHeight = 0; // Reset row height
        }

        // Place the dialog
        dialog.style.top = curTop + 'px';
        dialog.style.left = curLeft + 'px';
        dialog.style.zIndex = 100; // Arbitrary z-index

        // Update positions for the next dialog
        curLeft += dialogWidth + 5; // Add a small margin between dialogs
        rowHeight = Math.max(rowHeight, dialogHeight); // Update the current row height

        positionedDialogs.push(dialog);
    });

    // Adjust for the last row height
    curTop += rowHeight;
}

function TileDialogs2() {
    var pageWidth = document.documentElement.clientWidth; // Fixed width of the page
    var rows = [];

    var elements = document.getElementsByClassName('dialog');

    // Iterate over all dialog elements
    Array.from(elements).forEach(function(dialog) {
        if (dialog.style.display === 'none' ||
            dialog.parentElement.style.display === 'none' ||
            dialog.parentElement.parentElement.style.display === 'none') {
            return; // Skip hidden dialogs
        }

        var dialogWidth = dialog.offsetWidth;
        var dialogHeight = dialog.offsetHeight;
        var placed = false;

        // Try to place the dialog in existing rows
        for (var i = 0; i < rows.length && !placed; i++) {
            if (rows[i].remainingWidth >= dialogWidth) { // Check if it fits in the remaining width
                dialog.style.top = rows[i].top + 'px';
                dialog.style.left = (pageWidth - rows[i].remainingWidth) + 'px';
                dialog.style.zIndex = 100; // Arbitrary z-index

                // Update row information
                rows[i].remainingWidth -= dialogWidth + 5; // Update remaining width
                rows[i].height = Math.max(rows[i].height, dialogHeight); // Possibly update the row height
                placed = true;
            }
        }

        // If it wasn't placed, create a new row
        if (!placed) {
            var newTop = rows.length > 0 ? rows[rows.length - 1].top + rows[rows.length - 1].height + 5 : 5;
            dialog.style.top = newTop + 'px';
            dialog.style.left = '5px';
            dialog.style.zIndex = 100; // Arbitrary z-index

            // Create new row
            rows.push({
                top: newTop,
                remainingWidth: pageWidth - dialogWidth - 5,
                height: dialogHeight
            });
        }
    });
}

// below is from crypto2.js
					//	if (window.PubKeyShare) {
					//		//alert('DEBUG: MakeKey: (window.PubKeyShare) exists. calling');
					//		//PubKeyShare();
					//
					//		return true;
					//	} else {
					//		//alert('DEBUG: MakeKey: (window.PubKeyShare) does NOT exist, using window.location');
					//
					//		window.location = '/write.html#inspubkey';
					//		return true;
					//	}
					//alert('done MakeKey; callback = ' + callback);


					//if (window.AddLoadingIndicator) {
					//	AddLoadingIndicator('Creating profile...');
					//}
					//PubKeyPing();
//


if (!document.getElementsByClassName) {
    document.getElementsByClassName = function(search) {
        var d = document, elements, pattern, i, results = [];
        if (d.querySelectorAll) { // For IE8
            return d.querySelectorAll("." + search);
        }
        if (d.evaluate) { // For IE6, IE7
            pattern = ".//*[contains(concat(' ', @class, ' '), ' " + search + " ')]";
            elements = d.evaluate(pattern, d, null, 0, null);
            while ((i = elements.iterateNext())) {
                results.push(i);
            }
        } else {
            elements = d.getElementsByTagName("*");
            pattern = new RegExp("(^|\\s)" + search + "(\\s|$)");
            for (i = 0; i < elements.length; i++) {
                if ( pattern.test(elements[i].className) ) {
                    results.push(elements[i]);
                }
            }
        }
        return results;
    }
}



//			var gt = unescape('%3E');
//			var listContent = '<form' + gt; // id=formListDialog name=formListDialog

//			listContent = listContent + '</form' + gt;


				/* #todo
				var newLink = document.createElement('a');
				newLink.setAttribute('href', '#');
				newLink.setAttribute('onclick', "if (window.SpotlightDialog) { SpotlightDialog(' + dialogId + '); }");
				//newLink.innerHTML = dialogTitle;
				var newText = document.createTextNode(dialogTitle);
				var newBr = document.createElement('br');

				newLink.appendChild(newText);
				lstDialog.appendChild(newLink);
				lstDialog.appendChild(newBr);
				*/


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



			//if (event && event.clientX && event.clientY) {
			//	//alert(event.clientX);
			//	//alert(event.clientY);
			//	dialog.style.left = clientX + 'px';
			//	dialog.style.top = clientY + 'px';
			//} else {
			//	//alert();
			//}



function EnsureDialogIsInViewport (el) {
//	var height = window.innerHeight;
//	var width = window.innerWidth;
//
//	if (el.top + el.height
//}
//
//function IsInViewport(element) {
//    const rect = element.getBoundingClientRect();
//    return (
//        rect.top GT= 0 &&
//        rect.left GT= 0 &&
//        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
//        rect.right <= (window.innerWidth || document.documentElement.clientWidth)
//    );
} // EnsureDialogIsInViewport()



			//var comStyle = window.getComputedStyle(elements[i], null);
			//var iwidth = parseInt(comStyle.getPropertyValue("width"), 10);
			//var iheight = parseInt(comStyle.getPropertyValue("height"), 10);
			////alert('DEBUG: SetActiveDialog: iwidth: ' + document.documentElement.clientWidth + ', iheight:' + iheight);
			////alert('DEBUG: SetActiveDialog: document.documentElement.clientWidth and .clientHeight: ' + document.documentElement.clientWidth + ',' + document.documentElement.clientHeight);
			////alert('DEBUG: SetActiveDialog: myScale = ' + myScale);




//	for (var i = elements.length - 1; 0 <= i; i--) {
//		var newTop = elements[i].style.top;
//		var newLeft = elements[i].style.left;
//		elements[i].style.position = 'absolute';
//		elements[i].style.top = newTop;
//		elements[i].style.left = newLeft;
//	}
//
//	DraggingInit(0);



//
//			if (0) {
//				// position dialog to the right of the pagemap dialog
//			}
//			else if (0) {
//				// position dialog to the left of the pagemap dialog
//			}
//			else if (0) {
//				// position dialog above the pagemap dialog
//			}
//			else if (0) {
//				// position dialog below the pagemap dialog
//			}
//			else {
//				// fallback, position dialog to the right of the mouse cursor
//
//				//console.log(dialog.style);
//				// dialog.style.top = event.clientX;
//				// dialog.style.left = event.clientY;
//				// there is an issue with this for some reason
//				var dialogTop = (event.clientY - 35) + 'px';
//				var dialogLeft = (event.clientX + 100) + 'px';
//
//				dialog.style.top = dialogTop;
//				dialog.style.left = dialogLeft;
//
//				t.style.opacity = "80%"; // #todo classes
//			}



//
//if (window.GetPrefs) {
//	var needNotify = (GetPrefs('notify_on_change') ? 1 : 0);
//	if (needNotify == 1) { // check value of notify_on_change preference
//		if (window.EventLoop) {
//			EventLoop();
//		} else {
//			CheckIfFresh();
//		}
//	}
//}


// fresh.js
//function ReplacePageWithNewContent () {
//	window.location.replace(window.newPageLocation);
//	document.open();
//	document.write(window.newPageContent);
//	document.close();
//
//	return 0;
//}
//
//function StoreNewPageContent () {
//	var xmlhttp = window.xmlhttp2;
//
//	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
//		//alert('DEBUG: PingUrlCallbackReplaceCurrentPage() found status 200');
//		window.newPageContent = xmlhttp.responseText;
//		window.newPageLocation = xmlhttp.responseURL;
//
//		//window.location.replace(xmlhttp.responseURL);
////		document.open();
////		document.write(xmlhttp.responseText);
////		document.close();
//	}
//}
//
//function FetchNewPageContent (url) {
//	if (window.XMLHttpRequest) {
//		//alert('DEBUG: PingUrl: window.XMLHttpRequest was true');
//
//		var xmlhttp;
//		if (window.xmlhttp2) {
//			xmlhttp = window.xmlhttp2;
//		} else {
//			window.xmlhttp2 = new XMLHttpRequest();
//			xmlhttp = window.xmlhttp2;
//		}
//        xmlhttp.onreadystatechange = window.StoreNewPageContent;
//        xmlhttp.open("GET", url, true);
//		  xmlhttp.setRequestHeader('Cache-Control', 'no-cache');
//        xmlhttp.send();
//
//        return false;
//	}
//}


		if (newDialog.getAttribute('id')) {
			alert(1);
			// check for existing dialog in the document already
			// #todo this should be done via GetDialogId()
			var existingDialog = document.getElementById(newDialog.getAttribute('id'));
			if (existingDialog) {
				//alert('DEBUG: InsertFetchedDialog: warning: existingDialog found, removing');
				existingDialog.remove();
			}
		} else {
			alert(2);
		}



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




/* dragging.js */

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

/* / dragging.js */

//			if (t) {
//				var tParent = GetParentDialog(t);
//				if (tParent) {
//					// there is more room to the right of the tParent than there is to its left
//					var tParentLeft = tParent.style.left;
//					var tParentRight = tParent.style.right;
//					var tParentWidth = tParent.style.width;
//					var tParentHeight = tParent.style.height;
//					var tParentTop = tParent.style.top;
//					var tParentBottom = tParent.style.bottom;
//					var viewportWidth = document.documentElement.clientWidth;
//					var viewportHeight = document.documentElement.clientHeight;
//					if (tParentLeft) {
//						tParentLeft = parseInt(tParentLeft);
//					}
//					if (tParentRight) {
//						tParentRight = parseInt(tParentRight);
//					}
//					if (tParentWidth) {
//						tParentWidth = parseInt(tParentWidth);
//					}
//					if (tParentHeight) {
//						tParentHeight = parseInt(tParentHeight);
//					}
//					if (tParentTop) {
//						tParentTop = parseInt(tParentTop);
//					}
//					if (tParentBottom) {
//						tParentBottom = parseInt(tParentBottom);
//					}
//					if (viewportWidth) {
//						viewportWidth = parseInt(viewportWidth);
//					}
//					if (viewportHeight) {
//						viewportHeight = parseInt(viewportHeight);
//					}
//					var RoomToTheRight = viewportWidth - tParentLeft - tParentWidth;
//					var RoomToTheLeft = tParentLeft;
//					var RoomAbove = tParentTop;
//					var RoomBelow = viewportHeight - tParentTop - tParentHeight;
//					//alert('DEBUG: SpotlightDialog: RoomToTheRight = ' + RoomToTheRight);
//					//alert('DEBUG: SpotlightDialog: RoomToTheLeft = ' + RoomToTheLeft);
//					//alert('DEBUG: SpotlightDialog: RoomAbove = ' + RoomAbove);
//					//alert('DEBUG: SpotlightDialog: RoomBelow = ' + RoomBelow);
//					if (RoomToTheRight < RoomToTheLeft) {
//						//alert('DEBUG: SpotlightDialog: RoomToTheRight < RoomToTheLeft');
//						// position dialog to the right of the tParent
//						dialog.style.left = (tParentLeft + tParentWidth + 10) + 'px';
//					}
//					else if (RoomToTheLeft < RoomToTheRight) {
//						//alert('DEBUG: SpotlightDialog: RoomToTheLeft < RoomToTheRight');
//						// position dialog to the left of the tParent
//						dialog.style.left = (tParentLeft - 10) + 'px';
//					}
//					else if (RoomAbove < RoomBelow) {
//						//alert('DEBUG: SpotlightDialog: RoomAbove < RoomBelow');
//						// position dialog above the tParent
//						dialog.style.top = (tParentTop - 10) + 'px';
//					}
//					else if (RoomBelow < RoomAbove) {
//						//alert('DEBUG: SpotlightDialog: RoomBelow < RoomAbove');
//						// position dialog below the tParent
//						dialog.style.top = (tParentTop + tParentHeight + 10) + 'px';
//					}
//					else {
//						//alert('DEBUG: SpotlightDialog: fallback');
//						// fallback, position dialog to the right of the mouse cursor
//
//						//console.log(dialog.style);
//						// dialog.style.top = event.clientX;
//						// dialog.style.left = event.clientY;
//						// there is an issue with this for some reason
//						var dialogTop = (event.clientY - 35) + 'px';
//						var dialogLeft = (event.clientX + 100) + 'px';
//
//						dialog.style.top = dialogTop;
//						dialog.style.left = dialogLeft;
//
//						t.style.opacity = "80%"; // #todo classes
//					}
//
//				}
//			}



// Convert NodeList to array for easier iteration
const childNodesArray = Array.from(document.body.childNodes);

for (let i = 0; i < childNodesArray.length; i++) {
    // Save the child node in a variable for easy referencing
    let e = childNodesArray[i];

    if (e.nodeType === 8) { // We found a comment!
        // Increment the accumulator
        accumulator += 1;

        // Show the comments section
        comments_section.style.display = "block";
    }
}


				var displayTitle = '<b' + gt + dialogTitle.substring(0, 1) + '</b' + gt + dialogTitle.substring(1);
				if (DialogIsVisible(allOpenDialogs[iDialog])) {
					listContent = listContent + comma + '<a style="opacity: 80%" href="#' + dialogId + '" onclick="if (window.SpotlightDialog) { return SpotlightDialog(\'' + dialogId + '\', this); }"' + gt + displayTitle + '</a' + gt;
					// #todo classes and createElement
				} else {
					listContent = listContent + comma + '<a style="opacity: 100%" href="#' + dialogId + '" onclick="if (window.SpotlightDialog) { return SpotlightDialog(\'' + dialogId + '\', this); }"' + gt + displayTitle + '</a' + gt;
					// #todo classes and createElement
				}
				comma = ' ; ';



// Assuming you have a reference to your dialog element as 'dialog'
var dialogTop = 0;
var dialogLeft = 0;

if (window.innerHeight && window.innerWidth) {
  // Use more standard methods to get the window dimensions
  if (window.innerHeight / 2 < event.clientY) {
    // If the mouse cursor is below the middle, position the dialog mostly above the cursor
    dialogTop = (event.clientY - dialog.clientHeight) + 'px';
  } else {
    // Otherwise, position it below the mouse cursor
    dialogTop = (event.clientY) + 'px';
  }

  if (window.innerWidth / 2 < event.clientX) {
    // If the mouse cursor is to the right of center, position dialog mostly to the left of the cursor
    dialogLeft = (event.clientX - dialog.clientWidth) + 'px';
  } else {
    // Otherwise, position it to the right of the mouse cursor
    dialogLeft = (event.clientX) + 'px';
  }
} else {
  dialogTop = (event.clientY) + 'px';
  dialogLeft = (event.clientX) + 'px';
}

dialog.style.top = dialogTop;
dialog.style.left = dialogLeft;






			var dialogTop = 0;
			var dialogLeft = 0;

			if (window.innerHeight && window.innerHeight) { // #todo use more standard methods
				//alert('DEBUG: SpotlightDialog: window.innerWidth = ' + window.innerWidth + '; window.innerHeight = ' + window.innerHeight);

				if (window.innerHeight / 2 < event.clientY) {
				// if mouse cursor is below middle, position dialog mostly above cursor
					dialogTop = (event.clientY - dialog.style.height) + 'px';
				} else {
				// else, position it below mouse cursor
					dialogTop = (event.clientY + 35) + 'px';
				}


				// if mouse cursor is to the right of center, position dialog mostly to the left of cursor
				// else, position it to the right of mouse cursor
			} else {
				var dialogTop = (event.clientY - 35) + 'px';
				var dialogLeft = (event.clientX - 15) + 'px';
			}

			dialog.style.top = dialogTop;
			dialog.style.left = dialogLeft;



// SpotlightDialog :

		if (t) {
			//alert('DEBUG: SpotlightDialog: t found');
			if (GetParentDialog(t)) {
				if ((window.GetPrefs) && (window.SetPrefs)) {
					if (!GetPrefs('draggable')) {
						SetPrefs('draggable', '1');
					}
				}
				//alert('DEBUG: SpotlightDialog: GetParentDialog(t) found');
				var tParent = GetParentDialog(t);
				if (tParent && tParent.getClientBoundingRect) {
					//alert('DEBUG: SpotlightDialog: tParent.getClientBoundingRect found');
					var tRect = tParent.getClientBoundingRect();
					var tTop = tRect.top;
					var tLeft = tRect.left;
					var tHeight = tRect.height;
					var tWidth = tRect.width;
					var tBottom = tTop + tHeight;
					var tRight = tLeft + tWidth;

					var dRect = dialog.getClientBoundingRect();
					var dTop = dRect.top;
					var dLeft = dRect.left;
					var dHeight = dRect.height;
					var dWidth = dRect.width;
					var dBottom = dTop + dHeight;
					var dRight = dLeft + dWidth;

					var dialogTop = (tTop - 5) + 'px';
					var dialogLeft = (tLeft - 5) + 'px';

					dialog.style.top = dialogTop;
					dialog.style.left = dialogLeft;

					//alert('DEBUG: SpotlightDialog: dialogTop = ' + dialogTop + ', dialogLeft = ' + dialogLeft);
				} else {
					// #todo
				}
			} else {
				// #todo
			}
		} else {
			//alert('DEBUG: SpotlightDialog: t not found');

			var dialogTop = (event.clientY - 5) + 'px';
			var dialogLeft = (event.clientX - 5) + 'px';

			dialog.style.top = dialogTop;
			dialog.style.left = dialogLeft;
		}

		/////////////////////////////////////

		var dialogTop = (event.clientY - 5) + 'px';
		var dialogLeft = (event.clientX - 5) + 'px';

		dialog.style.top = dialogTop;
		dialog.style.left = dialogLeft;






		if (
			t.textContent &&
			(
				t.textContent == 'cart'
			)
		) {
			sortMethod = 4; // perform add all to cart #todo
		}





	function resetButtonOnMouseOut () {
		if (document.getElementById) {
			var btnReset = document.getElementById('btnReset');
			if (btnReset) {
				btnReset.innerHTML = 'RESET'
			}
		}
	}


	if (document.getElementById && this.innerHTML) {
		if (this.innerHTML.indexOf('YES') != -1) {
			// let it happen
			if (window.resetButtonOnClick) {
				document.getElementById('aButtonReset').onclick = window.resetButtonOnClick; // setAttribute?
				window.resetButtonOnClick = '';
			}
		} else {
			window.resetButtonOnClick = document.getElementById('aButtonReset').onclick; // getAttribute?
			document.getElementById('aButtonReset').onclick = '' // setAttribute?
			this.innerHTML = '<font color=#606060>R</font><font color=#00c000>YES</font><font color=#606060>T</font>';
			this.setAttribute('onmouseout', 'resetButtonOnMouseOut');
			return false;
		}
	} else {
		// todo
	}



			var walkUp = comment;
			while (walkUp != document.body) {
				walkUp.style.maxWidth = '95%';
				walkUp = walkUp.parentElement;
			}



		document.frmReply.comment.value = commtext + "\n\n" + window.location.href;



		if (voteValue == 'hide' && window.GetParentDialog) {
			// if we clicked a 'hide' vote, hide the parent dialog
			//alert('DEBUG: IncrementTagLink: special case for voteValue == hide');
			var parentDialog = GetParentDialog(t);
			HideDialog(parentDialog);
		}



module.exports = function toUTCString() {
		thisTimeValue(this); // to brand check

		var day = $getUTCDay(this);
		var date = $getUTCDate(this);
		var month = $getUTCMonth(this);
		var year = $getUTCFullYear(this);
		var hour = $getUTCHours(this);
		var minute = $getUTCMinutes(this);
		var second = $getUTCSeconds(this);
		return dayNames[day] + ', '
				+ (date < 10 ? '0' + date : date) + ' '
				+ monthNames[month] + ' '
				+ year + ' '
				+ (hour < 10 ? '0' + hour : hour) + ':'
				+ (minute < 10 ? '0' + minute : minute) + ':'
				+ (second < 10 ? '0' + second : second) + ' GMT';






const myFunction = async() => {
	console.log(await a + await b);
};
myFunction();


						if (!window.clockInitialValue) {
							window.clockInitialValue = document.frmTopMenu.txtClock.value;
						}



	if (GetPrefs('draggable_restore_collapsed') && !GetPrefs('draggable_restore')) {
		// if we restore closed state, but NOT restore position, reflow the dialogs again
		DraggingMakeFit(1)
	}





function selectLoadKey (keyName) {
	var newKey = GetPrefs(keyName, 'PrivateKey1');
	if (newKey) {
		setPrivateKeyFromTxt(newKey);
		// #todo: if author name is not already stored in PrivateKeyName, store it:
		//if (!GetPrefs(keyName, 'PrivateKeyName')) {
		//	var authorName = window.localStorage.getItem('authorName');
		//}
		if (document.compose.comment) {
			document.compose.comment.value = newKey;
			document.compose.submit();
		}
	}
}



	if (document.getElementById) {
		var topmenu = document.getElementById('topmenu');
		if (topmenu && (window.GetConfig) && GetConfig('draggable')) {
			topmenu.style.position = 'fixed';
			topmenu.style.top = '0';
			topmenu.style.left = '0';
		}
	}



				var labelLoadFromFile = document.getElementById('fileLoadKeyFromText');
				if (!labelLoadFromFile) {
					// label for "load from file" button
					var labelLoadFromFile = document.createElement('label');
					labelLoadFromFile.setAttribute('for', 'fileLoadKeyFromText');
					labelLoadFromFile.innerHTML = 'Load profile key from saved file:';

					// br after label
					var brLoadFromFile = document.createElement('br');
					labelLoadFromFile.appendChild(brLoadFromFile);

					// [load from file] file selector
					var fileLoadKeyFromText = document.createElement('input');
					fileLoadKeyFromText.setAttribute('type', 'file');
					fileLoadKeyFromText.setAttribute('accept', 'text/plain');
					fileLoadKeyFromText.setAttribute(
						'onchange',
						 'if (window.openFile) { openFile(event) } else { alert("i am so sorry, openFile() function was missing!"); }'
					);
					fileLoadKeyFromText.setAttribute('id', 'fileLoadKeyFromText');
					// fileLoadKeyFromText.setAttribute('style', 'display: none');
					// i tried hiding file selector and using a button instead.
					// it looked nicer, but sometimes didn't work as expected

					// pLoadKeyFromTxt.appendChild(aLoadKeyFromText);
					labelLoadFromFile.appendChild(fileLoadKeyFromText);
					var brLoadFromFile2 = document.createElement('br');
					pLoadKeyFromTxt.appendChild(labelLoadFromFile);
					pLoadKeyFromTxt.appendChild(brLoadFromFile2);


					fieldset.appendChild(pLoadKeyFromTxt);
				}





							if (window.SetInterfaceMode) {
				SetInterfaceMode('expert', this);

				DraggingInit(0);
				DraggingMakeFit(0);
				DraggingRetile();
				DraggingInit(0);
				SetPrefs('draggable_spawn', 1);
				SetPrefs('draggable_activate', 1);


				if (window.DraggingMakeFit) {
					DraggingMakeFit();
				}
				if ((window.SetActiveDialog) && (window.GetParentDialog)) {
					SetActiveDialog(GetParentDialog(this));
				}
				return false;
			}


	if (!window.eventLoopReadCookie) {
		window.eventLoopReadCookie = 1;
		var cookieValue = GetCookie('eventLoopEnabled');
		if (window.GetCookie && (window.eventLoopEnabled != cookieValue)) {
			window.eventLoopEnabled = GetCookie('eventLoopEnabled');
		}
	}

		window.eventLoopEnabled = !window.eventLoopEnabled;
		if (window.SetCookie) {
			SetCookie('eventLoopEnabled', !!window.eventLoopEnabled);
		}
		if (window.EventLoop && window.eventLoopEnabled) {
			EventLoop();
		} else {
			if (window.timeoutEventLoop) {
				clearTimeout(window.timeoutEventLoop);
			}
		}
		this.innerHTML = 'event-loop: ' + (!!window.eventLoopEnabled);
		return false;



	for (var i = 0; i < localStorage.length; i++) {
		var lsKey = localStorage.key(i);
		var lsValue = localStorage.getItem(lsKey);

		alert(lsKey + '=' + lsValue);
	}



//
//function UrlExists2(url, callback) { // checks if url exists
//// todo use async and callback
//// todo how to do pre-xhr browsers?
//    //alert('DEBUG: UrlExists(' + url + ')');
//
//	if (window.XMLHttpRequest) {
//	    //alert('DEBUG: UrlExists: window.XMLHttpRequest check passed');
//
//        var xhttp = new XMLHttpRequest();
//        xhttp.onreadystatechange = function() {
//    if (this.readyState == 4 && this.status == 200) {
//       // Typical action to be performed when the document is ready:
//       document.getElementById("demo").innerHTML = xhttp.responseText;
//    }
//};
//xhttp.open("GET", "filename", true);
//xhttp.send();
//
//
//
//		var http = new XMLHttpRequest();
//		http.open('HEAD', url, false);
//		http.send();
//		var httpStatusReturned = http.status;
//
//		//alert('DEBUG: UrlExists: httpStatusReturned = ' + httpStatusReturned);
//
//		return (httpStatusReturned == 200);
//	}
//}




		//var reader1 = new FileReader();
		//reader1.onload = function (event) {
		//	var imgImagePreview = document.getElementById('imgImagePreview');
		//	if (imgImagePreview) {
		//		imgImagePreview.style.display = 'inline';
		//		imgImagePreview.setAttribute('src', event.target.result);
		//	}
		//}
		//reader1.readAsDataURL(e.clipboardData.files.asBlob);

		/*
		var frm1 = document.createElement('form');
		frm1.setAttribute('action', '/upload.php');
		frm1.setAttribute('method', 'post');
		frm1.setAttribute('enctype', 'multipart/form-data');
		
		var input1 = document.createElement('input');
		input1.setAttribute('type', 'file');
		input1.setAttribute('name', 'uploaded_file');
		
		var sub1 = document.createElement('input');
		sub1.setAttribute('type', 'submit');
		
		frm1.appendChild(input1);
		frm1.appendChild(sub1);
		window.document.body.appendChild(frm1);
		*/




TagCloud = {
	//Color hues
	ca: [51,102,102],
	cz: [0,102,255],

	min_font_size: 12,
	max_font_size: 35,

	generate: function(all_tags, all_words) {
		var self = this, colors=[], font_size;

		var ul = UL({c: 'plurk-cloud'});

		map(all_words, function(t)  {
			for (var i=0; i<3; i++)
				colors[i] = self._score(self.ca[i], self.cz[i], all_tags[t]);

			font_size = self._score(self.min_font_size, self.max_font_size, all_tags[t]);

			var color_attr = 'color:rgb('+colors[0]+','+colors[1]+','+colors[2]+')';
			var li = LI({s: 'font-size:'+ font_size + 'px'},
				SPAN({s: color_attr}, t)
			);

			ACN(ul, li, ' ');
		});

		return DIV({c: 'plurk-tags'}, ul);
	},

	_score: function(a, b, counts) {
		//reducer impacts color and font size, choosing a bigger will make the font smaller
		var reducer = 11;
		var m = Math.abs(a-b) / Math.log(reducer);

		if(a > b)
			return a - Math.floor(Math.log(counts) * m);
		else
			return Math.floor(Math.log(counts) * m + a);
	}
}

var TAGS = ${ json(tags) };
var WORDS = ${ json( sorted(tags.keys()) ) };
RCN($('tags'), TagCloud.generate(TAGS, WORDS));













/* dragging.js */
// props https://www.w3schools.com/howto/howto_js_draggable.asp

/*
		#mydiv {
			position: absolute;
			z-index: 9;
		}

		#mydivheader {
			this is just the titlebar
		}
*/

window.draggingZ = 0;

function dragElement (elmnt, header) {
	var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

	if (header) {
		// if present, the header is where you move the DIV from:
		header.onmousedown = 'dragMouseDown(this)';
	} else {
		// otherwise, move the DIV from anywhere inside the DIV:
		elmnt.onmousedown = 'dragMouseDown(this)';
	}

	var rect = elmnt.getBoundingClientRect();

	elmnt.style.position = 'absolute';
	elmnt.style.top = (rect.top) + "px";
	elmnt.style.left = (rect.left) + "px";

	//console.log(rect.top, rect.right, rect.bottom, rect.left);
	//elmnt.style.position = 'absolute';
	//elmnt.style.z-index = '9';
}

function dragMouseDown(elmnt) {
	e = window.event;

	e.preventDefault();

	// get the mouse cursor position at startup:
	pos3 = e.clientX;
	pos4 = e.clientY;

	document.onmouseup = 'closeDragElement(elmnt)';
	// call a function whenever the cursor moves:
	document.onmousemove = 'elementDrag(elmnt)';

	elmnt.style.zIndex = ++window.draggingZ;
}

function elementDrag(e) {
	//document.title = pos1 + ',' + pos2 + ',' + pos3 + ',' + pos4;
	//document.title = e.clientX + ',' + e.clientY;
	//document.title = elmnt.offsetTop + ',' + elmnt.offsetLeft;
	e = e || window.event;
	e.preventDefault();
	// calculate the new cursor position:
	pos1 = pos3 - e.clientX;
	pos2 = pos4 - e.clientY;
	pos3 = e.clientX;
	pos4 = e.clientY;
	// set the element's new position:

	elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
	elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
}

function closeDragElement(elmnt) {
	// stop moving when mouse button is released:
	document.onmouseup = '';
	document.onmousemove = '';

	if (elmnt) {
		SaveWindowState(elmnt);
		elmnt.style.zIndex = ++window.draggingZ;
		// keep incrementing the global zindex counter
	}
//
//		if (elmnt.id) {
//			if (window.SetPrefs) {
//				SetPrefs(elmnt.id + '.style.top', elmnt.style.top);
//				SetPrefs(elmnt.id + '.style.left', elmnt.style.left);
//			}
//		}
}

function SaveWindowState (elmnt) {
	var allTitlebar = elmnt.getElementsByClassName('titlebar');
	var firstTitlebar = allTitlebar[0];

	if (firstTitlebar && firstTitlebar.getElementsByTagName) {
		var elId = firstTitlebar.getElementsByTagName('b');
		if (elId && elId[0]) {
			elId = elId[0];

			if (elId && elId.innerHTML.length < 31) {
				SetPrefs(elId.innerHTML + '.style.top', elmnt.style.top);
				SetPrefs(elId.innerHTML + '.style.left', elmnt.style.left);
//				elements[i].style.top = GetPrefs(elId.innerHTML + '.style.top') || elId.style.top;
//				elements[i].style.left = GetPrefs(elId.innerHTML + '.style.left') || elId.style.left;
			} else {
				//alert('DEBUG: SaveWindowState: elId is false');
			}
		}
	}
}

function ArrangeAll () {
	//alert('DEBUG: DraggingInit: doPosition = ' + doPosition);
	var elements = document.getElementsByClassName('dialog');
	//for (var i = 0; i < elements.length; i++) {
	for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
		elements[i].setAttribute('style', '');
//
//		var btnSkip = elements[i].getElementsByClassName('skip');
//		if (btnSkip && btnSkip[0]) {
//			btnSkip[0].click();
//		}
	}
}

function DraggingInit (doPosition) {
// initializes all class=dialog elements on the page to be draggable
	if (!document.getElementsByClassName) {
		//alert('DEBUG: DraggingInit: sanity check failed, document.getElementsByClassName was FALSE');
		return '';
	}

	if (doPosition) {
		doPosition = 1;
	} else {
		doPosition = 0;
	}

	//alert('DEBUG: DraggingInit: doPosition = ' + doPosition);
	var elements = document.getElementsByClassName('dialog');
	//for (var i = 0; i < elements.length; i++) {
	for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
		var allTitlebar = elements[i].getElementsByClassName('titlebar');
		var firstTitlebar = allTitlebar[0];

		if (firstTitlebar && firstTitlebar.getElementsByTagName) {
			dragElement(elements[i], firstTitlebar);
			var elId = firstTitlebar.getElementsByTagName('b');
			elId = elId[0];
			if (doPosition && elId && elId.innerHTML.length < 31) {
				elements[i].style.top = GetPrefs(elId.innerHTML + '.style.top') || elements[i].style.top;
				elements[i].style.left = GetPrefs(elId.innerHTML + '.style.left') || elements[i].style.left;
			} else {
				//alert('DEBUG: DraggingInit: elId is false');
			}
		}
	}

	return '';
} // DraggingInit()

/* / dragging.js */




=============================


//		if (elements[i].id && window.GetPrefs) {
//			var elTop = GetPrefs(elements[i].id + '.style.top');
//			var elLeft = GetPrefs(elements[i].id + '.style.left');
//
//			if (elTop && elLeft) {
//				elmnt.style.left = elLeft;
//				elmnt.style.top = elTop;
//			}
//
//			//var elTop = window.elementPosCounter || 1;
//			//var elTop = GetPrefs(elements[i].id + '.style.top');
//			//window.elementPosCounter += elmnt.style.height;
//
//			//var elLeft = GetPrefs(elements[i].id + '.style.left') || 1;
//
//			//if (elTop && elLeft) {
//				//elmnt.style.left = elLeft;
//				//elmnt.style.top = elTop;
//			//}
//		} else {
//			//alert('DEBUG: dragging.js: warning: id and/or GetPrefs() missing');
//		}
//		//dragElement(elements[i], firstTitlebar);





<div id='photos-preview'></div>
<input type="file" id="fileupload" multiple (change)="handleFileInput($event.target.files)" />
JS:

 function handleFileInput(fileList: FileList) {
		const preview = document.getElementById('photos-preview');
		Array.from(fileList).forEach((file: File) => {
			const reader = new FileReader();
			reader.onload = () => {
			  var image = new Image();
			  image.src = String(reader.result);
			  preview.appendChild(image);
			}
			reader.readAsDataURL(file);
		});
	}




function previewImages() {

  var preview = document.querySelector('#preview');

  if (this.files) {
	[].forEach.call(this.files, readAndPreview);
  }

  function readAndPreview(file) {

	// Make sure `file.name` matches our extensions criteria
	if (!/\.(jpe?g|png|gif)$/i.test(file.name)) {
	  return alert(file.name + " is not an image");
	} // else...

	var reader = new FileReader();

	reader.addEventListener("load", function() {
	  var image = new Image();
	  image.height = 100;
	  image.title  = file.name;
	  image.src    = this.result;
	  preview.appendChild(image);
	});

	reader.readAsDataURL(file);

  }

}

document.querySelector('#file-input').addEventListener("change", previewImages);



<script type="text/javascript">function addEvent(b,a,c){if(b.addEventListener){b.addEventListener(a,c,false);return true}else return b.attachEvent?b.attachEvent("on"+a,c):false}
var cid,lid,sp,et,pint=6E4,pdk=1.2,pfl=20,mb=0,mdrn=1,fixhead=0,dmcss='//d217i264rvtnq0.cloudfront.net/styles/mefi/dark-mode20200421.2810.css';
















export default function potpack(boxes) {

	// calculate total box area and maximum box width
	let area = 0;
	let maxWidth = 0;

	for (const box of boxes) {
		area += box.w * box.h;
		maxWidth = Math.max(maxWidth, box.w);
	}

	// sort the boxes for insertion by height, descending
	boxes.sort((a, b) => b.h - a.h);

	// aim for a squarish resulting container,
	// slightly adjusted for sub-100% space utilization
	const startWidth = Math.max(Math.ceil(Math.sqrt(area / 0.95)), maxWidth);

	// start with a single empty space, unbounded at the bottom
	const spaces = [{x: 0, y: 0, w: startWidth, h: Infinity}];

	let width = 0;
	let height = 0;

	for (const box of boxes) {
		// look through spaces backwards so that we check smaller spaces first
		for (let i = spaces.length - 1; i >= 0; i--) {
			const space = spaces[i];

			// look for empty spaces that can accommodate the current box
			if (box.w > space.w || box.h > space.h) continue;

			// found the space; add the box to its top-left corner
			// |-------|-------|
			// |  box  |       |
			// |_______|       |
			// |         space |
			// |_______________|
			box.x = space.x;
			box.y = space.y;

			height = Math.max(height, box.y + box.h);
			width = Math.max(width, box.x + box.w);

			if (box.w === space.w && box.h === space.h) {
				// space matches the box exactly; remove it
				const last = spaces.pop();
				if (i < spaces.length) spaces[i] = last;

			} else if (box.h === space.h) {
				// space matches the box height; update it accordingly
				// |-------|---------------|
				// |  box  | updated space |
				// |_______|_______________|
				space.x += box.w;
				space.w -= box.w;

			} else if (box.w === space.w) {
				// space matches the box width; update it accordingly
				// |---------------|
				// |      box      |
				// |_______________|
				// | updated space |
				// |_______________|
				space.y += box.h;
				space.h -= box.h;

			} else {
				// otherwise the box splits the space into two spaces
				// |-------|-----------|
				// |  box  | new space |
				// |_______|___________|
				// | updated space     |
				// |___________________|
				spaces.push({
					x: space.x + box.w,
					y: space.y,
					w: space.w - box.w,
					h: box.h
				});
				space.y += box.h;
				space.h -= box.h;
			}
			break;
		}
	}

	return {
		w: width, // container width
		h: height, // container height
		fill: (area / (width * height)) || 0 // space utilization
	};
}


var d = new Date();// # js time() cheatsheet
var n = d.getTime();// # js time() cheatsheet
n = Math.ceil(n / 1000);// # js time() cheatsheet

