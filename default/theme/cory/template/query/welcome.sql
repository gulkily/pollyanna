SELECT
	item_flat.file_path file_path,
	item_flat.item_name item_name,
	item_flat.file_hash file_hash,
	item_flat.author_key author_key,
	item_flat.child_count child_count,
	item_flat.parent_count parent_count,
	item_flat.add_timestamp add_timestamp,
	item_flat.item_title item_title,
	item_flat.item_score item_score,
	item_flat.labels_list labels_list,
	item_flat.item_type item_type,
	item_flat.item_order item_order,
	item_flat.item_sequence item_sequence
FROM
	item_flat
WHERE
	(
		item_type = 'txt'
		AND item_score >= 0
		AND labels_list NOT LIKE '%notext%'
		AND labels_list NOT LIKE '%changelog%'
	)
	OR
	(
		item_type = 'image'
		AND item_score >= 0
	)
ORDER BY
	add_timestamp DESC
LIMIT 100

