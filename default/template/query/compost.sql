SELECT
	item_title,
	item_flat.author_key AS author_id,
	author_score,
	item_score,
	item_type,
	add_timestamp,
	'' AS tagset_compost,
	file_hash
FROM
	item_flat
	LEFT JOIN author_score ON (item_flat.author_key = author_score.author_key)
WHERE
	labels_list NOT LIKE '%notext%'
ORDER BY
	child_count ASC,
	add_timestamp DESC
