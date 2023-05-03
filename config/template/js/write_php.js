// begin write_php.js

window.intCommentOnChangeLastValue = 0;

function CommentOnChange (t, formId) {
// changes form's method from get to post
// if comment's length is more than 1024
// and vice versa
//
// GET is more compatible and reliable
// POST allows longer messages
// 1024 is a relatively safe value
// some servers support up to 5-6K
//
// works down to netscape 3.04, but not 2.02
//
// this part requires getElementById()

	//window.dbgoff = 0;

	//alert('DEBUG: CommentOnChange() begin');

	////alert('DEBUG: CommentOnChange: t = ' + t + '; formId = ' + formId + '; t.value = ' + t.value + '; t.value.length = ' + t.value.length);

	if (!window.intCommentOnChangeLastValue) {
		window.intCommentOnChangeLastValue = 0;
	}

	if (!t.value || !t.value.length) {
		//alert('DEBUG: CommentOnChange: window.intCommentOnChangeLastValue <= 1024 && t.value.length <= 1024, return');
		window.intCommentOnChangeLastValue = 0;
		return true;
	}

	if (16 < (t.value.length - intCommentOnChangeLastValue)) {
		//alert('DEBUG: CommentOnChange: paste detected');
		if (GetPrefs('uncheck_sign_when_pasting')) {
			var chkSignAs = document.getElementById('chkSignAs');
			if (chkSignAs.checked) {
				chkSignAs.removeAttribute('checked');
			}
		}
	}

	if ((window.intCommentOnChangeLastValue <= 1024) && t.value && t.value.length && (t.value.length <= 1024)) {
		//alert('DEBUG: CommentOnChange: window.intCommentOnChangeLastValue <= 1024 && t.value.length <= 1024, return');
		window.intCommentOnChangeLastValue = t.value.length;
		return true;
	}

	if (1024 < window.intCommentOnChangeLastValue && t.value && t.value.length && (1024 < t.value.length)) {
		//alert('DEBUG: CommentOnChange: 1024 < window.intCommentOnChangeLastValue && 1024 < t.value.length, return');
		window.intCommentOnChangeLastValue = t.value.length;
		return true;
	}

	window.intCommentOnChangeLastValue = t.value.length;

	//alert('DEBUG: CommentOnChange: window.intCommentOnChangeLastValue = t.value.length = ' + t.value.length);

	var strFormMode;
	var strWarnDisplay;
	var strInnerHtml;

	//var gt = unescape('%3E');
	//var gt = '';
	var gt = unescape('%3E');

	//alert('DEBUG: CommentOnChange: gt = ' + gt);

	if (t.value.length <= 1024) {
		//alert('DEBUG: CommentOnChange: setting form method to GET');
		strFormMode = 'GET';
		strWarnDisplay = 'none';
		strInnerHtml = 'Long message mode.<br' + gt;
	} else {
		//alert('DEBUG: CommentOnChange: setting form method to POST');
		strFormMode = 'POST';
		strWarnDisplay = 'block';
		strInnerHtml = '';
	}

	if (document.forms && document.forms[formId] && document.forms[formId].method) {
		document.forms[formId].method = strFormMode;
//		var form = document.forms[formId];
//		if (form) {
//			form.method = strFormMode;
//		}
	}

	return true;
} // CommentOnChange()

// end write_php.js