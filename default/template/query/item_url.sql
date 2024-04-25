SELECT
	attribute,
	value,
	item_title,
	file_hash
FROM
	item_attribute
	JOIN item_flat USING(file_hash)
WHERE
	attribute IN('http', 'https') AND
	file_hash = ?
