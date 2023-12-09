SELECT
	file_hash,
	item_title,
	item_score,
	add_timestamp,
	author_key AS author_id
FROM
	item_flat
WHERE
	item_score >= 0
ORDER BY
	add_timestamp DESC