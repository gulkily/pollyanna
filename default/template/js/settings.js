// == begin settings.js

var showAdvancedLastAction = '';
var showBeginnerLastAction = '';
var showMeaniesLastAction = '';
var showAdminLastAction = '';
var showTimestampsLastAction = '';
var showPageInfoLastAction = '';

var timerShowAdvanced;

function SetElementVisible (element, displayValue, bgColor, borderStyle) { // sets element's visible status based on tag type
// displayValue = 'none' or 'initial'
// 	when 'initial', will try to substitute appropriate default for tag type
// also sets background color
// used for hiding/showing and highlighting beginner, advanced element classes on page.
	if (element) {
		//alert('DEBUG: SetElementVisible: before: ' + element.nodeName + ' : ' + element.style.display);
	} else {
		//alert('DEBUG: SetElementVisible: before: warning: no element');
		return '';
	}

	var changesMade = 0;

	//alert('DEBUG: SetElementVisible:' + element.tagName + "; displayValue:" + displayValue + "; bgColor:" + bgColor + "; borderStyle:" + borderStyle + "\n");

	if (bgColor && (element.tagName != 'SPAN')) {
		// background color
		if (bgColor == 'initial') {
			bgColor = '$colorWindow';
		}

		if (element.style.backgroundColor != bgColor) {
			element.style.backgroundColor = bgColor;
			changesMade++;
		}
		// this may cause issues in some themes
	}

	// depending on element type, we set different display style
	// block, table-row, table-cell, or default of 'initial'
	if (displayValue == 'initial' && (element.nodeName == 'P' || element.nodeName == 'H3' || element.nodeName == 'FIELDSET' || element.nodeName == 'HR')) {
		if (element.style.display != '') {
			element.style.display = '';
			changesMade++;
		}
		// element.style.display = 'block';
	} else if (displayValue == 'initial' && element.nodeName == 'TR') {
		if (element.style.display != '') {
			element.style.display = '';
			changesMade++;
		}
		// element.style.display = 'table-row';
	} else if (displayValue == 'initial' && (element.nodeName == 'TH' || element.nodeName == 'TD' || element.nodeName == 'TBODY')) {
		if (element.innerHTML != '') {
			if (element.style.display != '') {
				element.style.display = '';
				changesMade++
			}
			// element.style.display = 'table-cell';
		} else {
			if (element.style.display != 'none') {
				element.style.display = 'none'; // empty table cells display = none #why?
			}
		}
	} else {
		if (displayValue == 'initial') {
			displayValue = '';
			// displayValue = 'inline';
		}
		if (element.style.display != displayValue) {
			element.style.display = displayValue;
			changesMade++;
		}
		if (borderStyle) {
			// border style
			if (element.style.border != borderStyle) {
				element.style.border = borderStyle;
				changesMade++;
			}
			//element.style.borderRadius = '3pt';
		}
	}

	if (element) {
		//alert('DEBUG: SetElementVisible: after: ' + element.nodeName + ' : ' + element.style.display);
		if (changesMade) {
			return changesMade;
		} else {
			return 0;
		}
	} else {
		//alert('DEBUG: SetElementVisible: after: warning: no element');
		return changesMade;
	}

	return changesMade;
} // SetElementVisible()

