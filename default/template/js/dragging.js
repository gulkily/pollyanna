/* dragging.js */
// allows dragging of boxes on page with the mouse pointer

/*
	known issues:
	* problem: syntax errors on older browsers like netscape and ie3
	  proposed solution: remove nested function declarations
	  -or-
	  make dragging.js an external library like openpgp.js

	* problem: no keyboard alternative at this time
	  proposed solution: somehow allow moving through windows and moving them with keyboard

	* problem: slow and janky, needs more polish
	  proposed solution: optimizations, more elbow grease
*/

// props https://www.w3schools.com/howto/howto_js_draggable.asp

window.draggingZ = 0; // keeps track of the topmost box's zindex
// incremented whenever dragging is initiated, that way element pops to top

function dragElement (elmnt, header) { // initialize draggable state for dialog
	//alert('DEBUG: dragElement()');

	var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
	if (header) {
		// if present, the header is where you move the DIV from:
		header.onmousedown = dragMouseDown;
		//header.ontouchstart = dragMouseDown; // #touchdrag
	} else {
		// otherwise, move the DIV from anywhere inside the DIV:
		elmnt.onmousedown = dragMouseDown;
		//elmnt.ontouchstart = dragMouseDown; // #touchdrag
	}

	// set element's position based on its initial box model position
	var rect = elmnt.getBoundingClientRect();
	elmnt.style.top = (rect.top) + "px";
	elmnt.style.left = (rect.left) + "px";
	elmnt.style.position = 'absolute';
	elmnt.style.display = 'table';

	UpdateDialogPropertyDialog(elmnt);

	//console.log(rect.top, rect.right, rect.bottom, rect.left);
	//elmnt.style.position = 'absolute';
	//elmnt.style.z-index = '9';

	function dragMouseDown (e) {
		//alert('DEBUG: dragMouseDown');
		//SetActiveDialog(elmnt);
		window.dialogDragInProgress = 1;

		e = e || window.event;
		e.preventDefault();
		// get the mouse cursor position at startup:
		pos3 = e.clientX;
		pos4 = e.clientY;

		document.onmouseup = closeDragElement;
		//document.ontouchend = closeDragElement; // #touchdrag
		// call a function whenever the cursor moves:
		document.onmousemove = elementDrag;
		//document.ontouchmove = elementDrag; // #touchdrag
	}

	function elementDrag (e) {
		//alert('DEBUG: elementDrag');
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

		UpdateDialogPropertyDialog(elmnt);
	}

	function closeDragElement () {
		//alert('DEBUG: closeDragElement');
		window.dialogDragInProgress = 0;

		// stop moving when mouse button is released:
		document.onmouseup = null;
		document.onmousemove = null;

		//document.ontouchend = null; // #touchdrag
		//document.ontouchmove = null; // #touchdrag

		SaveDialogPosition(elmnt);
	}
} // dragElement()

function SaveDialogPosition (elmnt) {
// function SaveWindowPosition () {
// function SavePosition () {

	if (elmnt) {
		var elId = GetDialogId(elmnt);

		if (elId && elId.length < 31) {
			SetPrefs(elId + '.style.top', elmnt.style.top, 'dialogPosition');
			SetPrefs(elId + '.style.left', elmnt.style.left, 'dialogPosition');
		} else {
			//alert('DEBUG: SaveDialogPosition: warning: elId is false');
		}
	} else {
		//alert('DEBUG: SaveDialogPosition: warning: elmnt is false');
	}
} // SaveDialogPosition()

function AddToDialogHistory (dialog) {
	// #todo sanity checks
	var dialogHistory = GetPrefs('dialog_history');
	if (!dialogHistory) {
		dialogHistory = dialog + '\n';
	} else {
		dialogHistory = dialogHistory + '\n' + dialog;
	}
	SetPrefs('dialog_history', dialogHistory);
} // AddToDialogHistory()

function DraggingSaveAllDialogPositions () {
	//alert('DEBUG: DraggingSaveAllDialogPositions()');
	var elements = document.getElementsByClassName('dialog');

	for (var i = elements.length - 1; 0 <= i; i--) {
		SaveDialogPosition(elements[i]);
	}
} // DraggingSaveAllDialogPositions()

function CollapseAll () {
	//alert('DEBUG: CollapseAll()');
	if (document.getElementsByClassName) {
		var elements = document.getElementsByClassName('dialog');
		for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
			if (elements[i].getAttribute('id') == 'topmenu') {
				// controls dialog
			} else {
				CollapseWindow(elements[i], 'none'); // CollapseAll()
			}
		}
	}
} // CollapseAll()

function CollapseMost () {
	//alert('DEBUG: CollapseMost()');
	if (document.getElementsByClassName) {
		var elements = document.getElementsByClassName('dialog');
		var changesMade = 0;
		for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
			if (elements[i].getAttribute('id') == 'topmenu') {
				// controls dialog
			} else {
				changesMade += CollapseWindow(elements[i], 'none'); // CollapseMost()
			}
		}

		return changesMade;
	}

	return '';
} // CollapseMost()

function ExpandAll () {
	//alert('DEBUG: ExpandAll()');
	if (document.getElementsByClassName) {
		var elements = document.getElementsByClassName('dialog');
		for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
			if (elements[i].getAttribute('id') == 'topmenu') {
				// controls dialog
			} else {
				CollapseWindow(elements[i], 'initial'); // ExpandAll()
			}
		}
	}
} // ExpandAll()

function DraggingRetile () {
	return DraggingRetile2(1);

} // DraggingRetile()

