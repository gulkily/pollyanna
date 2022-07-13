function doCookie() {
	document.cookie='test=1;';
	return false;
}
var gt = unescape('%3E');
document.write('<form name=mc action=/help.html' + gt);
document.write('<input value="Human Press Button To Enter" type=submit name=sc onclick="return doCookie();"' + gt);
