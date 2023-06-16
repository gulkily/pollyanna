SELECT
	item_title,
	add_timestamp,
	file_hash
FROM
	item_flat
WHERE
	item_score > 0
ORDER BY
	add_timestamp DESC
LIMIT 10
