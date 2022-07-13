//#unfinished
var d=document;
var ct = d.getElementsByClassName('inner-content clearfix');

if (ct && ct.length) {
	if (confirm(ct.length + ' items found. continue?')) {
		var frm = document.createElement('form');
		frm.setAttribute('action', 'http://localhost:2784/post.html');
		frm.setAttribute('method', 'POST');

		document.body.appendChild(frm);

		for (i=0; i<ct.length; i++) {
			//var ctext = ct[i].innerHTML;
			var ctext = ct[i].textContent;

			var ta2 = document.createElement('input');
			ta2.setAttribute('type', 'hidden');
			ta2.setAttribute('name', 'comment['+i+']');
			ta2.setAttribute('value', ctext);

			frm.appendChild(ta2);
		}

		var ta2;
		ta2 = document.createElement('input');
		ta2.setAttribute('type', 'hidden');
		ta2.setAttribute('name', 's');
		ta2.setAttribute('value', document.location);
		frm.appendChild(ta2);

		ta2 = document.createElement('input');
		ta2.setAttribute('type', 'hidden');
		ta2.setAttribute('name', 't');
		ta2.setAttribute('value', document.title);
		frm.appendChild(ta2);

		frm.submit();
	}
}