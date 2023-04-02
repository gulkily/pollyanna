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
				tags_list LIKE '%,hasvote,%' AND
				tags_list LIKE '%,notext,%'
			) AND (
				tags_list NOT LIKE '%,signed,%' AND
				tags_list NOT LIKE '%,pubkey,%' AND
				tags_list NOT LIKE '%,approve,%'
			)
		) OR (
			tags_list LIKE '%,declined,%' AND
			tags_list LIKE '%,notext,%'
		)
" >>log/deleted.log
