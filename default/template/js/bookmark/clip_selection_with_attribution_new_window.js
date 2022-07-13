//javascript:
void(
	window.open(
		'http://localhost:2784/post.html?comment='+
		encodeURIComponent(
			window.getSelection()
		) +
		'&s='+encodeURIComponent(document.location) +
		'&t='+encodeURIComponent(document.title)
	)
)