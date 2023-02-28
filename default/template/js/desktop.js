// desktop.js
function DesktopOnLoad () {
	//alert('DEBUG: DesktopOnLoad()');
	if (window.location.href.indexOf('desktop')) {
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
		displayNotification('Annoying mode activated. Mouse is recommended. Use Reset button to stop.');
	}
} // DesktopOnLoad()
// / desktop.js