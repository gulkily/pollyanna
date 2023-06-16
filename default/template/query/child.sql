SELECT
	child_count,
	item_title,
	'http://localhost:2784/' || SUBSTR(file_hash, 1, 2) || '/' || SUBSTR(file_hash, 3, 2) || '/' || substr(file_hash, 1, 8) || '.html' AS local_url,
	file_hash
FROM
	item_flat
WHERE
	child_count > 1
ORDER BY
	child_count DESC;
