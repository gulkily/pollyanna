javascript: (function () {
    if (window.getSelection) {
        let selectedText = window.getSelection().toString().trim();
        if (!selectedText && (selectedText = document.title + " - " + window.location.href), document.querySelectorAll) {
            const listItems = document.querySelectorAll('ul li, ol li');
            for (let index = 0; index < listItems.length; index++) {
                selectedText += "\n" + (index + 1) + ". " + listItems[index].textContent;
            }
        }
        const encodedText = encodeURIComponent(selectedText),
            url = 'http://localhost:2784/?comment=' + encodedText;
        window.location.href = url;
        console.log("Navigating to:", url);
    } else console.log("Window.getSelection is not supported in this browser.");
})();




if (window.getSelection) {
	let selectedText = window.getSelection().toString().trim();
	if (!selectedText && (selectedText = document.title + " - " + window.location.href), document.querySelectorAll) {
		const listItems = document.querySelectorAll('ul li, ol li');
		for (let index = 0; index < listItems.length; index++) {
			selectedText += "\n" + (index + 1) + ". " + listItems[index].textContent;
		}
	}

	// Replace consecutive spaces with a single underscore
	const sanitizedText = selectedText.replace(/ +/g, '');
	// Only allow alphanumeric, spaces, and common punctuation characters
	const regex = /[^a-zA-Z0-9 .,?!@#$%^&*()_+=-]/g;
	const encodedText = encodeURIComponent(sanitizedText);

	const url = 'http://localhost:2784/post.html?comment=' + encodedText;
	window.location.href = encodeURI(url);
	console.log("Navigating to:", url);
} else console.log("Window.getSelection is not supported in this browser.");


