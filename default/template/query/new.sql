SELECT
	file_hash,
	item_title,
	'' AS cart,
	item_type,
	child_count,
	add_timestamp,
	labels_list
FROM
	item_flat
WHERE
	item_score >= 0 AND
	add_timestamp >= strftime('%s', 'now', '-3 day') AND
	labels_list NOT LIKE '%,notext,%'
ORDER BY
	add_timestamp DESC
