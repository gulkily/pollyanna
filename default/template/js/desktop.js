// desktop.js
function DesktopOnLoad () {
	//alert('DEBUG: DesktopOnLoad()');
	SetPrefs('draggable', 1);
	SetPrefs('draggable_activate', 1);
	SetPrefs('draggable_spawn', 1);
	SetPrefs('draggable_spawn_focus', 1);
	SetPrefs('draggable', 1);
	SetPrefs('draggable_restore', 1);
	SetPrefs('draggable_restore_collapsed', 1);
	SetActiveDialog(GetParentDialog(this));
	DraggingInit(0);
	DraggingMakeFit(0);
	DraggingInit(0);
	displayNotification('Annoying mode activated. I hope you have a good mouse. Click Reset to make it stop.');
} // DesktopOnLoad()
// / desktop.js