function ShowAll (t, container) { // t = clicked link ; container = document by default ; shows all elements, overriding settings
// admin elements are excluded. only beginner, advanced class elements are shown
	if (!document.getElementsByClassName) {
		//alert('DEBUG: ShowAll: warning: getElementsByClassName feature check FAILED');
		return false;
	}

	var gt = unescape('%3E');

	if (!container) {
		container = document;
	}

	var isMore = 1; // if 0, it is 'Less' link

	// change link caption, there are different variations
	if (t.innerHTML == 'Less') {
		// when without accesskey
		t.innerHTML = 'More';
		isMore = 0;
	}
	if (t.innerHTML == 'Less (<u' + gt + 'O</u' + gt + ')') {
		// when with accesskey
		t.innerHTML = 'M<u' + gt + 'o</u' + gt + 're';
		isMore = 0;
	}
	if (t.innerHTML == '<u' + gt + 'O</u' + gt + '') {
		// just the letter with accesskey
		t.innerHTML = '<u' + gt + 'o</u' + gt + '';
		isMore = 0;
	}

	if (isMore && container.getElementsByClassName) {
		// change link caption, there are different variations
		if (t.innerHTML == 'More') {
			// without accesskey
			t.innerHTML = 'Less';
		}
		if (t.innerHTML == 'M<u' + gt + 'o</u' + gt + 're') {
			// with accesskey
			t.innerHTML = 'Less (<u' + gt + 'O</u' + gt + ')';
		}
		if (t.innerHTML == '<u' + gt + 'o</u' + gt + '') {
			// just the letter with accesskey
			t.innerHTML = '<u' + gt + 'O</u' + gt + '';
		}

		var display;
		display = 'initial';

		var elements = container.getElementsByClassName('advanced');
		for (var i = 0; i < elements.length; i++) {
			SetElementVisible(elements[i], display, '$colorHighlightAdvanced', 0);
		}

		if (0) { // #todo
			var elements = container.getElementsByClassName('heading');
			for (var i = 0; i < elements.length; i++) {
				SetElementVisible(elements[i], display, '$colorHighlightAdvanced', 0);
			}
			var elements = container.getElementsByClassName('menubar');
			for (var i = 0; i < elements.length; i++) {
				SetElementVisible(elements[i], display, '$colorHighlightAdvanced', 0);
			}
			//var elements = container.getElementsByClassName('statusbar');
			//for (var i = 0; i < elements.length; i++) {
			//    SetElementVisible(elements[i], display, '$colorHighlightAdvanced', 0);
			//}
		}
		elements = container.getElementsByClassName('beginner');
		for (var i = 0; i < elements.length; i++) {
			SetElementVisible(elements[i], display, '$colorHighlightBeginner', 0);
		}
		elements = container.getElementsByClassName('expand');
		for (var i = 0; i < elements.length; i++) {
			SetElementVisible(elements[i], 'none', '', 0);
		}

		if (timerShowAdvanced) {
			clearTimeout(timerShowAdvanced);
		}
		//timerShowAdvanced = setTimeout('ShowAdvanced(1);', 10000);
		//
		//if (t && t.getAttribute('onclick')) {
		//t.setAttribute('onclick', '');
		//}
		//if (window.ArrangeAll) {
		//	ArrangeAll();
		//}

		return false;
	} else {
		ShowAdvanced(1, 0);

		return false;
	}

	return true;
} // ShowAll()

