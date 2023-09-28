#!/bin/sh

# flushes all temporary votes from the systems by putting the items in log/deleted.log
# removes all items which are (#hasvote and #notext) and not signed or approved

echo ALL UNSIGNED VOTES WILL BE REMOVED!!
echo To confirm, please wait five seconds
echo To abort, press Ctrl+C
sleep 5

sqlite3 cache/b/index.sqlite3 "
	SELECT file_hash
	FROM item_flat
	WHERE
	(
		(
				labels_list LIKE '%,hasvote,%' AND
				labels_list LIKE '%,notext,%'
			) AND (
				labels_list NOT LIKE '%,signed,%' AND
				labels_list NOT LIKE '%,pubkey,%' AND
				labels_list NOT LIKE '%,approve,%'
			)
		) OR (
			labels_list LIKE '%,declined,%' AND
			labels_list LIKE '%,notext,%'
		)
" >>log/deleted.log
