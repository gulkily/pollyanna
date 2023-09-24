SELECT
	file_hash,
	author_key AS author_id,
	add_timestamp,
	'' AS tagset_pending,
	'' AS cart,
	author_key
FROM item_flat
WHERE
	tags_list LIKE '%,pubkey,%'
	AND (tags_list NOT LIKE '%,approve,%' AND tags_list NOT like '%,person,%')
	AND author_key NOT IN (SELECT author_key FROM author_flat WHERE author_alias = 'Guest')
ORDER BY
	add_timestamp DESC
