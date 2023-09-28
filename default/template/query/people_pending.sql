SELECT
	file_hash,
	author_key AS author_id,
	author_score,
	add_timestamp,
	'' AS tagset_pending,
	'' AS cart,
	author_key
FROM
	item_flat
	JOIN author_score USING (author_key)
WHERE
	labels_list LIKE '%,pubkey,%'
	AND (labels_list NOT LIKE '%,approve,%' AND labels_list NOT like '%,person,%')
	AND author_key NOT IN (SELECT author_key FROM author_flat WHERE author_alias = 'Guest')
ORDER BY
	add_timestamp DESC
