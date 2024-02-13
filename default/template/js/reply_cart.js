// reply_cart.js

// #todo fix name formatting case etc

function insertReplyCart () {
// function addItemToReplyCart () {
// function ReplyCartAddItem () {
	// #todo split this off into separate module

	if (window.localStorage) {
		var existingList = window.localStorage.getItem('replyCart') || '';

		if (existingList) {
			if (document.compose && document.compose.comment) {
				if (document.compose.comment.value.indexOf(existingList) == -1) {
					document.compose.comment.value = existingList + ' ' + document.compose.comment.value;
				}
			}
		}
		return false;
	}
} // insertReplyCart()

function clearReplyCart () {
	if (window.localStorage) {
		window.localStorage.setItem('replyCart', '');
	}

	if (window.localStorage) {
		if (document.getElementById('replyCartCount')) {
			if (window.localStorage.getItem('replyCart')) {
				document.getElementById('replyCartCount').innerHTML =
					window.localStorage.getItem('replyCart').split('\n').length - 1;
				//document.getElementById('replyCartCount').innerHTML = window.localStorage.getItem('replyCart').split(/\r\n|\r|\n/).length - 1;
				// #todo fix overcount without assuming
			} else {
				document.getElementById('replyCartCount').innerHTML = 0;
			}
		}
	}
} // clearReplyCart()

function addToReplyCartButton (fileHash, ths) { // also removes ;|
// function addToReplyCart {
// #todo should be called add or remove
	// #todo split this off into separate module

	if (window.localStorage) {
		if (ths.innerHTML == '+cart') {
			var existingList = window.localStorage.getItem('replyCart') || '';
			var gt = unescape('%3E');
			var newLine = gt + gt + fileHash + '\n';

			if (existingList.indexOf(newLine) == -1) {
				var newList = existingList + newLine;
				window.localStorage.setItem('replyCart', newList);
			}

			if (window.displayNotification) {
				var itemCount = window.localStorage.getItem('replyCart').split('\n').length - 1;
				//displayNotification('Added to cart. (' + itemCount + ')', ths);
				//displayNotification('Added to cart.', ths);
			} else {
			}

			if (ths && ths.innerHTML) {
				ths.innerHTML = '-cart';
			}
		} else {
			var existingList = window.localStorage.getItem('replyCart') || '';
			var gt = unescape('%3E');
			var lineToRemove = gt + gt + fileHash + '\n';

			if (existingList.indexOf(lineToRemove) != -1) {
				//var newList = existingList + newLine;
				var newList = existingList.replace(lineToRemove, '');
				window.localStorage.setItem('replyCart', newList);
			}

			if (window.displayNotification) {
				var itemCount = window.localStorage.getItem('replyCart').split('\n').length - 1;
				//displayNotification('Removed from cart.', ths);
				//displayNotification('Removed from cart. (' + itemCount + ')', ths);
			} else {

			}
			if (ths && ths.innerHTML) {
				ths.innerHTML = '+cart';
			}
		}

		if (window.ReplyCartUpdateCount) {
			ReplyCartUpdateCount();
		}

//		if (ths) {
//			if (ths.remove) {
//				ths.remove();
//			}
//		}

		return false;
	}
} //addToReplyCartButton()

function ReplyCartUpdateCount () {
// function UpdateCart ()
// function CartUpdate ()
// function ReplyCartUpdate ()
	if (document.getElementById && document.getElementById('replyCartCount')) {
		if (window.localStorage.getItem('replyCart')) {
			document.getElementById('replyCartCount').innerHTML =
				window.localStorage.getItem('replyCart').split('\n').length - 1; //#cartCount
			//document.getElementById('replyCartCount').innerHTML = window.localStorage.getItem('replyCart').split(/\r\n|\r|\n/).length - 1;
			// #todo do not assume there's an extra line #bug
		} else {
			document.getElementById('replyCartCount').innerHTML = 0;
		}
	}

	if (document.getElementsByClassName && document.getElementsByClassName('replyCartButton')) {
		// update +/- buttons on page
		// very basic

		var cartButtons = document.getElementsByClassName('replyCartButton');
		var existingList = window.localStorage.getItem('replyCart') || '';

		if (existingList) {
			for (var b = 0; b < cartButtons.length; b++) {
				var fileHash = cartButtons[b].getAttribute('item-id');

				if (fileHash) {
					var gt = unescape('%3E');
					var cartLine = gt + gt + fileHash + '\n';
					var newCaption = '';

					if (existingList.indexOf(cartLine) != -1) {
						newCaption = '-cart';
					} else {
						newCaption = '+cart';
					}
					if (newCaption != cartButtons[b].innerHTML) {
						cartButtons[b].innerHTML = newCaption;
					}
				}
			}
		} // existingList
	} // feature check
} // ReplyCartUpdateCount()

function ReplyCartAddAll () {
	//alert('DEBUG: ReplyCartAddAll()');

	if (document.getElementsByClassName && document.getElementsByClassName('replyCartButton')) {
		// update +/- buttons on page
		// very basic

		//alert('DEBUG: ReplyCartAddAll: feature check passed');

		var cartButtons = document.getElementsByClassName('replyCartButton');
		//var existingList = window.localStorage.getItem('replyCart') || '';

		if (cartButtons) {
			for (var b = 0; b < cartButtons.length; b++) {
				var fileHash = cartButtons[b].getAttribute('item-id');

				if (fileHash) {
					addToReplyCartButton(fileHash, cartButtons[b]);
				}
			}
		} // if (cartButtons)

		ReplyCartUpdateCount();
	} // if (document.getElementsByClassName && document.getElementsByClassName('replyCartButton'))
} // ReplyCartAddAll()

// / reply_cart.js
