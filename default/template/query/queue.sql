SELECT
	author_key AS author_id,
	file_hash,
	item_title,
	item_score,
	'' AS tagset_queue
FROM
	item_flat
WHERE
	labels_list NOT LIKE '%,flag,%' AND
	labels_list NOT LIKE '%,hide,%' AND
	labels_list NOT LIKE '%,approve,%'
ORDER BY
	item_score DESC