function ShowAdvanced (force, container) { // show or hide controls based on preferences
//handles class=advanced based on 'show_advanced' preference
//handles class=beginner based on 'beginner' preference
//force parameter
// 1 = does not re-do setTimeout (called this way from checkboxes)
// 0 = previous preference values are remembered, and are not re-done (called by timer)

	//alert('DEBUG: ShowAdvanced(' + force + ')');

	if (!container) {
		container = document;
		// allows for localized effects (not document-wide)
		// this feature may or may not be actually used or tested
	}

	var counterChangesMade = 0;

	if (document.getElementById && window.localStorage && container.getElementsByClassName) {
		//alert('DEBUG: ShowAdvanced: feature check passed!');
		///////////

		var styleAssistShowAdvanced = document.getElementById('styleAssistShowAdvanced');
		if (styleAssistShowAdvanced && styleAssistShowAdvanced.remove) {
			styleAssistShowAdvanced.remove();
		}
		// this hides the special stylesheet which we inject into the page
		// so that there is no jittery dialog repositioning

		var displayTimestamps = '0';
		if (GetPrefs('timestamps_format')) {
			displayTimestamps = 1;
		}
		if (force || window.showTimestampsLastAction != displayTimestamps) {
			//ShowTimestamps();
			window.showTimestampsLastAction = displayTimestamps;
			counterChangesMade++;
		}

		{ // #show_admin
			var displayAdmin = 'none'; // not voting by default
			if (GetPrefs('show_admin') == 1) { // check value of show_admin preference
				displayAdmin = 'initial'; // display
			}
			if (force || showAdminLastAction != displayAdmin) {
				var elemAdmin = container.getElementsByClassName('admin');

				for (var i = 0; i < elemAdmin.length; i++) {
					SetElementVisible(elemAdmin[i], displayAdmin, 0, 0);
				}

				//// #todo make this optional
				//var elemAdmin = container.getElementsByClassName('heading');
				//
				//for (var i = 0; i < elemAdmin.length; i++) {
				//	SetElementVisible(elemAdmin[i], displayAdmin, 0, 0);
				//}
				//
				//var elemAdmin = container.getElementsByClassName('statusbar');
				//
				//for (var i = 0; i < elemAdmin.length; i++) {
				//	SetElementVisible(elemAdmin[i], displayAdmin, 0, 0);
				//}

				counterChangesMade++;
			}
		}

		{ // #show_advanced
			var displayValue = 'none'; // hide by default
			if (GetPrefs('show_advanced') == 1) { // check value of show_advanced preference
				displayValue = 'initial'; // display
			}

			var bgColor = 'initial';
			if (GetPrefs('advanced_highlight') == 1) { // check value of advanced_highlight preference
				bgColor = '$colorHighlightAdvanced'; // advanced_highlight
			}

			if (force || showAdvancedLastAction != (displayValue + bgColor)) {
				// thank you stackoverflow
				var divsToHide = container.getElementsByClassName("advanced"); //divsToHide is an array #todo nn3 compat
				for (var i = 0; i < divsToHide.length; i++) {
					//divsToHide[i].style.visibility = "hidden"; // or
					SetElementVisible(divsToHide[i], displayValue, bgColor, 0);
				}

				if (0) { // #todo
					var divsToHide = container.getElementsByClassName("heading"); //divsToHide is an array #todo nn3 compat
					for (var i = 0; i < divsToHide.length; i++) {
						//divsToHide[i].style.visibility = "hidden"; // or
						SetElementVisible(divsToHide[i], displayValue, bgColor, 0);
					}
					var divsToHide = container.getElementsByClassName("menubar"); //divsToHide is an array #todo nn3 compat
					for (var i = 0; i < divsToHide.length; i++) {
						//divsToHide[i].style.visibility = "hidden"; // or
						SetElementVisible(divsToHide[i], displayValue, bgColor, 0);
					}
		//			var divsToHide = container.getElementsByClassName("statusbar"); //divsToHide is an array #todo nn3 compat
		//			for (var i = 0; i < divsToHide.length; i++) {
		//				//divsToHide[i].style.visibility = "hidden"; // or
		//				SetElementVisible(divsToHide[i], displayValue, bgColor, 0);
		//			}
				}
	//			var clock = document.getElementById('txtClock');
	//			if (clock) {
	//			    SetElementVisible(clock, displayValue, bgColor, 0);
	//			}
				showAdvancedLastAction = displayValue + bgColor;

				counterChangesMade++;
			}
		} // show_advanced

		{ // #beginner_highlight
			displayValue = 'initial'; // show by default
			if (GetPrefs('beginner') == 0) { // check value of beginner preference
				displayValue = 'none';
			}

			bgColor = 'initial';
			if (GetPrefs('beginner_highlight') == 1) { // check value of beginner preference
				bgColor = '$colorHighlightBeginner'; // beginner_highlight
			}

			if (force || showBeginnerLastAction != displayValue + bgColor) {
				var divsToShow = container.getElementsByClassName('beginner');//#todo nn3 compat

				for (var i = 0; i < divsToShow.length; i++) {
					SetElementVisible(divsToShow[i], displayValue, bgColor, 0);
				}
				showBeginnerLastAction = displayValue + bgColor;

				counterChangesMade++;
			}
		}
//
//		if (window.freshTimeoutId) {
//			// reset the page change notifier state
//			clearTimeout(window.freshTimeoutId);
//
//			if (GetPrefs('notify_on_change')) {
//				// check if page has changed, notify user if so
//				if (window.EventLoop) {
//					EventLoop();
//				}
//			}
//		}

		if (window.setAva) {
			setAva(); // #todo caching similar to above
		}

		//if (!force) {
			//if (timerShowAdvanced) {
			//	clearTimeout(timerShowAdvanced);
			//}
			//timerShowAdvanced = setTimeout('ShowAdvanced()', 3000);
		//}

		//SettingsOnload();

	} else {
		//alert('DEBUG: ShowAdvanced: feature check FAILED!');
		//alert('DEBUG: window.localStorage: ' + window.localStorage + '; document.getElementsByClassName: ' + document.getElementsByClassName);
	}

	if (counterChangesMade) {
		LoadCheckboxValues();
	}

	//alert('DEBUG: ShowAdvanced: returning false');
	return '';
} // ShowAdvanced()