function DraggingRetile2 (ignoreMenu) {
	//alert('DEBUG: DraggingRetile()');

	window.scrollTo(0, 0);

	if (document.getElementsByClassName) {
		//alert('DEBUG: DraggingRetile: document.getElementsByClassName feature check PASSED');
		var elements = document.getElementsByClassName('dialog');

		for (var i = elements.length - 1; 0 <= i; i--) {
			if ((!ignoreMenu) || (elements[i].getAttribute('id') == 'topmenu')) { // controls dialog
				// do not reposition the controls dialog
			} else {
				elements[i].style.position = 'static';
				elements[i].style.display = 'inline-block';
			}
		}
	} else {
		//alert('DEBUG: DraggingRetile: document.getElementsByClassName is FALSE');
		return '';
	}
//	for (var i = elements.length - 1; 0 <= i; i--) {
//		var newTop = elements[i].style.top;
//		var newLeft = elements[i].style.left;
//		elements[i].style.position = 'absolute';
//		elements[i].style.top = newTop;
//		elements[i].style.left = newLeft;
//	}
//
//	DraggingInit(0);
} // DraggingRetile2()

function UpdateDialogPropertyDialog (dialog) {
	if (dialog && window.getComputedStyle && document.getElementById && document.getElementById('propDisplay')) {
		var d = new Date();
		if (
			(!window.propRecentUpdate)
				||
			(100 < (d.getTime() - window.propRecentUpdate))
		) {
			var s = getComputedStyle(dialog);
			if (s) {
				document.getElementById('propDisplay').innerHTML = s.display;
				document.getElementById('propPosition').innerHTML = s.position;
				document.getElementById('propZindex').innerHTML = s.zIndex;
				document.getElementById('propLeft').innerHTML = s.left;
				document.getElementById('propTop').innerHTML = s.top;
				document.getElementById('propWidth').innerHTML = s.width;
				document.getElementById('propHeight').innerHTML = s.height;
				document.getElementById('propRight').innerHTML = s.right;
				document.getElementById('propBottom').innerHTML = s.bottom;
			}

			var allTitlebar = dialog.getElementsByClassName('titlebar');
			if (allTitlebar) {
				var firstTitlebar = allTitlebar[0];
				if (firstTitlebar) {
					//document.title = firstTitlebar.innerHTML;
				}
			}

			window.propRecentUpdate = d.getTime();
		}
	}
} // UpdateDialogPropertyDialog();

function SetActiveDialogDelay (ths) {
	//alert();
		//set next window to focus to

		window.nextWindowToFocusTo = ths;

		//set timeout to focus to that window

		setTimeout('window.SetActiveDialog(window.nextWindowToFocusTo);', 130);
} // SetActiveDialogDelay()

function SetActiveDialog (ths) {
// function ActivateDialog () {
// function FocusMe () {
// function ShowMe () {
// function ActivateMe () {
// function ShowDialog () {

	if (!(window.GetPrefs) || !GetPrefs('draggable') || !GetPrefs('draggable_activate')) {
		// #todo optimize
		return '';
	}

	if (ths && ths.getAttribute('imactive') == '1') {
		//alert('DEBUG: SetActiveDialog: cancelled due to imactive');
		return true;
	} else if (window.dialogDragInProgress) {
		//alert('DEBUG: SetActiveDialog: cancelled due to window.dialogDragInProgress');
		return true;
	}

	//alert('DEBUG: SetActiveDialog: conditions met!');

	window.nextWindowToFocusTo = ths;
	// window.nextWindowToFocusTo stores the next window to focus to for mouseover
	// there is a short delay before a window gets focus after a mouseover
	// otherwise the interface gets jittery

	//alert('DEBUG: SetActiveDialog(ths = ' + ths + ')');
		// #thoughts should this be dependent on GetPrefs?
		// or should it unintentionally come on if GetPrefs() is not available?

	if (ths) {
		ths.style.zIndex = ++window.draggingZ;
		// document.title = window.draggingZ;
	}

	//draggable_activate
	var colorWindow = ''; // for templating
	var colorTitlebar = ''; // for templating
	var colorTitlebarInactive = ''; // for templating
	var colorSecondary = ''; // for templating
	var colorTitlebarText = ''; // for templating

	var doScale = GetPrefs('draggable_scale') ? 1 : 0; // SetActiveDialog()
	var scaleLarge = '1.9';
	var scaleSmall = '1.0';
	// this doesn't work right  yet, but loks promising

	var elements = document.getElementsByClassName('dialog');
	for (var i = 0; i < elements.length; i++) {
	// for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
		// walking backwards is necessary to preserve the element positioning on the page
		// once we remove the element from the page flow, all the other elements reflow to account it
		// if we walk forwards here, all the elements will end up in the top left corner
		if (ths && elements[i] == ths) {
			elements[i].setAttribute('imactive', '1');
			elements[i].style.borderColor = colorTitlebar;

			//var comStyle = window.getComputedStyle(elements[i], null);
			//var iwidth = parseInt(comStyle.getPropertyValue("width"), 10);
			//var iheight = parseInt(comStyle.getPropertyValue("height"), 10);
			////alert('DEBUG: SetActiveDialog: iwidth: ' + document.documentElement.clientWidth + ', iheight:' + iheight);
			////alert('DEBUG: SetActiveDialog: document.documentElement.clientWidth and .clientHeight: ' + document.documentElement.clientWidth + ',' + document.documentElement.clientHeight);
			////alert('DEBUG: SetActiveDialog: myScale = ' + myScale);

		} else {
			elements[i].setAttribute('imactive', '0');
			elements[i].style.borderColor = colorTitlebarInactive;
		}

		if (elements[i].getAttribute('imactive') == 1) {
			if (doScale) {
				// this doesn't work yet, and there's no ui for the setting yet
				//var myScale = 1 + (document.documentElement.clientWidth / (iwidth * 3));
				var myScale = scaleLarge;

				elements[i].style.transition = 'transform 0.15s';
				//elements[i].style.transform = 'scale(' + myScale + ')';
				elements[i].style.transform = 'scale(' + myScale + ')';
				elements[i].style.transformOrigin = 'top left';

				var css = window.getComputedStyle(elements[i]);
//				document.title =
//					css.getPropertyValue('top') +
//					',' +
//					css.getPropertyValue('left') +
//					',' +
//					css.getPropertyValue('height') +
//					',' +
//					css.getPropertyValue('width') +
//					'...'
//				;
			}
		} // imactive
		else {
			if (doScale) { // always de-scale window, because it may have been scaled up before user turned off scaling
				//var myScale =(document.documentElement.clientWidth / (iwidth * 5));
				var myScale = scaleSmall;
				elements[i].style.transform = 'scale(' + myScale + ')';
				elements[i].style.transformOrigin = 'top left';

				//elements[i].style.transform = 'scale(0.5)';
				//elements[i].style.transformOrigin = 'top center';
			}
		} // not imactive

		var allTitlebar = elements[i].getElementsByClassName('titlebar'); // #todo factor out
		var firstTitlebar = allTitlebar[0];

		if (firstTitlebar && firstTitlebar.getElementsByTagName) {
			if ((ths && elements[i] == ths) || elements[i].getAttribute('imactive') == 1) {
				// active
				firstTitlebar.style.backgroundColor = colorTitlebar;
				firstTitlebar.style.color = colorTitlebarText;
				//elements[i].style.boxShadow = '0 0 15pt #335555;';
			} else {
				// inactive
				firstTitlebar.style.backgroundColor = colorSecondary;
				firstTitlebar.style.color = colorWindow;
				//elements[i].style.boxShadow = '';
			}
		}
	}

	//UpdateDialogPropertyDialog(ths);

	return true;
} // SetActiveDialog()

