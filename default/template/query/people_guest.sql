SELECT
	file_hash,
	author_key AS author_id,
	'' AS tagset_pending,
	author_key
FROM item_flat
WHERE
	tags_list LIKE '%,pubkey,%'
	AND (tags_list NOT LIKE '%,approve,%' AND tags_list NOT like '%,person,%')
	AND author_key IN (SELECT author_key FROM author_flat WHERE author_alias = 'Guest')
ORDER BY
	author_seen DESC