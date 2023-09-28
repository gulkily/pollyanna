SELECT
	item_title,
	add_timestamp,
	labels_list,
	file_hash
FROM 
	item_flat
WHERE
	','||labels_list||',' LIKE '%,todo,%' AND
	','||labels_list||',' NOT LIKE '%,done,%'
ORDER BY 
	add_timestamp 
