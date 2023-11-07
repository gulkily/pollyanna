// paste.js

// handles pasting of images on the upload page

function PasteEvent (e) {
    // takes an image from the clipboard,
    // creates a form on the page and attaches the image,
    // and makes a POST request to the upload handler

	var uploadAllowed = 1;
	// this can be used for template-based feature allowing and disallowing
	
	if (uploadAllowed) {
		//var textData = event.clipboardData.getData('text');
		// this can later be used to differentiate text clipboard data from image clipboard data #todo
		
		if (e.clipboardData.files) {
		    // there were some files in the clipboard

			if (document.createElement) {
			    // browser supports basic DOM things, including document.createElement()

			    // create a form
				var form1 = document.createElement('form');
				form1.setAttribute('method', 'POST');
				form1.setAttribute('action', '/upload.php');
				form1.setAttribute('enctype', 'multipart/form-data');
				form1.style.display = 'none';

				// create an input element of type=file
				var up1 = document.createElement('input');
				up1.setAttribute('type', 'file');
				up1.setAttribute('name', 'uploaded_file');
				up1.files = e.clipboardData.files;

				// add input to form and form to document.body
				form1.appendChild(up1);
				document.body.appendChild(form1);

				// show notification that upload is beginning
				if (window.displayNotification) {
					displayNotification('Uploading...');
				}

                // if there is an input element for pasting, show notification there too
				if (document.getElementById('iospaste')) {
					document.getElementById('iospaste').value = 'Uploading...';
				}

				// submit the form to begin upload process
				form1.submit();

				// #todo change page to loading indicator (but it should change back if returning to page)
				//document.body.innerHTML = '<table border=0 cellpadding=5 cellspacing=5><tr valign=middle><td><img src=/loading.gif height=48 width=48></td><td><font size=7 face=arial>Meditate...</font></td></tr></table>';
			}
		}
	}
} // PasteEvent()

// add listener for paste event to page
// this affects all pasting done on the page, so should be used sparingly
// paste.js should only be included on the upload page until this is improved
if (window.addEventListener && window.PasteEvent) {
	window.addEventListener('paste', window.PasteEvent);
}

// paste.js
