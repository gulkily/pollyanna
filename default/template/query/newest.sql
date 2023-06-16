SELECT
	file_hash,
	item_title,
	add_timestamp
FROM
	item_flat
ORDER BY
	add_timestamp DESC
LIMIT 25