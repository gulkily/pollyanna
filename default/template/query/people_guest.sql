SELECT
	file_hash,
	author_key AS author_id,
	author_key,
	author_seen,
	'' AS tagset_flag,
	'' AS cart,
	item_count
FROM author_flat
WHERE
	author_alias = 'Guest'
	AND author_score >= 0
ORDER BY
	author_seen DESC