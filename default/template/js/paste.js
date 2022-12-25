// paste.js

function PasteEvent (e) {
	var uploadAllowed = 1;
	
	if (uploadAllowed) {
		//var textData = event.clipboardData.getData('text');
		
		if (e.clipboardData.files) {
			if (document.createElement) {
				var form1 = document.createElement('form');
				form1.setAttribute('method', 'POST');
				form1.setAttribute('action', '/upload.php');
				form1.setAttribute('enctype', 'multipart/form-data');
				form1.style.display = 'none';
				
				var up1 = document.createElement('input');
				up1.setAttribute('type', 'file');
				up1.setAttribute('name', 'uploaded_file');
				up1.files = e.clipboardData.files;
					
				form1.appendChild(up1);
				document.body.appendChild(form1);
				
				if (window.displayNotification) {
					displayNotification('Uploading...');
				}

				if (document.getElementById('iospaste')) {
					document.getElementById('iospaste').value = 'Uploading...';
				}
				
				form1.submit();
			}
		}
	}
} // PasteEvent()

if (window.addEventListener && window.PasteEvent) {
	window.addEventListener('paste', window.PasteEvent);
}

// paste.js