function GetPrefs (prefKey, storeName) { // get prefs value from localstorage
	// function GetConfig {
	// function  GetSetting {

	if (!storeName) {
		storeName = 'settings';
	}

	if (!prefKey) {
		//alert('DEBUG: GetPrefs: warning: missing prefKey');
		return '';
	}

	//alert('DEBUG: GetPrefs(' + prefKey + ')');
	if (window.localStorage) {
		//var nameContainer = 'settings';
		var nameContainer = storeName;

		{ // settings beginning with gtgt go into separate container
			var gt = unescape('%3E');
			if (prefKey.substr(0, 2) == gt+gt) {
				nameContainer = 'voted';
			}
		}
		var currentPrefs = localStorage.getItem(nameContainer);

		var prefsObj;
		if (currentPrefs) {
			prefsObj = JSON.parse(currentPrefs);
		} else {
			prefsObj = Object();
		}
		var prefValue = prefsObj[prefKey];

		if (!prefValue && prefValue != 0 && prefValue != '') {
			if (
				prefKey == 'beginner' || // default
				prefKey == 'beginner_highlight' || // default
				prefKey == 'notify_on_change' // // default
			) {
				// these settings default to 1/true:
				prefValue = 1;
			}
			if (
				prefKey == 'show_advanced' || // default
				prefKey == 'show_admin' || // default
				prefKey == 'draggable' || // default
				prefKey == 'draggable_scale' // default
			) {
				// these settings default to 0/false:
				// #todo does this need to be pre-set, if it is 0?
				// seems to work ok if it is not
				prefValue = 0;
			}

			if (prefKey == 'timestamps_format') {
				// default to 'adjusted' timestamp format
				prefValue = 'adjusted';
			}

			if (prefKey == 'performance_optimization') {
				// default to 'adjusted' timestamp format
				prefValue = 'faster';
			}

			SetPrefs(prefKey, prefValue);
		}

		return prefValue;
	}

	//alert('DEBUG: GetPrefs: fallthrough, returning ');
	return '';
} // GetPrefs()

function SetPrefs (prefKey, prefValue, storeName) { // set prefs key prefKey to value prefValue
	//alert('DEBUG: SetPrefs(' + prefKey + ', ' + prefValue + ')');

	if (!prefKey || !prefKey.substr) {
		//alert('DEBUG: GetPrefs: warning: missing prefKey');
		return '';
	}

	if (!storeName) {
		storeName = 'settings';
	}

	if (prefKey == 'show_advanced' || prefKey == 'beginner' || prefKey == 'show_admin') { // SetPrefs()
		//alert('DEBUG: SetPrefs: setting cookie to match LocalStorage');
		if (window.SetCookie) {
			SetCookie(prefKey, (prefValue ? 1 : 0));
		} else {
			//alert('DEBUG: warning: window.SetCookie missing');
		}
	}

	if (prefKey == 'performance_optimization') {
		window.performanceOptimization = prefValue;
		//alert('DEBUG: SetPrefs: setting cookie to match LocalStorage');
		if (prefValue != 'none') {
			//if (window.EventLoop) {
				// todo enable/disable eventloop?
				// this is disabled because it can cause race condition
				// the race condition manifests itself as checkbox changing state
				//EventLoop();
			//}
		}
	}

	if (window.localStorage) {
		//var nameContainer = 'settings';
		var nameContainer = storeName;

		var gt = unescape('%3E'); // #todo this should be elsewhere
		if (prefKey.substr(0, 2) == gt+gt) {
			nameContainer = 'voted';
		}

		var currentPrefs = localStorage.getItem(nameContainer);
		var prefsObj;
		if (currentPrefs) {
			prefsObj = JSON.parse(currentPrefs);
		} else {
			prefsObj = Object();
		}
		prefsObj[prefKey] = prefValue;

		var newPrefsString = JSON.stringify(prefsObj);
		localStorage.setItem(nameContainer, newPrefsString);

		if (prefKey != 'prefs_timestamp') {
			// remember time preferences were last changed
			var d = new Date();
			var t = d.getTime();
			SetPrefs('prefs_timestamp', t);
		}

		return 0;
	}

	return 1;
} // SetPrefs()