function GetParentDialog (el) {
	if (el) {
		var parentDialog = el;
		while (parentDialog && (parentDialog.className != 'dialog')) {
			parentDialog = parentDialog.parentElement;
		}
		if (parentDialog) {
			return parentDialog;
		}
	}
	return '';
} // GetParentDialog()

function DialogIsVisible (el) {
	if (el) {
		while (el) {
			elDisplay = el.style.display;
			//alert('DEBUG: DialogIsVisible: el = ' + el.tagName + ', elDisplay = ' + elDisplay);
			if (elDisplay == 'none') {
				return 0;
			}
			el = el.parentElement;
		}
		return 1;
	}
	return 0;
} // DialogIsVisible()

function SetContainingDialogActive (ths) { // sets active dialog based on control which received focus
//setfocus
	if (ths) {
		var parentDialog = ths;
		while (parentDialog && (parentDialog.className != 'dialog')) {
			parentDialog = parentDialog.parentElement;
		}
		if (parentDialog) {
			SetActiveDialog(parentDialog); // SetContainingDialogActive()
		}
	}
} // SetContainingDialogActive()

function DraggingReset () {
	//alert('DEBUG: DraggingReset()');

	if (document.getElementsByClassName) {
		// feature check
		//alert('DEBUG: DraggingReset: feature check success');

		localStorage.removeItem('dialogPosition'); // #todo this should be done via SetPrefs()

		// find all class=dialog elements and walk through them
		var elements = document.getElementsByClassName('dialog');
		for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
			// walking backwards is necessary to preserve the element positioning on the page
			// once we remove the element from the page flow, all the other elements reflow to account it
			// if we walk forwards here, all the elements will end up in the top left corner
			window.draggingZ++;
			DraggingInitDialog(elements[i], 0); // DraggingReset()
			CollapseWindow(elements[i], 'show'); // DraggingReset()
		} // for i in elements

		return '';
	} else {
		return '';
	}

	return '';
} // DraggingReset()

function ReopenDialogs () {
	//alert('DEBUG: ReopenDialogs()');

	// stored dialogs are stored as a JSON string in localStorage

	var dialogPosition = window.localStorage.getItem('dialogPosition');
	//alert('DEBUG: dialogPosition.length = ' + dialogPosition.length);

	// we need to parse that string into an object
	// then we can walk through the object and recreate the dialogs
	// #todo this should be done via SetPrefs()



	return '';
} // ReopenDialogs()

function DraggingCascade () {
// function CascadeDialogs () {
// function CascadeAll () {
	//alert('DEBUG: DraggingCascade()');
	
	var titlebarHeight = 0;

	var curTop = 55;
	var curLeft = 5;
	var curZ = 0;

	var maxLeft = document.documentElement.clientWidth / 2;

	var elements = document.getElementsByClassName('dialog');
	for (var i = 0; i < elements.length; i++) {
		var allTitlebar = elements[i].getElementsByClassName('titlebar'); // #todo factor out
		var firstTitlebar = allTitlebar[0];

		var allMenubar = elements[i].getElementsByClassName('menubar');
		var firstMenubar = allMenubar[0];

		titlebarHeight = 30;

		if (firstMenubar || elements[i].getAttribute('id') == 'topmenu') {
			elements[i].style.zIndex = 1337;
		} else {
			if (firstTitlebar && firstTitlebar.getElementsByTagName) {
				// dragElement(elements[i], firstTitlebar);

				if (elements[i].getAttribute('id') == 'topmenu') {
					// ignore the conrols dialog
				} else {
					if (
						elements[i].style.display != 'none' &&
						elements[i].parentElement.style.display != 'none' &&
						elements[i].parentElement.parentElement.style.display != 'none'
						// sometimes a dialog is hidden because its parent container is hidden
						// so here, we check two layers up
						// a bit of a hack, but it works
					) {
						curZ++;
						curTop += titlebarHeight;
						curLeft += titlebarHeight;

						if (maxLeft < curLeft) {
							curLeft = 5;
						}

						elements[i].style.top = curTop + 'px';
						elements[i].style.left = curLeft +'px';
						elements[i].style.zIndex = curZ;
					}
				}
			}
		}
	}
} // DraggingCascade()

