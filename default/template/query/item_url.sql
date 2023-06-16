SELECT
	attribute,
	value
FROM
	item_attribute
WHERE
	attribute IN('http', 'https') AND
	file_hash = ?
