SELECT
	file_hash,
	item_title,
	add_timestamp
FROM
	item_flat
WHERE
	(
		file_hash IN (
			SELECT file_hash
			FROM item_flat
			WHERE
				item_score >= 0
				AND
				(
					SUBSTR(DATETIME(add_timestamp, 'unixepoch', 'localtime'), 0, 11) = ?
					OR
					file_hash IN (
						SELECT file_hash FROM item_attribute where attribute = 'date' AND value = ?
					)
				)
		)
	)
	AND
	(
		file_hash NOT IN (
			SELECT file_hash FROM item_attribute WHERE attribute = 'date' AND value <> ?
			)
			OR
			file_hash IN (
				SELECT file_hash FROM item_attribute WHERE attribute = 'date' AND value = ?
		)
	)