SELECT
	file_hash,
	item_title,
	tags_list,
	add_timestamp,
	item_score
FROM
	item_flat
WHERE
	tags_list LIKE '%,bug,%' OR
	tags_list LIKE '%,todo,%' AND
	tags_list NOT LIKE '%,done,%' AND
	tags_list NOT LIKE '%,fixed,%' AND
	item_score >= 0
ORDER BY
	item_score DESC,
	add_timestamp DESC

