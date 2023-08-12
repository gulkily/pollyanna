/* table_sort.js */

function SortTable (t, sortOrder) {
// TableSort (
	//alert('DEBUG: SortTable() begins');
	//caution: bubble sort inside

	if (! document.body.textContent) {
		//alert('DEBUG: SortTable: warning: textContent feature check FAILED');
		return '';
	}

	var table, rows, switching, i, x, y, shouldSwitch, sortColumn, sortMethod;

	sortColumn = 0;
	sortMethod = 0;

	// sortMethod = 0 innerHTML
	// sortMethod = 1 textContent
	// sortMethod = 2 parseInt(innerHTML)

	if (1 < sortOrder) {
		return '';
	}

	var rowColor0 = ''; // these are templated from theme/.../color/row0
	var rowColor1 = ''; // these are templated from theme/.../color/row1

	sortOrder = sortOrder ? 1 : 0;

	var anyChanges = 0;

	var tOrig = t;

	if (!t) {
		//alert('DEBUG: SortTable: warning: t missing');
		return '';
	}

	var sortField = t.textContent;

	if (t.cellIndex || t.cellIndex == 0) {
		sortColumn = t.cellIndex;
		// default sortMethod is 0, defined above
		// innerHTML

		if (
			t.textContent &&
			t.textContent.indexOf('_title') != -1 ||
			t.textContent.indexOf('author_key') != -1 ||
			t.textContent.indexOf('author_id') != -1
		) {
			sortMethod = 1; // textContent
		}

		if (
			t.textContent &&
			(
				t.textContent.indexOf('_count') != -1 ||
				t.textContent.indexOf('_order') != -1 ||
				t.textContent.indexOf('_sequence') != -1 ||
				t.textContent.indexOf('_score') != -1
			)
		) {
			sortMethod = 2; // parseInt(innerHTML)
		}

		if (
			t.textContent &&
			(
				t.textContent.indexOf('_timestamp') != -1
			)
		) {
			sortMethod = 3; // timestamp widget
		}
	}

	while (!table && t.parentNode) {
		t = t.parentNode;
		if (t.tagName == 'TABLE') {
			table = t;
		}
	}

	if (!table) {
		//alert('DEBUG: SortTable: warning: table missing');
		return '';
	} else {
		//alert('DEBUG: SortTable: table exists, proceeding');
	}

	if (table && table.getAttribute) {
		var tableId = table.getAttribute('id');
		if (tableId) {
			if (window.SetPrefs) {
				SetPrefs('TableSort:' + tableId, sortField + ':' + sortOrder + ':' + sortMethod);
			}
		}
	} else {
		//alert('DEBUG: SortTable: warning: table is missing');
		return '';
	}

	//alert('DEBUG: SortTable: sortOrder = ' + sortOrder + '; sortMethod = ' + sortMethod);

	// bubble sort below by some website...

	switching = true;

	/* Make a loop that will continue until
	no switching has been done: */
	while (switching) {
		// Start by saying: no switching is done:
		switching = false;
		rows = table.rows;

		/* Loop through all table rows (except the
		first, which contains table headers): */
		for (i = 1; i < (rows.length - 2); i++) {
			// Start by saying there should be no switching:
			shouldSwitch = false;
			/* Get the two elements you want to compare,
			one from current row and one from the next: */

			x = rows[i].getElementsByTagName("TD")[sortColumn];
			y = rows[i + 1].getElementsByTagName("TD")[sortColumn];
			// Check if the two rows should switch place:

			if (
				x &&
				y &&
				x.innerHTML &&
				y.innerHTML
			) {
				var xValue = 0;
				var yValue = 0;

				if (sortMethod == 0) {
					xValue = x.innerHTML;
					yValue = y.innerHTML;
				}
				if (sortMethod == 1) {
					xValue = x.textContent; // #todo lowercase
					yValue = y.textContent; // #todo lowercase
				}
				if (sortMethod == 2) {
					if (x.textContent == '-') {
						xValue = 0;
					} else {
						xValue = parseInt(x.innerHTML);
					}
					if (y.textContent == '-') {
						yValue = 0;
					} else {
						yValue = parseInt(y.innerHTML);
					}
				}
				if (sortMethod == 3) {
					var xWidget = x.getElementsByClassName('timestamp');
					xValue = xWidget[0].getAttribute('datetime');
					var yWidget = y.getElementsByClassName('timestamp');
					yValue = yWidget[0].getAttribute('datetime');
				}

				//////

				if (
					(
						sortOrder == 0
						&&
						xValue < yValue
					)
					||
					(
						sortOrder == 1
						&&
						yValue < xValue
					)
				) {
					// If so, mark as a switch and break the loop:
					shouldSwitch = true;
					anyChanges++;
					break;
				}
			}
		}
		if (shouldSwitch) {
			/* If a switch has been marked, make the switch
			and mark that a switch has been done: */
			rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
			switching = true;
		}
	} // while (switching)

	if (!anyChanges) {
		sortOrder++
		return SortTable(tOrig, sortOrder);
	}

	if (anyChanges) {
		rows = table.rows;
		var rowsLength = rows.length;

		for (i = 2; i < rowsLength - 1; i++) {
			if (
				rows[i] &&
				rows[i].style.backgroundColor == rowColor0 ||
				rows[i].style.backgroundColor == rowColor1 ||
				rows[i].getAttribute('bgcolor') == rowColor0 ||
				rows[i].getAttribute('bgcolor') == rowColor1
			) {
				// the above check avoids changing the color of highlighted rows
				if (i % 2) {
					rows[i].style.backgroundColor = rowColor0;
				} else {
					rows[i].style.backgroundColor = rowColor1;
				}
			}
		}
	}

	//alert('DEBUG: SortTable() finished');

	return '';
} // SortTable()

/* / table_sort.js */
