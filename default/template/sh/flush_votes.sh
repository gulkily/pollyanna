#!/bin/sh

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
				tags_list not LIKE '%,signed,%' AND
				tags_list not LIKE '%,pubkey,%' AND
				tags_list not LIKE '%,approve,%'
			)
		) OR (
			tags_list LIKE '%,hasdecline,%' AND
			tags_list LIKE '%,notext,%'
		)
" >>log/deleted.log
