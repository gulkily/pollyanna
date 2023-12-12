// image_publish.js

function UploadImage(image, targetUrl) {
	// Create a form element
	var form = document.createElement('form');
	form.setAttribute('method', 'post');
	form.setAttribute('action', targetUrl);
	form.setAttribute('enctype', 'multipart/form-data'); // Ensure proper encoding for file uploads

	// Create an input element for the file
	var input = document.createElement('input');
	input.setAttribute('type', 'file');
	input.setAttribute('name', 'file'); // The name attribute is important for server-side processing
	input.files = image.files;

	// Append the input element to the form
	form.appendChild(input);

	// Append the form to the document
	document.body.appendChild(form);

	// Submit the form
	form.submit();

	// Optional: Remove the form from the document after submission
	document.body.removeChild(form);
} // UploadImage()

// / image_publish.js
