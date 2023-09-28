SELECT
	item_title,
	file_hash,
	author_key,
	item_sequence,
	'' AS tagset_pending,
	'' AS cart
FROM item_flat
WHERE
	file_hash IN (
		SELECT file_hash
		FROM author_flat
		WHERE
			author_alias IN (
				SELECT alias FROM author_alias
				WHERE
					key = ?
					AND file_hash IN (SELECT file_hash FROM item_flat WHERE labels_list LIKE '%,approve,%')
			)
			AND file_hash IN (
				SELECT file_hash
				FROM item_flat
				WHERE (
					labels_list NOT LIKE '%,approve,%' AND labels_list NOT LIKE '%,flag,%'
				)
			)
	)

