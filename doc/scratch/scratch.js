		document.frmReply.comment.value = commtext + "\n\n" + window.location.href;



		if (voteValue == 'hide' && window.GetParentDialog) {
			// if we clicked a 'hide' vote, hide the parent dialog
			//alert('DEBUG: IncrementTagLink: special case for voteValue == hide');
			var parentDialog = GetParentDialog(t);
			HideDialog(parentDialog);
		}



module.exports = function toUTCString() {
        thisTimeValue(this); // to brand check

        var day = $getUTCDay(this);
        var date = $getUTCDate(this);
        var month = $getUTCMonth(this);
        var year = $getUTCFullYear(this);
        var hour = $getUTCHours(this);
        var minute = $getUTCMinutes(this);
        var second = $getUTCSeconds(this);
        return dayNames[day] + ', '
                + (date < 10 ? '0' + date : date) + ' '
                + monthNames[month] + ' '
                + year + ' '
                + (hour < 10 ? '0' + hour : hour) + ':'
                + (minute < 10 ? '0' + minute : minute) + ':'
                + (second < 10 ? '0' + second : second) + ' GMT';






const myFunction = async() => {
	console.log(await a + await b);
};
myFunction();


						if (!window.clockInitialValue) {
							window.clockInitialValue = document.frmTopMenu.txtClock.value;
						}



	if (GetPrefs('draggable_restore_collapsed') && !GetPrefs('draggable_restore')) {
		// if we restore closed state, but NOT restore position, reflow the dialogs again
		DraggingMakeFit(1)
	}





function selectLoadKey (keyName) {
	var newKey = GetPrefs(keyName, 'PrivateKey1');
	if (newKey) {
		 setPrivateKeyFromTxt(newKey);
		 if (document.compose.comment) {
		 	document.compose.comment.value = newKey;
		 	document.compose.submit();
		 }
	}
}



	if (document.getElementById) {
		var topmenu = document.getElementById('topmenu');
		if (topmenu && (window.GetConfig) && GetConfig('draggable')) {
			topmenu.style.position = 'fixed';
			topmenu.style.top = '0';
			topmenu.style.left = '0';
		}
	}



				var labelLoadFromFile = document.getElementById('fileLoadKeyFromText');
				if (!labelLoadFromFile) {
					// label for "load from file" button
					var labelLoadFromFile = document.createElement('label');
					labelLoadFromFile.setAttribute('for', 'fileLoadKeyFromText');
					labelLoadFromFile.innerHTML = 'Load profile key from saved file:';

					// br after label
					var brLoadFromFile = document.createElement('br');
					labelLoadFromFile.appendChild(brLoadFromFile);

					// [load from file] file selector
					var fileLoadKeyFromText = document.createElement('input');
					fileLoadKeyFromText.setAttribute('type', 'file');
					fileLoadKeyFromText.setAttribute('accept', 'text/plain');
					fileLoadKeyFromText.setAttribute(
						'onchange',
						 'if (window.openFile) { openFile(event) } else { alert("i am so sorry, openFile() function was missing!"); }'
					);
					fileLoadKeyFromText.setAttribute('id', 'fileLoadKeyFromText');
					// fileLoadKeyFromText.setAttribute('style', 'display: none');
					// i tried hiding file selector and using a button instead.
					// it looked nicer, but sometimes didn't work as expected

					// pLoadKeyFromTxt.appendChild(aLoadKeyFromText);
					labelLoadFromFile.appendChild(fileLoadKeyFromText);
					var brLoadFromFile2 = document.createElement('br');
					pLoadKeyFromTxt.appendChild(labelLoadFromFile);
					pLoadKeyFromTxt.appendChild(brLoadFromFile2);


					fieldset.appendChild(pLoadKeyFromTxt);
				}





							if (window.SetInterfaceMode) {
				SetInterfaceMode('expert', this);

				DraggingInit(0);
				DraggingMakeFit(0);
				DraggingRetile();
				DraggingInit(0);
				SetPrefs('draggable_spawn', 1);
				SetPrefs('draggable_activate', 1);


				if (window.DraggingMakeFit) {
					DraggingMakeFit();
				}
				if (window.SetActiveDialog && window.GetParentDialog) {
					SetActiveDialog(GetParentDialog(this));
				}
				return false;
			}


	if (!window.eventLoopReadCookie) {
		window.eventLoopReadCookie = 1;
		var cookieValue = GetCookie('eventLoopEnabled');
		if (window.GetCookie && (window.eventLoopEnabled != cookieValue)) {
			window.eventLoopEnabled = GetCookie('eventLoopEnabled');
		}
	}

		window.eventLoopEnabled = !window.eventLoopEnabled;
		if (window.SetCookie) {
			SetCookie('eventLoopEnabled', !!window.eventLoopEnabled);
		}
		if (window.EventLoop && window.eventLoopEnabled) {
			EventLoop();
		} else {
			if (window.timeoutEventLoop) {
				clearTimeout(window.timeoutEventLoop);
			}
		}
		this.innerHTML = 'event-loop: ' + (!!window.eventLoopEnabled);
		return false;



	for (var i = 0; i < localStorage.length; i++) {
		var lsKey = localStorage.key(i);
		var lsValue = localStorage.getItem(lsKey);

		alert(lsKey + '=' + lsValue);
	}



//
//function UrlExists2(url, callback) { // checks if url exists
//// todo use async and callback
//// todo how to do pre-xhr browsers?
//    //alert('DEBUG: UrlExists(' + url + ')');
//
//	if (window.XMLHttpRequest) {
//	    //alert('DEBUG: UrlExists: window.XMLHttpRequest check passed');
//
//        var xhttp = new XMLHttpRequest();
//        xhttp.onreadystatechange = function() {
//    if (this.readyState == 4 && this.status == 200) {
//       // Typical action to be performed when the document is ready:
//       document.getElementById("demo").innerHTML = xhttp.responseText;
//    }
//};
//xhttp.open("GET", "filename", true);
//xhttp.send();
//
//
//
//		var http = new XMLHttpRequest();
//		http.open('HEAD', url, false);
//		http.send();
//		var httpStatusReturned = http.status;
//
//		//alert('DEBUG: UrlExists: httpStatusReturned = ' + httpStatusReturned);
//
//		return (httpStatusReturned == 200);
//	}
//}




		//var reader1 = new FileReader();
		//reader1.onload = function (event) {
		//	var imgImagePreview = document.getElementById('imgImagePreview');
		//	if (imgImagePreview) {
		//		imgImagePreview.style.display = 'inline';
		//		imgImagePreview.setAttribute('src', event.target.result);
		//	}
		//}
		//reader1.readAsDataURL(e.clipboardData.files.asBlob);

		/*
		var frm1 = document.createElement('form');
		frm1.setAttribute('action', '/upload.php');
		frm1.setAttribute('method', 'post');
		frm1.setAttribute('enctype', 'multipart/form-data');
		
		var input1 = document.createElement('input');
		input1.setAttribute('type', 'file');
		input1.setAttribute('name', 'uploaded_file');
		
		var sub1 = document.createElement('input');
		sub1.setAttribute('type', 'submit');
		
		frm1.appendChild(input1);
		frm1.appendChild(sub1);
		window.document.body.appendChild(frm1);
		*/




TagCloud = {
    //Color hues
    ca: [51,102,102],
    cz: [0,102,255],

    min_font_size: 12,
    max_font_size: 35,

    generate: function(all_tags, all_words) {
        var self = this, colors=[], font_size;

        var ul = UL({c: 'plurk-cloud'});

        map(all_words, function(t)  {
            for (var i=0; i<3; i++)
                colors[i] = self._score(self.ca[i], self.cz[i], all_tags[t]);

            font_size = self._score(self.min_font_size, self.max_font_size, all_tags[t]);

            var color_attr = 'color:rgb('+colors[0]+','+colors[1]+','+colors[2]+')';
            var li = LI({s: 'font-size:'+ font_size + 'px'},
                SPAN({s: color_attr}, t)
            );

            ACN(ul, li, ' ');
        });

        return DIV({c: 'plurk-tags'}, ul);
    },

    _score: function(a, b, counts) {
        //reducer impacts color and font size, choosing a bigger will make the font smaller
        var reducer = 11;
        var m = Math.abs(a-b) / Math.log(reducer);

        if(a > b)
            return a - Math.floor(Math.log(counts) * m);
        else
            return Math.floor(Math.log(counts) * m + a);
    }
}

var TAGS = ${ json(tags) };
var WORDS = ${ json( sorted(tags.keys()) ) };
RCN($('tags'), TagCloud.generate(TAGS, WORDS));













/* dragging.js */
// props https://www.w3schools.com/howto/howto_js_draggable.asp

/*
		#mydiv {
    	  	position: absolute;
     		z-index: 9;
    	}

    	#mydivheader {
    		this is just the titlebar
    	}
*/

window.draggingZ = 0;

function dragElement (elmnt, header) {
	var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

	if (header) {
		// if present, the header is where you move the DIV from:
		header.onmousedown = 'dragMouseDown(this)';
	} else {
		// otherwise, move the DIV from anywhere inside the DIV:
		elmnt.onmousedown = 'dragMouseDown(this)';
	}

	var rect = elmnt.getBoundingClientRect();

	elmnt.style.position = 'absolute';
	elmnt.style.top = (rect.top) + "px";
	elmnt.style.left = (rect.left) + "px";

    //console.log(rect.top, rect.right, rect.bottom, rect.left);
	//elmnt.style.position = 'absolute';
	//elmnt.style.z-index = '9';
}

function dragMouseDown(elmnt) {
	e = window.event;

	e.preventDefault();

	// get the mouse cursor position at startup:
	pos3 = e.clientX;
	pos4 = e.clientY;

	document.onmouseup = 'closeDragElement(elmnt)';
	// call a function whenever the cursor moves:
	document.onmousemove = 'elementDrag(elmnt)';

	elmnt.style.zIndex = ++window.draggingZ;
}

function elementDrag(e) {
	//document.title = pos1 + ',' + pos2 + ',' + pos3 + ',' + pos4;
	//document.title = e.clientX + ',' + e.clientY;
	//document.title = elmnt.offsetTop + ',' + elmnt.offsetLeft;
	e = e || window.event;
	e.preventDefault();
	// calculate the new cursor position:
	pos1 = pos3 - e.clientX;
	pos2 = pos4 - e.clientY;
	pos3 = e.clientX;
	pos4 = e.clientY;
	// set the element's new position:

	elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
	elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
}

function closeDragElement(elmnt) {
	// stop moving when mouse button is released:
	document.onmouseup = '';
	document.onmousemove = '';

	if (elmnt) {
		SaveWindowState(elmnt);
		elmnt.style.zIndex = ++window.draggingZ;
		// keep incrementing the global zindex counter
	}
//
//		if (elmnt.id) {
//			if (window.SetPrefs) {
//				SetPrefs(elmnt.id + '.style.top', elmnt.style.top);
//				SetPrefs(elmnt.id + '.style.left', elmnt.style.left);
//			}
//		}
}

function SaveWindowState (elmnt) {
	var allTitlebar = elmnt.getElementsByClassName('titlebar');
	var firstTitlebar = allTitlebar[0];

	if (firstTitlebar && firstTitlebar.getElementsByTagName) {
		var elId = firstTitlebar.getElementsByTagName('b');
		if (elId && elId[0]) {
			elId = elId[0];

			if (elId && elId.innerHTML.length < 31) {
				SetPrefs(elId.innerHTML + '.style.top', elmnt.style.top);
				SetPrefs(elId.innerHTML + '.style.left', elmnt.style.left);
//				elements[i].style.top = GetPrefs(elId.innerHTML + '.style.top') || elId.style.top;
//				elements[i].style.left = GetPrefs(elId.innerHTML + '.style.left') || elId.style.left;
			} else {
				//alert('DEBUG: SaveWindowState: elId is false');
			}
		}
	}
}

function ArrangeAll () {
	//alert('DEBUG: DraggingInit: doPosition = ' + doPosition);
	var elements = document.getElementsByClassName('dialog');
	//for (var i = 0; i < elements.length; i++) {
	for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
		elements[i].setAttribute('style', '');
//
//		var btnSkip = elements[i].getElementsByClassName('skip');
//		if (btnSkip && btnSkip[0]) {
//			btnSkip[0].click();
//		}
	}
}

