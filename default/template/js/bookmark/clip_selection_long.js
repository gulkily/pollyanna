// #todo this is a draft which may or may not work yet

window.f = document.createElement('form');
f.setAttribute('action', 'http://localhost:2784/post.html');
f.setAttribute('target', '_blank');
f.setAttribute('method', 'POST');
window.c = document.createElement('input');
c.setAttribute('name', 'comment');
c.setAttribute('type', 'hidden');
c.setAttribute('value', window.getSelection() + '\n' + document.title + '\n' + document.location);
document.body.appendChild(f);
f.appendChild(c);
f.submit();

javascript:void(window.f = document.createElement('form'); f.setAttribute('action', 'http://localhost:2784/post.html'); f.setAttribute('target', '_blank'); f.setAttribute('method', 'POST'); window.c = document.createElement('input'); c.setAttribute('name', 'comment'); c.setAttribute('type', 'hidden'); c.setAttribute('value', window.getSelection() + '\n' + document.title + '\n' + document.location); document.body.appendChild(f); f.appendChild(c); f.submit())
