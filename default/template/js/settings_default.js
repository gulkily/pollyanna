// settings_default.js

function GetDefault (prefKey) { // get default value of preference
// function GetSetting () {
	if (!prefKey) {
		//alert('DEBUG: GetDefault: warning: missing prefKey');
		return '';
	}


    // Correctly define the object with key-value pairs
    var defaultPrefs = {
        'show_advanced': 0,
        'beginner': 1,
        'beginner_highlight': 1,
        'show_admin': 0,
        'notify_on_change': 1,
        'timestamps_format': 'adjusted',
        'performance_optimization': 'faster',
        'draggable': 0,
        'draggable_scale': 0,
        'draggable_arrange_viewport_resize': 0
    };

    // Check if the prefKey exists in the defaultPrefs object
    if (defaultPrefs.hasOwnProperty(prefKey)) {
        //alert('DEBUG: GetDefault(' + prefKey + ')' + ' = ' + defaultPrefs[prefKey]);
        return defaultPrefs[prefKey];
    }
    else {
        //alert('DEBUG: GetDefault: warning: prefKey = ' + prefKey + ' not found in defaultPrefs');
        return '';
    }
} // GetDefault()

// / settings_default.js