function DraggingInitDialog (el, doPosition) {
// function DraggingRestoreDialogPosition () {
// function DraggingInitElement () {
// function RestorePosition () {

	if (!el) {
		//alert('DEBUG: DraggingInitDialog: warning: el argument is missing');
		return '';
	}

	var elId = GetDialogId(el);
	while (!elId && el && el.firstElement) {
		el = el.firstElement;
		elId = GetDialogId(el);
	}
	if (!elId) {}

	//alert('DEBUG: DraggingInitDialog: elId = ' + elId);

	// find all titlebars and remember the first one
	var allTitlebar = el.getElementsByClassName('titlebar');
	var firstTitlebar = allTitlebar[0];

	if (firstTitlebar) {
		//alert('DEBUG: DraggingInitDialog: titlebar found');
		dragElement(el, firstTitlebar);
		firstTitlebar.style.cursor = 'move';
		var titleTitle = firstTitlebar.getElementsByTagName('b');
		if (titleTitle) {
			titleTitle[0].style.cursor = 'inherit';
		}
	} else {
		//alert('DEBUG: DraggingInitDialog: titlebar missing');
		dragElement(el, el);
	}

	if (elId && elId.length < 31) {
		if (doPosition) {
			RestoreDialogPosition(el, elId);
		}

		if (GetPrefs('draggable_restore_collapsed')) { // chkDraggableRestore
			if (GetPrefs(elId + '.collapse', 'dialogPosition') == 'none') {
				CollapseWindow(el, 'none'); // DraggingInitDialog() // #meh
			} else {
				//ok
			}
		} else {
			// cool
		}
	} else {
		//alert('DEBUG: DraggingInitDialog: warning: elId is false 2');
	}
//
	//alert('DEBUG: DraggingInitDialog: finished');

	//elements[i].style.display = 'table !important';

	return '';
} // DraggingInitDialog()

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

function DraggingMakeFit (doPosition) { // initialize all class=dialog elements on the page to be draggable
// function DraggableMakeFit () {
// function ArrangeAll () {
// function DraggingArrange {

	//alert('DEBUG: DraggingMakeFit()');

	if (!document.getElementsByClassName) {
		// feature check
		//alert('DEBUG: DraggingInit: feature check failed');
		return '';
	}

	//if ((window.GetPrefs) && !GetPrefs('draggable')) {
	//	//alert('DEBUG: DraggingInit: warning: GetPrefs(draggable) was false, returning');
	//	return '';
	//}

	// find all class=dialog elements and walk through them
	var elements = document.getElementsByClassName('dialog');
	for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
		// walking backwards is necessary to preserve the element positioning on the page
		// once we remove the element from the page flow, all the other elements reflow to account it
		// if we walk forwards here, all the elements will end up in the top left corner
		window.draggingZ++;
		DraggingInitDialog(elements[i], doPosition); // DraggingMakeFit()
	} // for i in elements

	return '';
} // DraggingMakeFit()

function UnhideHiddenElements () {
	//alert('DEBUG: UnhideHiddenElements()');

	if (document.getElementById) {
		// this gets rid of the style which hides dialogs on
		// page load so that they can be positioned first
		// dragging_hide_dialogs.js
		// #todo optimize this
		if (document.getElementById('styleHideDialogs')) {
			if (document.getElementById('styleHideDialogs').remove) {
				document.getElementById('styleHideDialogs').remove();
			}
		}

		if (document.getElementById('loadingIndicator')) {
			// put loading indicator above other dialogs if it is on page
			document.getElementById('loadingIndicator').style.zIndex = 1336;
		}
	}
} // UnhideHiddenElements()

function DraggingInit (doPosition) { // initialize all class=dialog elements on the page to be draggable
// InitDrag {
// DragInit {
// initialize all class=dialog elements on the page to be draggable

	//alert('DEBUG: DraggingInit()');

	if (!document.getElementsByClassName) {
		// feature check
		//alert('DEBUG: DraggingInit: feature check failed');
		return '';
	}

	//if ((window.GetPrefs) && !GetPrefs('draggable')) {
	//	//alert('DEBUG: DraggingInit: warning: GetPrefs(draggable) was false, returning');
	//	return '';
	//}

	// also so that we can pass it on to DraggingInitDialog()
	var doPosition = GetPrefs('draggable_restore');

	UnhideHiddenElements();

	// ReopenDialogs();

	if (GetPrefs('draggable_reopen')) {
		//alert(1);
		var openDialogs = GetPrefs('opened_dialogs'); // DraggingInit()
		if (openDialogs) {
			var dialogsToOpen = openDialogs.split(',');
			openDialogs = '';
			if (dialogsToOpen.length) {
				for (var i = 0; i < dialogsToOpen.length; i++) {
					var dialogName = dialogsToOpen[i];
					if (dialogName) {
						if (dialogName == 0) {
							// skip
						}
						else if (document.getElementById(dialogName)) {
							// skip
						}
						else {
							if (openDialogs) {
								openDialogs = openDialogs + ',' + dialogName;
							} else {
								openDialogs = dialogName;
							}
						}
					}
				}
			}
			if (openDialogs) {
				// still something left to do after filtering
				var dialogUrl = '/dialog/' + openDialogs + '.html';
				FetchDialogFromUrl(dialogUrl);
			}

			// #todo 1: InsertFetchedDialog() should skip activating these dialogs
			// #todo 2: InsertFetchedDialog() should initialize all new dialogs, not just the first one
			// #todo 3: should skip all existing dialogs on page x
			// #todo 4: php should also be able to inject new dialogs
		}
	}

	// find all class=dialog elements and walk through them
	var elements = document.getElementsByClassName('dialog');
	for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
		// walking backwards is necessary to preserve the element positioning on the page
		// once we remove the element from the page flow, all the other elements reflow to account it
		// if we walk forwards here, all the elements will end up in the top left corner
		window.draggingZ++;

		DraggingInitDialog(elements[i], doPosition); // DraggingInit()
	} // for i in elements

	if (GetPrefs('draggable_activate')) {
		var elements = document.getElementsByTagName('A');
		for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
			elements[i].setAttribute('onfocus', 'SetContainingDialogActive(this)');
		}
		var elements = document.getElementsByTagName('INPUT');
		for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
			elements[i].setAttribute('onfocus', 'SetContainingDialogActive(this)');
		}
		var elements = document.getElementsByTagName('TEXTAREA');
		for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
			elements[i].setAttribute('onfocus', 'SetContainingDialogActive(this)');
		}
	} // if (GetPrefs('draggable_activate'))

	return '';

} // DraggingInit()

