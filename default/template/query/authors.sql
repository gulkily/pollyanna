SELECT
	author_key,
	author_key author_id,
	'' AS cart,
	author_alias,
	author_seen,
	item_count,
	author_score,
	'' AS tagset_author,
	file_hash
FROM
	author_flat
ORDER BY
	author_seen DESC,
	item_count DESC
