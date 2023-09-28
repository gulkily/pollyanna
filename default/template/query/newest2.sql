SELECT
	file_hash,
	item_title,
	add_timestamp
FROM
	item_flat
	JOIN author_score ON (item_flat.author_key = author_score.author_key)
WHERE
	(author_score > 0 OR item_score > 0)
		AND
	labels_list LIKE '%,hastext,%'
ORDER BY
	add_timestamp DESC
LIMIT 25;