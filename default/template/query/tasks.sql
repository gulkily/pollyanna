SELECT
	file_hash,
	item_title,
	labels_list,
	add_timestamp,
	item_score
FROM
	item_flat
WHERE
	labels_list LIKE '%,bug,%' OR
	labels_list LIKE '%,todo,%' AND
	labels_list NOT LIKE '%,done,%' AND
	labels_list NOT LIKE '%,fixed,%' AND
	item_score >= 0
ORDER BY
	item_score DESC,
	add_timestamp DESC

