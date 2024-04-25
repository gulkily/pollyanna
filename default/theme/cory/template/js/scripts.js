function displayNewIdea(ideaText, timestamp) {
	const ideasList = document.getElementById('ideasList');

	// Create the card element
	const card = document.createElement('div');
	card.className = 'idea-card';

	// Create the content element
	const content = document.createElement('div');
	content.className = 'idea-content';
	content.textContent = ideaText;

	// Create the timestamp element
	const time = document.createElement('div');
	time.className = 'idea-time';
	time.textContent = new Date(timestamp).toLocaleString();

	// Assemble the card
	card.appendChild(content);
	card.appendChild(time);

	// Prepend to list
	ideasList.prepend(card);  // Adds the new idea to the top of the list
}

document.getElementById('ideaForm').addEventListener('submit', function(event) {
	event.preventDefault(); // Prevent the default form submission

	const ideaInput = document.getElementById('ideaInput');
	const idea = ideaInput.value;
	if (!idea.trim()) return; // Prevent submitting empty ideas

	// AJAX request to submit the idea to the server
	const xhr = new XMLHttpRequest();
	xhr.open('POST', '/post.html', true);
	xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

	// Handle the response
	xhr.onload = function() {
		if (this.status >= 200 && this.status < 300) {
			// Use the idea and current time since the server isn't sending back data
			//displayNewIdea(idea, Date.now());
			//window.location.reload();
			window.location=window.location+'?time=9999999999';
		} else {
			console.error('The request failed!');
		}
	};

	// Send the request with the data
	xhr.send('comment=' + encodeURIComponent(idea));

	// Clear the input field after submission
	ideaInput.value = '';
});

function displayNewIdea(ideaText, timestamp) {
	const ideasList = document.getElementById('ideasList');
	const card = document.createElement('div');
	card.className = 'idea-card';
	const content = document.createElement('div');
	content.className = 'idea-content';
	content.textContent = ideaText;
	const time = document.createElement('div');
	time.className = 'idea-time';
	time.textContent = new Date(timestamp).toLocaleString();
	card.appendChild(content);
	card.appendChild(time);
	ideasList.prepend(card); // Adds the new idea to the top of the list
}


/*
document.getElementById('ideaForm').addEventListener('submit', function(event) {
	event.preventDefault(); // Prevent the default form submission

	const idea = document.getElementById('ideaInput').value;
	if (!idea.trim()) return; // Prevent submitting empty ideas

	// AJAX request to submit the idea to the server
	const xhr = new XMLHttpRequest();
	xhr.open('POST', '/post.html', true);
	xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

	// Handle the response
	xhr.onload = function() {
		if (this.status >= 200 && this.status < 300) {
			// Assuming the server response includes the submitted idea and timestamp
			const response = JSON.parse(this.responseText);
			displayNewIdea(response.comment, response.timestamp); // Update the page dynamically
		} else {
			console.error('The request failed!');
		}
	};

	// Send the request with the data
	xhr.send('comment=' + encodeURIComponent(idea));

	// Clear the input field after submission
	document.getElementById('ideaInput').value = '';
});

function displayNewIdea(ideaText, timestamp) {
	const ideasList = document.getElementById('ideasList');
	const card = document.createElement('div');
	card.className = 'idea-card';
	const content = document.createElement('div');
	content.className = 'idea-content';
	content.textContent = ideaText;
	const time = document.createElement('div');
	time.className = 'idea-time';
	time.textContent = new Date(timestamp).toLocaleString();
	card.appendChild(content);
	card.appendChild(time);
	ideasList.prepend(card); // Adds the new idea to the top of the list
}
*/

// Example of adding an idea (this would be replaced by real data handling)
//displayNewIdea("This is a great new idea!", Date.now());

