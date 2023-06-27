SELECT
	author_key,
	author_key author_id,
	author_seen,
	item_count,
	author_score,
	'' AS tagset_author,
	file_hash
FROM
	author_flat
WHERE
	author_seen >= strftime('%s', 'now', '-3 day')
ORDER BY
	author_seen DESC

