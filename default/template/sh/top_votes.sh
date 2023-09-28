#!/bin/bash

# show the top used labels in the item_label table

sqlite3 -echo -cmd ".headers on" -cmd ".timeout 500" -cmd ".mode column" cache/*/index.sqlite3 'SELECT DISTINCT label, COUNT(label) label_count FROM item_label GROUP BY label ORDER BY label_count DESC;'