function DraggingInit (doPosition) {
// initializes all class=dialog elements on the page to be draggable
	if (!document.getElementsByClassName) {
		//alert('DEBUG: DraggingInit: sanity check failed, document.getElementsByClassName was FALSE');
		return '';
	}

	if (doPosition) {
		doPosition = 1;
	} else {
		doPosition = 0;
	}

	//alert('DEBUG: DraggingInit: doPosition = ' + doPosition);
	var elements = document.getElementsByClassName('dialog');
	//for (var i = 0; i < elements.length; i++) {
	for (var i = elements.length - 1; 0 <= i; i--) { // walk backwards for positioning reasons
		var allTitlebar = elements[i].getElementsByClassName('titlebar');
		var firstTitlebar = allTitlebar[0];

		if (firstTitlebar && firstTitlebar.getElementsByTagName) {
			dragElement(elements[i], firstTitlebar);
			var elId = firstTitlebar.getElementsByTagName('b');
			elId = elId[0];
			if (doPosition && elId && elId.innerHTML.length < 31) {
				elements[i].style.top = GetPrefs(elId.innerHTML + '.style.top') || elements[i].style.top;
				elements[i].style.left = GetPrefs(elId.innerHTML + '.style.left') || elements[i].style.left;
			} else {
				//alert('DEBUG: DraggingInit: elId is false');
			}
		}
	}

	return '';
} // DraggingInit()

