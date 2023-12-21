// desktop.js
function DesktopOnLoad () {
	//alert('DEBUG: DesktopOnLoad()');
	if (window.location.href.indexOf('desktop') != -1) {
		if ((window.DraggingInit) && (window.DraggingMakeFit) && (window.SetActiveDialog) && (window.GetParentDialog) && (window.displayNotification)) {
			if (! GetPrefs('draggable')) {
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
				displayNotification('Annoying mode activated.');
			}
		}
	}
} // DesktopOnLoad()
// / desktop.js