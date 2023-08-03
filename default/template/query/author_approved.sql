SELECT
	author_flat.author_key
FROM
	author_flat
	JOIN item_flat USING (file_hash)
WHERE
	tags_list LIKE '%,approve,%'
	OR tags_list LIKE '%,admin,%';
