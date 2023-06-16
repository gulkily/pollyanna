SELECT
	item_title,
	add_timestamp,
	file_hash
FROM
	item_flat
WHERE
	','||tags_list||',' LIKE ? AND
	item_score >= 0
ORDER BY
	item_score DESC
