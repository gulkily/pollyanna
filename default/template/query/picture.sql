SELECT 
	file_hash AS file_hash,
	item_title AS item_title,
	item_name AS item_name,
	item_score AS item_score
FROM
	item_flat
WHERE
	tags_list like '%,image,%'
