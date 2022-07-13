SELECT
	item_title,
	add_timestamp,
	tags_list,
	file_hash
FROM 
	item_flat
WHERE
	','||tags_list||',' LIKE '%,todo,%' AND
	','||tags_list||',' NOT LIKE '%,done,%'
ORDER BY 
	add_timestamp 