function SaveCheckbox (ths, prefKey) { // saves value of checkbox, toggles affected elements
// id = id of pane to hide or show; not required
// ths = "this" of calling checkbox)
// prefKey = key of preference value to set with checkbox
//
// this function is a bit of a mess, could use a refactor #todo

	//alert('DEBUG: SaveCheckbox(' + ths + ',' + prefKey);

	var checkboxState = (ths.checked ? 1 : 0);
	//alert('DEBUG: checkboxState = ' + checkboxState);

	///////////////////////////////
	// BEFORE SAVE ACTIONS BEGIN //
	//if (prefKey == '' +	'draggable_scale') {
	if (prefKey == '' +	'draggable_scale') {
		if (window.SetActiveDialog) {
			SetActiveDialog(0);
		}
	}
	if (prefKey == 'draggable') {
		if (checkboxState && window.DraggingInit) {
			DraggingInit(0);
		} else {
			if (window.displayNotification) {
				displayNotification('Please reload page');
				// #todo make this nicer
			}
		}
	}
	// BEFORE SAVE ACTIONS FINISH //
	////////////////////////////////


	///////////////////////
	// ACTUAL SAVE BEGIN //
	if (prefKey == 'timestamps_format' || prefKey == 'performance_optimization' && window.ShowTimestamps) { //#todo
		SetPrefs(prefKey, ths.value);
		ShowTimestamps();
	} else {
		// saves checkbox's value as 0/1 value to prefs(prefKey)
		SetPrefs(prefKey, checkboxState);
	}
	// ACTUAL SAVE FINISH //
	////////////////////////

	//////////////////////////////
	// AFTER SAVE ACTIONS BEGIN //
	if (prefKey == 'draggable_scale' || prefKey == 'draggable_activate') {
		if (window.SetActiveDialog) {
			SetActiveDialog(0);
		}
	}

	if (prefKey == 'show_advanced' || prefKey == 'beginner' || prefKey == 'show_admin' && window.ShowAdvanced) { // SaveCheckbox()
		ShowAdvanced(1, 0);
	}

	if (prefKey == 'draggable_restore' && checkboxState) {
		if (document.getElementsByClassName) {
			var dialogs = document.getElementsByClassName('dialog');
			if (dialogs) {
				for (var i = 0; i < dialogs.length; i++) {
					SaveDialogPosition(dialogs[i]);
				}
			}
		}
	}
	// AFTER SAVE ACTIONS FINISH //
	///////////////////////////////

	//alert('DEBUG: after SetPrefs, GetPrefs(' + prefKey + ') returns: ' + GetPrefs(prefKey));

	// call ShowAdvanced(1) to update ui appearance
	// ShowAdvanced(1);

	return 1;
} // SaveCheckbox()

function SetInterfaceMode (ab, thisButton) { // updates several settings to change to "ui mode" (beginner, advanced, etc.)
	//alert('DEBUG: SetInterfaceMode(' + ab + ')');

	if (window.localStorage && window.SetPrefs) {
		if (ab == 'beginner') {
			// switching to beginner mode resets most preferences to their beginner-friendly defaults
			SetPrefs('show_advanced', 0);
			SetPrefs('advanced_highlight', 0);
			SetPrefs('beginner', 1);
			SetPrefs('beginner_highlight', 1);
			SetPrefs('notify_on_change', 1);
			SetPrefs('show_admin', 0);
			SetPrefs('write_enhance', 0);
			SetPrefs('write_autosave', 0);
			SetPrefs('timestamps_format', 'adjusted'); // reset to beginner
			SetPrefs('performance_optimization', 'faster');
			SetPrefs('draggable', 0);
			SetPrefs('draggable_scale', 0);
			SetPrefs('draggable_activate', 0);
			SetPrefs('draggable_restore', 1);
			SetPrefs('draggable_restore_collapsed', 1);
			SetPrefs('draggable_spawn', 0);
			SetPrefs('focus_reply', 0);
			SetPrefs('sign_by_default', 1);

			if (window.DraggingReset) {
				DraggingReset();
			}

			//if (window.displayNotification) {
				//displayNotification('', thisButton);
			//}
		} else if (ab == 'intermediate') {
		if (window.DraggingInit) {
				DraggingInit();
			}
			SetPrefs('show_advanced', 1);
			SetPrefs('advanced_highlight', 1);
			SetPrefs('beginner', 1);
			SetPrefs('beginner_highlight', 1);
			SetPrefs('notify_on_change', 1);
//            SetPrefs('show_admin', 0);
		} else if (ab == 'expert') {
			if (thisButton && window.GetParentDialog) {
				var parentDialog = GetParentDialog(thisButton);
				if (parentDialog) {
					//alert('DEBUG: SetInterfaceMode: calling DraggingInitDialog(parentDialog)');
					DraggingInitDialog(parentDialog);
				}
			}
			SetPrefs('show_advanced', 1);
			SetPrefs('advanced_highlight', 0);
			SetPrefs('beginner', 0);
			SetPrefs('beginner_highlight', 0);
			SetPrefs('notify_on_change', 1);
		}

		ShowTimestamps();
		ShowAdvanced(1, 0);
		LoadCheckboxValues();

		//alert('DEBUG: window.SetPrefs was found, and ShowAdvanced(1) was called');

		return false;
	}

	//alert('DEBUG: returning true');

	return true;
} // SetInterfaceMode()

