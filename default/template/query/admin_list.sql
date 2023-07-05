SELECT
	author_key AS author_id,
	author_seen
FROM author_flat 
WHERE 
	file_hash IN (
		SELECT
			file_hash
		FROM
			item_flat
		WHERE
			','||tags_list||',' LIKE '%,admin,%'
	)
;
