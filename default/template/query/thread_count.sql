SELECT
	COUNT(file_hash) AS thread_count
FROM
	item_flat
WHERE
	item_flat.parent_count = 0 AND
	item_flat.child_count > 0 AND
	item_flat.item_score >= 0
