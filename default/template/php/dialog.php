<?php

function GetDialogX ( # body, title, headings, status, menu
	$windowBody,
	$windowTitle = '',
	$columnHeadings = '',
	$windowStatus = '',
	$windowMenubarContent = ''
) { // returns html for dialog template
# function GetWindowTemplate {
// uses template/window/standard.template by default

	// stores number of columns if they exist
	// if no columns, remains at 0
	// whether there are columns or not determines:
	// * column headers
	// * colspan= in non-column cells
	$contentColumnCount = 0;

	// base template
	$windowTemplate = GetTemplate('html/window/standard.template');

	$showButtons = GetConfig('html/window_titlebar_buttons'); # titlebar hide and skip buttons;
	WriteLog('GetDialogX: $showButtons = ' . $showButtons);

	// titlebar, if there's a title
	if ($windowTitle) {
		WriteLog('GetDialogX: $windowTitle = ' . $windowTitle);
		if (1 || $showButtons && GetConfig('admin/js/dragging')) {
			WriteLog('GetDialogX: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('admin/js/dragging'));
			$windowTitlebar = GetTemplate('html/window/titlebar.template');
			$windowTitlebar = str_replace('$windowTitle', $windowTitle, $windowTitlebar);
			$windowTemplate = str_replace('$windowTitlebar', $windowTitlebar, $windowTemplate);

			if (GetConfig('setting/admin/js/enable')) {
				#todo maybe should depend on another setting?
				$windowTemplate = AddAttributeToTag($windowTemplate, 'a', 'onclick', "if ((window.ShowAll) && window.GetParentDialog) { return !ShowAll(this, GetParentDialog(this)); } return false;");
			}
		} else {
			WriteLog('GetDialogX: $showButtons = ' . $showButtons . '; $windowTitle = ' . $windowTitle . '; dragging = ' . GetConfig('admin/js/dragging'));
		}
	} else {
		WriteLog('GetDialogX: warning: $windowTitle is FALSE');
		$windowTemplate = str_replace('$windowTitlebar', '', $windowTemplate);
	}

	// menubar, if there is menubar content
	if ($windowMenubarContent) {
		$windowMenubar = GetTemplate('html/window/menubar.template');
		$windowMenubar = str_replace('$windowMenubarContent', $windowMenubarContent, $windowMenubar);

		$windowTemplate = str_replace('$windowMenubar', $windowMenubar, $windowTemplate);
	} else {
		$windowTemplate = str_replace('$windowMenubar', '', $windowTemplate);
		//#todo currently results in an empty menubar
	}

	// column headings from the $columnHeadings variable
	if ($columnHeadings) {
		$windowHeaderTemplate = GetTemplate('html/window/header_wrapper.template');
		$windowHeaderColumns = '';
		$columnsArray = explode(',', $columnHeadings);

		$printedColumnsCount = 0;
		foreach ($columnsArray as $columnCaption) {
			$printedColumnsCount++;

			$columnHeaderTemplate = GetTemplate('html/window/header_column.template');
			if ($printedColumnsCount >= count($columnsArray)) {
				$columnCaption .= '<br>'; //# for no-table browsers
			}

			$columnHeaderTemplate = str_replace('$headerCaption', $columnCaption, $columnHeaderTemplate);
			$windowHeaderColumns .= $columnHeaderTemplate;
		}

		$windowHeaderTemplate = str_replace('$windowHeadings', $windowHeaderColumns, $windowHeaderTemplate);
		$windowTemplate = str_replace('$windowHeader', $windowHeaderTemplate, $windowTemplate);

		$contentColumnCount = count($columnsArray);
	} else {
		$windowTemplate = str_replace('$windowHeader', '', $windowTemplate);
		$contentColumnCount = 0;
	}

	// main window content, aka body
	if ($windowBody) {
		if (index(strtolower($windowBody), '<tr') == -1) {
			// put content into a table row and cell if missing
			$windowBody = '<tr class=content><td>' . $windowBody . '</td></tr>';
		}

		$windowTemplate = str_replace('$windowBody', $windowBody, $windowTemplate);
	} else {
		$windowTemplate = str_replace('$windowBody', '', $windowTemplate);
	}

	// status bar
	if ($windowStatus) {
		$windowStatusTemplate = GetTemplate('html/window/status.template');
		$windowStatusTemplate = str_replace('$windowStatus', $windowStatus, $windowStatusTemplate);
		$windowTemplate = str_replace('$windowStatus', $windowStatusTemplate, $windowTemplate);
	} else {
		$windowTemplate = str_replace('$windowStatus', '', $windowTemplate);
	}

	// fill in the column count if necessary
	if ($contentColumnCount) {
		$windowTemplate = str_replace('$contentColumnCount', $contentColumnCount, $windowTemplate);
	} else {
		$windowTemplate = str_replace('$contentColumnCount', '', $windowTemplate);
	}

	/* my */ $modernMode = 0;
	if (in_array('modern', GetActiveThemes())) {
		#todo this is a hard-coded hack, pls fix #hack #fixme
		#todo this should be memoized, and the memo clearing should be linked to GetActiveThemes()
		$modernMode = 1;
	}

	if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
		#todo adapt to modern theme also

		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmousedown', 'this.style.zIndex = ++window.draggingZ;');

		if ($modernMode) {
			#todo this should be done with js modern-like
			$windowTemplate = AddAttributeToTag($windowTemplate, 'div class="dialog"', 'onmouseenter', 'if (window.SetActiveDialogDelay) { return SetActiveDialogDelay(this); }'); #SetActiveDialog() GetDialogX2()
			$windowTemplate = AddAttributeToTag($windowTemplate, 'div class="dialog"', 'onmousedown', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetDialogX2()

		}
		else {
			$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmouseenter', 'if (window.SetActiveDialogDelay) { return SetActiveDialogDelay(this); }'); #SetActiveDialog() GetDialogX2()
			$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onmousedown', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetDialogX2()
		}
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'ontouchstart', 'if (window.SetActiveDialog) { return SetActiveDialog(this); }'); #SetActiveDialog() GetDialogX2()
		#$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'onfocus', 'if (window.SetActiveDialog) { SetActiveDialog(this); return true; }'); #SetActiveDialog()
	}

	if ($windowTitle) {
		# hack for setting id= from title
		# this should really be a separate argument
		# this is mainly needed for modern theme, but is nice to have in classic also
		# #todo clean up and refactor?
		if ($windowTitle == 'CookieInfo' || $windowTitle == 'PrintedInfo') {
			if ($modernMode) {
				#todo this should be done with js modern-like
				$windowTemplate = AddAttributeToTag($windowTemplate, 'div class="dialog"', 'id', $windowTitle); #SetActiveDialog() GetDialogX2()
			}
			else {
				$windowTemplate = AddAttributeToTag($windowTemplate, 'table', 'id', $windowTitle); #SetActiveDialog() GetDialogX2()
			}
		}
	}

	$windowTemplate = str_replace('$colorWindow', GetThemeColor('window'), $windowTemplate);
	$windowTemplate = str_replace('$colorTitlebarText', GetThemeColor('titlebar_text'), $windowTemplate);
	$windowTemplate = str_replace('$colorTitlebar', GetThemeColor('titlebar'), $windowTemplate);
	$windowTemplate = str_replace('$dialogAnchor', '', $windowTemplate);

	return $windowTemplate;
} # GetDialogX()
