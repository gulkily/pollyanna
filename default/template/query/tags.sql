SELECT
	label,
	label_count
FROM (
	SELECT
		label,
		COUNT(label) AS label_count
	FROM
		item_label
	WHERE
		file_hash IN (
			SELECT file_hash
			FROM item_flat
			WHERE item_score >= 0
		)
	GROUP BY
		item_label.label
	)
WHERE
	label = LOWER(label)
ORDER BY
	label_count DESC