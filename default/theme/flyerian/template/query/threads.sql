SELECT
	item_flat.item_title AS item_title,
	item_flat.child_count AS child_count,
	item_flat.item_score AS item_score,
	item_flat.file_hash AS file_hash,
	item_flat.add_timestamp AS add_timestamp
FROM
	item_flat
WHERE
	item_flat.parent_count = 0 AND
	item_flat.child_count > 0 AND
	item_flat.item_score >= 0 AND
	item_flat.labels_list NOT LIKE '%,hide,%' AND
	item_flat.labels_list NOT LIKE '%,pubkey,%'
ORDER BY
	add_timestamp DESC