function CenterDialog (el) { // #todo rename and test
	//alert('DEBUG: CenterDialog()');


	if (el.style.display == 'none') {
		el.style.display = 'table';
		needResetStyleDisplay = 1;
	}

	var newTop = '200px';
	if (newTop) {
		el.style.top = newTop;
	}
	var newLeft = '100px';
	if (newLeft) {
		el.style.left = newLeft;
	}
	if (needResetStyleDisplay) {
		el.style.display = 'inline-block';
	}


	return '';

} // CenterDialog()

function RestoreDialogPosition (el, elId) {
// function RestoreWindowPosition {
	//alert('DEBUG: RestoreDialogPosition()');
	if (!elId) {
		elId = GetDialogId(el);
	}
	if (!elId) {
		//alert('DEBUG: RestoreDialogPosition: warning: elId missing');
		return '';
	}

	var needResetStyleDisplay = 0;
	if (el.style.display == 'none') {
		// #todo why are we setting it here and then resetting?
		// #needsdoc
		el.style.display = 'table';
		needResetStyleDisplay = 1;
	}

	var newTop = GetPrefs(elId + '.style.top', 'dialogPosition');
	if (newTop) {
		el.style.top = newTop;
	}
	var newLeft = GetPrefs(elId + '.style.left', 'dialogPosition');
	if (newLeft) {
		el.style.left = newLeft;
	}
	if (needResetStyleDisplay) {
		el.style.display = 'inline-block';
	}

	return '';
} // RestoreDialogPosition()

