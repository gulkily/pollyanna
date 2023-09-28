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
		file_hash IN (SELECT file_hash FROM item)
	GROUP BY
		label
	)
WHERE
	label_count >= 1
GROUP BY
	label
ORDER BY
	label