/* / dragging.js */




=============================


//		if (elements[i].id && window.GetPrefs) {
//			var elTop = GetPrefs(elements[i].id + '.style.top');
//			var elLeft = GetPrefs(elements[i].id + '.style.left');
//
//			if (elTop && elLeft) {
//				elmnt.style.left = elLeft;
//				elmnt.style.top = elTop;
//			}
//
//			//var elTop = window.elementPosCounter || 1;
//			//var elTop = GetPrefs(elements[i].id + '.style.top');
//			//window.elementPosCounter += elmnt.style.height;
//
//			//var elLeft = GetPrefs(elements[i].id + '.style.left') || 1;
//
//			//if (elTop && elLeft) {
//				//elmnt.style.left = elLeft;
//				//elmnt.style.top = elTop;
//			//}
//		} else {
//			//alert('DEBUG: dragging.js: warning: id and/or GetPrefs() missing');
//		}
//		//dragElement(elements[i], firstTitlebar);





<div id='photos-preview'></div>
<input type="file" id="fileupload" multiple (change)="handleFileInput($event.target.files)" />
JS:

 function handleFileInput(fileList: FileList) {
        const preview = document.getElementById('photos-preview');
        Array.from(fileList).forEach((file: File) => {
            const reader = new FileReader();
            reader.onload = () => {
              var image = new Image();
              image.src = String(reader.result);
              preview.appendChild(image);
            }
            reader.readAsDataURL(file);
        });
    }