function GetDialogId (win) { // returns dialog id (based on id= or title bar caption)
	//alert('DEBUG: GetDialogId()');
	if (win && win.getElementsByClassName) {
		if (win && win.getAttribute && win.getAttribute('id')) {
			// easy
			//alert('DEBUG: GetDialogId: returning win.getAttribute(id) = ' + win.getAttribute('id') );
			return win.getAttribute('id');

		} else {
			// hard
			//alert('DEBUG: GetDialogId: hard mode!');

			var allTitlebar = win.getElementsByClassName('titlebar');
			var firstTitlebar = allTitlebar[0];

			if (firstTitlebar && firstTitlebar.getElementsByTagName) {
				var elId = firstTitlebar.getElementsByTagName('b');
				if (elId && elId[0]) {
					elId = elId[0];

					if (elId && elId.innerHTML) {
						if (elId.innerHTML.length <= 31) {
							//alert('DEBUG: GetDialogId: returning elId.innerHTML = ' + elId.innerHTML);

							return elId.innerHTML;
						} else {
							//alert('DEBUG: GetDialogId: returning elId.innerHTML.substr(0, 31) = ' + elId.innerHTML.substr(0, 31));

							return elId.innerHTML.substr(0, 31);
						}
					}
				}
			}
		}
	} else {
		//alert('GetDialogId: warning: fallback');
	}
	return '';
} // GetDialogId()

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

		// #todo if dialog itself has class=advanced, remove it
		//alert('DEBUG: SpotlightDialog: dialog.className = ' + dialog.className);
		// but also, move upwards, and check that any spans it's inside of have class=advanced, remove advanced from the class names of those spans
		var element = dialog;
		while (element.parentElement) {
			//alert('DEBUG: SpotlightDialog: element.tagName + element.className = ' + element.tagName + ',' + element.className);
			if (element.className == 'advanced') {
				//alert('advanced found');
				element.className = '';
				if (element.style.display == 'none') {
					element.style.display = '';
				}
				ShowAdvanced(1);
				// #todo multiple class names
			}
			if (element.className == 'admin') {
				//alert('admin found');
				element.className = '';
				if (element.style.display == 'none') {
					element.style.display = '';
				}
				ShowAdvanced(1);
				// #todo multiple class names
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
		var dialogTop = (event.clientY - 5) + 'px';
		var dialogLeft = (event.clientX - 5) + 'px';

		dialog.style.top = dialogTop;
		dialog.style.left = dialogLeft;

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

function HideDialog (dialog) { // takes dialog element as reference
	//alert('DEBUG: HideDialog: dialog = ' + dialog);
	if (dialog && dialog.style) {
		//alert('DEBUG: HideDialog: sanity check passed');
		dialog.style.display = 'none';
	}
} // HideDialog()

function UpdateDialogList () {
// PageMap pagemap dialog list
// pagemap.js
// dialoglist.js
// function DialogListDialog () {
// function UpdateListDialog () {
// dialog_list.template
// page_map.template
// #todo put this in a separate template that doesn't get injected unless html/page_map is on

	var lstDialog = document.getElementById('lstDialog');
	if (lstDialog) {
		var allOpenDialogs = document.getElementsByClassName('dialog');
		if (allOpenDialogs.length) {
//			var gt = unescape('%3E');
//			var listContent = '<form' + gt; // id=formListDialog name=formListDialog
			var listContent = ''; // id=formListDialog name=formListDialog
			for (var iDialog = 0; iDialog < allOpenDialogs.length; iDialog++) {
				var dialogTitle = GetDialogTitle(allOpenDialogs[iDialog]);
				var dialogId = GetDialogId(allOpenDialogs[iDialog]);

				if (!dialogId) {
					if (dialogTitle) {
						var newDialogId = dialogTitle.replace(' ', '');
						allOpenDialogs[iDialog].setAttribute('id', newDialogId);
						dialogId = newDialogId;
					}
				}

				var gt = unescape('%3E');

				if (24 < dialogTitle.length) {
					dialogTitle = dialogTitle.substr(0, 24);
				}
				if (dialogTitle == '') {
					//alert('DEBUG: UpdateDialogList: warning: dialogTitle is empty');
					dialogTitle = dialogId || 'Untitled';
				}


				listContent = listContent + '<a href="#' + dialogId + '" onclick="if (window.SpotlightDialog) { return SpotlightDialog(\'' + dialogId + '\', this); }"' + gt + dialogTitle + '</a' + gt + '<br' + gt;
				//listContent = listContent + '<label for="c' + dialogId + '"' + gt + '<input type=checkbox name="c' + dialogId + '" id="c' + dialogId + '"' + gt + dialogId + '</label' + gt + '<br' + gt;
				lstDialog.innerHTML = lstDialog.innerHTML + iDialog;

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
			}
//			listContent = listContent + '</form' + gt;

			if (lstDialog.innerHTML != listContent) {
				lstDialog.innerHTML = listContent;
			}
		}
	}
	//#todo this should go into a sep module
} // UpdateDialogList()

function GetDialogTitle (win) { // returns dialog title (based on title bar caption)
	//alert('DEBUG: GetDialogTitle()');
	//document.title = 0;
	if (win && win.getElementsByClassName) {
		//document.title = 1;
		var allTitlebar = win.getElementsByClassName('titlebar');
		var firstTitlebar = allTitlebar[0];

		if (firstTitlebar && firstTitlebar.getElementsByTagName) {
			//document.title = 2;
			var elId = firstTitlebar.getElementsByTagName('b');
			if (elId && elId[0]) {
				elId = elId[0];

				if (elId && elId.innerHTML) {
					//alert('DEBUG: GetDialogTitle: returning elId.innerHTML = ' + elId.innerHTML);
					return elId.innerHTML;
				}
			}
		}
	} else {
		//alert('GetDialogTitle: warning: fallback');
	}
	return '';
} // GetDialogId()

function CollapseWindow (p, newVisible) { // p = dialog element ; newVisible = 'none'/0 or anything else
// function ExpandDialog () {
// should be called CollapseExpandDialog ?
// collapses or expands specified window/dialog
// function CollapseDialog (
	// collapse: newVisible = none
	// expand: newVisible = anything else
	//alert('DEBUG: CollapseWindow()');
	var changesMade = 0;

	if (p.getElementsByClassName) {
		var content = p.getElementsByClassName('content');

		if (content.length) {
			changesMade += SetElementVisible(content[0], newVisible);
		}
		content = p.getElementsByClassName('menubar');
		if (content.length) {
			changesMade += SetElementVisible(content[0], newVisible);
		}
		content = p.getElementsByClassName('heading');
		if (content.length) {
			changesMade += SetElementVisible(content[0], newVisible);
		}
		content = p.getElementsByClassName('statusbar');
		if (content.length) {
			changesMade += SetElementVisible(content[0], newVisible);
		}

		var btnSkip = p.getElementsByClassName('skip');
		if (btnSkip && btnSkip[0]) {
			if (newVisible == 'none') {
				if (btnSkip[0].innerHTML != '~') {
					btnSkip[0].innerHTML = '~';
					changesMade++;
				}
			} else {
				if (btnSkip[0].innerHTML != '#') {
					btnSkip[0].innerHTML = '#';
					changesMade++;
				}
			}
		}
	}

	return !changesMade;
	// if changes were made, then it should return false, because this will cancel the double-click event
	// if changes were not made, it should return true, because it should let the double-click event happen
} // CollapseWindow()

function CollapseWindowFromButton (t) { // collapses or expands window based on parentage of button pressed (t)
// t is presumed to be clicked element's this, but can be any other element
// if t's caption is '~', window is re-expanded
// if '#' (or anything else) collapses window
// this is done by navigating up until a table is reached
// and then hiding the first class=content element within
// presumably a TR but doesn't matter really because SetElementVisible() is used
// pretty basic, but it works.
	if (t.innerHTML && t.firstChild) {
		if (t.firstChild.nodeName == 'FONT') {
			// small hack in case link has a font tag inside
			// the font tag is typically used to style the link a different color for older browsers
			t = t.firstChild;
		}
		var newVisible = 'initial';
		if (t.innerHTML == '~') { //#collapseButton
			//currently collapsed, expand
			t.innerHTML = '#'; // //#collapseButton
		} else {
			// currently expanded, collapse
			t.innerHTML = '~'; //#collapseButton
			newVisible = 'none';
		}
		if (t.parentElement) {
			//hide content elements
			var p = t;

			var sanityCounter = 20;

			while (p.nodeName != 'TABLE') {
				p = p.parentElement;
				sanityCounter--;
				if (sanityCounter < 1) {
					//alert('DEBUG: CollapseWindowFromButton: warning: sanity check failed');
					return '';
				}
			}

			var winId = GetDialogId(p);
			SetPrefs(winId + '.collapse', newVisible, 'dialogPosition');

			return CollapseWindow(p, newVisible); // CollapseWindowFromButton()
		}
	}

	return true;
} // CollapseWindowFromButton()

function SelectMe (ths) {
	// not worky yet

	//alert('DEBUG: SelectMe()');
	if (!ths) {
		//alert('DEBUG: SelectMe: warning: ths missing');
		return '';
	}

	if (window.getSelection && document.createRange) {
		var selection = window.getSelection();
		var range = document.createRange();
		range.selectNodeContents(ths);
		selection.removeAllRanges();
		selection.addRange(range);
	} else if (document.selection && document.body.createTextRange) {
		var range = document.body.createTextRange();
		range.moveToElementText(ths);
		range.select();
	}

	return true;
} // SelectMe()

function InsertFetchedDialog () {
//alert('DEBUG: InsertFetchedDialog()');
// inserts dialog at the top of the document, before the first child
// function InjectDialog () { // InsertFetchedDialog()
// function InsertDialog () {
// function SpawnDialog () {
	//debug document.title = 'InsertFetchedDialog';

	var xmlhttp = window.xmlhttp2;
	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		//alert('DEBUG: InsertFetchedDialog: found status 200');

		var inject = document.createElement('span'); // temporary
		inject.innerHTML = xmlhttp.responseText;

		if (1) {
		//if (1 || window.location.href.indexOf('chat') != -1) {
			// insert dialog at the top of the document, before the first child

			//debug document.title += 1;
			// #todo this should probably be somewhere else, as it relates to chat only
			// this is a special case handler for the chat page, allowing
			// new chats to be injected at the top of maincontent
			var mainC = document.getElementById('maincontent');
			if (mainC) {
				if (mainC.firstElementChild) {
					//debug document.title += 6;
					mainC.insertBefore(inject, mainC.firstElementChild);
				} else {
					//debug document.title += 7;
					mainC.appendChild(inject);
				}
				//debug document.title += 3;
			} else {
				//alert('DEBUG: InsertFetchedDialog: warning: maincontent is missing');
				if (document.body) {
					if (document.body.firstElementChild) {
						// #todo eliminate race cond
						//debug document.title += 8;
						document.body.insertBefore(inject, document.body.firstElementChild);
					} else {
						document.body.appendChild(inject);
						//debug document.title += 4;
					}
				}
			}
			if (window.UpdateDialogList) {
				UpdateDialogList();
			}
		} else {
			//debug document.title += 2;
			// add the dialog at the bottom/end of the document
			document.body.appendChild(inject);
		}
		//debug document.title += 5;

		var newDialog = inject.getElementsByClassName('dialog');
		//alert('DEBUG: InsertFetchedDialog: newDialog.length = ' + newDialog.length);
		//alert('DEBUG: InsertFetchedDialog: newDialog = ' + newDialog);

		//var actualDialog = newDialog.firstElement;
		//var actualDialog = newDialog[0]; #todo
		////alert('DEBUG: InsertFetchedDialog: actualDialog = ' + actualDialog);

		if (window.ShowTimestamps) {
			ShowTimestamps();
		}
		if (window.LoadCheckboxValues) {
			LoadCheckboxValues();
		}
		if ((window.DraggingInit) && (window.GetPrefs) && GetPrefs('draggable')) {
			//DraggingInit(0);
			if (newDialog.length) {
				for (var iDialog = 0; iDialog < newDialog.length; iDialog++) {
					DraggingInitDialog(newDialog[iDialog], 1); // InsertFetchedDialog()
				}
			}
			//document.title = 'asdf';
		} else {
			//document.title = 'qwer';
		}
		if (newDialog.length == 1) {
			// new dialog was found in page, and is referenced by newDialog

			if (GetPrefs('draggable_spawn_focus')) {
				// focus newly inserted dialog
				SetActiveDialog(newDialog[0]); // InsertFetchedDialog()
			}

			// if it is profile dialog, call ProfileOnLoad()
			var frmProfile = newDialog[0].getElementsByClassName('frmProfile');
			if (frmProfile) {
				if (window.ProfileOnLoad) {
					ProfileOnLoad();
				}
			}

			// if there is a textarea inside new dialog, focus the textarea
			var textareaNew = newDialog[0].getElementsByClassName('txtarea');
			if (textareaNew && textareaNew.length && textareaNew[0]) {
				if (textareaNew[0].focus) {
					textareaNew[0].focus();
				}
				if (window.WriteOnLoad) {
					// #todo load and/or inject write.js as necessary?
					// i think there's a bug here, but it's better than not doing it
					WriteOnLoad();
				}
			} else {
				// if there is no textarea, look for a skip link
				var dialogLinks = newDialog[0].getElementsByClassName('skip');
				if (dialogLinks && dialogLinks[0]) {
					dialogLinks[0].focus();
				} else {
					//alert('DEBUG: InsertFetchedDialog: dialogLinks missing');
					//return '';
				}
			}
		} // if (newDialog.length)

		if (window.ShowAdvanced) {
			//alert('DEBUG: InsertFetchedDialog: ShowAdvanced found, calling');

			// show/hide document layers based on user settings
			// #todo this doesn't actually seem to work.
			ShowAdvanced(1, newDialog[0]);
			//ShowAdvanced(1); // call global ShowAdvanced(), which is slightly less efficient, but should actually work
		} else {
			//alert('DEBUG: InsertFetchedDialog: ShowAdvanced NOT found');
		}

		//var isinv = IsInViewport(newDialog[0]);
		////debug document.title = isinv;

		if (document.getElementsByClassName) {
			var notifications = document.getElementsByClassName('notification');
			if (notifications) {
				//alert('DEBUG: InsertFetchedDialog: notifications found, removing');
				for (var notif = 0; notif < notifications.length; notif++) {
					notifications[notif].remove();
				}
			} else {
				//alert('DEBUG: InsertFetchedDialog: notifications NOT found');
			}

			// #todo
			//if (window.displayNotification) {
			//	var notificationString = 'Repeat to go to page';
			//	displayNotification('hi');
			//}
		} // getElementsByClassName feature check
	} // status 200

	return '';
} // InsertFetchedDialog()

function FetchDialog (dialogName) {
// function InjectDialog () { // FetchDialog
	if ((window.GetPrefs) && !GetPrefs('draggable_spawn')) {
		//alert('DEBUG: FetchDialog: warning: draggable_spawn is FALSE');
		return true; // #todo..
	}

	//alert('DEBUG: FetchDialog(' + dialogName + ')');

	var url = '/dialog/' + dialogName + '.html';
	var dialogId = dialogName.replace('/', '_');

	if (document.getElementById) {
		var dialogExists = document.getElementById(dialogId);
		if (dialogExists) {
			// if dialog is already on page, we just focus it
			// because we want to see the other settings dialogs
			if (
				dialogName == 'upload'
				||
				dialogName == 'settings'
				||
				dialogName == 'write'
			) {
				// these are exceptions to the rule above
				//alert('DEBUG: FetchDialog: dialogExists, opening page: ' + dialogName);
				return true;
			} else {
				//alert('DEBUG: FetchDialog: dialogExists');
				if (GetPrefs('draggable_spawn')) {
					//document.title = !!dialogExists.getAttribute('imactive');
					SetActiveDialog(dialogExists);
					return false;
				}
				return false; // #todo refactor this
			}
		}
	}

	//alert(dialogName);
	var openDialogs = GetPrefs('opened_dialogs'); // FetchDialog()
	//alert('DEBUG: FetchDialog: openDialogs = ' + openDialogs);
	if (openDialogs && openDialogs.indexOf(dialogId) != -1) {
		//
	} else {
		SetPrefs('opened_dialogs', openDialogs + ',' + dialogId); // FetchDialog()
		//SetPrefs('opened_dialogs', ((openDialogs && openDialogs != '0') ? openDialogs + ',' : '') + dialogId); // FetchDialog()
	}
	//alert(openDialogs);

	return FetchDialogFromUrl(url);
} // FetchDialog()

function CloseDialog(t) {
	//alert('DEBUG: CloseDialog()');
	if (window.GetParentDialog) {
		var parentDialog = GetParentDialog(t);

		var dialogTitle = GetDialogTitle(parentDialog);
		//dialogTitle = dialogTitle.toLowerCase();
		var dialogId = GetDialogId(parentDialog);

		//alert(dialogName);
		var openDialogs = GetPrefs('opened_dialogs'); // CloseDialog()
		if (openDialogs && openDialogs.indexOf(dialogId) != -1) {
			var withoutDialog = openDialogs.replace(',' + dialogId, '');
			SetPrefs('opened_dialogs', withoutDialog); // CloseDialog()
		} else {
			//don't need to do anything
		}
		//alert(openDialogs);

		//GetParentDialog(t).remove();
		parentDialog.remove();

		if (window.UpdateDialogList) {
			UpdateDialogList();
		}
	}
	return false;
} // CloseDialog()

function FetchDialogFromUrl (url) { // url example: /dialog/help.html
// function InjectDialog () {
// function FetchDialogFromUrl () {
// function SpawnDialog () {
	if ((window.GetPrefs) && !window.GetPrefs('draggable_spawn')) {
		// #should be one layer above #todo
		// not cool
		//alert('DEBUG: warning: FetchDialogFromUrl() called, but draggable_spawn is FALSE');
		return true; // return true so that click can happen
	}

	if (
		document.getElementById &&
		window.XMLHttpRequest &&
		window.InsertFetchedDialog
	) {
		//alert('DEBUG: FetchDialogFromUrl: window.XMLHttpRequest feature check PASSED');

		var xmlhttp;
		if (window.xmlhttp2) {
			xmlhttp = window.xmlhttp2;
		} else {
			window.xmlhttp2 = new XMLHttpRequest();
			xmlhttp = window.xmlhttp2;
		}
		// this is a hack to always use the same instance
		// of xhr which also makes the process non-async
		// which is ok for our purposes.
		// this is the main reason for the 'too fast' message
		// which appears if you try to vote when already waiting
		// for a vote request to return

		// #todo it needs to be async now, because we want to use it to restore previously opened dialogs

		if (window.displayNotification) {
			displayNotification('Meditate...');
		}

		xmlhttp.onreadystatechange = window.InsertFetchedDialog;
		xmlhttp.open("GET", url, true);
		xmlhttp.setRequestHeader('Cache-Control', 'no-cache');
		xmlhttp.send();

		//alert('DEBUG: FetchDialog: finished xmlhttp.send()');

		return false; // cancel triggering event
	} else {
		//alert('DEBUG: FetchDialogFromUrl: window.XMLHttpRequest feature check FAILED');
		return true; // if there was a click, let it happen
	}
} // FetchDialogFromUrl()

/* / dragging.js */
