SELECT
	file_hash,
	item_title,
	'' AS tagset_queue,
	author_key AS author_id
FROM
	item_flat
WHERE
	labels_list LIKE '%,queue,%' AND
	labels_list NOT LIKE '%,done,%'