function previewImages() {

  var preview = document.querySelector('#preview');

  if (this.files) {
    [].forEach.call(this.files, readAndPreview);
  }

  function readAndPreview(file) {

    // Make sure `file.name` matches our extensions criteria
    if (!/\.(jpe?g|png|gif)$/i.test(file.name)) {
      return alert(file.name + " is not an image");
    } // else...

    var reader = new FileReader();

    reader.addEventListener("load", function() {
      var image = new Image();
      image.height = 100;
      image.title  = file.name;
      image.src    = this.result;
      preview.appendChild(image);
    });

    reader.readAsDataURL(file);

  }

}

document.querySelector('#file-input').addEventListener("change", previewImages);



<script type="text/javascript">function addEvent(b,a,c){if(b.addEventListener){b.addEventListener(a,c,false);return true}else return b.attachEvent?b.attachEvent("on"+a,c):false}
var cid,lid,sp,et,pint=6E4,pdk=1.2,pfl=20,mb=0,mdrn=1,fixhead=0,dmcss='//d217i264rvtnq0.cloudfront.net/styles/mefi/dark-mode20200421.2810.css';
















export default function potpack(boxes) {

    // calculate total box area and maximum box width
    let area = 0;
    let maxWidth = 0;

    for (const box of boxes) {
        area += box.w * box.h;
        maxWidth = Math.max(maxWidth, box.w);
    }

    // sort the boxes for insertion by height, descending
    boxes.sort((a, b) => b.h - a.h);

    // aim for a squarish resulting container,
    // slightly adjusted for sub-100% space utilization
    const startWidth = Math.max(Math.ceil(Math.sqrt(area / 0.95)), maxWidth);

    // start with a single empty space, unbounded at the bottom
    const spaces = [{x: 0, y: 0, w: startWidth, h: Infinity}];

    let width = 0;
    let height = 0;

    for (const box of boxes) {
        // look through spaces backwards so that we check smaller spaces first
        for (let i = spaces.length - 1; i >= 0; i--) {
            const space = spaces[i];

            // look for empty spaces that can accommodate the current box
            if (box.w > space.w || box.h > space.h) continue;

            // found the space; add the box to its top-left corner
            // |-------|-------|
            // |  box  |       |
            // |_______|       |
            // |         space |
            // |_______________|
            box.x = space.x;
            box.y = space.y;

            height = Math.max(height, box.y + box.h);
            width = Math.max(width, box.x + box.w);

            if (box.w === space.w && box.h === space.h) {
                // space matches the box exactly; remove it
                const last = spaces.pop();
                if (i < spaces.length) spaces[i] = last;

            } else if (box.h === space.h) {
                // space matches the box height; update it accordingly
                // |-------|---------------|
                // |  box  | updated space |
                // |_______|_______________|
                space.x += box.w;
                space.w -= box.w;

            } else if (box.w === space.w) {
                // space matches the box width; update it accordingly
                // |---------------|
                // |      box      |
                // |_______________|
                // | updated space |
                // |_______________|
                space.y += box.h;
                space.h -= box.h;

            } else {
                // otherwise the box splits the space into two spaces
                // |-------|-----------|
                // |  box  | new space |
                // |_______|___________|
                // | updated space     |
                // |___________________|
                spaces.push({
                    x: space.x + box.w,
                    y: space.y,
                    w: space.w - box.w,
                    h: box.h
                });
                space.y += box.h;
                space.h -= box.h;
            }
            break;
        }
    }

    return {
        w: width, // container width
        h: height, // container height
        fill: (area / (width * height)) || 0 // space utilization
    };
}
