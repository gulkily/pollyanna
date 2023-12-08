// table_sort.js

function SortTable(t, sortOrder) {
    if (!document.body.textContent || 1 < sortOrder) {
        return '';
    }

    var table = findParentTable(t);
    if (!table) {
        return '';
    }

    var sortColumn = t.cellIndex || 0;
    var sortMethod = determineSortMethod(t.textContent);

    sortOrder = sortOrder ? 1 : 0;

    var anyChanges = 0;

    var tOrig = t;

    var sortField = t.textContent;

    savePrefs(table, sortField, sortOrder, sortMethod);

    var switching = true;

    while (switching) {
        switching = false;
        var rows = table.rows;

        for (var i = 1; i < rows.length - 2; i++) {
            var shouldSwitch = false;

            var x = rows[i].getElementsByTagName("TD")[sortColumn];
            var y = rows[i + 1].getElementsByTagName("TD")[sortColumn];

            if (x && y && x.innerHTML && y.innerHTML) {
                var xValue = extractCellValue(x, sortMethod);
                var yValue = extractCellValue(y, sortMethod);

                if ((sortOrder === 0 && xValue < yValue) || (sortOrder === 1 && yValue < xValue)) {
                    shouldSwitch = true;
                    anyChanges++;
                    break;
                }
            }
        }

        if (shouldSwitch) {
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
        }
    }

    if (!anyChanges) {
        sortOrder++;
        return SortTable(tOrig, sortOrder);
    }

    updateRowColors(table);

    return '';
}

function findParentTable(element) {
    while (element && element.parentNode) {
        element = element.parentNode;
        if (element.tagName === 'TABLE') {
            return element;
        }
    }
    return null;
}

function determineSortMethod(textContent) {
    if (textContent.includes('_title') || textContent.includes('author_key') || textContent.includes('author_id')) {
        return 1; // textContent
    } else if (
        textContent.includes('_count') ||
        textContent.includes('_order') ||
        textContent.includes('_sequence') ||
        textContent.includes('_score')
    ) {
        return 2; // parseInt(innerHTML)
    } else if (textContent.includes('_timestamp')) {
        return 3; // timestamp widget
    } else {
        return 0; // innerHTML
    }
}

function savePrefs(table, sortField, sortOrder, sortMethod) {
    if (table && table.getAttribute) {
        var tableId = table.getAttribute('id');
        if (tableId && window.SetPrefs) {
            SetPrefs('TableSort:' + tableId, sortField + ':' + sortOrder + ':' + sortMethod);
        }
    }
}

function extractCellValue(cell, sortMethod) {
    if (sortMethod === 0) {
        return cell.innerHTML;
    } else if (sortMethod === 1) {
        return cell.textContent.toLowerCase();
    } else if (sortMethod === 2) {
        return cell.textContent === '-' ? 0 : parseInt(cell.innerHTML);
    } else if (sortMethod === 3) {
        var widget = cell.getElementsByClassName('timestamp')[0];
        return widget.getAttribute('datetime');
    }
    return 0;
}

function updateRowColors(table) {
    var rows = table.rows;
    var rowsLength = rows.length;

    for (var i = 2; i < rowsLength - 1; i++) {
        var bgColor = rows[i].style.backgroundColor;
        var attributeColor = rows[i].getAttribute('bgcolor');

        if (
            bgColor === rowColor0 ||
            bgColor === rowColor1 ||
            attributeColor === rowColor0 ||
            attributeColor === rowColor1
        ) {
            if (i % 2) {
                rows[i].style.backgroundColor = rowColor0;
            } else {
                rows[i].style.backgroundColor = rowColor1;
            }
        }
    }
}

// /table_sort.js