function LoadCheckbox (c, prefKey) { // updates checkbox state to reflect settings
// function RestoreCheckbox () {
// c = checkbox object
// prefKey = key of preference value
	//console.log(prefKey);
	if (!c) {
		//alert('DEBUG: LoadCheckbox: warning: c was missing');
		// this happens a lot because LoadCheckboxes doesn't verify that elements exist before calling #todo
		// #todo this should really find the checkbox automatically and have only one argument
		//return '';
	}

	//alert('DEBUG: LoadCheckbox(..., ' + prefKey + ')');

	if (prefKey == 'timestamps_format') {
		//alert('DEBUG: LoadCheckbox: timestamps_format');
		var checkboxState = GetPrefs(prefKey);

		if (document.frmSettings && document.frmSettings.optTimestampsFormat) {
			document.frmSettings.optTimestampsFormat.value = checkboxState;
		}
	}
	else if (prefKey == 'performance_optimization') {
		//alert('DEBUG: LoadCheckbox: performance_optimization');
		var checkboxState = GetPrefs(prefKey);

		if (document.frmSettings && document.frmSettings.optPerformanceOptimization) {
			document.frmSettings.optPerformanceOptimization.value = checkboxState;
		}
	}
	else {
		//alert('DEBUG: LoadCheckbox: ' + prefKey);
		var checkboxState = GetPrefs(prefKey);

		if (c && c.checked != (checkboxState ? 1 : 0)) {
			c.checked = (checkboxState ? 1 : 0);
		}

		return 1;
	}

	return 1;
} // LoadCheckbox()

function LoadCheckboxValues () {
	//alert('DEBUG: LoadCheckboxValues()');

	// #todo check if being called too often?

	LoadCheckbox(document.getElementById('chkDraggable'), 'draggable');
	LoadCheckbox(document.getElementById('chkDraggableRestore'), 'draggable_restore');
	LoadCheckbox(document.getElementById('chkDraggableRestoreCollapsed'), 'draggable_restore_collapsed');
	LoadCheckbox(document.getElementById('chkDraggableScale'), 'draggable_scale');
	LoadCheckbox(document.getElementById('chkDraggableActivate'), 'draggable_activate');

	LoadCheckbox(document.getElementById('chkDraggableSpawn'), 'draggable_spawn');
	LoadCheckbox(document.getElementById('chkDraggableSpawnFocus'), 'draggable_spawn_focus');
	LoadCheckbox(document.getElementById('chkShowAdmin'), 'show_admin');
	LoadCheckbox(document.getElementById('chkShowBeginner'), 'beginner');
	LoadCheckbox(document.getElementById('chkShowAdvanced'), 'show_advanced');
	LoadCheckbox(document.getElementById('chkWriteEnhance'), 'write_enhance');
	LoadCheckbox(document.getElementById('chkWriteAutoSave'), 'write_autosave');
	LoadCheckbox(document.getElementById('chkFocusReply'), 'focus_reply');
	LoadCheckbox(document.getElementById('chkSignByDefault'), 'sign_by_default');

	//alert('DEBUG: LoadCheckboxValues: about to do option groups');

	LoadCheckbox(document.getElementById('optTimestampsFormat'), 'timestamps_format');
	LoadCheckbox(document.getElementById('optPerformanceOptimization'), 'performance_optimization');
	//LoadCheckbox(document.getElementById('chkExpertTimestamps'), 'expert_timestamps');

} // LoadCheckboxValues()

function SettingsOnload () { // onload function for settings page
	//alert('debug: SettingsOnload() begin');

	if (document.getElementById) {
	// below is code which sets the checked state of settings checkboxes
	// based on settings state
		//var pane;

		LoadCheckboxValues();

		//if (GetPrefs('sign_by_default') == 1) {
		//	var cbM = document.getElementById('chkSignByDefault');
		//	if (cbM) {
		//		cbM.checked = 1;
		//	}
		//}

	}

	//alert('debug: SettingsOnload: returning false');
	return false;
} // SettingsOnload()

if (window.EventLoop) {
	window.eventLoopShowAdvanced = 1;
} else {
	ShowAdvanced(0, 0);
}

// == end settings.js
