SELECT
	author_key,
	author_key author_id,
	author_score AS score,
	'' AS tagset_author,
	file_hash
FROM
	author_flat
WHERE
	author_score > 0
ORDER BY
	author_score DESC

