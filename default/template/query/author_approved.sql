SELECT
	author_flat.author_key
FROM
	author_flat
	JOIN item_flat USING (file_hash)
WHERE
	labels_list LIKE '%,approve,%'
	OR labels_list LIKE '%,admin,%';
